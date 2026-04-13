from __future__ import annotations

import asyncio

import httpx

import main
import routes.auth as auth_routes


def test_login_recebe_payload_json_no_body(monkeypatch):
    recebido = {}

    def _auth_fake(email: str, senha: str, *, cliente_auth=None):
        recebido["email"] = email
        recebido["senha"] = senha
        return {
            "access_token": "jwt-access",
            "refresh_token": "jwt-refresh",
            "expires_at": 1893456000,
            "expires_in": 3600,
            "token_type": "bearer",
            "user": {
                "id": "user-1",
                "email": email,
                "role": "authenticated",
                "nome": "Topógrafo Teste",
            },
        }

    async def _executar():
        transport = httpx.ASGITransport(app=main.app)
        async with httpx.AsyncClient(transport=transport, base_url="http://localhost") as client:
            return await client.post(
                "/auth/login",
                json={"email": "topografo@geoadmin.test", "senha": "senha-segura"},
            )

    monkeypatch.setattr(auth_routes, "autenticar_topografo", _auth_fake)
    resposta = asyncio.run(_executar())

    assert resposta.status_code == 200
    assert resposta.json()["access_token"] == "jwt-access"
    assert recebido == {
        "email": "topografo@geoadmin.test",
        "senha": "senha-segura",
    }


def test_refresh_recebe_payload_json_no_body(monkeypatch):
    recebido = {}

    def _refresh_fake(refresh_token: str, *, cliente_auth=None):
        recebido["refresh_token"] = refresh_token
        return {
            "access_token": "jwt-access-renovado",
            "refresh_token": refresh_token,
            "expires_at": 1893459600,
            "expires_in": 3600,
            "token_type": "bearer",
            "user": {
                "id": "user-1",
                "email": "topografo@geoadmin.test",
                "role": "authenticated",
                "nome": "Topógrafo Teste",
            },
        }

    async def _executar():
        transport = httpx.ASGITransport(app=main.app)
        async with httpx.AsyncClient(transport=transport, base_url="http://localhost") as client:
            return await client.post(
                "/auth/refresh",
                json={"refresh_token": "jwt-refresh-token"},
            )

    monkeypatch.setattr(auth_routes, "renovar_sessao_topografo", _refresh_fake)
    resposta = asyncio.run(_executar())

    assert resposta.status_code == 200
    assert resposta.json()["access_token"] == "jwt-access-renovado"
    assert recebido == {"refresh_token": "jwt-refresh-token"}
