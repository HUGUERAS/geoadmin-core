# GeoAdmin Pro - Matriz Operacional das Telas V1

## Objetivo

Este documento transforma o pack visual em base de implementacao.

Ele responde, para as telas nucleo da V1:

- quem usa
- quem nao usa
- qual e o papel da tela no fluxo
- quais blocos sao obrigatorios
- o que cada botao principal deve acionar
- qual logica fica local e qual depende de backend
- quais permissoes e cuidados de seguranca precisam existir

## Escopo desta matriz

Esta V1 fecha 5 telas centrais do produto:

1. `Central de Projetos`
2. `Dossie do Projeto`
3. `Workspace Geoespacial`
4. `Documentos e Protocolos`
5. `Portal do Cliente`

## Regras transversais da V1

- `Dossie do Projeto` e `Workspace Geoespacial` sao de uso interno apenas.
- `Cliente nunca acessa o dossie interno`.
- `Portal do Cliente` e a experiencia externa controlada por `magic link`.
- `OCR` fica fora da V1. Upload e preenchimento serao guiados e manuais.
- `Workspace Geoespacial` e um unico ambiente com `CAD`, `Satelite`, `camadas` e `comparativo`.
- Mudancas em `magic links`, uploads, documentos, protocolos, exportacao tecnica e rotas publicas exigem revisao de seguranca.

---

## 1. Central de Projetos

### Resumo operacional

| Campo | Definicao |
|---|---|
| Tipo | Interna |
| Perfis com acesso | escritorio, gestor, responsavel tecnico, topografo |
| Perfis sem acesso | cliente |
| Rota atual | `/(tabs)/projeto` |
| Base atual | lista de projetos com filtro e cache local |
| Papel alvo na V1 | cabine de operacao do escritorio |

### Momento do fluxo

Usada para decidir `qual dossie mexer agora`, `por que esta travado` e `qual acao sai hoje`.

### Blocos obrigatorios

- fila decisiva do dia
- fila por bloqueio
- filtros por carteira e orgao
- alertas quentes
- protocolos recentes
- indicador de projetos prontos para emitir

### Acoes principais

| Botao / acao | Papel | Logica principal | Backend atual | Backend alvo V1 | Permissao |
|---|---|---|---|---|---|
| `Abrir dossie` | entrar no caso | navegar para o projeto escolhido | sem backend | sem backend | interno |
| `Novo projeto` | iniciar caso novo | navegar para criacao | sem backend | sem backend | interno |
| `Filtrar por status/orgao` | leitura operacional | filtro local em memoria | sem backend | sem backend | interno |
| `Buscar projeto` | localizar rapido | filtro local por nome, cliente e identificadores | sem backend | sem backend | interno |
| `Ver no mapa` | abrir operacao espacial | salvar contexto e navegar para workspace | sem backend | sem backend | interno |
| `Cobrar cliente` | disparar pendencia externa | abrir fluxo de `magic link` ou contato | sem backend | `POST /projetos/{id}/magic-link` quando aplicavel | interno |
| `Ver protocolos recentes` | entrar na camada documental | navegar para tela documental do projeto | sem backend | sem backend | interno |

### Estado local e offline

- manter cache local da lista de projetos
- filtros e busca ficam locais
- mostrar fallback quando API falhar
- permitir leitura minima mesmo sem rede

### Regras de permissao e seguranca

- nunca expor documentos sensiveis ou links publicos completos na grade
- exibir somente resumo operacional
- qualquer acao de `magic link`, exportacao ou protocolo deve exigir contexto autenticado

### Observacao de implementacao

A tela atual ja cobre `lista + filtro + refresh`. O trabalho da V1 e elevar essa tela para `quadro de comando`, nao reescrever o basico.

---

## 2. Dossie do Projeto

### Resumo operacional

| Campo | Definicao |
|---|---|
| Tipo | Interna |
| Perfis com acesso | escritorio, gestor, responsavel tecnico, topografo |
| Perfis sem acesso | cliente |
| Rota atual | `/(tabs)/projeto/[id]` |
| Base atual | painel operacional do projeto |
| Papel alvo na V1 | centro do caso |

### Momento do fluxo

Usada para ler o projeto inteiro como `dossie fundiario`, concentrando identidade, fase, pessoas, documentos, cadastros, risco e proximos atos.

### Blocos obrigatorios

- identidade do dossie
- escopo de acesso interno
- situacao processual
- cadastros oficiais
- pessoas-chave
- alertas do dossie
- proximos atos
- atalhos para mapa, cliente, documentos e exportacao

### Acoes principais

| Botao / acao | Papel | Logica principal | Backend atual | Backend alvo V1 | Permissao |
|---|---|---|---|---|---|
| `Abrir workspace geoespacial` | ir para CAD/satelite | navegar para `/(tabs)/mapa/[id]` | sem backend | sem backend | interno |
| `Abrir cliente e representacao` | ver pessoas e magic links | navegar para cliente vinculado | sem backend | sem backend | interno |
| `Copiar link do cliente` | acao externa controlada | gerar `magic link` e copiar mensagem | `POST /projetos/{id}/magic-link` | `POST /projetos/{id}/magic-link` | interno |
| `Gerar links em lote` | empurrar coleta externa | disparar links para lotes elegiveis | `POST /projetos/{id}/magic-links/lote` | `POST /projetos/{id}/magic-links/lote` | interno |
| `Importar lotes` | trazer base inicial | upload e recarga do projeto | `POST /projetos/{id}/areas/importar-arquivo` | `POST /projetos/{id}/areas/importar-arquivo` | interno |
| `Gerar documentos` | entrar na esteira documental | hoje gera pacote direto; na V1 deve abrir a mesa documental | `POST /projetos/{id}/gerar-documentos` | navegar para tela documental; geracao fica la | interno |
| `Gerar cartas ZIP` | tratar confrontacoes | abrir pacote de cartas | `GET /projetos/{id}/confrontacoes/cartas` | `GET /projetos/{id}/confrontacoes/cartas` | interno |
| `Confirmar/Descartar confrontacao` | revisar dados do caso | registrar revisao e recarregar | `POST /projetos/{id}/confrontacoes/revisar` | `POST /projetos/{id}/confrontacoes/revisar` | interno |
| `Manifesto Metrica` | ver saida tecnica | abrir manifesto de exportacao | `GET /projetos/{id}/metrica/manifesto` | rota atual + futuras exportacoes V1 | interno |

### Estado local e offline

- manter cache do projeto no dispositivo
- exibir badge de sincronizacao local
- permitir leitura do ultimo estado conhecido quando a rede falhar

### Regras de permissao e seguranca

- tela explicitamente `uso interno`
- nao compartilhar esta rota com cliente
- dados de processo, protocolos, cadastro oficial e documentos sensiveis exigem autenticacao
- downloads e geracoes devem ser auditaveis

### Observacao de implementacao

O dossie ja existe em forma inicial no painel do projeto. A V1 precisa reorganizar a informacao por `leitura de caso`, nao por lista dispersa de cards.

---

## 3. Workspace Geoespacial

### Resumo operacional

| Campo | Definicao |
|---|---|
| Tipo | Interna |
| Perfis com acesso | topografo, responsavel tecnico, escritorio em leitura |
| Perfis sem acesso | cliente |
| Rota atual | `/(tabs)/mapa/[id]` |
| Base atual | mapa/CAD com edicao de perimetro |
| Papel alvo na V1 | ambiente unico de operacao geoespacial |

### Momento do fluxo

Usada para editar geometria, comparar referencia, revisar camadas e aplicar calculos no contexto do perimetro ativo.

### Blocos obrigatorios

- area principal do mapa
- alternancia `CAD` / `Satelite`
- sidebar com `camadas`, `comparativo` e `ferramentas`
- toolbar de edicao
- painel geometrico com versao, vertices e status
- acoes para salvar, cancelar e desfazer

### Acoes principais

| Botao / acao | Papel | Logica principal | Backend atual | Backend alvo V1 | Permissao |
|---|---|---|---|---|---|
| `Alternar CAD / Satelite` | trocar leitura visual | muda apenas estado da tela | sem backend | sem backend | interno |
| `Sidebar hamburger` | abrir camadas e painel contextual | estado local | sem backend | sem backend | interno |
| `Editar` | entrar em edicao | registrar versao original e abrir sessao de edicao | `POST /perimetros/` | manter rota, com semantica mais clara de versao | interno |
| `Salvar` | persistir nova versao | salvar perimetro editado | `POST /perimetros/` | `POST /perimetros/` | interno |
| `Cancelar` | abortar sessao | descartar alteracoes locais | sem backend | sem backend | interno |
| `Desfazer` | voltar um passo | historico local | sem backend | sem backend | interno |
| `Ferramentas em contexto` | calculos tecnicos | logica local no mapa | majoritariamente local | integrar progressivamente com backend quando fizer sentido | interno |
| `Comparativo` | cruzar croqui e camada oficial | alternar referencia externa | sem backend | rotas de leitura de referencia do cliente quando necessario | interno |

### Estado local e offline

- historico de edicao local
- camadas e visualizacao sao locais
- perimetro so vai ao backend no `salvar`
- ferramentas auxiliares continuam majoritariamente locais na V1

### Regras de permissao e seguranca

- cliente nao acessa
- salvar nova versao exige usuario autenticado
- toda versao nova de perimetro deve ser rastreavel
- exportacao tecnica nao deve sair diretamente da tela sem passar por contexto de projeto

### Observacao de implementacao

A decisao de produto ja esta tomada: `nao existem duas telas de mapa`. O `Workspace Geoespacial` absorve CAD, satelite e camadas numa mesma experiencia.

---

## 4. Documentos e Protocolos

### Resumo operacional

| Campo | Definicao |
|---|---|
| Tipo | Interna |
| Perfis com acesso | escritorio, gestor, responsavel tecnico |
| Perfis sem acesso | cliente, uso topografico puro |
| Rota atual | espalhada entre `/(tabs)/projeto/[id]` e `/(tabs)/clientes/[id]` |
| Base atual | acoes documentais soltas no projeto |
| Papel alvo na V1 | esteira documental do caso |

### Momento do fluxo

Usada para montar, revisar, emitir, registrar e rastrear a documentacao do projeto.

### Blocos obrigatorios

- checklist documental
- gerador de documentos
- recibos e protocolos
- documentos vinculados
- situacao por peca
- acoes de emitir, revisar, protocolar e anexar comprovante

### Acoes principais

| Botao / acao | Papel | Logica principal | Backend atual | Backend alvo V1 | Permissao |
|---|---|---|---|---|---|
| `Gerar documentos` | emitir pecas | hoje gera pacote direto | `POST /projetos/{id}/gerar-documentos` | manter como acao de emissao, mas partindo desta tela | interno |
| `Migrar legado` | consolidar acervo | migrar arquivos antigos | `POST /projetos/{id}/arquivos/migrar-legado` | `POST /projetos/{id}/arquivos/migrar-legado` | interno |
| `Promover arquivo` | oficializar documento | mover da bandeja para base oficial | `POST /projetos/{id}/arquivos/{arquivo_id}/promover` | `POST /projetos/{id}/arquivos/{arquivo_id}/promover` | interno |
| `Registrar protocolo` | guardar numero e comprovante | criar registro ligado ao projeto | nao existe como tela dedicada | `POST /projetos/{id}/protocolos` | interno |
| `Vincular comprovante` | ligar arquivo ao evento correto | associacao documental | nao existe como acao dedicada | `POST /projetos/{id}/protocolos/{protocolo_id}/comprovantes` | interno |
| `Abrir documento` | revisar peca emitida | leitura e download | hoje espalhado por arquivos | `GET /projetos/{id}/documentos/{doc_id}` | interno |
| `Emitir pacote final` | consolidar dossie | gerar ZIP final | parcial | `POST /projetos/{id}/pacote-final` | interno |

### Estado local e offline

- filtros por tipo de documento podem ser locais
- fila de emissao e protocolo deve refletir estado remoto
- evitar depender de estado apenas no navegador para comprovantes e vinculos

### Regras de permissao e seguranca

- documentos podem conter dados pessoais, cadastrais e oficiais
- downloads devem respeitar autenticacao e autorizacao por projeto
- uploads precisam de validacao de tipo, tamanho e trilha de auditoria
- geracao documental e protocolo entram no escopo de revisao de seguranca

### Observacao de implementacao

Na V1, esta tela e o principal salto de produto, porque tira a camada documental do modo `botao solto` e transforma em `esteira clara`.

---

## 5. Portal do Cliente

### Resumo operacional

| Campo | Definicao |
|---|---|
| Tipo | Externa controlada |
| Perfis com acesso | cliente, representante externo autorizado |
| Perfis sem acesso | escritorio sem contexto publico; usuario anonimo sem token |
| Rota atual | ainda nao existe como tela dedicada |
| Base atual | apenas geracao de `magic link` |
| Papel alvo na V1 | coleta externa simples e segura |

### Momento do fluxo

Usada quando o escritorio precisa receber dados, anexos, correcoes ou confirmacoes do cliente sem expor o dossie interno.

### Blocos obrigatorios

- cabecalho simples com identificacao minima do caso
- progresso por etapas
- checklist de pendencias do cliente
- upload de arquivos
- atualizacao de dados cadastrais
- ajuda e privacidade
- mensagem clara de que o acesso e limitado

### Acoes principais

| Botao / acao | Papel | Logica principal | Backend atual | Backend alvo V1 | Permissao |
|---|---|---|---|---|---|
| `Abrir link` | entrar no fluxo externo | autenticacao por token temporario | geracao via `POST /projetos/{id}/magic-link` | `GET /portal/{token}` ou equivalente | publico controlado |
| `Atualizar dados` | corrigir cadastro | salvar campos permitidos pelo cliente | nao existe | `POST /portal/{token}/dados` | token valido |
| `Enviar documento` | anexar arquivo solicitado | upload guiado por etapa | nao existe | `POST /portal/{token}/arquivos` | token valido |
| `Remover arquivo antes de concluir` | controle do envio | apagar anexo temporario | nao existe | `DELETE /portal/{token}/arquivos/{arquivo_id}` | token valido |
| `Concluir envio` | fechar etapa do cliente | registrar entrega e notificar escritorio | nao existe | `POST /portal/{token}/concluir` | token valido |
| `Precisa de ajuda?` | suporte | abrir canal simples de contato | nao existe | pode iniciar sem backend ou via webhook posterior | token valido |

### Estado local e offline

- uploads podem ter progresso local
- formulario deve ser resiliente a recarregamento curto
- nao persistir dados sensiveis em storage fraco por tempo indeterminado

### Regras de permissao e seguranca

- acesso limitado por `magic link` com expiracao
- cliente ve somente o necessario para sua etapa
- sem acesso ao dossie, protocolos internos ou leitura de risco
- uploads e dados pessoais exigem validacao, expiracao e trilha minima

### Observacao de implementacao

O `Portal do Cliente` e a contraparte externa do `Dossie do Projeto`. Um organiza o trabalho interno; o outro coleta o minimo necessario do lado de fora.

---

## Fechamento da V1

Se estas 5 telas estiverem fechadas, o produto ja tem:

- entrada operacional do escritorio
- centro interno do caso
- operacao geoespacial unificada
- esteira documental clara
- fluxo externo controlado para cliente

Esse e o ponto em que os prototipos deixam de ser apenas referencia visual e passam a funcionar como contrato de implementacao.
