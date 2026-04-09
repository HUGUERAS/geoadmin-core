# GeoAdmin Pro - Pacotes de Trabalho dos Agentes V1

## Objetivo

Transformar as 3 trilhas paralelas em pacotes executaveis com write set claro, dependencias e Definition of Done.

## Pacote A - Protocolos Backend

### Escopo

- criar a camada de escrita de protocolos
- registrar comprovantes
- refletir isso no painel documental

### Write set preferencial

- `backend/integracoes/protocolos_projeto.py`
- `backend/routes/protocolos.py` ou rota dedicada equivalente
- `backend/routes/projetos.py` apenas para integracao de leitura

### Dependencias

- contratos V1 atuais
- painel documental atual

### Nao inclui

- tela do portal do cliente
- mapa/CAD

### Definition of Done

- criar protocolo
- anexar comprovante
- reler protocolo pelo projeto
- auditoria minima registrada

---

## Pacote B - Portal do Cliente

### Escopo

- contexto do magic link
- estado do portal
- checklist simples
- upload simples
- sem OCR

### Write set preferencial

- `backend/routes/documentos.py`
- `backend/integracoes/projeto_clientes.py`
- telas/rotas novas do portal

### Dependencias

- fluxo de magic link existente
- `EstadoPortalClienteV1`

### Nao inclui

- dossie interno
- protocolos internos do escritorio

### Definition of Done

- cliente acessa contexto por link
- ve pendencias
- envia arquivos
- sistema registra estado sem expor o dossie

---

## Pacote C - Workspace Geoespacial

### Escopo

- contrato proprio do workspace
- leitura de pontos, perimetro e camadas
- refatoracao do mapa para usar cliente central da API

### Write set preferencial

- `mobile/app/(tabs)/mapa/[id].tsx`
- `mobile/app/(tabs)/mapa/index.tsx`
- `backend/routes/perimetros.py`
- `backend/routes/geo.py`
- `backend/routes/projetos.py` para anexar `workspace_geoespacial_v1`

### Dependencias

- payload de projeto enriquecido
- perimetro atual
- referencia do cliente

### Nao inclui

- esteira documental
- portal externo

### Definition of Done

- mapa recebe `workspace_geoespacial_v1`
- editor continua funcional
- sem `fetch(API_URL...)` cru nessa trilha principal

---

## Integracao final

O integrador deve conferir:

- contratos centrais preservados
- sem colisao entre `documentos` e `protocolos`
- sem exposicao indevida entre portal externo e dossie interno
- mapa consumindo bloco proprio de workspace, nao distorcao do dossie

## Observacao operacional

Se houver trabalho simultaneo:

- `Pacote A` e `Pacote B` nao devem compartilhar o mesmo arquivo de rota
- `Pacote C` deve evitar mexer em documentacao e auth
