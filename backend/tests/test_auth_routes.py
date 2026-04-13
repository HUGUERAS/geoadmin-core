from __future__ import annotations

from types import SimpleNamespace

import pytest
from fastapi import HTTPException

import routes.auth as auth_routes


def _sessao_fake():
    return SimpleNamespace(
        access_token="jwt-access",
        refresh_token="jwt-refresh",
        expires_at=1893456000,
        expires_in=3600,
        token_type="bearer",
        user=SimpleNamespace(
            id="user-1",
            email="topografo@geoadmin.test",
            role="authenticated",
            user_metadata={"name": "Topógrafo Teste"},
            app_metadata={"role": "topografo"},
        ),
    )


def _resposta_auth_fake():
    sessao = _sessao_fake()
    return SimpleNamespace(session=sessao, user=sessao.user)


def test_autenticar_topografo_retorna_sessao_serializada():
    class FakeAuth:
        def sign_in_with_password(self, payload):
            assert payload["email"] == "topografo@geoadmin.test"
            assert payload["password"] == "senha-segura"
            return _resposta_auth_fake()

    resposta = auth_routes.autenticar_topografo(
        "topografo@geoadmin.test",
        "senha-segura",
        cliente_auth=FakeAuth(),
    )

    assert resposta["access_token"] == "jwt-access"
    assert resposta["refresh_token"] == "jwt-refresh"
    assert resposta["user"]["email"] == "topografo@geoadmin.test"
    assert resposta["user"]["nome"] == "Topógrafo Teste"
    assert resposta["user"]["role"] == "authenticated"


def test_renovar_sessao_topografo_retorna_sessao_serializada():
    class FakeAuth:
        def refresh_session(self, refresh_token):
            assert refresh_token == "jwt-refresh"
            return _resposta_auth_fake()

    resposta = auth_routes.renovar_sessao_topografo(
        "jwt-refresh",
        cliente_auth=FakeAuth(),
    )

    assert resposta["access_token"] == "jwt-access"
    assert resposta["refresh_token"] == "jwt-refresh"


def test_autenticar_topografo_retorna_401_em_credenciais_invalidas():
    class FakeAuth:
        def sign_in_with_password(self, _payload):
            raise RuntimeError("Invalid login credentials")

    with pytest.raises(HTTPException) as excinfo:
        auth_routes.autenticar_topografo(
            "topografo@geoadmin.test",
            "senha-ruim",
            cliente_auth=FakeAuth(),
        )

    assert excinfo.value.status_code == 401
    assert excinfo.value.detail["codigo"] == 401


def test_me_topografo_reaproveita_usuario_validado():
    request = SimpleNamespace(
        client=SimpleNamespace(host="127.0.0.1"),
        headers={},
    )
    usuario = {"sub": "user-1", "email": "topografo@geoadmin.test", "role": "authenticated"}

    resposta = auth_routes.me_topografo(request, usuario)

    assert resposta == {"user": {
        "id": "user-1",
        "email": "topografo@geoadmin.test",
        "role": "authenticated",
        "nome": None,
    }}
