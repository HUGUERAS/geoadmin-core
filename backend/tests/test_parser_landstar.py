"""Testes para backend/integracoes/parser_landstar.py"""

import pytest
from integracoes.parser_landstar import parse_linha, parse_arquivo, _dms_para_decimal


class TestDmsParaDecimal:
    def test_sul(self):
        assert round(_dms_para_decimal("022°39'06.09099\"S"), 6) == pytest.approx(-22.651692, abs=1e-4)

    def test_oeste(self):
        assert _dms_para_decimal("043°15'30.00000\"W") < 0

    def test_norte(self):
        assert _dms_para_decimal("10°00'00.00000\"N") > 0

    def test_formato_invalido(self):
        with pytest.raises(ValueError, match="Formato DMS"):
            _dms_para_decimal("abc")


class TestParseLinha:
    LINHA_FIXO = (
        "1,TN,7395200.123,423061.456,880.500,"
        "022°39'06.09099\"S,043°15'30.00000\"W,879.100,"
        "022°39'06.09099\"S,043°15'30.00000\"W,"
        "12,1.2,0.8,0.9,Fixo,"
        "0.005,0.004,0.008,0.006,0.010"
    )

    LINHA_BASE = (
        "M45,BASE,7395200.123,423061.456,880.500,"
        "022°39'06.09099\"S,043°15'30.00000\"W,879.100,"
        "022°39'06.09099\"S,043°15'30.00000\"W,"
        "8,2.1,1.5,1.8,Autônomo,"
        "0.010,0.012,0.015,0.016,0.020"
    )

    def test_parse_ponto_fixo(self):
        ponto = parse_linha(self.LINHA_FIXO)
        assert ponto is not None
        assert ponto.nome == "TN"
        assert ponto.codigo == "TN"
        assert ponto.norte == pytest.approx(7395200.123)
        assert ponto.este == pytest.approx(423061.456)
        assert ponto.status_gnss == "Fixo"
        assert ponto.satelites == 12
        assert ponto.pdop == pytest.approx(1.2)

    def test_parse_ponto_base(self):
        ponto = parse_linha(self.LINHA_BASE)
        assert ponto is not None
        assert ponto.nome == "M45"
        assert ponto.status_gnss == "Autônomo"

    def test_linha_vazia(self):
        assert parse_linha("") is None
        assert parse_linha("   ") is None

    def test_linha_comentario(self):
        assert parse_linha("# comentario") is None
        assert parse_linha("* header") is None

    def test_campos_insuficientes(self):
        with pytest.raises(ValueError, match="campos"):
            parse_linha("1,2,3")


class TestParseArquivo:
    def test_arquivo_valido(self):
        conteudo = (
            "M45,BASE,7395200.123,423061.456,880.500,"
            "022°39'06.09099\"S,043°15'30.00000\"W,879.100,"
            "022°39'06.09099\"S,043°15'30.00000\"W,"
            "8,2.1,1.5,1.8,Autônomo,"
            "0.010,0.012,0.015,0.016,0.020\n"
            "1,TN,7395200.123,423061.456,880.500,"
            "022°39'06.09099\"S,043°15'30.00000\"W,879.100,"
            "022°39'06.09099\"S,043°15'30.00000\"W,"
            "12,1.2,0.8,0.9,Fixo,"
            "0.005,0.004,0.008,0.006,0.010"
        )
        pontos, erros = parse_arquivo(conteudo)
        assert len(pontos) == 2
        assert len(erros) == 0
        assert pontos[0].nome == "M45"
        assert pontos[1].nome == "TN"

    def test_arquivo_com_linhas_vazias(self):
        conteudo = "\n\n# comentario\n"
        pontos, erros = parse_arquivo(conteudo)
        assert len(pontos) == 0
        assert len(erros) == 0

    def test_arquivo_com_erros(self):
        conteudo = "dado,invalido,poucos_campos\n"
        pontos, erros = parse_arquivo(conteudo)
        assert len(pontos) == 0
        assert len(erros) == 1
