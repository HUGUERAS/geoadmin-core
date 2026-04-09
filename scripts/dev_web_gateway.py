from __future__ import annotations

import argparse
import mimetypes
import posixpath
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urljoin
from urllib.request import Request, urlopen


API_PREFIXES = (
    "/health",
    "/projetos",
    "/clientes",
    "/documentos",
    "/geo",
    "/metrica",
    "/perimetros",
    "/pontos",
    "/catalogo",
    "/importar",
    "/static",
)

HOP_BY_HOP_HEADERS = {
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


class GatewayHandler(BaseHTTPRequestHandler):
    diretorio_web: Path
    upstream_base: str

    def do_OPTIONS(self) -> None:
        self.send_response(HTTPStatus.NO_CONTENT)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET,POST,PATCH,PUT,DELETE,OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.end_headers()

    def do_GET(self) -> None:
        if self._deve_proxiar():
            self._proxiar()
            return
        self._servir_arquivo()

    def do_POST(self) -> None:
        self._proxiar()

    def do_PATCH(self) -> None:
        self._proxiar()

    def do_PUT(self) -> None:
        self._proxiar()

    def do_DELETE(self) -> None:
        self._proxiar()

    def _deve_proxiar(self) -> bool:
        caminho = self.path.split("?", 1)[0]
        return caminho.startswith(API_PREFIXES)

    def _proxiar(self) -> None:
        destino = urljoin(self.upstream_base.rstrip("/") + "/", self.path.lstrip("/"))
        tamanho = int(self.headers.get("Content-Length", "0") or "0")
        corpo = self.rfile.read(tamanho) if tamanho else None

        cabecalhos = {
            chave: valor
            for chave, valor in self.headers.items()
            if chave.lower() not in HOP_BY_HOP_HEADERS and chave.lower() != "host"
        }

        requisicao = Request(destino, data=corpo, headers=cabecalhos, method=self.command)

        try:
            with urlopen(requisicao, timeout=60) as resposta:
                self.send_response(resposta.status)
                for chave, valor in resposta.headers.items():
                    if chave.lower() in HOP_BY_HOP_HEADERS:
                        continue
                    self.send_header(chave, valor)
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                self.wfile.write(resposta.read())
        except HTTPError as erro:
            self.send_response(erro.code)
            for chave, valor in erro.headers.items():
                if chave.lower() in HOP_BY_HOP_HEADERS:
                    continue
                self.send_header(chave, valor)
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(erro.read())
        except URLError as erro:
            mensagem = f"Falha ao acessar upstream: {erro.reason}".encode("utf-8")
            self.send_response(HTTPStatus.BAD_GATEWAY)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.send_header("Content-Length", str(len(mensagem)))
            self.end_headers()
            self.wfile.write(mensagem)

    def _servir_arquivo(self) -> None:
        caminho = self.path.split("?", 1)[0]
        caminho_normalizado = posixpath.normpath(caminho).lstrip("/")
        candidato = self._resolver_arquivo_web(caminho_normalizado)

        try:
            conteudo = candidato.read_bytes()
        except OSError:
            self.send_error(HTTPStatus.NOT_FOUND, "Arquivo nao encontrado")
            return

        tipo, _ = mimetypes.guess_type(str(candidato))
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", tipo or "application/octet-stream")
        self.send_header("Content-Length", str(len(conteudo)))
        self.end_headers()
        self.wfile.write(conteudo)

    def _resolver_arquivo_web(self, caminho_normalizado: str) -> Path:
        if caminho_normalizado in ("", "."):
            return self.diretorio_web / "index.html"

        candidato = self.diretorio_web / Path(caminho_normalizado)
        if candidato.is_file():
            return candidato

        if candidato.is_dir():
            index_diretorio = candidato / "index.html"
            if index_diretorio.exists():
                return index_diretorio

        if not candidato.suffix:
            index_aninhado = self.diretorio_web / caminho_normalizado / "index.html"
            if index_aninhado.exists():
                return index_aninhado

            dinamico = self._resolver_rota_dinamica(caminho_normalizado)
            if dinamico is not None:
                return dinamico

        return self.diretorio_web / "index.html"

    def _resolver_rota_dinamica(self, caminho_normalizado: str) -> Path | None:
        segmentos = [segmento for segmento in caminho_normalizado.split("/") if segmento]
        if not segmentos:
            return None

        diretorio_atual = self.diretorio_web
        for indice, segmento in enumerate(segmentos):
            ultimo_segmento = indice == len(segmentos) - 1

            candidato_direto = diretorio_atual / segmento
            if candidato_direto.is_dir():
                diretorio_atual = candidato_direto
                continue

            if ultimo_segmento:
                arquivo_direto = diretorio_atual / f"{segmento}.html"
                if arquivo_direto.exists():
                    return arquivo_direto

                arquivos_dinamicos = sorted(diretorio_atual.glob("[[]*[]].html"))
                if arquivos_dinamicos:
                    return arquivos_dinamicos[0]

            diretorios_dinamicos = sorted(
                item for item in diretorio_atual.glob("[[]*[]]") if item.is_dir()
            )
            if diretorios_dinamicos:
                diretorio_atual = diretorios_dinamicos[0]
                continue

            return None

        index_diretorio = diretorio_atual / "index.html"
        if index_diretorio.exists():
            return index_diretorio

        arquivos_dinamicos = sorted(diretorio_atual.glob("[[]*[]].html"))
        if arquivos_dinamicos:
            return arquivos_dinamicos[0]

        return None


def main() -> None:
    parser = argparse.ArgumentParser(description="Serve a versao web e proxia a API do GeoAdmin Core.")
    parser.add_argument(
        "--web-dir",
        default=str(Path(__file__).resolve().parents[1] / "mobile" / "dist"),
        help="Diretorio do build web exportado.",
    )
    parser.add_argument(
        "--upstream",
        default="http://127.0.0.1:8001",
        help="Base URL do backend a ser usado pelo gateway. Local por padrão.",
    )
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8000)
    args = parser.parse_args()

    handler = GatewayHandler
    handler.diretorio_web = Path(args.web_dir).resolve()
    handler.upstream_base = args.upstream.rstrip("/")

    servidor = ThreadingHTTPServer((args.host, args.port), handler)
    print(f"Gateway web em http://{args.host}:{args.port}")
    print(f"Servindo web de {handler.diretorio_web}")
    print(f"Proxiando API para {handler.upstream_base}")
    servidor.serve_forever()


if __name__ == "__main__":
    main()
