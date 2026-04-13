from __future__ import annotations

from typing import Any, Optional

from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel, Field

from middleware.auth import verificar_token
from middleware.limiter import limiter


router = APIRouter(prefix="/auth", tags=["Auth"])


class LoginPayload(BaseModel):
    email: str
    senha: str = Field(min_length=6)


class RefreshPayload(BaseModel):
    refresh_token: str = Field(min_length=16)


def _get_supabase_auth_client():
    from main import get_supabase as _get
    return _get()


def _serializar_usuario(user: Any) -> dict[str, Any]:
    if not user:
        raise HTTPException(
            status_code=401,
            detail={"erro": "Sessão inválida ou expirada", "codigo": 401},
        )

    user_metadata = getattr(user, "user_metadata", None) or {}
    app_metadata = getattr(user, "app_metadata", None) or {}
    nome = user_metadata.get("name") or user_metadata.get("nome") or user_metadata.get("full_name")

    return {
        "id": getattr(user, "id", None),
        "email": getattr(user, "email", None),
        "role": getattr(user, "role", None) or app_metadata.get("role"),
        "nome": nome,
    }


def _serializar_resposta_auth(resposta: Any) -> dict[str, Any]:
    session = getattr(resposta, "session", None)
    user = getattr(resposta, "user", None) or getattr(session, "user", None)

    if not session or not user:
        raise HTTPException(
            status_code=401,
            detail={"erro": "Credenciais inválidas ou sessão ausente", "codigo": 401},
        )

    return {
        "access_token": getattr(session, "access_token", None),
        "refresh_token": getattr(session, "refresh_token", None),
        "expires_at": getattr(session, "expires_at", None),
        "expires_in": getattr(session, "expires_in", None),
        "token_type": getattr(session, "token_type", None),
        "user": _serializar_usuario(user),
    }


def autenticar_topografo(email: str, senha: str, *, cliente_auth=None) -> dict[str, Any]:
    auth = cliente_auth or _get_supabase_auth_client().auth
    try:
        resposta = auth.sign_in_with_password({
            "email": email,
            "password": senha,
        })
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(
            status_code=401,
            detail={"erro": "Credenciais inválidas ou sessão indisponível.", "codigo": 401},
        ) from exc

    return _serializar_resposta_auth(resposta)


def renovar_sessao_topografo(refresh_token: str, *, cliente_auth=None) -> dict[str, Any]:
    auth = cliente_auth or _get_supabase_auth_client().auth
    try:
        resposta = auth.refresh_session(refresh_token)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(
            status_code=401,
            detail={"erro": "Não foi possível renovar a sessão.", "codigo": 401},
        ) from exc

    return _serializar_resposta_auth(resposta)


@router.post("/login", summary="Autenticar topógrafo/usuário interno")
@limiter.limit("10/minute")
def login_topografo(request: Request, payload: LoginPayload):
    return autenticar_topografo(payload.email, payload.senha)


@router.post("/refresh", summary="Renovar sessão interna")
@limiter.limit("20/minute")
def refresh_topografo(request: Request, payload: RefreshPayload):
    return renovar_sessao_topografo(payload.refresh_token)


@router.get("/me", summary="Obter identidade da sessão atual")
@limiter.limit("60/minute")
def me_topografo(request: Request, usuario: dict = Depends(verificar_token)):
    token = (request.headers.get("authorization") or "").removeprefix("Bearer").strip()
    if token:
        try:
            resposta = _get_supabase_auth_client().auth.get_user(token)
            user = getattr(resposta, "user", None)
            if user:
                return {"user": _serializar_usuario(user)}
        except Exception:
            pass

    return {
        "user": {
            "id": usuario.get("sub"),
            "email": usuario.get("email"),
            "role": usuario.get("role"),
            "nome": usuario.get("nome"),
        }
    }
