# GeoAdmin Core — Arquitetura Oficial do Projeto

## Propósito

Este documento define a arquitetura oficial do `GeoAdmin Core`.

Ele existe para deixar claro:

- qual é o núcleo do produto
- quais são as fronteiras entre módulos
- onde ficam os dados oficiais
- como backend, app, banco e infraestrutura se relacionam
- o que fica dentro e fora do core

## Missão do núcleo

O `GeoAdmin Core` é a fonte única de verdade do produto operacional.

Ele deve sustentar:

- gestão de projetos rurais
- topografia operacional
- georreferenciamento
- clientes e vínculos
- áreas, perímetros e confrontações
- documentação
- exportações técnicas
- fluxo controlado de banco, auth, storage e contratos

## Princípios arquiteturais

### 1. Fonte única de verdade

O banco oficial e o storage oficial são a fonte única de verdade.

Consequências:

- nada de fallback silencioso como solução final
- nada de JSON local como persistência operacional do domínio
- nada de arquivo local como storage final de produção

### 2. Núcleo transacional primeiro

O produto deve priorizar:

- banco consistente
- contratos consistentes
- rotas consistentes
- telas núcleo consistentes

Capacidades futuras, como `RAG`, não podem contaminar o núcleo agora.

### 3. Copy-only na transição

A fundação do `GeoAdmin Core` é por cópia controlada.

Isso significa:

- o repositório de origem não é recortado
- o novo núcleo evolui sem destruir a referência anterior

### 4. Segurança by default

O núcleo nasce com:

- governança explícita
- revisão de mudanças sensíveis
- docs fechadas por padrão
- separação de ambientes
- cuidado com auth, uploads, documentos e banco

## Visão em camadas

```text
GeoAdmin Core
  ├── App (mobile + web)
  ├── API (FastAPI)
  ├── Domínio e integrações
  ├── Banco oficial (Supabase/Postgres/PostGIS)
  ├── Storage oficial
  └── Infra e governança
```

## Camadas oficiais

### 1. Interface

Diretório:

- `mobile/`

Responsabilidade:

- app mobile oficial
- versão web oficial derivada do mesmo núcleo
- consumo dos contratos oficiais

Entram aqui:

- projetos
- dossiê do projeto
- workspace geoespacial
- clientes
- documentos
- cálculos

Não entra aqui:

- regras persistidas no cliente como fonte de verdade
- fluxo futuro de `RAG`

### 2. API

Diretório:

- `backend/`

Responsabilidade:

- expor o domínio em rotas estáveis
- validar auth
- serializar contratos
- orquestrar storage e banco
- executar integrações técnicas

Subcamadas esperadas:

- `routes/`
- `middleware/`
- `integracoes/`
- `schemas/`
- `tests/`

### 3. Domínio

Responsabilidade:

- modelar projetos
- clientes e vínculos
- áreas e lotes
- confrontantes
- documentos
- eventos
- exportações

Regra:

- domínio não deve depender de compatibilidade silenciosa para sempre

### 4. Banco oficial

Diretório de referência:

- `infra/supabase/`

Stack atual mantida:

- `Supabase`
- `Postgres`
- `PostGIS`

Papel do banco:

- persistência oficial
- relações do domínio
- views controladas
- histórico de migrations
- tipos gerados

### 5. Storage oficial

Papel:

- uploads do cliente
- arquivos cartográficos
- documentos gerados

Regra:

- storage local não é solução final

### 6. Infra e operação

Responsabilidade:

- migrations
- tipos gerados
- scripts de bootstrap
- ambientes
- governança de revisão

## Módulos do produto

### Módulos dentro do core

- `Projetos`
- `Clientes`
- `Áreas`
- `Perímetros`
- `Confrontações`
- `Documentos`
- `Exportação técnica`
- `Cálculos`
- `Auth`
- `Storage`
- `Banco`

### Módulos fora do core agora

- `RAG Topografia`
- `bridge` como produto próprio
- demos exploratórias
- protótipos de descoberta

## Arquitetura de dados oficial

Base canônica obrigatória:

- `registro_imobiliario_ampliado`
- `responsavel_tecnico_oficial`
- separação entre:
  - `endereco_residencial_ou_correspondencia`
  - `endereco_do_imovel_rural`

Diretriz:

- pessoa e imóvel não podem compartilhar o mesmo endereço lógico

## Arquitetura de contratos

Os contratos oficiais ficam em:

- `backend/schemas/`
- `mobile/types/`

Regra:

- contrato acompanha schema real
- frontend e backend falam a mesma língua
- o contrato não pode depender de campo fantasma

## Arquitetura de segurança

Referência principal:

- [REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md)

Regras centrais:

- mudança sensível exige revisão
- tarefa de banco aciona agente de banco
- contexto comprimido sempre retoma pela referência central

## Arquitetura de evolução

### Agora

Foco:

- fechar banco
- fechar auth
- fechar storage
- fechar contratos
- fechar telas núcleo

### Depois

Separadamente:

- `RAG Topografia`
- chat interno de normas e melhores práticas
- pipelines de ingestão documental

## Estado-alvo

O `GeoAdmin Core` é considerado maduro quando tiver:

- banco oficial coerente
- migrations oficiais estáveis
- auth minimamente endurecida
- storage sem fallback silencioso
- contratos sincronizados
- módulos núcleo operando sobre a base real

## Resumo executivo

O `GeoAdmin Core` é:

- o repositório oficial do núcleo do produto
- a base transacional e operacional do GeoAdmin
- separado de iniciativas futuras como `RAG`
- sustentado por `mobile + backend + Supabase + PostGIS`

E ele deve evoluir com uma regra simples:

- primeiro estabilidade do core
- depois expansão do ecossistema
