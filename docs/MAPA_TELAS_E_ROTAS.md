# GeoAdmin Pro - Mapa de Telas e Rotas

## Objetivo

Este documento descreve:

- quais paginas existem hoje no app
- qual arquivo implementa cada tela
- quais botoes e acoes o usuario aciona em cada fluxo
- quais rotas do backend sao chamadas por essas acoes
- onde a logica ainda e local, offline ou apenas de navegacao

Baseado no estado atual do codigo em `mobile/` e `backend/`.

## Visao geral

### Navegacao principal do app

| Rota mobile | Arquivo | Papel |
|---|---|---|
| `/` | `mobile/app/index.tsx` | Redireciona para `/(tabs)/projeto` |
| `/(tabs)/projeto` | `mobile/app/(tabs)/projeto/index.tsx` | Lista de projetos |
| `/(tabs)/projeto/novo` | `mobile/app/(tabs)/projeto/novo.tsx` | Criacao de projeto |
| `/(tabs)/projeto/[id]` | `mobile/app/(tabs)/projeto/[id].tsx` | Painel operacional do projeto |
| `/(tabs)/mapa` | `mobile/app/(tabs)/mapa/index.tsx` | Recupera ultimo projeto aberto no CAD |
| `/(tabs)/mapa/[id]` | `mobile/app/(tabs)/mapa/[id].tsx` | Tela de mapa/CAD e edicao de perimetro |
| `/(tabs)/calculos` | `mobile/app/(tabs)/calculos/index.tsx` | Hub de ferramentas tecnicas |
| `/(tabs)/calculos/*` | `mobile/app/(tabs)/calculos/*.tsx` | Ferramentas de calculo |
| `/(tabs)/clientes` | `mobile/app/(tabs)/clientes/index.tsx` | Lista de clientes e documentacao |
| `/(tabs)/clientes/[id]` | `mobile/app/(tabs)/clientes/[id].tsx` | Hub documental do cliente |
| `/bluetooth` | `mobile/app/bluetooth.tsx` | Coleta GNSS Bluetooth no Android |
| `/bluetooth` na web | `mobile/app/bluetooth.web.tsx` | Stub informativo para navegador |

### Routers ativos no backend

Registrados em `backend/main.py`:

- `projetos_router`
- `clientes_router`
- `exportacao_router`
- `metrica_router`
- `docs_router`
- `pontos_router`
- `perimetros_router`
- `geo_router`
- `importar_router`
- `catalogo_router`

Rotas especiais:

- `GET /health` e o healthcheck da API
- a trilha de `RAG Topografia` foi removida do core e fica fora do escopo deste repositório

## Telas e fluxos

## Projetos

### `/(tabs)/projeto`

Arquivo: `mobile/app/(tabs)/projeto/index.tsx`

Objetivo:

- listar projetos
- permitir busca e filtro por status
- abrir detalhe do projeto
- iniciar criacao de novo projeto

Carregamento:

| Evento | Logica | Backend |
|---|---|---|
| Entrar na tela | Tenta carregar projetos da API e salva cache local | `GET /projetos` |
| Falha de rede | Usa cache local em SQLite | sem backend |
| Pull to refresh | Reexecuta carregamento | `GET /projetos` |
| Botao `Tentar novamente` | Reexecuta carregamento | `GET /projetos` |

Acoes visiveis:

| Acao na UI | Logica | Backend |
|---|---|---|
| Card do projeto | Navega para o detalhe | sem backend |
| Botao `Novo` | Navega para criacao | sem backend |
| Chips de status | Filtram a lista em memoria | sem backend |
| Campo de busca | Filtra nome e cliente em memoria | sem backend |

### `/(tabs)/projeto/novo`

Arquivo: `mobile/app/(tabs)/projeto/novo.tsx`

Objetivo:

- abrir um novo projeto
- cadastrar participantes
- opcionalmente enviar base cartografica inicial

Acoes principais:

| Acao na UI | Logica | Backend |
|---|---|---|
| `+ Adicionar outro cliente` | Adiciona participante no estado local da tela | sem backend |
| Trocar `status inicial` | Atualiza form local | sem backend |
| Trocar `papel no projeto` | Atualiza participante local | sem backend |
| Toggle `Gerar magic link para este participante` | Atualiza participante local | sem backend |
| `Remover participante` | Remove participante da lista local | sem backend |
| `+ Adicionar arquivo` | Abre seletor de arquivo e monta lista local de anexos | sem backend |
| `Remover` arquivo | Remove arquivo da lista local | sem backend |
| Chips `Origem` e `Classificacao` do arquivo | Atualizam metadados locais do anexo | sem backend |
| `Criar projeto` | Cria projeto, envia participantes e depois tenta subir arquivos um a um | `POST /projetos` seguido de `POST /projetos/{id}/arquivos` |

Observacao:

- a tela cria o projeto primeiro e so depois tenta subir os arquivos de base cartografica
- se algum arquivo falhar, o projeto continua criado e a tela apenas alerta o usuario

### `/(tabs)/projeto/[id]`

Arquivo: `mobile/app/(tabs)/projeto/[id].tsx`

Objetivo:

- ser o painel operacional do projeto
- concentrar visao, areas, participantes, confrontacoes, documentos e base cartografica

Carregamento e apoio offline:

| Evento | Logica | Backend |
|---|---|---|
| Abrir tela | Busca detalhe do projeto e salva cache local | `GET /projetos/{id}` |
| Falha de rede | Usa cache local do projeto | sem backend |
| Badge de sincronizacao | Conta pendencias e erros locais | sem backend |
| Sincronizar pontos | Envia pontos offline do SQLite para o backend | `POST /pontos/sync` |

Cards de atalho do topo:

| Botao | Logica | Backend |
|---|---|---|
| `Ver no mapa` | Salva contexto do ultimo projeto no mapa e navega para CAD | sem backend |
| `Copiar link do cliente` | Gera magic link e copia mensagem para clipboard | `POST /projetos/{id}/magic-link` |
| `Preparar para Metrica` | Tenta abrir URL do pacote para download | intencao: `POST /projetos/{id}/metrica/preparar` |
| `Manifesto Metrica` | Abre manifesto do pacote no navegador | `GET /projetos/{id}/metrica/manifesto` |

Secao `Visao`:

| Acao | Logica | Backend |
|---|---|---|
| `Importar lotes` | Seleciona arquivo, envia `FormData`, atualiza projeto | `POST /projetos/{id}/areas/importar-arquivo` |
| `Gerar links em lote` | Gera magic links para lotes elegiveis e recarrega projeto | `POST /projetos/{id}/magic-links/lote` |

Secao `Clientes`:

| Acao | Logica | Backend |
|---|---|---|
| `Abrir cliente & documentacao` | Navega para o detalhe do cliente vinculado | sem backend |

Secao `Confrontacoes`:

| Acao | Logica | Backend |
|---|---|---|
| `Gerar cartas ZIP` | Abre pacote de cartas no navegador | `GET /projetos/{id}/confrontacoes/cartas` |
| `Confirmar` confrontacao | Registra revisao e recarrega projeto | `POST /projetos/{id}/confrontacoes/revisar` |
| `Descartar` confrontacao | Registra revisao e recarrega projeto | `POST /projetos/{id}/confrontacoes/revisar` |

Secao `Documentos`:

| Acao | Logica | Backend |
|---|---|---|
| `Gerar documentos GPRF` | Dispara a geracao do pacote documental | `POST /projetos/{id}/gerar-documentos` |
| `Migrar legado` | Migra arquivos antigos para o storage e recarrega projeto | `POST /projetos/{id}/arquivos/migrar-legado` |
| `Promover` arquivo | Promove arquivo da bandeja para base oficial | `POST /projetos/{id}/arquivos/{arquivo_id}/promover` |

## Clientes

### `/(tabs)/clientes`

Arquivo: `mobile/app/(tabs)/clientes/index.tsx`

Objetivo:

- listar clientes com status documental
- filtrar e localizar rapidamente quem precisa de acao

Carregamento:

| Evento | Logica | Backend |
|---|---|---|
| Entrar na tela | Carrega lista de clientes | `GET /clientes` |
| Pull to refresh | Recarrega a lista | `GET /clientes` |
| Botao `Tentar novamente` | Recarrega a lista | `GET /clientes` |

Acoes:

| Acao na UI | Logica | Backend |
|---|---|---|
| Card do cliente | Navega para o detalhe | sem backend |
| Busca por nome/telefone/email/CPF | Filtro local em memoria | sem backend |
| Chips de filtro | Filtro local por status documental | sem backend |
| `Limpar filtros` | Limpa estado local da tela | sem backend |

### `/(tabs)/clientes/[id]`

Arquivo: `mobile/app/(tabs)/clientes/[id].tsx`

Objetivo:

- centralizar cadastro, projetos vinculados, confrontantes, referencia geometrica e timeline do cliente

Carregamento:

| Evento | Logica | Backend |
|---|---|---|
| Abrir tela | Carrega detalhe completo do cliente | `GET /clientes/{id}` |

Bloco `Cadastro do cliente`:

| Acao | Logica | Backend |
|---|---|---|
| `Salvar cadastro` | Atualiza dados cadastrais e recarrega a tela | `PATCH /clientes/{id}` |

Bloco `Projetos vinculados`:

| Acao | Logica | Backend |
|---|---|---|
| `Ver no mapa` | Salva ultimo projeto no contexto local e navega para CAD | sem backend |
| `Abrir projeto` | Navega para o detalhe do projeto | sem backend |
| `Reenviar magic link` ou `Renovar link` | Gera novo magic link e tenta abrir WhatsApp | `POST /projetos/{projeto_id}/magic-link` |

Bloco `Confrontantes e vizinhos`:

| Acao | Logica | Backend |
|---|---|---|
| `Adicionar confrontante` | Cria confrontante e recarrega tela | `POST /clientes/{id}/confrontantes` |
| `Atualizar confrontante` | Atualiza confrontante e recarrega tela | `PATCH /clientes/{id}/confrontantes/{confrontante_id}` |
| `Excluir` confrontante | Remove confrontante e recarrega tela | `DELETE /clientes/{id}/confrontantes/{confrontante_id}` |
| `Cancelar edicao` | Limpa formulario local | sem backend |

Bloco `Area de referencia do cliente`:

| Acao | Logica | Backend |
|---|---|---|
| `Salvar referencia manual` | Converte texto em vertices e salva referencia | `POST /clientes/{id}/geometria-referencia/manual` |
| `Importar texto` | Envia conteudo GeoJSON/KML/CSV/TXT colado na tela | `POST /clientes/{id}/geometria-referencia/importar-texto` |
| `Selecionar arquivo` | Envia arquivo ou ZIP suportado | `POST /clientes/{id}/geometria-referencia/importar` |
| `Excluir referencia salva` | Remove referencia do cliente | `DELETE /clientes/{id}/geometria-referencia` |

## Mapa / CAD

### `/(tabs)/mapa`

Arquivo: `mobile/app/(tabs)/mapa/index.tsx`

Objetivo:

- recuperar o ultimo projeto aberto no mapa
- servir como porta de entrada para o CAD

Fluxo:

| Evento | Logica | Backend |
|---|---|---|
| Abrir tela | Lê `ultimoProjetoMapa` do banco local e redireciona | sem backend |
| Sem projeto recente | Exibe orientacao para abrir um projeto ou cliente e tocar em `Ver no mapa` | sem backend |

### `/(tabs)/mapa/[id]`

Arquivo: `mobile/app/(tabs)/mapa/[id].tsx`

Objetivo:

- visualizar projeto em satelite ou CAD
- editar o perimetro ativo
- executar ferramentas em contexto do perimetro

Carregamento:

| Evento | Logica | Backend |
|---|---|---|
| Abrir tela | Carrega projeto, pontos e perimetro ativo | `GET /projetos/{id}` |

Toolbar normal:

| Acao | Logica | Backend |
|---|---|---|
| Alternar `Satelite` / `CAD` | Troca apenas o modo de visualizacao | sem backend |
| `Editar` | Entra em modo de edicao e tenta registrar o perimetro original | `POST /perimetros/` |
| Botao de `camadas` | Abre painel local de exibicao | sem backend |

Toolbar de edicao:

| Acao | Logica | Backend |
|---|---|---|
| Ferramentas `mover`, `+`, `x` | Alteram apenas o estado da edicao | sem backend |
| `Desfazer` | Usa historico local da edicao | sem backend |
| `⚙` | Abre seletor de ferramentas em contexto | sem backend |
| `Cancelar` | Descarta alteracoes locais da sessao | sem backend |
| `Salvar` | Persiste o perimetro editado como nova versao | `POST /perimetros/` |

Painel de camadas:

| Acao | Logica | Backend |
|---|---|---|
| Alternar `Pontos visiveis`, `Poligono`, `Rotulos` | Controla somente a exibicao local | sem backend |

Ferramentas em contexto do mapa:

| Ferramenta | Logica principal | Backend |
|---|---|---|
| `area` | Calcula area do poligono em contexto | local no mapa |
| `inverso` | Calcula distancia e azimute entre vertices selecionados | local no mapa |
| `irradiacao` | Gera ponto por azimute e distancia e permite inserir no perimetro | local no mapa |
| `intersecao` | Gera ponto de intersecao e permite inserir no perimetro | local no mapa |
| `distpl` | Distancia ponto-linha em vertices selecionados | local no mapa |
| `deflexao` | Azimute de saida com base em angulo e lado | local no mapa |
| `mediaPts` | Calcula ponto medio de vertices selecionados e permite inserir | local no mapa |
| `conversao` | Converte coordenadas a partir da geometria em uso | local no mapa |
| `rotacao` | Calcula rotacao e pode aplicar ao perimetro | local no mapa |
| `subdivisao` | Calcula ponto de corte e pode inserir no perimetro | local no mapa |

Observacao:

- a tela de mapa faz bastante logica geometrica local
- o backend entra aqui principalmente para carregar o projeto e salvar versoes de perimetro

## Calculos

### `/(tabs)/calculos`

Arquivo: `mobile/app/(tabs)/calculos/index.tsx`

Objetivo:

- servir como hub tecnico
- abrir ferramentas isoladas ou em contexto do CAD

Carregamento:

| Evento | Logica | Backend |
|---|---|---|
| Abrir tela | Recupera o ultimo projeto ativo do mapa; tenta complementar com detalhe remoto | `GET /projetos/{id}` quando ha projeto ativo |

Acoes:

| Acao | Logica | Backend |
|---|---|---|
| `Abrir CAD` | Navega para `/(tabs)/mapa/[id]` | sem backend |
| `Abrir projeto` | Navega para `/(tabs)/projeto/[id]` | sem backend |
| `Escolher projeto` | Navega para lista de projetos | sem backend |
| Botao de ferramenta com projeto ativo e `toolMapa` | Abre a ferramenta direto dentro do mapa/CAD | sem backend |
| Botao de ferramenta sem projeto ativo | Abre a tela isolada da ferramenta | sem backend |

### Ferramentas de calculo em tela propria

| Rota | Arquivo | Botao principal | Tipo de logica | Backend |
|---|---|---|---|---|
| `/calculos/inverso` | `inverso.tsx` | `Calcular` | calculo remoto | `POST /geo/inverso` |
| `/calculos/area` | `area.tsx` | `Calcular` | calculo remoto | `POST /geo/area` |
| `/calculos/conversao` | `conversao.tsx` | `Calcular` | calculo remoto | `POST /geo/converter/utm-geo` e `POST /geo/converter/geo-utm` |
| `/calculos/deflexao` | `deflexao.tsx` | `Calcular` | calculo local | sem backend |
| `/calculos/intersecao` | `intersecao.tsx` | `Calcular` | calculo remoto | `POST /geo/intersecao` |
| `/calculos/distancia` | `distancia.tsx` | `Calcular` | calculo remoto | `POST /geo/distancia-ponto-linha` |
| `/calculos/rotacao` | `rotacao.tsx` | `Calcular` | calculo remoto | `POST /geo/rotacao` |
| `/calculos/media` | `media.tsx` | `Calcular` | calculo local | sem backend |
| `/calculos/irradiacao` | `irradiacao.tsx` | `Calcular` | calculo local | sem backend |
| `/calculos/subdivisao` | `subdivisao.tsx` | `Calcular` | calculo remoto | `POST /geo/subdivisao` |
| `/calculos/pontos` | `pontos.tsx` | `Adicionar`, `Copiar`, `Limpar` | bloco de notas local | sem backend |
| `/calculos/linha` | `linha.tsx` | `Calcular` | calculo local | sem backend |
| `/calculos/polilinha` | `polilinha.tsx` | `Calcular` | calculo local | sem backend |
| `/calculos/nomenclatura` | `nomenclatura.tsx` | `Gerar`, `Copiar` | logica local | sem backend |

Padrao comum das telas de calculo:

- `Limpar` sempre reseta o estado local da ferramenta
- `Gabarito` ou preenchimento de exemplo existe em varias telas e nao usa backend
- nas telas remotas, o erro padrao orienta verificar conexao com o backend

## Bluetooth

### `/bluetooth` no Android

Arquivo: `mobile/app/bluetooth.tsx`

Objetivo:

- conectar receptor GNSS via Bluetooth classico
- coletar ponto em campo
- salvar localmente
- opcionalmente sincronizar com o backend

Acoes:

| Acao | Logica | Backend |
|---|---|---|
| `Conectar` / `Desconectar` | Opera apenas no modulo nativo Bluetooth | sem backend |
| `COLETAR PONTO` | Abre modal para nomear o ponto | sem backend |
| `Salvar Local` | Persiste ponto no banco local do app | sem backend |
| `Salvar + Sincronizar` | Salva localmente e depois sincroniza pendencias | `POST /pontos/sync` |

### `/bluetooth` na web

Arquivo: `mobile/app/bluetooth.web.tsx`

Objetivo:

- informar que a coleta GNSS Bluetooth exige APK Android

Backend:

- nenhum

## Rotas backend hoje acionadas pelo app

### Projetos, documentos e exportacao

| Metodo | Rota | Usada por |
|---|---|---|
| `GET` | `/projetos` | lista de projetos |
| `POST` | `/projetos` | criacao de projeto |
| `GET` | `/projetos/{id}` | detalhe do projeto, CAD, contexto de calculos |
| `POST` | `/projetos/{id}/magic-link` | detalhe de projeto e detalhe de cliente |
| `POST` | `/projetos/{id}/gerar-documentos` | detalhe de projeto |
| `GET` | `/projetos/{id}/metrica/manifesto` | detalhe de projeto |
| `POST` | `/projetos/{id}/metrica/preparar` | detalhe de projeto |
| `POST` | `/projetos/{id}/arquivos` | criacao de projeto |
| `POST` | `/projetos/{id}/arquivos/{arquivo_id}/promover` | detalhe de projeto |
| `POST` | `/projetos/{id}/arquivos/migrar-legado` | detalhe de projeto |
| `POST` | `/projetos/{id}/magic-links/lote` | detalhe de projeto |
| `POST` | `/projetos/{id}/areas/importar-arquivo` | detalhe de projeto |
| `POST` | `/projetos/{id}/confrontacoes/revisar` | detalhe de projeto |
| `GET` | `/projetos/{id}/confrontacoes/cartas` | detalhe de projeto |

### Clientes

| Metodo | Rota | Usada por |
|---|---|---|
| `GET` | `/clientes` | lista de clientes |
| `GET` | `/clientes/{id}` | detalhe de cliente |
| `PATCH` | `/clientes/{id}` | detalhe de cliente |
| `POST` | `/clientes/{id}/confrontantes` | detalhe de cliente |
| `PATCH` | `/clientes/{id}/confrontantes/{confrontante_id}` | detalhe de cliente |
| `DELETE` | `/clientes/{id}/confrontantes/{confrontante_id}` | detalhe de cliente |
| `POST` | `/clientes/{id}/geometria-referencia/manual` | detalhe de cliente |
| `POST` | `/clientes/{id}/geometria-referencia/importar-texto` | detalhe de cliente |
| `POST` | `/clientes/{id}/geometria-referencia/importar` | detalhe de cliente |
| `DELETE` | `/clientes/{id}/geometria-referencia` | detalhe de cliente |

### CAD, pontos e geodesia

| Metodo | Rota | Usada por |
|---|---|---|
| `POST` | `/perimetros/` | tela de mapa/CAD |
| `POST` | `/pontos/sync` | sincronizacao offline e Bluetooth |
| `POST` | `/geo/inverso` | calculos/inverso |
| `POST` | `/geo/area` | calculos/area |
| `POST` | `/geo/converter/utm-geo` | calculos/conversao |
| `POST` | `/geo/converter/geo-utm` | calculos/conversao |
| `POST` | `/geo/intersecao` | calculos/intersecao |
| `POST` | `/geo/distancia-ponto-linha` | calculos/distancia |
| `POST` | `/geo/rotacao` | calculos/rotacao |
| `POST` | `/geo/subdivisao` | calculos/subdivisao |

## Rotas expostas no backend que ainda nao aparecem no fluxo principal do app

| Metodo | Rota | Arquivo backend | Observacao |
|---|---|---|---|
| `GET` | `/health` | `backend/main.py` | healthcheck |
| `GET` | `/projetos/{id}/clientes` | `backend/routes/projetos.py` | apoio para evolucao do painel |
| `GET` | `/projetos/{id}/arquivos` | `backend/routes/projetos.py` | dados podem vir embutidos no detalhe atual |
| `GET` | `/projetos/{id}/arquivos/exportar` | `backend/routes/projetos.py` | nao ha botao explicito hoje |
| `GET` | `/projetos/{id}/arquivos/eventos` | `backend/routes/projetos.py` | nao ha tela propria hoje |
| `GET` | `/projetos/{id}/lotes/painel` | `backend/routes/projetos.py` | painel ja e consumido indiretamente pelo detalhe |
| `POST` | `/projetos/{id}/areas/importar` | `backend/routes/projetos.py` | hoje a UI usa importacao por arquivo |
| `GET` | `/projetos/{id}/areas` | `backend/routes/projetos.py` | hoje os dados chegam pelo detalhe do projeto |
| `POST` | `/projetos/{id}/areas` | `backend/routes/projetos.py` | sem formulario dedicado no app |
| `PATCH` | `/projetos/{id}/areas/{area_id}` | `backend/routes/projetos.py` | sem edicao dedicada no app |
| `GET` | `/projetos/{id}/confrontacoes` | `backend/routes/projetos.py` | hoje consumido via detalhe do projeto |
| `GET` | `/projetos/{id}/documentos` | `backend/routes/documentos.py` | sem tela dedicada de listagem |
| `GET` | `/projetos/{id}/magic-links/eventos` | `backend/routes/documentos.py` | sem tela dedicada de historico paginado |
| `GET` | `/formulario/cliente/contexto` | `backend/routes/documentos.py` | usado pelo formulario publico, nao pelo app interno |
| `GET` | `/formulario/cliente` | `backend/routes/documentos.py` | formulario publico HTML |
| `POST` | `/formulario/cliente` | `backend/routes/documentos.py` | envio do formulario publico |
| `POST` | `/metrica/txt` | `backend/routes/metrica_simples.py` | rota simples de integracao, fora da UI principal |
| `POST` | `/importar/*` | `backend/routes/importar.py` | suporte tecnico, sem tela dedicada hoje |
| `GET` | `/catalogo/*` | `backend/routes/catalogo.py` | base para catalogos e referencias futuras |
| `POST` | `/geo/altitude/corrigir` | `backend/routes/geo.py` | ainda sem tela no app |
| `GET` | `/geo/altitude/modelos` | `backend/routes/geo.py` | ainda sem tela no app |
| `POST` | `/pontos` | `backend/routes/pontos.py` | hoje o app usa fluxo offline + sync |
| `GET` | `/pontos/{ponto_id}` | `backend/routes/pontos.py` | sem tela dedicada |
| `DELETE` | `/pontos/{ponto_id}` | `backend/routes/pontos.py` | sem tela dedicada |

## Observacoes de alinhamento

### 1. Mistura de cliente HTTP

Hoje o app usa dois estilos de acesso:

- `mobile/lib/api.ts` com timeout, parse padronizado e suporte a token
- `fetch` direto com `API_URL` em algumas telas como projeto e mapa

Impacto:

- dificulta padronizar erro, auth e CORS
- deixa parte da superficie mais dificil de manter

### 2. Mismatch no fluxo `Preparar para Metrica`

Na tela `/(tabs)/projeto/[id]`, a acao `Preparar para Metrica` tenta abrir uma URL no navegador.

Hoje o backend expoe:

- `POST /projetos/{id}/metrica/preparar`

Isso indica um desalinhamento de fluxo:

- ou a UI deveria fazer `POST` programatico e baixar o arquivo
- ou o backend deveria oferecer uma rota `GET` equivalente para download direto

### 3. O detalhe do projeto virou agregador

`GET /projetos/{id}` hoje alimenta:

- painel do projeto
- areas
- participantes
- confrontacoes
- resumo documental
- base cartografica
- parte do contexto de calculos
- tela de mapa

Isso simplifica a UI, mas tambem faz dessa rota um contrato critico do produto.

### 4. O CAD usa backend mais para persistencia do que para renderizacao

A tela de mapa/CAD faz a maior parte do trabalho localmente:

- alternancia de camadas
- selecao de vertices
- historico de edicao
- varias ferramentas contextuais

O backend entra principalmente para:

- carregar o projeto
- salvar versoes do perimetro
- sincronizar pontos

## Sugestao de proximo passo

Depois deste mapa, o proximo documento natural e um `contrato de navegacao e integracao` com:

- padronizacao do cliente HTTP
- definicao de quais rotas sao canonicas por tela
- padrao de `carregar`, `salvar`, `baixar`, `sincronizar`
- checklist de seguranca para cada acao sensivel
