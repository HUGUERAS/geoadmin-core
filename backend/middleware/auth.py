"""
Middleware de autenticação via JWT do Supabase.
Uso: adicione `usuario: dict = Depends(verificar_token)` nos endpoints protegidos.
"""
import os
import logging
from typing import Optional

from fastapi import Depends, HTTPException, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)

_seguranca = HTTPBearer(auto_error=False)

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
    if auth_obrigatorio:
        return True
    if _ambiente_producao():
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

        return {
            "sub": resposta.user.id,
            "email": resposta.user.email,
            "role": resposta.user.role,
        }
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
