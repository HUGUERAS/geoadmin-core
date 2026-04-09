# GeoAdmin Pro - Hub de Conhecimento

Este arquivo funciona como ponto de entrada em estilo Obsidian ou Confluence.

Objetivo:

- centralizar navegacao tecnica
- ajudar onboarding
- facilitar leitura de produto, telas, backend e fluxos

## Inicio rapido

- [README do projeto](../README.md)
- [Mapa de telas e rotas](./MAPA_TELAS_E_ROTAS.md)
- [Mapa mental](./MAPA_MENTAL_GEOADMIN.md)
- [Governanca de seguranca](./GOVERNANCA_SEGURANCA.md)

## Produto

- App mobile em `mobile/`
- Backend FastAPI em `backend/`
- Fonte unica de verdade: `GeoAdmin Pro`
- Dominio principal:
  - topografia
  - georreferenciamento
  - regularizacao fundiaria
  - documentacao rural

## Areas do app

### Projetos

- Lista: [mobile/app/(tabs)/projeto/index.tsx](../mobile/app/(tabs)/projeto/index.tsx)
- Novo projeto: [mobile/app/(tabs)/projeto/novo.tsx](../mobile/app/(tabs)/projeto/novo.tsx)
- Painel do projeto: [mobile/app/(tabs)/projeto/[id].tsx](../mobile/app/(tabs)/projeto/[id].tsx)

### Mapa / CAD

- Hub do mapa: [mobile/app/(tabs)/mapa/index.tsx](../mobile/app/(tabs)/mapa/index.tsx)
- CAD por projeto: [mobile/app/(tabs)/mapa/[id].tsx](../mobile/app/(tabs)/mapa/[id].tsx)

### Calculos

- Hub: [mobile/app/(tabs)/calculos/index.tsx](../mobile/app/(tabs)/calculos/index.tsx)
- Ferramentas remotas:
  - [inverso.tsx](../mobile/app/(tabs)/calculos/inverso.tsx)
  - [area.tsx](../mobile/app/(tabs)/calculos/area.tsx)
  - [conversao.tsx](../mobile/app/(tabs)/calculos/conversao.tsx)
  - [intersecao.tsx](../mobile/app/(tabs)/calculos/intersecao.tsx)
  - [distancia.tsx](../mobile/app/(tabs)/calculos/distancia.tsx)
  - [rotacao.tsx](../mobile/app/(tabs)/calculos/rotacao.tsx)
  - [subdivisao.tsx](../mobile/app/(tabs)/calculos/subdivisao.tsx)
- Ferramentas locais:
  - [deflexao.tsx](../mobile/app/(tabs)/calculos/deflexao.tsx)
  - [media.tsx](../mobile/app/(tabs)/calculos/media.tsx)
  - [irradiacao.tsx](../mobile/app/(tabs)/calculos/irradiacao.tsx)
  - [linha.tsx](../mobile/app/(tabs)/calculos/linha.tsx)
  - [pontos.tsx](../mobile/app/(tabs)/calculos/pontos.tsx)
  - [polilinha.tsx](../mobile/app/(tabs)/calculos/polilinha.tsx)
  - [nomenclatura.tsx](../mobile/app/(tabs)/calculos/nomenclatura.tsx)

### Clientes

- Lista: [mobile/app/(tabs)/clientes/index.tsx](../mobile/app/(tabs)/clientes/index.tsx)
- Hub documental: [mobile/app/(tabs)/clientes/[id].tsx](../mobile/app/(tabs)/clientes/[id].tsx)

### Bluetooth

- Android: [mobile/app/bluetooth.tsx](../mobile/app/bluetooth.tsx)
- Web stub: [mobile/app/bluetooth.web.tsx](../mobile/app/bluetooth.web.tsx)

## Backend

### Entrada principal

- [backend/main.py](../backend/main.py)

### Routers

- Projetos: [backend/routes/projetos.py](../backend/routes/projetos.py)
- Clientes: [backend/routes/clientes/routes.py](../backend/routes/clientes/routes.py)
- Documentos: [backend/routes/documentos.py](../backend/routes/documentos.py)
- Exportacao: [backend/routes/exportacao/routes.py](../backend/routes/exportacao/routes.py)
- Geo: [backend/routes/geo.py](../backend/routes/geo.py)
- Perimetros: [backend/routes/perimetros.py](../backend/routes/perimetros.py)
- Pontos: [backend/routes/pontos.py](../backend/routes/pontos.py)
- Importar: [backend/routes/importar.py](../backend/routes/importar.py)
- Catalogo: [backend/routes/catalogo.py](../backend/routes/catalogo.py)

## Fluxos criticos

### Criar projeto

1. Usuario preenche nome, localizacao, status e participantes
2. App chama `POST /projetos`
3. App envia arquivos da base inicial com `POST /projetos/{id}/arquivos`
4. App navega para o painel do projeto

### Abrir projeto no CAD

1. Usuario toca em `Ver no mapa`
2. App salva `ultimoProjetoMapa` localmente
3. App navega para `/(tabs)/mapa/[id]`
4. Tela do mapa chama `GET /projetos/{id}`

### Gerar magic link

1. Usuario toca em `Copiar link do cliente` ou `Reenviar magic link`
2. App chama `POST /projetos/{id}/magic-link`
3. Mensagem vai para clipboard ou WhatsApp

### Gerar documentos

1. Usuario toca em `Gerar documentos GPRF`
2. App chama `POST /projetos/{id}/gerar-documentos`
3. Backend monta pacote documental

### Sincronizar pontos offline

1. App le pendencias locais
2. App chama `POST /pontos/sync`
3. Banco local marca itens sincronizados, duplicados ou erro

## Governanca

- [Governanca de seguranca](./GOVERNANCA_SEGURANCA.md)
- Agentes permanentes:
  - `security-backend-reviewer`
  - `security-frontend-docs-reviewer`
- Skills recomendadas:
  - `geoadmin-security-baseline`
  - `geoadmin-security-review`
  - `geoadmin-document-data-security`

## Pendencias arquiteturais conhecidas

- padronizar cliente HTTP entre `fetch` direto e [mobile/lib/api.ts](../mobile/lib/api.ts)
- alinhar o fluxo de `Preparar para Metrica` com a rota `POST /projetos/{id}/metrica/preparar`
- explicitar melhor os contratos de `GET /projetos/{id}`
- separar melhor logica local do CAD e persistencia do backend

## Proximos artefatos recomendados

- quadro `tela -> rota -> contrato -> seguranca`
- ADR para o fluxo do Metrica
- contrato canonico do detalhe do projeto
- mapa de dados do `GET /projetos/{id}`
