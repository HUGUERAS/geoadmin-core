"""
Middleware de autenticação via JWT do Supabase.
Uso: adicione `usuario: dict = Depends(verificar_token)` nos endpoints protegidos.

Estratégia de validação (P1.1):
  1. Validação local via SUPABASE_JWT_SECRET (HS256) — sem roundtrip remoto.
  2. Validação local via JWKS (RS256) do endpoint /auth/v1/.well-known/jwks.json.
  3. Fallback remoto via supabase.auth.get_user(token) — apenas fora de produção
     ou quando JWT_LOCAL_ONLY=false explicitamente.
"""
import hashlib  # [SEC-JWT-CACHE] hashing do token para chave de cache
import os
import logging
import time  # [SEC-JWT-CACHE] controle de TTL do cache
from typing import Optional

import jwt as _jwt
from jwt import PyJWKClient as _PyJWKClient
from jwt.exceptions import ExpiredSignatureError as _JWTExpired, InvalidTokenError as _JWTInvalid

from fastapi import Depends, HTTPException, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)

_seguranca = HTTPBearer(auto_error=False)

# ---------------------------------------------------------------------------
# [SEC-JWT-CACHE] Cache em memória de resultados de validação de token.
#
# Estratégia:
#   • Chave  = SHA-256(token) — nunca armazena o token bruto em memória.
#   • TTL    = 5 minutos — curto o suficiente para que tokens revogados
#              sejam rejeitados rapidamente na próxima janela.
#   • Purge  = limpeza lazy das entradas expiradas após cada cache miss,
#              evitando crescimento ilimitado do dict sem precisar de thread.
# ---------------------------------------------------------------------------
_TOKEN_CACHE: dict[str, tuple[dict, float]] = {}
_TOKEN_CACHE_TTL: float = 300.0  # segundos

# ---------------------------------------------------------------------------
# [P1.1] Cache de clientes JWKS para validação local via RS256.
#   • Chave  = URL da instância Supabase
#   • Valor  = (PyJWKClient, timestamp_de_criacao)
#   • TTL    = 1 hora — chaves rotacionam raramente; cache longo é seguro.
# ---------------------------------------------------------------------------
_JWKS_CACHE: dict[str, tuple[_PyJWKClient, float]] = {}
_JWKS_CACHE_TTL: float = 3600.0  # segundos

# Endpoints que não exigem autenticação
ROTAS_PUBLICAS = {"/health", "/docs", "/openapi.json", "/redoc"}
AMBIENTES_PRODUCAO = {"prod", "production", "staging", "preview"}
SINAIS_IMPLANTACAO = (
    "K_SERVICE",
    "K_REVISION",
    "K_CONFIGURATION",
    "CLOUD_RUN_JOB",
    "CLOUD_RUN_EXECUTION",
    "RAILWAY_ENVIRONMENT",
    "VERCEL_ENV",
)


def _ambiente_producao() -> bool:
    ambiente = (
        os.getenv("APP_ENV")
        or os.getenv("ENVIRONMENT")
        or os.getenv("FASTAPI_ENV")
        or ""
    ).strip().lower()
    if ambiente in AMBIENTES_PRODUCAO:
        return True
    return any((os.getenv(chave) or "").strip() for chave in SINAIS_IMPLANTACAO)


def _auth_obrigatoria() -> bool:
    auth_obrigatorio = os.getenv("AUTH_OBRIGATORIO", "true").lower() == "true"
    permitir_bypass_implantacao = (
        os.getenv("AUTH_PERMITIR_BYPASS_IMPLANTACAO", "false").lower() == "true"
    )
    if auth_obrigatorio:
        return True
    if _ambiente_producao():
        if permitir_bypass_implantacao:
            logger.warning(
                "AUTH_OBRIGATORIO=false permitido em ambiente de implantação "
                "por AUTH_PERMITIR_BYPASS_IMPLANTACAO=true"
            )
            return False
        logger.warning("AUTH_OBRIGATORIO=false ignorado em ambiente de implantação")
        return True
    return False


def _obter_jwks_client(url: str) -> _PyJWKClient | None:
    """Retorna um cliente JWKS em cache ou cria um novo. Retorna None se indisponível."""
    agora = time.time()
    if url in _JWKS_CACHE:
        cliente, ts = _JWKS_CACHE[url]
        if (agora - ts) < _JWKS_CACHE_TTL:
            return cliente
    try:
        jwks_url = f"{url.rstrip('/')}/auth/v1/.well-known/jwks.json"
        cliente = _PyJWKClient(jwks_url, cache_keys=True)
        _JWKS_CACHE[url] = (cliente, agora)
        return cliente
    except Exception as exc:
        logger.warning("[P1.1] Falha ao inicializar cliente JWKS: %s", exc)
        return None


def _validar_jwt_local(token: str, *, supabase_url: str = "", jwt_secret: str = "") -> dict | None:
    """
    [P1.1] Valida JWT localmente sem roundtrip ao Supabase Auth.

    Tenta, na ordem:
      1. HS256 com SUPABASE_JWT_SECRET (mais simples, sem dependência de rede).
      2. RS256 via JWKS publicado pelo Supabase (para instâncias com RS256).

    Levanta HTTPException 401 se o token expirou (erro definitivo).
    Retorna None se nenhum método local conseguiu validar (fallback remoto possível).
    """
    # 1. Tentativa com HS256 + SUPABASE_JWT_SECRET
    if jwt_secret:
        try:
            payload = _jwt.decode(
                token,
                jwt_secret,
                algorithms=["HS256"],
                audience="authenticated",
                options={"verify_aud": True},
            )
            logger.debug("[P1.1] Token validado localmente via HS256")
            return {
                "sub": payload["sub"],
                "email": payload.get("email"),
                "role": payload.get("role", "authenticated"),
            }
        except _JWTExpired:
            raise HTTPException(
                status_code=401,
                detail={"erro": "Token expirado", "codigo": 401},
            )
        except _JWTInvalid:
            pass  # Pode ser RS256 — tenta JWKS

    # 2. Tentativa via JWKS (RS256)
    if supabase_url:
        cliente = _obter_jwks_client(supabase_url)
        if cliente:
            try:
                chave = cliente.get_signing_key_from_jwt(token)
                payload = _jwt.decode(
                    token,
                    chave.key,
                    algorithms=["RS256"],
                    audience="authenticated",
                )
                logger.debug("[P1.1] Token validado localmente via JWKS/RS256")
                return {
                    "sub": payload["sub"],
                    "email": payload.get("email"),
                    "role": payload.get("role", "authenticated"),
                }
            except _JWTExpired:
                raise HTTPException(
                    status_code=401,
                    detail={"erro": "Token expirado", "codigo": 401},
                )
            except Exception as exc:
                logger.debug("[P1.1] Falha na validação JWKS/RS256: %s", exc)

    return None


def _cache_armazenar(token_hash: str, usuario: dict, agora: float) -> None:
    """Armazena resultado de validação no cache com purge lazy."""
    _TOKEN_CACHE[token_hash] = (usuario, agora)
    if len(_TOKEN_CACHE) > 500:
        expirados = [
            k for k, (_, ts) in _TOKEN_CACHE.items()
            if (agora - ts) >= _TOKEN_CACHE_TTL
        ]
        for k in expirados:
            del _TOKEN_CACHE[k]
        logger.debug(
            "[SEC-JWT-CACHE] Purge lazy: %d entradas expiradas removidas",
            len(expirados),
        )


async def verificar_token(
    request: Request,
    credenciais: Optional[HTTPAuthorizationCredentials] = Depends(_seguranca),
) -> dict:
    """
    Valida o token JWT do Supabase Auth.
    Retorna o payload do usuário (sub, email, role, etc.).

    Fluxo de validação (P1.1):
      1. Verificação no cache em memória (sem chamada externa).
      2. Validação local via SUPABASE_JWT_SECRET (HS256) ou JWKS (RS256).
      3. Fallback remoto via supabase.auth.get_user — apenas quando
         JWT_LOCAL_ONLY=false E fora de ambiente de produção.

    Em modo desenvolvimento (AUTH_OBRIGATORIO=false), permite acesso sem token.
    Em ambiente implantado, esse bypass só é aceito com
    AUTH_PERMITIR_BYPASS_IMPLANTACAO=true.
    """
    # Permite rotas públicas
    if request.url.path in ROTAS_PUBLICAS:
        return {"sub": "anonimo", "role": "anon"}

    # AUTH_OBRIGATORIO=false só é aceito fora de ambientes de implantação.
    auth_obrigatorio = _auth_obrigatoria()

    if not credenciais:
        if not auth_obrigatorio:
            logger.debug("Auth desabilitado localmente (AUTH_OBRIGATORIO=false) — acesso anônimo permitido")
            return {"sub": "dev-local", "role": "anon"}
        raise HTTPException(
            status_code=401,
            detail={"erro": "Token de autenticação não fornecido", "codigo": 401},
        )

    token = credenciais.credentials

    # [SEC-JWT-CACHE] Verificar cache antes de qualquer validação.
    # A chave é o SHA-256 do token — o token bruto nunca é armazenado.
    _token_hash = hashlib.sha256(token.encode()).hexdigest()
    _agora = time.time()
    if _token_hash in _TOKEN_CACHE:
        _payload_cached, _ts = _TOKEN_CACHE[_token_hash]
        if (_agora - _ts) < _TOKEN_CACHE_TTL:
            logger.debug("Token validado via cache (sem chamada ao Supabase)")
            return _payload_cached
        del _TOKEN_CACHE[_token_hash]

    url = os.getenv("SUPABASE_URL", "")
    jwt_secret = os.getenv("SUPABASE_JWT_SECRET", "")

    # [P1.1] Tentativa de validação local (sem roundtrip ao Supabase Auth).
    try:
        usuario_local = _validar_jwt_local(token, supabase_url=url, jwt_secret=jwt_secret)
    except HTTPException:
        raise

    if usuario_local:
        _cache_armazenar(_token_hash, usuario_local, _agora)
        return usuario_local

    # [P1.1] Fallback remoto: apenas quando não estamos em produção e
    # JWT_LOCAL_ONLY não está ativo.
    # Em produção, a ausência de SUPABASE_JWT_SECRET ou JWKS inválido é
    # tratada como erro de configuração, não como permissão silenciosa.
    jwt_local_only = (
        os.getenv("JWT_LOCAL_ONLY", "false").lower() == "true"
        or _ambiente_producao()
    )

    if jwt_local_only:
        logger.warning(
            "[P1.1] Validação local falhou e fallback remoto está desabilitado "
            "(JWT_LOCAL_ONLY=true ou ambiente de produção). "
            "Verifique SUPABASE_JWT_SECRET ou o endpoint JWKS."
        )
        raise HTTPException(
            status_code=401,
            detail={"erro": "Token inválido ou expirado", "codigo": 401},
        )

    try:
        from supabase import create_client
        key = os.getenv("SUPABASE_KEY", "")
        if not url or not key:
            if not auth_obrigatorio:
                return {"sub": "dev-local", "role": "anon"}
            raise HTTPException(status_code=500, detail={"erro": "Supabase não configurado", "codigo": 500})

        logger.debug("[P1.1] Fallback: validando token remotamente via Supabase Auth")
        cliente = create_client(url, key)
        resposta = cliente.auth.get_user(token)

        if not resposta or not resposta.user:
            raise HTTPException(
                status_code=401,
                detail={"erro": "Token inválido ou expirado", "codigo": 401},
            )

        usuario = {
            "sub": resposta.user.id,
            "email": resposta.user.email,
            "role": resposta.user.role,
        }

        _cache_armazenar(_token_hash, usuario, _agora)
        return usuario
    except HTTPException:
        raise
    except Exception as exc:
        logger.warning(f"Erro ao validar token remotamente: {exc}")
        if not auth_obrigatorio:
            return {"sub": "dev-local", "role": "anon"}
        raise HTTPException(
            status_code=401,
            detail={"erro": "Falha na validação do token", "codigo": 401},
        )
