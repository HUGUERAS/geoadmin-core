from __future__ import annotations

import asyncio
import hashlib
from types import SimpleNamespace

import jwt
import pytest
from fastapi import HTTPException

import middleware.auth as auth_mod


def _request_fake(path: str = "/projetos"):
    return SimpleNamespace(
        url=SimpleNamespace(path=path),
        client=SimpleNamespace(host="127.0.0.1"),
    )


def _credenciais_fake(token: str):
    return SimpleNamespace(credentials=token)


def _token_hs256(secret: str, *, sub: str = "user-123", email: str = "test@test.com", expired: bool = False) -> str:
    import time as _time
    agora = int(_time.time())
    payload = {
        "sub": sub,
        "email": email,
        "role": "authenticated",
        "aud": "authenticated",
        "exp": agora - 60 if expired else agora + 3600,
        "iat": agora,
    }
    return jwt.encode(payload, secret, algorithm="HS256")


def test_auth_pode_ser_desligada_apenas_fora_de_implantacao(monkeypatch):
    monkeypatch.setenv("AUTH_OBRIGATORIO", "false")
    monkeypatch.delenv("K_SERVICE", raising=False)
    monkeypatch.delenv("RAILWAY_ENVIRONMENT", raising=False)
    monkeypatch.delenv("VERCEL_ENV", raising=False)
    monkeypatch.delenv("APP_ENV", raising=False)
    monkeypatch.delenv("ENVIRONMENT", raising=False)

    resultado = asyncio.run(auth_mod.verificar_token(_request_fake(), None))

    assert resultado["sub"] == "dev-local"


def test_auth_nao_pode_ser_desligada_em_implantacao(monkeypatch):
    monkeypatch.setenv("AUTH_OBRIGATORIO", "false")
    monkeypatch.setenv("K_SERVICE", "geoadmin-api")

    with pytest.raises(HTTPException) as excinfo:
        asyncio.run(auth_mod.verificar_token(_request_fake(), None))

    assert excinfo.value.status_code == 401
    assert excinfo.value.detail["codigo"] == 401


def test_auth_pode_ser_desligada_em_implantacao_com_flag_explicita(monkeypatch):
    monkeypatch.setenv("AUTH_OBRIGATORIO", "false")
    monkeypatch.setenv("AUTH_PERMITIR_BYPASS_IMPLANTACAO", "true")
    monkeypatch.setenv("K_SERVICE", "geoadmin-api")

    resultado = asyncio.run(auth_mod.verificar_token(_request_fake(), None))

    assert resultado["sub"] == "dev-local"


# ---------------------------------------------------------------------------
# [P1.1] Testes de validacao local de JWT
# ---------------------------------------------------------------------------

def test_validacao_local_hs256_valido():
    """Token HS256 valido deve ser autenticado localmente sem chamada remota."""
    segredo = "segredo-de-teste-geoadmin"
    token = _token_hs256(segredo, sub="user-abc")

    resultado = auth_mod._validar_jwt_local(token, jwt_secret=segredo)

    assert resultado is not None
    assert resultado["sub"] == "user-abc"
    assert resultado["role"] == "authenticated"


def test_validacao_local_hs256_expirado_levanta_401():
    """Token HS256 expirado deve levantar HTTPException 401."""
    segredo = "segredo-de-teste-geoadmin"
    token = _token_hs256(segredo, expired=True)

    with pytest.raises(HTTPException) as excinfo:
        auth_mod._validar_jwt_local(token, jwt_secret=segredo)

    assert excinfo.value.status_code == 401


def test_validacao_local_hs256_segredo_errado_retorna_none():
    """Token assinado com segredo diferente deve retornar None."""
    token = _token_hs256("segredo-certo")
    resultado = auth_mod._validar_jwt_local(token, jwt_secret="segredo-errado")
    assert resultado is None


def test_validacao_local_sem_segredo_sem_url_retorna_none():
    """Sem SUPABASE_JWT_SECRET e sem URL, deve retornar None."""
    token = _token_hs256("qualquer")
    resultado = auth_mod._validar_jwt_local(token, jwt_secret="", supabase_url="")
    assert resultado is None


def test_verificar_token_local_hs256_armazena_cache(monkeypatch):
    """Token validado localmente deve ser armazenado no cache."""
    segredo = "segredo-cache-test"
    sub = "user-cache"
    token = _token_hs256(segredo, sub=sub)

    monkeypatch.setenv("SUPABASE_JWT_SECRET", segredo)
    monkeypatch.delenv("SUPABASE_URL", raising=False)
    monkeypatch.delenv("K_SERVICE", raising=False)
    monkeypatch.delenv("RAILWAY_ENVIRONMENT", raising=False)
    monkeypatch.delenv("VERCEL_ENV", raising=False)
    monkeypatch.setenv("AUTH_OBRIGATORIO", "true")
    auth_mod._TOKEN_CACHE.clear()

    creds = _credenciais_fake(token)
    resultado = asyncio.run(auth_mod.verificar_token(_request_fake(), creds))

    assert resultado["sub"] == sub
    hash_token = hashlib.sha256(token.encode()).hexdigest()
    assert hash_token in auth_mod._TOKEN_CACHE


def test_verificar_token_segunda_chamada_usa_cache(monkeypatch):
    """Segunda chamada com mesmo token deve usar cache."""
    segredo = "segredo-cache-hit"
    sub = "user-hit"
    token = _token_hs256(segredo, sub=sub)

    monkeypatch.setenv("SUPABASE_JWT_SECRET", segredo)
    monkeypatch.delenv("SUPABASE_URL", raising=False)
    monkeypatch.delenv("K_SERVICE", raising=False)
    monkeypatch.delenv("RAILWAY_ENVIRONMENT", raising=False)
    monkeypatch.delenv("VERCEL_ENV", raising=False)
    monkeypatch.setenv("AUTH_OBRIGATORIO", "true")
    auth_mod._TOKEN_CACHE.clear()

    creds = _credenciais_fake(token)
    r1 = asyncio.run(auth_mod.verificar_token(_request_fake(), creds))
    r2 = asyncio.run(auth_mod.verificar_token(_request_fake(), creds))

    assert r1["sub"] == sub
    assert r2["sub"] == sub


def test_verificar_token_producao_sem_segredo_rejeita(monkeypatch):
    """Em producao sem SUPABASE_JWT_SECRET, token invalido deve retornar 401."""
    monkeypatch.setenv("RAILWAY_ENVIRONMENT", "production")
    monkeypatch.setenv("AUTH_OBRIGATORIO", "true")
    monkeypatch.delenv("SUPABASE_JWT_SECRET", raising=False)
    monkeypatch.delenv("SUPABASE_URL", raising=False)
    auth_mod._TOKEN_CACHE.clear()

    creds = _credenciais_fake("token.invalido.aqui")

    with pytest.raises(HTTPException) as excinfo:
        asyncio.run(auth_mod.verificar_token(_request_fake(), creds))

    assert excinfo.value.status_code == 401
