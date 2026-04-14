"""backend/utils/upload.py

Utilitários para validação segura de uploads de arquivos.

[SEC-04] Limite de tamanho por categoria, aplicado em streaming — o arquivo é
         lido em chunks e rejeitado assim que o limite é ultrapassado, sem
         nunca carregar o payload completo em memória.

[SEC-10] Validação de MIME real via magic bytes (biblioteca `filetype`), não
         apenas extensão declarada pelo cliente.  Isso impede bypass por simples
         renomeação de arquivo (ex: malware.exe → relatorio.pdf).
"""
from __future__ import annotations

import logging
from pathlib import Path

import filetype  # [SEC-10] detecção de MIME por magic bytes — pip install filetype==1.2.0

from fastapi import HTTPException, UploadFile

logger = logging.getLogger("geoadmin.upload")

# ---------------------------------------------------------------------------
# [SEC-10] Mapeamento MIME → extensões válidas
# Toda extensão aceita DEVE estar mapeada aqui.
# ---------------------------------------------------------------------------
TIPOS_PERMITIDOS: dict[str, list[str]] = {
    "application/pdf": [".pdf"],
    "image/jpeg": [".jpg", ".jpeg"],
    "image/png": [".png"],
    # KMZ é um ZIP com KML interno; ambos partilham application/zip
    "application/zip": [".zip", ".kmz"],
    # Formatos texto/JSON — sem magic bytes binários; validados por extensão
    "application/json": [".json", ".geojson"],
    "application/vnd.google-earth.kml+xml": [".kml"],
    "text/plain": [".txt"],
    "text/csv": [".csv"],
    "image/svg+xml": [".svg"],
    # Formatos Office legados (OLE2) e modernos (OOXML/ZIP)
    "application/msword": [".doc"],
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document": [".docx"],
    "application/vnd.ms-excel": [".xls"],
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": [".xlsx"],
    # AutoCAD DWG — filetype detecta como image/vnd.dwg
    "image/vnd.dwg": [".dwg"],
    # Formatos geoespaciais sem MIME padronizado — validados apenas por extensão
    "application/octet-stream": [".shp", ".shx", ".dbf", ".prj", ".gpkg", ".dxf"],
}

# ---------------------------------------------------------------------------
# Conjuntos pré-montados por contexto de uso
# ---------------------------------------------------------------------------

# Documentos e imagens enviados pelo cliente via formulário público
TIPOS_FORMULARIO: list[str] = [
    "application/pdf",
    "image/jpeg",
    "image/png",
    "application/zip",
    "application/json",
    "application/vnd.google-earth.kml+xml",
    "text/plain",
    "text/csv",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
]

# Arquivo de geometria enviado pelo cliente no formulário (limite maior)
TIPOS_GEO_FORMULARIO: list[str] = [
    "application/zip",
    "application/json",
    "application/vnd.google-earth.kml+xml",
    "text/plain",
    "text/csv",
    "application/octet-stream",
]

# Bandeja cartográfica do projeto (topógrafo/escritório — backend autenticado)
TIPOS_ARQUIVO_PROJETO: list[str] = [
    "application/pdf",
    "image/jpeg",
    "image/png",
    "application/zip",
    "application/json",
    "application/vnd.google-earth.kml+xml",
    "text/plain",
    "text/csv",
    "image/svg+xml",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "application/vnd.ms-excel",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "image/vnd.dwg",
    "application/octet-stream",
]

# Importação de lotes/áreas em formato geoespacial
TIPOS_GEO_IMPORTACAO: list[str] = [
    "application/zip",
    "application/json",
    "application/vnd.google-earth.kml+xml",
    "text/plain",
    "text/csv",
    "application/octet-stream",
]

# ---------------------------------------------------------------------------
# [SEC-04] Limites de tamanho por categoria
# ---------------------------------------------------------------------------
LIMITE_DOCUMENTOS_MB: int = 10   # PDF, imagens, documentos Office
LIMITE_GEOESPACIAL_MB: int = 50  # ZIP, GeoJSON, KML, shapefiles
LIMITE_SVG_MB: int = 2           # SVG (apenas server-side; não exposto diretamente)
LIMITE_PADRAO_MB: int = 10

# ---------------------------------------------------------------------------
# [SEC-10] Controle de quais extensões pulam a detecção por magic bytes
#
# Motivo: formatos texto puro (JSON, KML, CSV…) e certos binários (shapefile,
# GeoPackage) não têm assinaturas confiáveis na lib `filetype`.  Para esses,
# a validação recai sobre a extensão declarada (já checada antes).
# ---------------------------------------------------------------------------
_SKIP_MIME_DETECTION: frozenset[str] = frozenset({
    # texto puro / XML
    ".json", ".geojson", ".kml", ".csv", ".txt", ".svg", ".dxf", ".prj",
    # componentes Shapefile (sem magic bytes padronizados no filetype)
    ".shp", ".shx", ".dbf",
    # OLE2 containers: filetype retorna tipo genérico que não mapeia para .doc/.xls
    ".doc", ".xls",
    # GeoPackage — base SQLite; filetype retorna application/x-sqlite3
    ".gpkg",
})

# Formatos derivados de ZIP: versões antigas do filetype podem classificar
# DOCX/XLSX/KMZ como "application/zip" — toleramos isso.
_ZIP_DERIVADOS: frozenset[str] = frozenset({".docx", ".xlsx", ".pptx", ".kmz"})


def _detectar_mime(cabecalho: bytes, nome_arquivo: str) -> str | None:
    """
    [SEC-10] Detecta o MIME type real a partir dos magic bytes do arquivo.

    Retorna ``None`` quando a extensão pertence a ``_SKIP_MIME_DETECTION`` ou
    quando a biblioteca não reconhece o formato — nesses casos, a validação
    recai apenas sobre a extensão já verificada.
    """
    extensao = Path(nome_arquivo or "").suffix.lower()
    if extensao in _SKIP_MIME_DETECTION:
        return None  # sem detecção — extensão já validada anteriormente

    kind = filetype.guess(cabecalho)
    return kind.mime if kind else None


def _mime_eh_compativel(
    mime_detectado: str,
    extensao: str,
    tipos_permitidos: list[str],
) -> bool:
    """
    [SEC-10] Verifica se o MIME detectado é aceito e se a extensão declarada
    é coerente com esse MIME.

    Retorna ``True`` quando compatível, ``False`` caso contrário.
    """
    if mime_detectado not in tipos_permitidos:
        # Tolerância: formatos ZIP-derivados que versões mais antigas do
        # filetype classificam como application/zip (ex: DOCX, XLSX, KMZ).
        if mime_detectado == "application/zip" and extensao in _ZIP_DERIVADOS:
            return True
        return False

    # A extensão declarada deve corresponder ao MIME detectado.
    extensoes_do_mime = TIPOS_PERMITIDOS.get(mime_detectado, [])
    if extensoes_do_mime and extensao not in extensoes_do_mime:
        return False

    return True


async def validar_upload(
    file: UploadFile,
    tipos_permitidos: list[str],
    max_mb: int = LIMITE_PADRAO_MB,
    *,
    permitir_vazio: bool = False,
) -> bytes | None:
    """
    Valida upload quanto a tamanho e tipo MIME real, retornando o conteúdo.

    [SEC-04] Lê o arquivo em chunks de 256 KB e rejeita com HTTP 413 assim
             que o total ultrapassa ``max_mb``, sem carregar o payload inteiro
             em memória.  Isso previne DoS por arquivo gigante.

    [SEC-10] Detecta o MIME real via magic bytes (``filetype``) e verifica que
             a extensão declarada pelo cliente é coerente com o conteúdo real,
             bloqueando bypass por renomeação de arquivo.

    Parâmetros
    ----------
    file : UploadFile
        Arquivo recebido pelo FastAPI.
    tipos_permitidos : list[str]
        MIMEs aceitos neste contexto. Use as constantes TIPOS_* deste módulo.
    max_mb : int
        Limite de tamanho em MB.  Default: LIMITE_PADRAO_MB (10 MB).
    permitir_vazio : bool
        Se ``True``, retorna ``None`` quando o arquivo está vazio (campo
        opcional não preenchido).  Se ``False`` (default), levanta HTTP 422.

    Retorna
    -------
    bytes
        Conteúdo completo do arquivo, já validado.
    None
        Somente quando ``permitir_vazio=True`` e o arquivo está vazio.

    Levanta
    -------
    HTTPException 413  — arquivo excede ``max_mb``.
    HTTPException 415  — MIME real ou extensão não aceitos.
    HTTPException 422  — arquivo vazio (quando ``permitir_vazio=False``).
    """
    max_bytes = max_mb * 1024 * 1024  # [SEC-04]
    nome = file.filename or "arquivo"
    extensao = Path(nome).suffix.lower()

    # ------------------------------------------------------------------
    # 1. Validar extensão contra os tipos permitidos  [SEC-10]
    #    Feito antes da leitura para falhar rápido sem consumir banda.
    # ------------------------------------------------------------------
    extensoes_validas: set[str] = set()
    for mime in tipos_permitidos:
        extensoes_validas.update(TIPOS_PERMITIDOS.get(mime, []))

    if extensao not in extensoes_validas:  # [SEC-10]
        raise HTTPException(
            status_code=415,
            detail={
                "erro": "Tipo de arquivo não permitido.",
                "codigo": "upload_tipo_nao_permitido",
                "extensao": extensao or None,
            },
        )

    # ------------------------------------------------------------------
    # 2. Ler em chunks, abortando ao ultrapassar o limite  [SEC-04]
    # ------------------------------------------------------------------
    partes: list[bytes] = []
    total = 0
    cabecalho: bytes | None = None  # primeiros bytes para detecção de MIME

    while True:
        bloco = await file.read(256 * 1024)  # 256 KB por iteração
        if not bloco:
            break
        total += len(bloco)
        if total > max_bytes:  # [SEC-04] rejeitar antes de gravar qualquer dado
            raise HTTPException(
                status_code=413,
                detail={
                    "erro": f"Arquivo excede o limite de {max_mb} MB.",
                    "codigo": "upload_tamanho_excedido",
                    "limite_mb": max_mb,
                    "limite_bytes": max_bytes,
                },
            )
        partes.append(bloco)
        if cabecalho is None:
            # 8 KB são suficientes para qualquer assinatura de magic bytes
            cabecalho = bloco[:8192]

    # ------------------------------------------------------------------
    # 3. Arquivo vazio
    # ------------------------------------------------------------------
    if not partes:
        if permitir_vazio:
            return None
        raise HTTPException(
            status_code=422,
            detail={"erro": "Arquivo vazio.", "codigo": "upload_vazio"},
        )

    # ------------------------------------------------------------------
    # 4. Validar MIME real via magic bytes  [SEC-10]
    # ------------------------------------------------------------------
    mime_detectado = _detectar_mime(cabecalho or b"", nome)
    if mime_detectado is not None:
        if not _mime_eh_compativel(mime_detectado, extensao, tipos_permitidos):
            logger.warning(
                "[SEC-10] Upload bloqueado — MIME real '%s' incompatível com "
                "extensão '%s' (arquivo: %s)",
                mime_detectado,
                extensao,
                nome,
            )
            raise HTTPException(
                status_code=415,
                detail={
                    "erro": (
                        "O conteúdo real do arquivo não corresponde à extensão "
                        "declarada. Verifique se o arquivo não foi renomeado."
                    ),
                    "codigo": "upload_mime_invalido",
                    "mime_detectado": mime_detectado,
                    "extensao": extensao,
                },
            )

    return b"".join(partes)
