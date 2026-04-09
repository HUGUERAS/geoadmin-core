from __future__ import annotations

import asyncio
from types import SimpleNamespace

import pytest
from fastapi import HTTPException

import middleware.auth as auth_mod


def _request_fake(path: str = "/projetos"):
    return SimpleNamespace(
        url=SimpleNamespace(path=path),
        client=SimpleNamespace(host="127.0.0.1"),
    )


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
