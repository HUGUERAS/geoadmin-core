"""Testes para funcoes puras de backend/integracoes/integracao_metrica.py"""

import pytest
from integracoes.integracao_metrica import (
    PontoExportacao,
    gerar_txt,
    gerar_csv,
)


def _pontos_exemplo() -> list[PontoExportacao]:
    return [
        PontoExportacao(
            nome="P01", norte=7395200.123, este=423061.456, cota=879.100,
            codigo="TP", descricao="Vertice 1", latitude=-22.651, longitude=-43.258,
        ),
        PontoExportacao(
            nome="P02", norte=7395300.789, este=423100.321, cota=880.500,
            codigo="TN", descricao="Vertice 2", latitude=-22.650, longitude=-43.257,
        ),
    ]


def _projeto_exemplo() -> dict:
    return {
        "id": "abc-123",
        "nome": "Fazenda Teste",
        "numero_job": "JOB-001",
        "cliente_nome": "Hugo",
    }


class TestGerarTxt:
    def test_formato_basico(self):
        txt = gerar_txt(_pontos_exemplo(), _projeto_exemplo())
        linhas = txt.strip().split("\n")
        assert len(linhas) == 2
        assert linhas[0] == "P01,TP,7395200.123,423061.456,879.100"
        assert linhas[1] == "P02,TN,7395300.789,423100.321,880.500"

    def test_lista_vazia(self):
        txt = gerar_txt([], _projeto_exemplo())
        assert txt == ""

    def test_precisao_3_casas(self):
        pontos = [
            PontoExportacao(
                nome="V1", norte=100.1, este=200.2, cota=300.3,
                codigo="TP", descricao="", latitude=0, longitude=0,
            )
        ]
        txt = gerar_txt(pontos, _projeto_exemplo())
        assert "100.100" in txt
        assert "200.200" in txt
        assert "300.300" in txt


class TestGerarCsv:
    def test_separador_padrao_ponto_virgula(self):
        csv_content = gerar_csv(_pontos_exemplo(), _projeto_exemplo())
        assert ";" in csv_content

    def test_separador_virgula(self):
        csv_content = gerar_csv(_pontos_exemplo(), _projeto_exemplo(), separador=",")
        linhas = csv_content.strip().split("\n")
        assert len(linhas) >= 2
        assert "," in linhas[0]

    def test_contem_dados_dos_pontos(self):
        csv_content = gerar_csv(_pontos_exemplo(), _projeto_exemplo())
        assert "P01" in csv_content
        assert "P02" in csv_content
        assert "7395200" in csv_content
