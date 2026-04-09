# GeoAdmin Pro - Lista Mestre de Telas

## Objetivo

Este documento organiza a estrutura de telas do `GeoAdmin Pro` em um mapa mais completo de produto.

Ele responde a quatro perguntas:

- quais telas formam o nucleo do sistema
- quais telas operacionais ainda precisam ser refinadas
- quais telas documentais sao indispensaveis para o fluxo real
- quais telas ficam para fase futura

Importante:

- esta lista nao e apenas uma lista de rotas
- ela representa o modelo de produto que queremos construir
- uma parte das telas ja existe no app atual
- outra parte ainda esta em prototipo e precisa ser desenhada melhor antes da implementacao

## Legenda de status

- `implementada`: ja existe no app atual
- `parcial`: existe, mas ainda nao representa bem o modelo final
- `prototipo`: desenhada no pack HTML, ainda sem implementacao final
- `planejada`: identificada como necessaria, mas ainda nao prototipada
- `futura`: importante, mas fora da rodada imediata

## 1. Telas Nucleo

Estas telas definem a espinha do produto.

| Tela | Papel no produto | Status | Prioridade |
|---|---|---|---|
| `Central de Projetos` | Entrada operacional do escritorio com fila, filtros, risco e proximos passos | `prototipo` | `altissima` |
| `Novo Projeto` | Criacao do projeto, participantes iniciais e base cartografica | `implementada` | `altissima` |
| `Dossie do Projeto` | Painel central com visao, clientes, areas, documentos, protocolos e exportacao | `prototipo` | `altissima` |
| `Cliente e Representacao` | Cadastro de pessoas, papeis, representantes, magic links e status documental | `prototipo` | `altissima` |
| `Documentos e Protocolos` | Esteira documental, checklist, recibos, protocolos e dossie final | `prototipo` | `altissima` |
| `Exportacao Tecnica` | Saidas para `JSON`, `DXF`, `ODT`, `PDF`, `FreeCAD` e manifesto | `prototipo` | `altissima` |

## 2. Telas Tecnicas e Cartograficas

Estas telas representam o coracao tecnico do trabalho geoespacial.

| Tela | Papel no produto | Status | Prioridade |
|---|---|---|---|
| `Workspace Geoespacial` | Ambiente unico com `CAD`, `Satelite`, camadas, comparacao e edicao de geometria | `prototipo` | `altissima` |
| `Confrontacoes` | Revisao, confirmacao, descarte e geracao de cartas | `prototipo` | `alta` |
| `Importacao de Areas e Lotes` | Entrada de arquivos, loteamento, validacao e distribuicao de dados por area | `planejada` | `alta` |
| `Painel de Versoes de Perimetro` | Historico das versoes do perimetro tecnico e restauracao | `planejada` | `media` |
| `Comparador Geometrico` | Comparar perimetro tecnico com croqui do cliente, CAR ou camada externa | `planejada` | `media` |

## 3. Telas Documentais

Estas telas aproximam o produto do dossie fundiario real.

| Tela | Papel no produto | Status | Prioridade |
|---|---|---|---|
| `Checklist Documental do Projeto` | Mostrar o que falta, o que venceu, o que esta revisado e o que esta pronto | `prototipo` | `alta` |
| `Gerador de Documentos` | Emitir memoriais, declaracoes, procuracoes, requerimentos e pacotes | `prototipo` | `alta` |
| `Detalhe do Documento` | Ver metadados, versao, origem, historico e arquivo final | `planejada` | `alta` |
| `Recibos e Protocolos` | Guardar numero, orgao, data, comprovante e relacao com o projeto | `prototipo` | `alta` |
| `Pacote Final / Dossie ZIP` | Consolidar entrega final por projeto | `planejada` | `media` |
| `Timeline Documental` | Historico de emissoes, revisoes e envios | `planejada` | `media` |

## 4. Telas de Relacionamento com Cliente

Estas telas organizam a comunicacao e a coleta de dados externos.

| Tela | Papel no produto | Status | Prioridade |
|---|---|---|---|
| `Lista de Clientes` | Busca, filtro e leitura documental do cliente | `implementada` | `alta` |
| `Detalhe do Cliente` | Hub de cadastro, confrontantes, referencia geometrica e projetos vinculados | `implementada` | `alta` |
| `Formulario Publico por Magic Link` | Coleta externa em etapas com dados pessoais, imovel, anexos e observacoes | `prototipo` | `altissima` |
| `Controle de Magic Links` | Estado, expiracao, reenvio e historico de links | `planejada` | `alta` |
| `Confrontantes e Vizinhos` | CRUD de confrontantes e situacao de resposta | `parcial` | `alta` |
| `Referencia Geometrica do Cliente` | Croqui informal, importacao por texto/arquivo e preview comparativo | `parcial` | `alta` |

## 5. Telas de Processo e Cadastros Oficiais

Estas telas deixam o produto mais alinhado ao mundo real de `ETR`, `SEAPA`, `SIGEF`, `SNCR`, `CCIR` e `CAR`.

| Tela | Papel no produto | Status | Prioridade |
|---|---|---|---|
| `Painel de Processo Administrativo` | Numero, orgao, etapa, notificacoes, pendencias e resposta | `prototipo` | `alta` |
| `Cadastros Oficiais do Imovel` | `CAR`, `CCIR`, `SNCR`, `SIGEF`, matricula, RIP/CAT e outros vinculos | `prototipo` | `alta` |
| `Resposta a Notificacao` | Montar, rastrear e protocolar resposta | `prototipo` | `alta` |
| `Registro Imobiliario` | Matricula, CNS, CNM, cartorio e dados registrais estruturados | `planejada` | `media` |
| `Painel Rural / Urbano` | Variar os campos e blocos conforme o tipo do imovel | `planejada` | `media` |

## 6. Telas de Apoio Operacional

Estas telas ajudam o escritorio no dia a dia, mesmo nao sendo o centro do produto.

| Tela | Papel no produto | Status | Prioridade |
|---|---|---|---|
| `Agenda / Proximos Passos` | Ver o que vence hoje, esta atrasado ou depende de retorno | `planejada` | `media` |
| `Historico do Projeto` | Timeline consolidada de eventos tecnicos e documentais | `planejada` | `media` |
| `Fila de Pendencias` | Agrupar projetos com bloqueios por categoria | `planejada` | `media` |
| `Painel de Sincronizacao` | Offline, pontos pendentes e erros de envio | `planejada` | `media` |
| `Centro de Alertas` | Vencimento de links, faltas documentais, conflitos e revisoes | `planejada` | `media` |

## 7. Telas Futuras

Estas telas fazem sentido, mas nao precisam entrar antes do modelo principal ficar maduro.

| Tela | Papel no produto | Status | Prioridade |
|---|---|---|---|
| `Dashboard Executivo` | Indicadores de carteira, produtividade e funil por fase | `futura` | `baixa` |
| `Viewer 3D / Terreno` | Visualizacao espacial expandida | `futura` | `baixa` |
| `Workspace FreeCAD Assistido` | Abertura orientada do pacote tecnico e retorno de status | `futura` | `baixa` |
| `Workspace LibreOffice Assistido` | Controle da esteira de emissao documental | `futura` | `baixa` |
| `Auditoria Completa` | Trilha detalhada de acao por usuario e evento | `futura` | `media` |

## 8. Proposta de Ordem de Refinamento

Se formos refinar tela por tela, esta e a ordem mais produtiva:

1. `Central de Projetos`
2. `Dossie do Projeto`
3. `Cliente e Representacao`
4. `Documentos e Protocolos`
5. `Workspace Geoespacial`
6. `Confrontacoes`
7. `Formulario Publico por Magic Link`
8. `Exportacao Tecnica`
9. `Gerador de Documentos`
10. `Painel de Processo Administrativo`

## 9. Relacao com os Prototipos Atuais

### Ja representado no pack HTML

Arquivo: `docs/PACK_TELAS_MODELO.html`

- `Central de Projetos`
- `Dossie do Projeto`
- `Workspace Geoespacial`
- `Confrontacoes`
- `Cliente e Representacao`
- `Documentos e Protocolos`
- `Exportacao Tecnica`
- `Portal do Cliente / Formulario Publico por Magic Link`
- `Gerador de Documentos`
- `Recibos e Protocolos`
- `Processo Administrativo`
- `Cadastros Oficiais do Imovel`

### Ja representado no prototipo navegavel

Arquivo: `docs/PROTOTIPO_HTML_FASE1.html`

- `Projetos`
- `Novo Projeto`
- `Painel do Projeto`
- `Cliente e Documentacao`

## 10. Observacao Final

O principal ganho desta lista e parar de pensar o produto apenas por rotas ou tabs.

O `GeoAdmin Pro` precisa ser tratado como:

- sistema de projetos
- sistema de dossie fundiario
- sistema de geometria e CAD
- sistema de coleta documental e de protocolo

Ou seja: a lista mestre de telas serve para manter o modelo de produto coerente enquanto o app evolui.
