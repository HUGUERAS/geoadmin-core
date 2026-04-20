# GeoAdmin Core — Contexto para Codex

## O Projeto
`GeoAdmin Core` é o repositório oficial do produto GeoAdmin. Ele concentra o núcleo operacional do sistema de administração geoespacial para topografia, georreferenciamento e gestão de projetos rurais.

## Stack
| Camada | Tecnologia | Diretório |
|---|---|---|
| Mobile | React Native (Expo 54 + Expo Router) | `mobile/` |
| Backend | FastAPI (Python) | `backend/` |
| Banco | Supabase + PostGIS | — |
| Integração | Métrica TOPO via `POST /metrica/txt` | `backend/integracoes/` |

## Arquitetura
- `GeoAdmin Core` é o repositório oficial do produto, e o banco oficial + storage oficial são a **fonte única de verdade** — não replicar dados em múltiplos sistemas
- Credenciais **exclusivamente em `.env`** — nunca commitar
- URL do backend via [mobile/lib/api.ts](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile\lib\api.ts) — fallbacks só no desenvolvimento local; builds publicados exigem `EXPO_PUBLIC_API_BASE_URL`
- Arquitetura oficial de produção: `Vercel` para web, `Cloud Run` para API e `Supabase` para banco/auth/storage
- `RAG Topografia` fica fora do escopo deste repositório por enquanto

## Governança de Segurança

- Mudanças em autenticação, autorização, `magic links`, uploads, downloads, geração documental, exportação técnica, `proxy`, rotas públicas e integrações externas exigem revisão de segurança.
- O projeto adota duas frentes permanentes de revisão:
  - `security-backend-reviewer`
  - `security-frontend-docs-reviewer`
- O projeto também adota as seguintes skills operacionais:
  - `geoadmin-security-baseline`
  - `geoadmin-security-review`
  - `geoadmin-document-data-security` (recomendada para documentos e dados sensíveis)
- Regras detalhadas em [docs/GOVERNANCA_SEGURANCA.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\GOVERNANCA_SEGURANCA.md)
- Nenhuma mudança sensível deve entrar sem passar por pelo menos um agente de segurança.

## Governança de Banco de Dados

- O agente oficial de banco do projeto é:
  - [db-manager.agent.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\.github\agents\db-manager.agent.md)
- Esse agente deve ser acionado como **padrão obrigatório** sempre que a tarefa tocar:
  - `Supabase`, `Postgres`, `schema`, `migration`, `SQL`, `database.types.ts`
  - qualquer tabela, view, policy, índice, constraint, função ou storage metadata
  - persistência de `projetos`, `clientes`, `projeto_clientes`, `areas_projeto`, `area_clientes`, `documentos`, `arquivos_projeto`, `eventos_magic_link`, `confrontantes` ou `confrontacoes_revisadas`
  - qualquer contrato de aplicação dependente do banco
- Em tarefa mista, o agente de banco entra primeiro para validar impacto em schema, integridade, segurança e contratos.
- Antes de qualquer migration estrutural, auditoria de schema ou investigação de bug de dado, também deve ser usada a skill:
  - [geoadmin-schema-audit](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\.codex\skills\geoadmin-schema-audit\SKILL.md)

### Regra Prática de Acionamento

- `mudou dado persistido?` chama
- `mudou contrato dependente do banco?` chama
- `mudou só layout, navegação, estilo ou copy?` não precisa

### Interpretação Operacional

- `obrigatório`:
  - schema, migrations, SQL, views, policies, grants, índices, constraints
  - qualquer leitura ou escrita nova em Supabase/Postgres
  - mudanças em contratos que dependem do banco
  - fluxos de documentos, protocolos, `magic links`, storage metadata ou persistência de cliente/projeto/área
- `recomendado`:
  - tarefas mistas em que o backend ou frontend continua igual, mas o formato ou a origem do dado pode mudar
  - investigações de inconsistência de dados, performance de consulta ou tipagem gerada
- `não precisa`:
  - ajustes de layout, UX, copy, estilo visual e navegação sem impacto em persistência ou contratos de dados

## Continuidade de Contexto

- Quando a janela de contexto estiver se aproximando de `70%`, o agente deve parar de abrir novas frentes amplas e consolidar o estado do trabalho.
- Antes de qualquer compactação, o agente deve atualizar a referência central se houver mudança estrutural relevante.
- Após a compactação, o **primeiro documento a ser lido** deve ser:
  - [docs/REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md)
- Só depois desse documento o agente deve reler:
  - `AGENTS.md`
  - documentação operacional específica da frente ativa

## Backend (FastAPI)
**Entry point:** `backend/main.py`

Rotas:
- `GET /health` — healthcheck
- `GET /projetos` — lista projetos do Supabase
- `GET /projetos/{id}` — detalhe do projeto
- `POST /projetos/{id}/magic-link` — gera link WhatsApp para cliente
- `POST /projetos/{id}/gerar-documentos` — gera docs GPRF
- `POST /geo/inverso` — distância e azimute entre 2 pontos (UTM)
- `POST /geo/area` — área (m², ha) e perímetro de polígono UTM
- `POST /geo/converter/utm-geo` — UTM → Geográfico (SIRGAS 2000 / pyproj)
- `POST /geo/converter/geo-utm` — Geográfico → UTM (SIRGAS 2000 / pyproj)
- `POST /geo/intersecao` — interseção de duas semiretas (ponto + azimute)
- `POST /geo/distancia-ponto-linha` — distância perpendicular ponto-segmento
- `POST /geo/rotacao` — rotação de pontos UTM em torno de origem
- `POST /geo/subdivisao` — subdivisão de polígono por área alvo (bisseção)
- `POST /metrica/txt` — exportação para Métrica TOPO (recebe JSON, retorna TXT)

**Rotas de cálculo** definidas em `backend/routes/geo.py` e registradas em `main.py`.

**Deploy:** Cloud Run para a API e Vercel para a web, com `Supabase` como banco/storage

**Variáveis de ambiente necessárias:**
```
SUPABASE_URL=https://jrlrlsotwsiidglcbifo.supabase.co
SUPABASE_KEY=<service_key>
PUBLIC_APP_URL=https://SEU-FRONT.vercel.app
```

## Mobile (Expo)
**Navegação:** Expo Router com 4 tabs — Projetos, Cálculos, Mapa, Clientes

**Tabs ativas:**
- `Projetos` — lista + detalhe (`projeto/index.tsx`, `projeto/[id].tsx`)
- `Cálculos` — grade de ferramentas geodésicas (`calculos/index.tsx`)
- `Mapa` — Vista CAD + editor de perímetro (`mapa/[id].tsx`)

**Tabs placeholder:**
- `Clientes` — gestão de clientes

### Filosofia das Ferramentas de Cálculo

> **Todas as ferramentas da aba Cálculos existem para servir o ambiente CAD.**

Cada ferramenta é um auxílio ao trabalho topográfico dentro do editor de perímetro e da vista CAD. O fluxo esperado é:
- O topógrafo trabalha na **Vista CAD** (aba Mapa) editando vértices do perímetro
- Quando precisa de um cálculo auxiliar (azimute, área, irradiação, interseção etc.), acessa a **aba Cálculos**
- O resultado alimenta o trabalho de volta no CAD

Consequência direta: qualquer nova ferramenta deve ser projetada pensando em **como ela apoia a edição de vértices, perímetros e a vista CAD**. Ferramentas que calculam coordenadas de novos pontos (Irradiação, Interseção) devem, em versões futuras, permitir inserir o ponto resultante diretamente no perímetro ativo.

**Ferramentas implementadas** (`calculos/`):
| Ferramenta | Arquivo | Tipo | Endpoint |
|---|---|---|---|
| Inverso | `inverso.tsx` | backend | `POST /geo/inverso` |
| Área | `area.tsx` | backend | `POST /geo/area` |
| Conversão | `conversao.tsx` | backend | `POST /geo/converter/*` |
| Deflexão | `deflexao.tsx` | frontend | — |
| Interseção | `intersecao.tsx` | backend | `POST /geo/intersecao` |
| Dist. P-L | `distancia.tsx` | backend | `POST /geo/distancia-ponto-linha` |
| Rotação | `rotacao.tsx` | backend | `POST /geo/rotacao` |
| Média Pts | `media.tsx` | frontend | — |
| Irradiação | `irradiacao.tsx` | frontend | — |
| Subdivisão | `subdivisao.tsx` | backend | `POST /geo/subdivisao` |
| GNSS BT | `bluetooth.tsx` | nativo | — (Android only) |

**Componentes reutilizáveis:** `ProjetoCard`, `StatusBadge`, `FerramentaBtn`

**Constantes:** `Colors.ts` (paleta dark), `mobile/lib/api.ts` (resolução da URL do backend)

**EAS Build:**
- Perfil `preview` → APK Android para instalação direta
- Perfil `production` → AAB para Play Store
- `app.json` já configurado com `slug`, `android.package`, `extra.eas.projectId`, `owner`

**Build APK:**
```bash
cd mobile
npx eas-cli@latest build --platform android --profile preview
```

## Status dos Módulos
| Módulo | Status |
|---|---|
| Projetos (lista + detalhe) | ✅ Implementado |
| Cálculo Inverso | ✅ Implementado |
| Exportação Métrica TOPO | ✅ Implementado |
| Geração de Documentos GPRF | ✅ Implementado |
| Mapa / Vista CAD + editor de perímetro | ✅ Implementado |
| Ferramentas geodésicas (Área, Conversão, Deflexão, Interseção, Dist.P-L, Rotação, Média, Irradiação, Subdivisão) | ✅ Implementado |
| Versão web (browser) | ✅ Implementado |
| Gestão de Clientes | 🔜 Em breve |
| Integração Ferramentas → CAD (inserir ponto calculado direto no perímetro) | 🔜 Próxima fase |

## Convenções
- Tema: **dark only** — sempre usar `Colors.dark`
- Idioma do código: variáveis e funções em **português** (ex: `carregar`, `setProjetos`)
- Status dos projetos: `medicao`, `montagem`, `protocolado`, `aprovado`, `finalizado`
- Coordenadas: sistema UTM (Norte/Este em metros)
