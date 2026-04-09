# GeoAdmin Pro - Folha de Missao dos Agentes V1

## Objetivo

Formalizar a divisao de trabalho em 3 trilhas paralelas sem colisao de arquivos, sem quebra dos contratos centrais e com integracao final controlada.

## Regras gerais

- O integrador continua sendo o agente principal deste thread.
- Nenhum agente deve reescrever os contratos centrais sozinho:
  - `backend/schemas/contratos_v1.py`
  - `mobile/types/contratos-v1.ts`
- Mudancas sensiveis continuam sob governanca de seguranca:
  - `auth`
  - `magic links`
  - uploads
  - downloads
  - documentos
  - exportacoes tecnicas
  - rotas publicas
- Sempre preferir write set exclusivo por trilha.
- Quando uma trilha precisar tocar um arquivo compartilhado, a mudanca deve ser minima e orientada por contrato.

---

## Agente 1 - Workspace Geoespacial

### Missao

Ligar o ambiente de mapa/CAD a um contrato proprio de workspace, preservando o fluxo atual do topografo e evitando acoplamento artificial ao `ProjetoOficialV1`.

### Ownership principal

- `mobile/app/(tabs)/mapa/[id].tsx`
- `mobile/app/(tabs)/mapa/index.tsx`
- `backend/routes/perimetros.py`
- `backend/routes/geo.py`

### Pode tocar com parcimonia

- `backend/routes/projetos.py`
- `backend/schemas/contratos_v1.py`
- `mobile/types/contratos-v1.ts`

### Nao deve tocar

- `backend/routes/documentos.py`
- telas internas de projeto fora do mapa
- fluxos do portal do cliente

### Entrega minima esperada

- contrato `WorkspaceGeoespacialV1`
- `workspace_geoespacial_v1` anexado ao `GET /projetos/{id}`
- leitura do workspace em `mobile/app/(tabs)/mapa/[id].tsx`
- substituicao de `fetch(API_URL...)` por `apiGet/apiPost` onde couber

### Criterio de pronto

- topografo abre o mapa e recebe um bloco proprio de workspace com:
  - pontos
  - perimetro editavel em `lon/lat`
  - geometria de referencia
  - camadas disponiveis
  - indicacao de base oficial

### Ponto de integracao final

- o dossie continua consumindo `ProjetoOficialV1`
- o mapa passa a consumir `workspace_geoespacial_v1`

---

## Agente 2 - Portal do Cliente

### Missao

Abrir a frente externa do cliente em cima de `EstadoPortalClienteV1`, `magic link`, checklist e upload guiado, sem OCR e sem expor o dossie interno.

### Ownership principal

- `backend/routes/documentos.py`
- `backend/integracoes/projeto_clientes.py`
- rotas e telas novas do portal externo

### Pode tocar com parcimonia

- `backend/schemas/contratos_v1.py`
- `mobile/types/contratos-v1.ts`

### Nao deve tocar

- `mobile/app/(tabs)/projeto/[id].tsx`
- `backend/routes/projetos.py` para logica interna do dossie
- esteira de protocolos do escritorio

### Entrega minima esperada

- contexto do token/magic link
- leitura do estado do portal
- checklist de pendencias
- upload simples de arquivos
- confirmacao de recebimento

### Criterio de pronto

- cliente entra por link proprio
- ve apenas o que precisa preencher/enviar
- nao acessa o dossie interno

### Ponto de integracao final

- o dossie interno continua sendo tela do escritorio
- o portal externo conversa com esse dossie apenas por contratos e eventos

---

## Agente 3 - Protocolos Backend

### Missao

Sair da leitura de protocolos para escrita controlada de protocolos, comprovantes e trilha minima de auditoria, aderente ao `PainelDocumentalProjetoV1`.

### Ownership principal

- novo `backend/integracoes/protocolos_projeto.py`
- nova rota dedicada de protocolos no backend
- leitura e escrita de comprovantes

### Pode tocar com parcimonia

- `backend/routes/projetos.py`
- `mobile/types/contratos-v1.ts`

### Nao deve tocar

- `backend/routes/documentos.py`
- fluxo de token do portal do cliente
- mapa/CAD

### Entrega minima esperada

- `POST /projetos/{id}/protocolos`
- `POST /projetos/{id}/protocolos/{protocolo_id}/comprovantes`
- auditoria minima
- reflexo da escrita no painel documental

### Criterio de pronto

- escritorio consegue registrar protocolo e anexar comprovante sem tratar tudo como arquivo solto

### Ponto de integracao final

- `GET /projetos/{id}/protocolos` e `painel_documental_v1` devem refletir as escritas novas

---

## Arquivos congelados

Estes arquivos so devem ser alterados na integracao final ou por mudanca contratual deliberada:

- `backend/schemas/contratos_v1.py`
- `mobile/types/contratos-v1.ts`

## Ordem recomendada

1. `Protocolos Backend`
2. `Portal do Cliente`
3. `Workspace Geoespacial`

Observacao:
- `Portal do Cliente` e `Workspace Geoespacial` podem andar em paralelo.
- `Protocolos Backend` deve sair primeiro porque estabiliza a trilha documental.
