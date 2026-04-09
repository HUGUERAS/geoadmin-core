# GeoAdmin Pro - Backlog Tecnico das Telas V1

## Objetivo

Este backlog converte a `Matriz Operacional das Telas V1` em trabalho tecnico executavel.

Ele organiza:

- quais arquivos do frontend precisam ser adaptados ou criados
- quais endpoints atuais podem ser reaproveitados
- quais endpoints novos precisam nascer
- quais contratos sustentam a V1
- qual a ordem mais segura de implementacao

## Contratos-base da V1

Os contratos canonicos desta rodada passam a morar em:

- `backend/schemas/contratos_v1.py`
- `mobile/types/contratos-v1.ts`

Contratos principais:

- `ProjetoOficialV1`
- `ResumoProjetoOperacionalV1`
- `PainelDocumentalProjetoV1`
- `EstadoPortalClienteV1`

## Ordem recomendada

1. `Contratos e leitura`
2. `Central de Projetos`
3. `Dossie do Projeto`
4. `Workspace Geoespacial`
5. `Documentos e Protocolos`
6. `Portal do Cliente`

---

## Etapa 1 - Contratos e leitura

### Objetivo

Fechar uma linguagem unica para frontend e backend antes de abrir novas telas ou endpoints.

### Entregas

- definir contrato `ProjetoOficialV1`
- definir contrato `ResumoProjetoOperacionalV1`
- definir contrato `PainelDocumentalProjetoV1`
- definir contrato `EstadoPortalClienteV1`
- mapear quais dados ja existem em `GET /projetos` e `GET /projetos/{id}`
- identificar campos que ainda estao soltos em PDF, checklist ou payload improvisado

### Arquivos

- `backend/schemas/contratos_v1.py`
- `mobile/types/contratos-v1.ts`
- `docs/MATRIZ_OPERACIONAL_TELAS_V1.md`

### Criterio de pronto

- o time consegue apontar para um contrato canonico da V1
- frontend e backend passam a falar dos mesmos blocos

---

## Tela 1 - Central de Projetos

### Frontend

Arquivo principal:

- `mobile/app/(tabs)/projeto/index.tsx`

Componentes candidatos:

- `mobile/components/ProjetoCard.tsx`
- `mobile/components/StatusBadge.tsx`

### Backend

Endpoint atual:

- `GET /projetos`

Arquivo atual:

- `backend/routes/projetos.py`

### Trabalho tecnico

#### Frontend

- transformar lista simples em painel operacional
- adicionar blocos de:
  - fila decisiva do dia
  - fila por bloqueio
  - alertas quentes
  - protocolos recentes
- manter cache local e filtros em memoria
- garantir que `Ver no mapa` continue reaproveitando o fluxo atual

#### Backend

- revisar se `GET /projetos` ja devolve dados suficientes para:
  - risco
  - proximo passo
  - bloqueio principal
  - pronto para emitir
- se nao devolver, enriquecer o payload existente sem quebrar a lista atual

### Contrato alvo

- `ResumoProjetoOperacionalV1`

### Risco principal

- transformar a tela em dashboard pesado demais e perder velocidade de leitura

### Criterio de pronto

- o escritorio consegue decidir `qual projeto mexer agora` sem abrir 10 cards

---

## Tela 2 - Dossie do Projeto

### Frontend

Arquivo principal:

- `mobile/app/(tabs)/projeto/[id].tsx`

### Backend

Endpoint atual:

- `GET /projetos/{id}`

Arquivos envolvidos:

- `backend/routes/projetos.py`
- `backend/routes/clientes/resumos.py`
- `backend/integracoes/projeto_clientes.py`

### Trabalho tecnico

#### Frontend

- reorganizar o painel para leitura de caso
- separar claramente:
  - identidade do dossie
  - situacao processual
  - pessoas-chave
  - cadastros oficiais
  - alertas
  - proximos atos
- manter os atalhos:
  - abrir mapa
  - abrir cliente
  - copiar magic link
  - abrir documentos

#### Backend

- revisar a resposta de `GET /projetos/{id}` para aderir ao `ProjetoOficialV1`
- consolidar no mesmo payload:
  - projeto
  - participantes
  - areas
  - confrontacoes
  - documentos
  - protocolos
  - referencia do cliente
- evitar obrigar a tela a fazer costura demais no frontend

### Contrato alvo

- `ProjetoOficialV1`

### Risco principal

- deixar o dossie dependente de muitos requests paralelos e perder clareza operacional

### Criterio de pronto

- qualquer membro interno entende o caso abrindo uma unica tela

---

## Tela 3 - Workspace Geoespacial

### Frontend

Arquivo principal:

- `mobile/app/(tabs)/mapa/[id].tsx`

Arquivos de apoio:

- `mobile/app/(tabs)/mapa/index.tsx`
- ferramentas em `mobile/app/(tabs)/calculos/`

### Backend

Endpoints atuais:

- `GET /projetos/{id}`
- `POST /perimetros/`

Arquivos envolvidos:

- `backend/routes/perimetros.py`
- `backend/routes/projetos.py`

### Trabalho tecnico

#### Frontend

- consolidar visualmente o ambiente unico:
  - modo `CAD`
  - modo `Satelite`
  - `sidebar hamburger`
  - comparativo
  - painel geometrico
- manter ferramentas em contexto dentro da mesma tela
- deixar claro quando a alteracao esta apenas local e quando foi persistida

#### Backend

- manter o fluxo atual de salvar perimetro por versao
- avaliar melhoria de semantica no retorno do `POST /perimetros/`
- no futuro, expor leitura de historico de versoes, mas isso nao bloqueia a V1

### Contrato alvo

- `ProjetoOficialV1`

### Risco principal

- misturar demais a logica de CAD com leitura documental e sobrecarregar a tela

### Criterio de pronto

- topografo trabalha no mesmo ambiente sem trocar de tela entre `CAD` e `Satelite`

---

## Tela 4 - Documentos e Protocolos

### Frontend

Arquivos sugeridos:

- adaptar `mobile/app/(tabs)/projeto/[id].tsx` na primeira rodada
- ou criar uma rota dedicada:
  - `mobile/app/(tabs)/projeto/[id]/documentos.tsx`

### Backend

Endpoints atuais reaproveitaveis:

- `POST /projetos/{id}/gerar-documentos`
- `POST /projetos/{id}/arquivos/migrar-legado`
- `POST /projetos/{id}/arquivos/{arquivo_id}/promover`

Endpoints a criar:

- `GET /projetos/{id}/documentos`
- `GET /projetos/{id}/documentos/{documento_id}`
- `GET /projetos/{id}/protocolos`
- `POST /projetos/{id}/protocolos`
- `POST /projetos/{id}/protocolos/{protocolo_id}/comprovantes`
- `POST /projetos/{id}/pacote-final`

Arquivos candidatos no backend:

- `backend/routes/documentos.py`
- `backend/routes/projetos.py`
- `backend/integracoes/arquivos_projeto.py`
- `backend/integracoes/gerador_documentos.py`

### Trabalho tecnico

#### Frontend

- criar esteira documental legivel por peca
- separar:
  - checklist
  - gerador
  - recibos
  - comprovantes
  - pacote final
- evitar que o usuario precise caçar arquivos em listas genericas

#### Backend

- formalizar entidade de `protocolo`
- formalizar leitura de `documentos do projeto`
- formalizar anexo de comprovante ligado a evento
- preparar emissao de pacote final

### Contrato alvo

- `PainelDocumentalProjetoV1`

### Risco principal

- continuar tratando protocolo e comprovante como arquivo solto

### Criterio de pronto

- o escritorio entende o estado documental do caso sem sair do projeto

---

## Tela 5 - Portal do Cliente

### Frontend

Opcoes de implementacao:

- `backend/static/formulario_cliente.html` como base inicial web publica
- ou nova rota web/mobile dedicada no futuro:
  - `mobile/app/portal/[token].tsx`

### Backend

Endpoint atual relacionado:

- `POST /projetos/{id}/magic-link`

Endpoints a criar:

- `GET /portal/{token}`
- `POST /portal/{token}/dados`
- `POST /portal/{token}/arquivos`
- `DELETE /portal/{token}/arquivos/{arquivo_id}`
- `POST /portal/{token}/concluir`

Arquivos candidatos:

- `backend/routes/documentos.py`
- `backend/integracoes/projeto_clientes.py`
- `backend/integracoes/arquivos_projeto.py`
- `backend/static/formulario_cliente.html`

### Trabalho tecnico

#### Frontend

- montar experiencia simples por etapas
- mostrar progresso, pendencias e uploads
- deixar claro que o cliente nao acessa o dossie interno
- manter linguagem nao tecnica

#### Backend

- validar token temporario
- limitar escopo do que o cliente pode ler e escrever
- aceitar uploads guiados
- registrar conclusao da etapa do cliente

### Contrato alvo

- `EstadoPortalClienteV1`

### Risco principal

- abrir informacao demais para o cliente ou criar token sem validade forte

### Criterio de pronto

- o cliente consegue enviar o necessario sem depender de WhatsApp para tudo

---

## Backlog tecnico por pacote

## Pacote A - Base de contratos

- [ ] consolidar `ProjetoOficialV1`
- [ ] consolidar `ResumoProjetoOperacionalV1`
- [ ] consolidar `PainelDocumentalProjetoV1`
- [ ] consolidar `EstadoPortalClienteV1`

## Pacote B - Leitura interna

- [ ] adaptar `/(tabs)/projeto`
- [ ] adaptar `/(tabs)/projeto/[id]`
- [ ] ajustar resposta de `GET /projetos`
- [ ] ajustar resposta de `GET /projetos/{id}`

## Pacote C - Operacao geoespacial

- [ ] consolidar `Workspace Geoespacial` no `/(tabs)/mapa/[id]`
- [ ] alinhar toolbar, sidebar e comparativo
- [ ] revisar semantica de versao de perimetro

## Pacote D - Esteira documental

- [ ] criar painel documental do projeto
- [ ] criar leitura de documentos por projeto
- [ ] criar entidade de protocolos
- [ ] criar vinculo de comprovantes
- [ ] criar emissao de pacote final

## Pacote E - Portal do cliente

- [ ] criar leitura publica controlada por token
- [ ] criar endpoint de atualizacao de dados pelo cliente
- [ ] criar upload publico controlado
- [ ] criar conclusao da etapa externa
- [ ] revisar seguranca de `magic link` e uploads

---

## Observacao final

O melhor caminho agora nao e abrir mais telas.

O melhor caminho e implementar a V1 em cima destas 5 frentes, com contratos claros e sem criar uma segunda arquitetura paralela.
