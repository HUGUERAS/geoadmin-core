# GeoAdmin Pro — Plano de Agentes para Base Canônica

## Objetivo

Distribuir a trilha da base canônica e do funcionamento real do app em agentes com ownership claro, pouca colisão de arquivos e ordem de integração segura.

## Princípios

- toda tarefa que tocar banco, schema, migration, Supabase ou contrato dependente do banco passa primeiro pelo agente de banco
- nenhuma solução final pode depender de `stub`, `mock`, `hook` ou `fallback local`
- quando a execução exigir decisão estrutural com risco, a ação para e consulta o responsável antes
- o integrador continua sendo o agente principal do thread

## Visão geral dos agentes

### Agente 0 — Integrador

Responsabilidade:

- manter a visão do produto
- integrar entregas dos outros agentes
- revisar colisões de contrato
- decidir a ordem de merge

Não deve:

- tomar sozinho decisão de `migration repair`
- remover legado crítico sem confirmação

---

### Agente 1 — Banco Canônico e Migrations

Missão:

- desenhar e consolidar a base canônica nova
- preparar o caminho para reconciliação de migrations
- garantir que `registro_imobiliario_ampliado` e `responsavel_tecnico_oficial` nasçam corretos
- formalizar a separação entre `endereco_residencial_ou_correspondencia` e `endereco_do_imovel_rural`

Ownership principal:

- `infra/supabase/migrations/`
- `infra/supabase/database.types.ts`
- `docs/MODELO_DADOS_BASE_CANONICA.md`
- `docs/TASKS_BANCO_FUNCIONAMENTO_REAL.md`
- `docs/MATRIZ_COBERTURA_DADOS_SEAPA.md`

Pode tocar com parcimônia:

- `backend/schemas/contratos_v1.py`
- `mobile/types/contratos-v1.ts`

Não deve tocar:

- telas do app
- fluxo de mapa/CAD
- UX do portal do cliente

Definition of Done:

- schema canônico definido e documentado
- plano de reconciliação de migrations pronto
- tabelas novas e relações principais especificadas
- impacto nos contratos mapeado

Bloqueio de consulta:

- qualquer `migration repair`
- qualquer criação definitiva de banco novo em produção

---

### Agente 2 — Persistência Real e Storage

Missão:

- eliminar caminhos silenciosos fora do banco oficial
- garantir que dados e arquivos parem de cair em disco local
- preparar a persistência web real

Ownership principal:

- `backend/integracoes/areas_projeto.py`
- `backend/integracoes/referencia_cliente.py`
- `backend/integracoes/arquivos_projeto.py`
- `mobile/lib/db.web.ts`
- `mobile/lib/sync.ts`

Pode tocar com parcimônia:

- `backend/routes/pontos.py`
- `backend/routes/perimetros.py`
- `backend/routes/importar.py`

Não deve tocar:

- auth
- magic link
- regras do dossiê interno

Definition of Done:

- sem fallback em `json` local para áreas
- sem fallback em `json` local para geometria de referência
- sem `local://` como storage final
- persistência web real implementada

Bloqueio de consulta:

- se a remoção de fallback quebrar algum fluxo real ainda não coberto

---

### Agente 3 — Identidade, Magic Link e Acesso

Missão:

- consolidar o modelo canônico de `magic link`
- endurecer autenticação e consumo de contexto externo
- preparar a trilha para autorização por objeto

Ownership principal:

- `backend/middleware/auth.py`
- `backend/routes/documentos.py`
- `backend/integracoes/projeto_clientes.py`

Pode tocar com parcimônia:

- `backend/main.py`
- `backend/routes/projetos.py`
- `backend/schemas/contratos_v1.py`

Não deve tocar:

- storage cartográfico
- sync web
- mapa/CAD

Definition of Done:

- um único modelo de `magic link` definido
- consumo de token sem ambiguidade
- trilha de auth mais previsível
- dependências do legado identificadas

Bloqueio de consulta:

- remoção definitiva de `clientes.magic_link_*`
- mudança estrutural de auth que afete operação já em uso

---

### Agente 4 — Contratos e Superfícies do App

Missão:

- alinhar backend e frontend com a base real
- garantir que contratos representem o banco de verdade, não suposições
- preparar o app para consumir os novos blocos canônicos

Ownership principal:

- `backend/schemas/contratos_v1.py`
- `mobile/types/contratos-v1.ts`
- `backend/routes/projetos.py`
- `mobile/app/(tabs)/projeto/index.tsx`
- `mobile/app/(tabs)/projeto/[id].tsx`

Pode tocar com parcimônia:

- `mobile/lib/api.ts`

Não deve tocar:

- migrations
- auth
- storage

Definition of Done:

- contratos revalidados contra o banco real
- telas principais consumindo payloads coerentes
- sem campo fantasma nem `best effort` escondido

## Ordem recomendada

### Fase 1 — Preparação estrutural

1. Agente 1 mapeia schema canônico e impacto de migrations
2. Agente 3 mapeia dependências reais do legado de `magic link`
3. Agente 2 mapeia todos os fallbacks e pontos de persistência fora do banco

### Fase 2 — Base oficial

1. Agente 1 prepara a trilha de schema/migrations
2. consultar o responsável antes de `repair` ou criação definitiva de banco novo
3. Agente 4 ajusta contratos ao schema estabilizado

### Fase 3 — Funcionamento real

1. Agente 2 remove fallbacks e implementa persistência web real
2. Agente 3 consolida `magic link` e auth
3. Agente 4 ajusta backend e telas para o banco real

## Distribuição prática em paralelo

Paralelismo seguro:

- Agente 1 pode trabalhar em paralelo com Agente 2
- Agente 3 pode trabalhar em paralelo com Agente 1, desde que não altere contratos sozinho
- Agente 4 deve entrar forte depois que o schema alvo estiver claro

Paralelismo arriscado:

- Agente 1 e Agente 4 alterando contratos ao mesmo tempo
- Agente 2 e Agente 3 mexendo juntos em `documentos.py`
- qualquer agente alterando migrations enquanto outro executa `db pull/push/repair`

## Próximo passo operacional recomendado

1. Agente 1 fecha o desenho físico da base canônica
2. Agente 2 levanta a lista executável de remoção de fallback
3. Agente 3 fecha o diagnóstico do legado de `magic link`
4. Agente 4 só começa a refinar contratos depois disso

## Resultado esperado

Ao fim dessa distribuição:

- o banco deixa de ser tolerante e passa a ser canônico
- o app deixa de “funcionar por improviso”
- o legado fica visível e com prazo de remoção
- a nova base nasce com modelagem rural correta
