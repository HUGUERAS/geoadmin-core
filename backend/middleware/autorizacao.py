"""
[P1.2] Autorização por objeto — verificadores de acesso a recursos.

Estratégia:
  • Fundação para autorização por projeto, área, cliente e arquivo.
  • Fase atual: todos os usuários autenticados têm acesso a todos os recursos
    (comportamento atual preservado enquanto backfill de criado_por_user_id
    não for concluído).
  • Fase futura: quando criado_por_user_id estiver populado, as funções aqui
    poderão ser endurecidas para filtrar por proprietário.

Uso típico em rotas:
    @router.get("/{projeto_id}")
    def buscar(projeto_id: str, usuario: dict = Depends(verificar_token)):
        projeto = _projeto_ou_404(sb, projeto_id)
        verificar_acesso_projeto(projeto, usuario)
        ...
"""
from __future__ import annotations

import logging
from typing import Any

from fastapi import HTTPException

logger = logging.getLogger(__name__)


def verificar_acesso_projeto(projeto: dict[str, Any], usuario: dict[str, Any]) -> None:
    """
    Verifica se o usuário tem acesso ao projeto.

    Fase atual (transição P1.2):
    • Se o projeto não tem `criado_por_user_id` definido (NULL), qualquer
      usuário autenticado pode acessar (projetos legados ou de org compartilhada).
    • Se o projeto tem `criado_por_user_id`, apenas o próprio usuário pode acessar
      — exceto quando o usuário é service_role (acesso total de backend).

    Fase futura (após backfill):
    • Restringir para `criado_por_user_id = usuario["sub"]` apenas.
    """
    sub = (usuario or {}).get("sub", "")
    role = (usuario or {}).get("role", "")

    # service_role e anon de dev local têm acesso irrestrito
    if role == "service_role" or sub in {"dev-local", "anonimo"}:
        return

    criado_por = (projeto or {}).get("criado_por_user_id")

    # Projeto sem proprietário definido → acesso liberado para qualquer autenticado
    if not criado_por:
        return

    # Projeto com proprietário: verificar identidade
    if str(criado_por) != str(sub):
        logger.warning(
            "[P1.2] Acesso negado: usuario=%s tentou acessar projeto "
            "com criado_por_user_id=%s",
            sub,
            criado_por,
        )
        raise HTTPException(
            status_code=403,
            detail={"erro": "Acesso negado a este recurso", "codigo": 403},
        )


def verificar_acesso_area(area: dict[str, Any], projeto: dict[str, Any], usuario: dict[str, Any]) -> None:
    """
    Verifica se o usuário tem acesso à área.
    A área herda a autorização do projeto a que pertence.
    """
    verificar_acesso_projeto(projeto, usuario)


def usuario_sub(usuario: dict[str, Any] | None) -> str | None:
    """Extrai o `sub` (user_id) do payload do usuário autenticado."""
    if not usuario:
        return None
    sub = (usuario.get("sub") or "").strip()
    return sub if sub and sub not in {"dev-local", "anonimo"} else None
