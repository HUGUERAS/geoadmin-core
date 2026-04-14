import time
import asyncio
import functools
from collections import defaultdict
from fastapi import Request, HTTPException

# [SEC-11] Mensagem padronizada em português para respostas HTTP 429
_MSG_429 = "Muitas requisições. Tente novamente em alguns minutos."


class CustomLimiter:
    def __init__(self):
        self.history: dict[str, list[float]] = defaultdict(list)

    def _check_limit(
        self,
        request: Request,
        max_reqs: int,
        window: int,
        key: str | None = None,  # [SEC-11] chave customizada (ex: user ID, hash JWT) ou None → usa IP
    ) -> None:
        # [SEC-11] Resolve a chave de rate limit: customizada > IP do cliente
        if key is None:
            # Sem chave explícita: tenta usar IP
            if not (request and request.client):
                return  # Chamada interna sem contexto HTTP → sem rate limit
            key = request.client.host
        elif not key:
            # Chave vazia explicitamente retornada pelo key_func → pular (chamada interna)
            return

        now = time.time()
        self.history[key] = [t for t in self.history[key] if now - t < window]
        if len(self.history[key]) >= max_reqs:
            raise HTTPException(status_code=429, detail=_MSG_429)  # [SEC-11]
        self.history[key].append(now)

    def limit(self, limit_str: str, key_func=None):  # [SEC-11] key_func estendido
        """
        Decorador de rate limit.

        :param limit_str: "N/minute" ou "N/second"
        :param key_func: callable(request, **kwargs) -> str | None  [SEC-11]
            Extrai a chave de rate limit (ex: sub do usuário, hash do JWT).
            - None  → CustomLimiter usa o IP do cliente (padrão para rotas públicas)
            - ""    → rate limit ignorado (útil para chamadas internas sem Request)
            Se não fornecido, comportamento original por IP é mantido.
        """
        parts = limit_str.split("/")
        max_reqs = int(parts[0])
        window = 60 if "minute" in parts[1] else 1

        def decorator(func):
            if asyncio.iscoroutinefunction(func):
                @functools.wraps(func)
                async def async_wrapper(*args, **kwargs):
                    req = kwargs.get("request") or next(
                        (a for a in args if isinstance(a, Request)), None
                    )
                    # [SEC-11] Resolve chave via key_func ou deixa None para fallback por IP
                    resolved_key = None
                    if key_func is not None:
                        try:
                            resolved_key = key_func(req, **kwargs)
                        except Exception:
                            resolved_key = None
                    self._check_limit(req, max_reqs, window, key=resolved_key)
                    return await func(*args, **kwargs)
                return async_wrapper
            else:
                @functools.wraps(func)
                def sync_wrapper(*args, **kwargs):
                    req = kwargs.get("request") or next(
                        (a for a in args if isinstance(a, Request)), None
                    )
                    # [SEC-11] Resolve chave via key_func ou deixa None para fallback por IP
                    resolved_key = None
                    if key_func is not None:
                        try:
                            resolved_key = key_func(req, **kwargs)
                        except Exception:
                            resolved_key = None
                    self._check_limit(req, max_reqs, window, key=resolved_key)
                    return func(*args, **kwargs)
                return sync_wrapper

        return decorator


limiter = CustomLimiter()
