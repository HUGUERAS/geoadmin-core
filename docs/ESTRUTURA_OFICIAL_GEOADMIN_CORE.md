# GeoAdmin Pro — Estrutura Oficial do Novo Repositório `GeoAdmin Core`

## Decisão recomendada

Sim, faz sentido criar um **novo repositório oficial** para o núcleo do produto.

Nome sugerido:

- `geoadmin-core`

Objetivo:

- consolidar o que é **canônico, útil e operacionalmente real**
- separar o núcleo do produto da trilha de incubação, prototipação e legado
- reduzir ruído de contexto, documentação paralela e herança técnica desnecessária

## O que o novo repositório deve ser

O `GeoAdmin Core` deve ser o repositório do **produto oficial**.

Ele deve conter:

- backend oficial
- app mobile oficial
- versão web oficial
- infraestrutura oficial
- schema e migrations oficiais
- contratos oficiais
- documentação viva do produto
- templates e seeds controlados

Ele **não** deve ser um repositório de acervo operacional bruto.

## Regra sobre dados reais

O novo repositório pode consolidar **dados úteis reais**, mas não deve versionar **dados operacionais reais brutos**.

### Pode entrar no Git

- seeds saneados
- fixtures anonimizadas
- vocabulários controlados
- tabelas de referência
- templates documentais
- exemplos reais desidentificados
- casos de teste representativos
- dicionário de dados

### Não pode entrar no Git

- documentos reais de cliente
- PDFs assinados reais
- anexos operacionais sensíveis
- dumps brutos de produção
- credenciais
- tokens
- planilhas internas com dados identificáveis

## Fronteira oficial do `GeoAdmin Core`

### Entra no novo repositório

- `backend/`
- `mobile/`
- `infra/`
- `docs/`
- `scripts/`

### Entra só o que for oficial

- `docs/REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md`
- `docs/TASKS_BANCO_FUNCIONAMENTO_REAL.md`
- `docs/MODELO_DADOS_BASE_CANONICA.md`
- `docs/BASE_CANONICA_IMPLEMENTACAO.md`
- `docs/GOVERNANCA_SEGURANCA.md`
- `docs/MATRIZ_OPERACIONAL_TELAS_V1.md`
- `docs/BACKLOG_TECNICO_TELAS_V1.md`

### Fica fora do núcleo oficial

- protótipos temporários que não virarem tela oficial
- rascunhos exploratórios
- materiais de incubação do `RAG`
- documentação redundante de transição
- diretórios locais de build ou cache

## O que deve nascer limpo no novo repositório

### 1. Banco oficial

O novo repo deve nascer já com a base canônica como referência.

Diretivas obrigatórias:

- `registro_imobiliario_ampliado` dentro
- `responsavel_tecnico_oficial` dentro
- separação entre:
  - `endereco_residencial_ou_correspondencia`
  - `endereco_do_imovel_rural`

### 2. Infra oficial

Diretório sugerido:

- `infra/supabase/`

Conteúdo:

- migrations oficiais
- `config.toml`
- `database.types.ts`
- scripts de bootstrap
- documentação de ambiente

### 3. Contratos oficiais

Arquivos base:

- `backend/schemas/`
- `mobile/types/`

Regra:

- contrato acompanha schema real
- frontend e backend não podem mais depender de “melhor esforço”

### 4. Segurança oficial

O novo repo deve nascer com:

- governança de segurança explícita
- docs fechadas por padrão
- `TrustedHost`
- separação de ambientes
- revisão obrigatória para auth, banco, uploads, documentos e exportações

## Estrutura sugerida do novo repositório

```text
geoadmin-core/
  backend/
    app/
    routes/
    integracoes/
    middleware/
    schemas/
    services/
    tests/
    main.py
  mobile/
    app/
    components/
    constants/
    lib/
    types/
  infra/
    supabase/
      migrations/
      config.toml
      database.types.ts
    environments/
  docs/
    REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md
    MODELO_DADOS_BASE_CANONICA.md
    BASE_CANONICA_IMPLEMENTACAO.md
    TASKS_BANCO_FUNCIONAMENTO_REAL.md
    GOVERNANCA_SEGURANCA.md
    MAPA_TELAS_E_ROTAS.md
    MATRIZ_OPERACIONAL_TELAS_V1.md
  scripts/
    bootstrap/
    dev/
    maintenance/
  .github/
    workflows/
    agents/
  .codex/
    skills/
```

## O que deve ficar em projeto separado no futuro

### `RAG Topografia`

O `RAG` não deve entrar no `GeoAdmin Core` agora.

Quando sair do campo de ideia e virar execução, a recomendação é um projeto próprio:

- `geoadmin-rag-topografia`

Ele deve conter:

- pipeline de ingestão
- OCR
- embeddings
- busca híbrida
- chat interno
- avaliação e curadoria de conhecimento

O `Core` só precisa garantir que os dados e documentos oficiais estejam organizados para futura ingestão.

## O que fazer com o repositório atual

O repositório atual pode continuar existindo temporariamente como:

- base de transição
- incubadora de decisões
- fonte de comparação
- apoio para migração

Mas a intenção deve ser:

- parar de tratar este repositório como núcleo definitivo
- migrar o que é canônico para o `GeoAdmin Core`
- aposentar o legado aos poucos

## Critério de corte para o novo repositório

O novo `GeoAdmin Core` deve ser considerado pronto para assumir o papel de repositório oficial quando tiver:

- banco oficial definido
- migrations oficiais coerentes
- contratos sincronizados
- auth minimamente endurecida
- storage oficial sem fallback silencioso
- telas núcleo ligadas ao banco real
- documentação de operação mínima

## Ordem recomendada de migração

### Etapa 1 — Fundar o novo núcleo

- criar o novo repositório
- copiar só a estrutura útil
- remover arquivos de build, lixo local e duplicidades

### Etapa 2 — Levar o coração do produto

- backend
- mobile
- infra
- scripts necessários

### Etapa 3 — Levar a documentação canônica

- referência oficial
- base canônica
- tasks de banco
- governança
- telas e matrizes úteis

### Etapa 4 — Reconectar o banco oficial

- definir Supabase oficial do novo núcleo
- estabilizar migrations
- regenerar tipos
- alinhar `.env.example`

### Etapa 5 — Validar o funcionamento real

- smoke tests
- auth
- projetos
- clientes
- magic link
- documentos
- storage

## Decisão prática recomendada

Sim, eu recomendo:

1. criar `geoadmin-core`
2. usar este novo repo como **produto oficial**
3. manter dados reais no banco e no storage, não no Git
4. levar para o Git apenas dados úteis saneados e artefatos canônicos
5. deixar `RAG` como iniciativa separada quando chegar a hora
