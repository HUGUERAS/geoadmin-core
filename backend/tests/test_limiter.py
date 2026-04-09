from __future__ import annotations

from types import SimpleNamespace

import pytest
from fastapi import HTTPException

from middleware.limiter import CustomLimiter


def _request(ip: str):
    return SimpleNamespace(client=SimpleNamespace(host=ip))


def test_limiter_isola_contadores_por_escopo():
    limiter = CustomLimiter()
    request = _request("127.0.0.1")

    limiter._check_limit(request, 1, 60, scope="rota-a")
    limiter._check_limit(request, 1, 60, scope="rota-b")

    with pytest.raises(HTTPException) as excinfo:
        limiter._check_limit(request, 1, 60, scope="rota-a")

    assert excinfo.value.status_code == 429


def test_limiter_isola_contadores_por_ip():
    limiter = CustomLimiter()

    limiter._check_limit(_request("127.0.0.1"), 1, 60, scope="rota-a")
    limiter._check_limit(_request("127.0.0.2"), 1, 60, scope="rota-a")
