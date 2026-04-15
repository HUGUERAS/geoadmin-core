"""
Contratos canonicos da V1 do GeoAdmin Pro.

Estes modelos servem como referencia para:

- payloads enriquecidos de projeto
- leituras operacionais de dashboard
- esteira documental
- portal externo do cliente
"""

from __future__ import annotations

from datetime import date, datetime
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field


class ModeloContratoV1(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


StatusProjeto = Literal["medicao", "montagem", "protocolado", "aprovado", "finalizado"]
TipoFluxoProjeto = Literal["INCRA_SIGEF", "SEAPA", "AMBOS", "SEAPA_ETR", "ETR", "SIGEF"]
TipoImovel = Literal["rural", "urbano"]
TipoGeometria = Literal["ponto", "linha", "poligono"]


class MetaContratoV1(ModeloContratoV1):
    versao: str = "1.2"
    gerado_em: datetime | None = None
    origem: str = "GeoAdmin Pro"
    observacao: str | None = None


class ProjetoResumoV1(ModeloContratoV1):
    id: str
    nome: str
    codigo: str | None = None
    status: StatusProjeto
    tipo_fluxo: TipoFluxoProjeto | str | None = None


class PessoaProjetoV1(ModeloContratoV1):
    id: str | None = None
    nome: str
    cpf_cnpj: str | None = None
    rg: str | None = None
    estado_civil: str | None = None
    profissao: str | None = None
    telefone: str | None = None
    email: str | None = None
    endereco_correspondencia: str | None = None
    papel: str


class RepresentanteProjetoV1(ModeloContratoV1):
    id: str | None = None
    nome: str
    cpf: str | None = None
    rg: str | None = None
    tipo: str
    validade: date | None = None
    poderes: list[str] = Field(default_factory=list)


class ImovelProjetoV1(ModeloContratoV1):
    tipo_imovel: TipoImovel
    nome: str | None = None
    denominacao: str | None = None
    municipio: str | None = None
    estado: str | None = None
    comarca: str | None = None
    regiao_administrativa: str | None = None
    endereco: str | None = None
    area_total_ha: float | None = None


class RegistroImobiliarioV1(ModeloContratoV1):
    matricula: str | None = None
    cnm: str | None = None
    cns: str | None = None
    cartorio: str | None = None
    comarca: str | None = None
    livro_ou_ficha: str | None = None
    data_registro: date | None = None
    municipio_cartorio: str | None = None
    uf_cartorio: str | None = None


class CadastroCarV1(ModeloContratoV1):
    codigo: str | None = None
    situacao_cadastro: str | None = None
    condicao_externa: str | None = None
    data_inscricao: date | None = None
    data_retificacao: date | None = None


class CadastroCcirV1(ModeloContratoV1):
    numero: str | None = None
    codigo_imovel_rural: str | None = None
    area_certificada_ha: float | None = None


class CadastroSncrV1(ModeloContratoV1):
    codigo_imovel: str | None = None


class CadastroSigefV1(ModeloContratoV1):
    codigo_parcela: str | None = None
    situacao: str | None = None


class IndicadoresAmbientaisV1(ModeloContratoV1):
    reserva_legal_ha: float | None = None
    app_ha: float | None = None
    area_rural_consolidada_ha: float | None = None
    passivo_reserva_legal_ha: float | None = None


class CadastrosOficiaisV1(ModeloContratoV1):
    car: CadastroCarV1 = Field(default_factory=CadastroCarV1)
    ccir: CadastroCcirV1 = Field(default_factory=CadastroCcirV1)
    sncr: CadastroSncrV1 = Field(default_factory=CadastroSncrV1)
    sigef: CadastroSigefV1 = Field(default_factory=CadastroSigefV1)
    indicadores_ambientais: IndicadoresAmbientaisV1 = Field(default_factory=IndicadoresAmbientaisV1)


class ProcessoAdministrativoV1(ModeloContratoV1):
    orgao: str
    numero_processo: str | None = None
    numero_notificacao: str | None = None
    tipo: str
    status: str
    prazo_resposta: date | None = None
    documentos_exigidos: list[str] = Field(default_factory=list)


class ResponsavelTecnicoV1(ModeloContratoV1):
    nome: str
    profissao: str | None = None
    cpf: str | None = None
    conselho: str | None = None
    registro: str | None = None
    trt_art: str | None = None
    codigo_incra: str | None = None


class SistemaCoordenadasV1(ModeloContratoV1):
    datum: str
    tipo: str
    zona: str | None = None


class VerticeProjetoV1(ModeloContratoV1):
    codigo: str
    norte: float
    este: float
    cota: float | None = None
    confrontante_id: str | None = None


class PerimetroAtivoV1(ModeloContratoV1):
    tipo: TipoGeometria = "poligono"
    area_m2: float | None = None
    area_ha: float | None = None
    perimetro_m: float | None = None
    vertices: list[VerticeProjetoV1] = Field(default_factory=list)


class CamadaCartograficaV1(ModeloContratoV1):
    tipo: str
    nome: str
    origem: str
    formato_geometria: TipoGeometria
    atributos: dict[str, Any] = Field(default_factory=dict)


class ConfrontanteV1(ModeloContratoV1):
    id: str | None = None
    nome: str
    documento: str | None = None
    lado: str | None = None
    status: str | None = None


class DocumentosProjetoV1(ModeloContratoV1):
    formulario_ok: bool = False
    documentos_requeridos: list[str] = Field(default_factory=list)


class ProtocoloProjetoV1(ModeloContratoV1):
    tipo: str
    numero: str
    origem: str
    data_evento: date | None = None
    comprovante_arquivo_id: str | None = None


class ProjetoOficialV1(ModeloContratoV1):
    meta: MetaContratoV1 = Field(default_factory=MetaContratoV1)
    projeto: ProjetoResumoV1
    proponentes: list[PessoaProjetoV1] = Field(default_factory=list)
    representantes: list[RepresentanteProjetoV1] = Field(default_factory=list)
    imovel: ImovelProjetoV1
    registro_imobiliario: RegistroImobiliarioV1 = Field(default_factory=RegistroImobiliarioV1)
    cadastros_oficiais: CadastrosOficiaisV1 = Field(default_factory=CadastrosOficiaisV1)
    processos_administrativos: list[ProcessoAdministrativoV1] = Field(default_factory=list)
    responsavel_tecnico: ResponsavelTecnicoV1 | None = None
    sistema_coordenadas: SistemaCoordenadasV1 | None = None
    perimetro_ativo: PerimetroAtivoV1 | None = None
    camadas_cartograficas: list[CamadaCartograficaV1] = Field(default_factory=list)
    confrontantes: list[ConfrontanteV1] = Field(default_factory=list)
    documentos: DocumentosProjetoV1 = Field(default_factory=DocumentosProjetoV1)
    protocolos: list[ProtocoloProjetoV1] = Field(default_factory=list)


class ResumoProjetoOperacionalV1(ModeloContratoV1):
    id: str
    nome: str
    codigo: str | None = None
    status: StatusProjeto
    tipo_fluxo: TipoFluxoProjeto | str | None = None
    orgao_principal: str | None = None
    risco: Literal["baixo", "medio", "alto", "critico"] | None = None
    prazo_rotulo: str | None = None
    bloqueio_principal: str | None = None
    proximo_passo: str | None = None
    pronto_para_emitir: bool = False
    aguardando_cliente: bool = False
    possui_notificacao_aberta: bool = False
    status_geometrico: Literal["sem_geometria", "referencia_recebida", "em_revisao", "divergente", "pronto_para_documento", "aprovado"] = "sem_geometria"


class DocumentoPainelV1(ModeloContratoV1):
    id: str
    nome: str
    tipo: str
    status: str
    origem: str | None = None
    formato: str | None = None
    atualizado_em: datetime | None = None


class PainelDocumentalProjetoV1(ModeloContratoV1):
    projeto_id: str
    checklist_documental: dict[str, bool] = Field(default_factory=dict)
    documentos: list[DocumentoPainelV1] = Field(default_factory=list)
    protocolos: list[ProtocoloProjetoV1] = Field(default_factory=list)
    pendencias: list[str] = Field(default_factory=list)
    pronto_para_pacote_final: bool = False


class PendenciaPortalClienteV1(ModeloContratoV1):
    id: str
    titulo: str
    descricao: str | None = None
    obrigatoria: bool = True
    status: Literal["pendente", "enviado", "revisao", "concluido"] = "pendente"


class ArquivoPortalClienteV1(ModeloContratoV1):
    id: str
    nome: str
    tipo: str | None = None
    tamanho_bytes: int | None = None
    enviado_em: datetime | None = None


class EstadoPortalClienteV1(ModeloContratoV1):
    token_id: str
    projeto_id: str
    projeto_nome: str
    participante_nome: str | None = None
    expira_em: datetime | None = None
    etapa_atual: str | None = None
    progresso_atual: int = 0
    progresso_total: int = 0
    pendencias: list[PendenciaPortalClienteV1] = Field(default_factory=list)
    arquivos_recebidos: list[ArquivoPortalClienteV1] = Field(default_factory=list)
    ajuda_contato: str | None = None
