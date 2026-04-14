"""
Middleware de autenticação via JWT do Supabase.
Uso: adicione `usuario: dict = Depends(verificar_token)` nos endpoints protegidos.
"""
import hashlib  # [SEC-JWT-CACHE] hashing do token para chave de cache
import os
import logging
import time  # [SEC-JWT-CACHE] controle de TTL do cache
from typing import Optional

from fastapi import Depends, HTTPException, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)

_seguranca = HTTPBearer(auto_error=False)

# ---------------------------------------------------------------------------
# [SEC-JWT-CACHE] Cache em memória de resultados de validação de token.
#
# Por quê: o SDK Supabase valida tokens via REST (`auth.get_user(token)`),
# o que significa uma chamada HTTP ao Supabase Auth a CADA request autenticado.
# Sob carga isso eleva latência e pode acionar rate-limit do próprio Supabase.
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


async def verificar_token(
    request: Request,
    credenciais: Optional[HTTPAuthorizationCredentials] = Depends(_seguranca),
) -> dict:
    """
    Valida o token JWT do Supabase Auth.
    Retorna o payload do usuário (sub, email, role, etc.).
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

    # [SEC-JWT-CACHE] Verificar cache antes de chamar o Supabase Auth.
    # A chave é o SHA-256 do token — o token bruto nunca é armazenado.
    _token_hash = hashlib.sha256(token.encode()).hexdigest()
    _agora = time.time()
    if _token_hash in _TOKEN_CACHE:
        _payload_cached, _ts = _TOKEN_CACHE[_token_hash]
        if (_agora - _ts) < _TOKEN_CACHE_TTL:
            logger.debug("Token validado via cache (sem chamada ao Supabase)")
            return _payload_cached
        # TTL expirado — remover entrada obsoleta
        del _TOKEN_CACHE[_token_hash]

    try:
        from supabase import create_client
        url = os.getenv("SUPABASE_URL", "")
        key = os.getenv("SUPABASE_KEY", "")
        if not url or not key:
            if not auth_obrigatorio:
                return {"sub": "dev-local", "role": "anon"}
            raise HTTPException(status_code=500, detail={"erro": "Supabase não configurado", "codigo": 500})

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

        # [SEC-JWT-CACHE] Armazenar resultado válido no cache.
        # Purge lazy: remove todas as entradas expiradas quando o cache
        # ultrapassar 500 entradas, evitando crescimento ilimitado.
        _TOKEN_CACHE[_token_hash] = (usuario, _agora)
        if len(_TOKEN_CACHE) > 500:
            _expirados = [
                k for k, (_, ts) in _TOKEN_CACHE.items()
                if (_agora - ts) >= _TOKEN_CACHE_TTL
            ]
            for k in _expirados:
                del _TOKEN_CACHE[k]
            logger.debug(
                "[SEC-JWT-CACHE] Purge lazy: %d entradas expiradas removidas",
                len(_expirados),
            )

        return usuario
    except HTTPException:
        raise
    except Exception as exc:
        logger.warning(f"Erro ao validar token: {exc}")
        if not auth_obrigatorio:
            return {"sub": "dev-local", "role": "anon"}
        raise HTTPException(
            status_code=401,
            detail={"erro": "Falha na validação do token", "codigo": 401},
        )
