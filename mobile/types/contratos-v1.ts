/**
 * Contratos canonicos da V1 do GeoAdmin Pro.
 *
 * Estes tipos espelham os schemas Pydantic do backend para:
 *
 * - leituras operacionais do escritorio
 * - dossie do projeto
 * - esteira documental
 * - portal externo do cliente
 */

export type StatusProjeto =
  | 'medicao'
  | 'montagem'
  | 'protocolado'
  | 'aprovado'
  | 'finalizado'

export type TipoFluxoProjeto =
  | 'INCRA_SIGEF'
  | 'SEAPA'
  | 'AMBOS'
  | 'SEAPA_ETR'
  | 'ETR'
  | 'SIGEF'

export type TipoImovel = 'rural' | 'urbano'
export type TipoGeometria = 'ponto' | 'linha' | 'poligono'
export type NivelRisco = 'baixo' | 'medio' | 'alto' | 'critico'
export type StatusPendenciaPortal = 'pendente' | 'enviado' | 'revisao' | 'concluido'

export interface MetaContratoV1 {
  versao: string
  gerado_em?: string | null
  origem: string
  observacao?: string | null
}

export interface ProjetoResumoV1 {
  id: string
  nome: string
  codigo?: string | null
  status: StatusProjeto
  tipo_fluxo?: TipoFluxoProjeto | string | null
}

export interface PessoaProjetoV1 {
  id?: string | null
  nome: string
  cpf_cnpj?: string | null
  rg?: string | null
  estado_civil?: string | null
  profissao?: string | null
  telefone?: string | null
  email?: string | null
  endereco_correspondencia?: string | null
  papel: string
}

export interface RepresentanteProjetoV1 {
  id?: string | null
  nome: string
  cpf?: string | null
  rg?: string | null
  tipo: string
  validade?: string | null
  poderes: string[]
}

export interface ImovelProjetoV1 {
  tipo_imovel: TipoImovel
  nome?: string | null
  denominacao?: string | null
  municipio?: string | null
  estado?: string | null
  comarca?: string | null
  regiao_administrativa?: string | null
  endereco?: string | null
  area_total_ha?: number | null
}

export interface RegistroImobiliarioV1 {
  matricula?: string | null
  cnm?: string | null
  cns?: string | null
  cartorio?: string | null
  comarca?: string | null
  livro_ou_ficha?: string | null
  data_registro?: string | null
  municipio_cartorio?: string | null
  uf_cartorio?: string | null
}

export interface CadastroCarV1 {
  codigo?: string | null
  situacao_cadastro?: string | null
  condicao_externa?: string | null
  data_inscricao?: string | null
  data_retificacao?: string | null
}

export interface CadastroCcirV1 {
  numero?: string | null
  codigo_imovel_rural?: string | null
  area_certificada_ha?: number | null
}

export interface CadastroSncrV1 {
  codigo_imovel?: string | null
}

export interface CadastroSigefV1 {
  codigo_parcela?: string | null
  situacao?: string | null
}

export interface IndicadoresAmbientaisV1 {
  reserva_legal_ha?: number | null
  app_ha?: number | null
  area_rural_consolidada_ha?: number | null
  passivo_reserva_legal_ha?: number | null
}

export interface CadastrosOficiaisV1 {
  car: CadastroCarV1
  ccir: CadastroCcirV1
  sncr: CadastroSncrV1
  sigef: CadastroSigefV1
  indicadores_ambientais: IndicadoresAmbientaisV1
}

export interface ProcessoAdministrativoV1 {
  orgao: string
  numero_processo?: string | null
  numero_notificacao?: string | null
  tipo: string
  status: string
  prazo_resposta?: string | null
  documentos_exigidos: string[]
}

export interface ResponsavelTecnicoV1 {
  nome: string
  profissao?: string | null
  cpf?: string | null
  conselho?: string | null
  registro?: string | null
  trt_art?: string | null
  codigo_incra?: string | null
}

export interface SistemaCoordenadasV1 {
  datum: string
  tipo: string
  zona?: string | null
}

export interface VerticeProjetoV1 {
  codigo: string
  norte: number
  este: number
  cota?: number | null
}

export interface PerimetroAtivoV1 {
  tipo: TipoGeometria
  area_m2?: number | null
  area_ha?: number | null
  perimetro_m?: number | null
  vertices: VerticeProjetoV1[]
}

export interface CamadaCartograficaV1 {
  tipo: string
  nome: string
  origem: string
  formato_geometria: TipoGeometria
  atributos: Record<string, unknown>
}

export interface ConfrontanteV1 {
  id?: string | null
  nome: string
  documento?: string | null
  lado?: string | null
  status?: string | null
}

export interface DocumentosProjetoV1 {
  formulario_ok: boolean
  documentos_requeridos: string[]
}

export interface ProtocoloProjetoV1 {
  tipo: string
  numero: string
  origem: string
  data_evento?: string | null
  comprovante_arquivo_id?: string | null
}

export interface ProjetoOficialV1 {
  meta: MetaContratoV1
  projeto: ProjetoResumoV1
  proponentes: PessoaProjetoV1[]
  representantes: RepresentanteProjetoV1[]
  imovel: ImovelProjetoV1
  registro_imobiliario: RegistroImobiliarioV1
  cadastros_oficiais: CadastrosOficiaisV1
  processos_administrativos: ProcessoAdministrativoV1[]
  responsavel_tecnico?: ResponsavelTecnicoV1 | null
  sistema_coordenadas?: SistemaCoordenadasV1 | null
  perimetro_ativo?: PerimetroAtivoV1 | null
  camadas_cartograficas: CamadaCartograficaV1[]
  confrontantes: ConfrontanteV1[]
  documentos: DocumentosProjetoV1
  protocolos: ProtocoloProjetoV1[]
}

export interface ResumoProjetoOperacionalV1 {
  id: string
  nome: string
  codigo?: string | null
  status: StatusProjeto
  tipo_fluxo?: TipoFluxoProjeto | string | null
  orgao_principal?: string | null
  risco?: NivelRisco | null
  prazo_rotulo?: string | null
  bloqueio_principal?: string | null
  proximo_passo?: string | null
  pronto_para_emitir: boolean
  aguardando_cliente: boolean
  possui_notificacao_aberta: boolean
}

export interface DocumentoPainelV1 {
  id: string
  nome: string
  tipo: string
  status: string
  origem?: string | null
  formato?: string | null
  atualizado_em?: string | null
}

export interface PainelDocumentalProjetoV1 {
  projeto_id: string
  checklist_documental: Record<string, boolean>
  documentos: DocumentoPainelV1[]
  protocolos: ProtocoloProjetoV1[]
  pendencias: string[]
  pronto_para_pacote_final: boolean
}

export interface PendenciaPortalClienteV1 {
  id: string
  titulo: string
  descricao?: string | null
  obrigatoria: boolean
  status: StatusPendenciaPortal
}

export interface ArquivoPortalClienteV1 {
  id: string
  nome: string
  tipo?: string | null
  tamanho_bytes?: number | null
  enviado_em?: string | null
}

export interface EstadoPortalClienteV1 {
  token_id: string
  projeto_id: string
  projeto_nome: string
  participante_nome?: string | null
  expira_em?: string | null
  etapa_atual?: string | null
  progresso_atual: number
  progresso_total: number
  pendencias: PendenciaPortalClienteV1[]
  arquivos_recebidos: ArquivoPortalClienteV1[]
  ajuda_contato?: string | null
}

export interface ResumoLotesProjetoApiV1 {
  total?: number
  sem_participante?: number
  com_geometria?: number
  prontos?: number
  pendentes?: number
  por_status_operacional?: Record<string, number>
  por_status_documental?: Record<string, number>
}

export interface CheckItemDocumentalApiV1 {
  id: string
  label: string
  descricao: string
  ok: boolean
}

export interface ChecklistDocumentalApiV1 {
  itens?: CheckItemDocumentalApiV1[]
}

export interface FormularioProjetoApiV1 {
  formulario_ok?: boolean
  formulario_em?: string | null
  magic_link_expira?: string | null
}

export interface ParticipanteProjetoApiV1 extends PessoaProjetoV1 {
  cliente_id?: string | null
  principal?: boolean
  recebe_magic_link?: boolean
  formulario_ok?: boolean
  area_id?: string | null
}

export interface ResumoAtivoAreaApiV1 {
  area_ha?: number | null
  vertices_total?: number | null
}

export interface AreaProjetoApiV1 {
  id: string
  nome?: string | null
  codigo_lote?: string | null
  quadra?: string | null
  setor?: string | null
  proprietario_nome?: string | null
  cliente_id?: string | null
  status_geometria?: string | null
  status_operacional?: string | null
  status_documental?: string | null
  municipio?: string | null
  matricula?: string | null
  anexos?: unknown[]
  participantes_area?: ParticipanteProjetoApiV1[]
  participantes?: ParticipanteProjetoApiV1[]
  area_clientes?: ParticipanteProjetoApiV1[]
  resumo_ativo?: ResumoAtivoAreaApiV1 | null
}

export interface ConfrontacaoProjetoApiV1 {
  id: string
  tipo?: string | null
  status_revisao?: string | null
  status?: string | null
  tipo_relacao?: string | null
  contato_m?: number | null
  area_intersecao_ha?: number | null
  observacao?: string | null
  area_a?: { nome?: string | null }
  area_b?: { nome?: string | null }
}

export interface ArquivoCartograficoApiV1 {
  id: string
  nome_original?: string | null
  nome_arquivo?: string | null
  classificacao?: string | null
  origem?: string | null
  base_oficial?: boolean
}

export interface EventoAuditoriaApiV1 {
  id?: string | number
  tipo_evento?: string | null
  criado_em?: string | null
  arquivo_id?: string | null
  observacao?: string | null
}

export interface EventoMagicLinkApiV1 {
  id?: string | number
  tipo_evento?: string | null
  criado_em?: string | null
  canal?: string | null
  projeto_cliente_id?: string | null
}

export interface ArquivosResumoProjetoApiV1 {
  total?: number
  base_oficial_total?: number
  eventos_total?: number
  [key: string]: unknown
}

export interface MagicLinksResumoProjetoApiV1 {
  total_eventos?: number
  consumidos?: number
  [key: string]: unknown
}

export interface ConfrontacoesResumoProjetoApiV1 {
  total?: number
  confirmadas?: number
  pendentes?: number
  externas?: number
  [key: string]: unknown
}

export interface DocumentosResumoProjetoApiV1 {
  total?: number
  [key: string]: unknown
}

export interface ProntidaoPilotoApiV1 {
  status?: string | null
  formularios_recebidos?: number
  base_oficial_total?: number
  confrontacoes_confirmadas?: number
  percentual?: number
  [key: string]: unknown
}

export interface ResumoGeoProjetoApiV1 {
  areas_total?: number
  confrontacoes_total?: number
  confrontantes_total?: number
  esbocos_total?: number
  geometrias_finais_total?: number
  participantes_total?: number
  arquivos_total?: number
}

export interface ProjetoListaItemApiV1 {
  id: string
  nome?: string | null
  projeto_nome?: string | null
  cliente_nome?: string | null
  status: string
  total_pontos?: number
  municipio?: string | null
  numero_job?: string | null
  resumo_lotes?: ResumoLotesProjetoApiV1
  areas_total?: number
  lotes_prontos?: number
  lotes_pendentes?: number
  resumo_operacional_v1?: ResumoProjetoOperacionalV1 | null
  [key: string]: unknown
}

export interface ListaProjetosResponseV1 {
  total: number
  projetos: ProjetoListaItemApiV1[]
}

export interface ProjetoDetalheApiV1 {
  id: string
  nome?: string | null
  projeto_nome?: string | null
  status: string
  municipio?: string | null
  comarca?: string | null
  matricula?: string | null
  numero_job?: string | null
  zona_utm?: string | null
  cliente_id?: string | null
  cliente_nome?: string | null
  total_pontos?: number
  resumo_lotes?: ResumoLotesProjetoApiV1
  areas?: AreaProjetoApiV1[]
  confrontacoes?: ConfrontacaoProjetoApiV1[]
  documentos?: DocumentoPainelV1[]
  formulario?: FormularioProjetoApiV1
  checklist_documental?: ChecklistDocumentalApiV1
  cliente?: ParticipanteProjetoApiV1 | null
  clientes?: ParticipanteProjetoApiV1[]
  participantes?: ParticipanteProjetoApiV1[]
  resumo_geo?: ResumoGeoProjetoApiV1
  arquivos_cartograficos?: ArquivoCartograficoApiV1[]
  arquivos_eventos?: EventoAuditoriaApiV1[]
  arquivos_resumo?: ArquivosResumoProjetoApiV1
  magic_links_historico?: EventoMagicLinkApiV1[]
  magic_links_resumo?: MagicLinksResumoProjetoApiV1
  confrontacoes_resumo?: ConfrontacoesResumoProjetoApiV1
  prontidao_piloto?: ProntidaoPilotoApiV1
  documentos_resumo?: DocumentosResumoProjetoApiV1
  perimetro_ativo?: { tipo?: string | null; vertices?: { lon: number; lat: number; nome?: string | null }[] } | null
  projeto_oficial_v1?: ProjetoOficialV1 | null
  painel_documental_v1?: PainelDocumentalProjetoV1 | null
  resumo_operacional_v1?: ResumoProjetoOperacionalV1 | null
  [key: string]: unknown
}

export interface DocumentosProjetoResponseV1 {
  projeto_id: string
  total: number
  resumo: Record<string, unknown>
  documentos: DocumentoPainelV1[]
  pendencias: string[]
  pronto_para_pacote_final: boolean
  checklist_documental: Record<string, boolean>
}

export interface ProtocolosProjetoResponseV1 {
  projeto_id: string
  total: number
  protocolos: ProtocoloProjetoV1[]
  pendencias: string[]
  pronto_para_pacote_final: boolean
}
