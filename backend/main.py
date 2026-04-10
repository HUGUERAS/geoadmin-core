import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# ── Banco de dados PROJ local (operação offline / sem internet) ────────────────
# O proj.db contém todas as definições CRS (SIRGAS2000, SAD69, UTM, etc.)
# sem necessidade de rede.
# Definir PROJ_DATA *antes* de importar pyproj para que ele use o banco local.
# Configure via variável de ambiente PROJ_DATA, ou deixe vazio para usar valor padrão do pyproj.
_proj_data_dir = os.getenv("PROJ_DATA")
if _proj_data_dir and os.path.isdir(_proj_data_dir):
    os.environ["PROJ_DATA"] = _proj_data_dir
# ──────────────────────────────────────────────────────────────────────────────

from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, Response
from starlette.middleware.trustedhost import TrustedHostMiddleware
from typing import Dict, Any

from dotenv import load_dotenv
from supabase import create_client, Client
import httpx

# Importa o middleware de autenticação
from middleware.auth import verificar_token

# Carrega origens CORS permitidas do ambiente
load_dotenv()
_origens_padrao = [
    "http://localhost:8081",
    "http://127.0.0.1:8081",
    "http://localhost:8082",
    "http://127.0.0.1:8082",
    "http://localhost:19006",
    "http://127.0.0.1:19006",
    "http://localhost:8000",
    "http://127.0.0.1:8000",
]
_origens_permitidas = os.getenv("ALLOWED_ORIGINS", ",".join(_origens_padrao)).split(",")
_origem_permitida_regex = (
    r"^https?://("
    # Rede local (dev)
    r"localhost|"
    r"127\.0\.0\.1|"
    r"10(?:\.\d{1,3}){3}|"
    r"192\.168(?:\.\d{1,3}){2}|"
    r"172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2}|"
    # Vercel (preview + production)
    r"[a-z0-9\-]+\.vercel\.app"
    r")(:\d+)?$"
)
_hosts_padrao = [
    "localhost",
    "127.0.0.1",
    "*.run.app",
]
_hosts_permitidos = [host.strip() for host in os.getenv("ALLOWED_HOSTS", ",".join(_hosts_padrao)).split(",") if host.strip()]
_expor_docs_api = os.getenv("EXPOSE_API_DOCS", "false").lower() == "true"
_detalhar_erros = os.getenv("DEBUG_ERRORS", "false").lower() == "true"

# ── Rotas
# Para proteger um endpoint com autenticação, adicione o seguinte ao seus handlers:
#     usuario: dict = Depends(verificar_token)
# Exemplo:
#     @router.get("/exemplo")
#     def exemplo(usuario: dict = Depends(verificar_token)):
#         print(f"Usuário autenticado: {usuario['sub']}")

from routes.exportacao import router as exportacao_router
from routes.metrica_simples import router as metrica_router
from routes.projetos import router as projetos_router
from routes.clientes import router as clientes_router
from routes.documentos import router as docs_router
from routes.pontos import router as pontos_router
# RAG removido do backend principal — rodar separadamente quando necessário
# from routes.rag import router as rag_router
from routes.perimetros import router as perimetros_router
from routes.geo import router as geo_router
from routes.importar import router as importar_router
from routes.catalogo import router as catalogo_router

from middleware.limiter import limiter

app = FastAPI(
    title="GeoAdmin Pro - Backend MVP",
    docs_url="/docs" if _expor_docs_api else None,
    redoc_url="/redoc" if _expor_docs_api else None,
    openapi_url="/openapi.json" if _expor_docs_api else None,
)
app.state.limiter = limiter

app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=_hosts_permitidos,
)

app.add_middleware(
  CORSMiddleware,
  allow_origins=[origem.strip() for origem in _origens_permitidas],
  allow_origin_regex=_origem_permitida_regex,
  allow_methods=["*"],
  allow_headers=["*"],
)


def _proxy_dev_ativo() -> bool:
    upstream = os.getenv("DEV_PROXY_BACKEND_URL", "").strip()
    if not upstream:
        return False
    return not (os.getenv("SUPABASE_URL") and os.getenv("SUPABASE_KEY"))


def _proxy_dev_url_base() -> str:
    return os.getenv("DEV_PROXY_BACKEND_URL", "").strip().rstrip("/")


_ROTAS_LOCAIS_PROXY_DEV = {"/health", "/docs", "/openapi.json", "/redoc"}
_HEADERS_HOP_BY_HOP = {
    "connection",
    "keep-alive",
    "proxy-authenticate",
    "proxy-authorization",
    "te",
    "trailers",
    "transfer-encoding",
    "upgrade",
    "content-encoding",
}


@app.middleware("http")
async def _proxy_dev_middleware(request: Request, call_next):
    if not _proxy_dev_ativo() or request.url.path in _ROTAS_LOCAIS_PROXY_DEV:
        return await call_next(request)

    destino_base = _proxy_dev_url_base()
    if not destino_base:
        return await call_next(request)

    query = request.url.query
    destino = f"{destino_base}{request.url.path}"
    if query:
        destino = f"{destino}?{query}"

    cabecalhos = {
        chave: valor
        for chave, valor in request.headers.items()
        if chave.lower() not in _HEADERS_HOP_BY_HOP and chave.lower() != "host"
    }
    corpo = await request.body()

    try:
        async with httpx.AsyncClient(follow_redirects=True, timeout=60.0) as client:
            resposta = await client.request(
                request.method,
                destino,
                content=corpo,
                headers=cabecalhos,
            )
    except Exception as exc:
        _logger_main.error("Falha no proxy dev para %s: %s", request.url.path, exc, exc_info=True)
        return JSONResponse(
            status_code=502,
            content={"erro": "Falha ao acessar o backend remoto de desenvolvimento", "codigo": 502},
        )

    headers_resposta = {
        chave: valor
        for chave, valor in resposta.headers.items()
        if chave.lower() not in _HEADERS_HOP_BY_HOP
    }
    headers_resposta["X-GeoAdmin-Dev-Proxy"] = "1"
    return Response(
        content=resposta.content,
        status_code=resposta.status_code,
        headers=headers_resposta,
        media_type=resposta.headers.get("content-type"),
    )

_static_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "static")
if os.path.isdir(_static_dir):
  app.mount("/static", StaticFiles(directory=_static_dir), name="static")

app.include_router(projetos_router)
app.include_router(clientes_router)
app.include_router(exportacao_router)
app.include_router(metrica_router)
app.include_router(docs_router)
app.include_router(pontos_router)
# app.include_router(rag_router)  # RAG desativado — módulo isolado
app.include_router(perimetros_router)
app.include_router(geo_router)
app.include_router(importar_router)
app.include_router(catalogo_router)


import logging as _logging
_logger_main = _logging.getLogger("geoadmin.main")


@app.exception_handler(Exception)
async def _handler_erro_global(request: Request, exc: Exception) -> JSONResponse:
    """Garante que exceções não capturadas retornem JSON (não text/plain do Starlette)."""
    if isinstance(exc, HTTPException):
        return JSONResponse(status_code=exc.status_code, content={"detail": exc.detail})
    _logger_main.error("Exceção não tratada em %s: %s", request.url.path, exc, exc_info=True)
    mensagem = f"Erro interno: {str(exc)}" if _detalhar_erros else "Erro interno do servidor"
    return JSONResponse(
        status_code=500,
        content={"erro": mensagem, "codigo": 500},
    )


@app.get("/health")
def health() -> Dict[str, str]:
  return {"status": "ok"}


_supabase_client: Client | None = None


def get_supabase() -> Client:
  """
  Retorna um cliente Supabase configurado via variáveis de ambiente.

  Espera encontrar:
  - SUPABASE_URL
  - SUPABASE_KEY  (use a anon key ou service key conforme o caso)

  Você pode definir essas variáveis em um arquivo `.env` dentro de `backend/`
  (carregado automaticamente pelo python-dotenv) ou diretamente no ambiente.
  """
  global _supabase_client

  if _supabase_client is not None:
    return _supabase_client

  # Carrega variáveis de ambiente de backend/.env, se existir
  load_dotenv()

  url = os.getenv("SUPABASE_URL")
  key = os.getenv("SUPABASE_KEY")

  if not url or not key:
    raise HTTPException(
      status_code=500,
      detail={
        "erro": (
          "Supabase não configurado. Defina SUPABASE_URL e SUPABASE_KEY "
          "no arquivo backend/.env ou no ambiente do servidor."
        ),
        "codigo": 500,
      },
    )

  _supabase_client = create_client(url, key)
  return _supabase_client

