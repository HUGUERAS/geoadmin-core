# GeoAdmin Pro — Tasks de Banco para Funcionamento Real do App

## Propósito

Este documento consolida a auditoria do `Supabase` e de todos os arquivos que hoje influenciam persistência, schema, storage, sync e contratos do banco no `GeoAdmin Pro`.

A premissa aqui é explícita:

- esta **não é** uma versão de teste
- não devemos depender de `stub`, `mock`, `hook`, `fallback local` ou compatibilidade silenciosa como solução final
- quando houver falha que exija escolha estrutural, a decisão deve ser consultada com o responsável antes da execução

## Escopo auditado

### Supabase e schema

- [infra/supabase/config.toml](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\infra\supabase\config.toml)
- [infra/supabase/database.types.ts](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\infra\supabase\database.types.ts)
- [infra/supabase/migrations](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\infra\supabase\migrations)

### Backend que influencia banco, storage e auth

- [backend/main.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\main.py)
- [backend/middleware/auth.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\middleware\auth.py)
- [backend/routes/projetos.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\routes\projetos.py)
- [backend/routes/documentos.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\routes\documentos.py)
- [backend/routes/pontos.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\routes\pontos.py)
- [backend/routes/perimetros.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\routes\perimetros.py)
- [backend/routes/clientes/routes.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\routes\clientes\routes.py)
- [backend/routes/clientes/crud.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\routes\clientes\crud.py)
- [backend/routes/importar.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\routes\importar.py)
- [backend/integracoes/areas_projeto.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\integracoes\areas_projeto.py)
- [backend/integracoes/referencia_cliente.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\integracoes\referencia_cliente.py)
- [backend/integracoes/arquivos_projeto.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\integracoes\arquivos_projeto.py)
- [backend/integracoes/projeto_clientes.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\integracoes\projeto_clientes.py)
- [backend/schemas/contratos_v1.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\schemas\contratos_v1.py)

### Mobile/Web que influencia persistência e sync

- [mobile/lib/api.ts](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\mobile\lib\api.ts)
- [mobile/lib/db.ts](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\mobile\lib\db.ts)
- [mobile/lib/db.web.ts](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\mobile\lib\db.web.ts)
- [mobile/lib/sync.ts](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\mobile\lib\sync.ts)
- [mobile/types/contratos-v1.ts](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\mobile\types\contratos-v1.ts)

## Verificações executadas

### Supabase CLI

Executado com sucesso:

```bash
npx supabase migration list --workdir infra
supabase db lint --linked --workdir infra
```

Resultado importante:

- o `npx supabase` conseguiu listar as migrations remotas e locais
- o `supabase` global instalado no ambiente falhou para `migration list` com erro de autenticação do usuário `cli_login_postgres`

Conclusão operacional:

- o projeto deve padronizar o uso de `npx supabase` ou atualizar a versão global do CLI
- não é seguro depender de duas versões com comportamento diferente

### Banco real confirmado pelos tipos gerados

O schema atual confirmado em [database.types.ts](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\infra\supabase\database.types.ts) inclui, entre outras, as tabelas e views:

- `areas_projeto`
- `arquivos_projeto`
- `documentos_gerados`
- `eventos_magic_link`
- `eventos_cartograficos`
- `geometrias_referencia_cliente`
- `projeto_clientes`
- `area_clientes`
- `perimetros`
- `pontos`
- `vw_formulario_cliente`
- `vw_projetos_completo`

### Lint do banco

O `db lint` retornou alertas e erros em funções do schema `public`, com destaque para:

- `public.st_findextent`
- `public.populate_geometry_columns`
- `public.postgis_full_version`
- `public.lockrow`
- `public.addauth`

Leitura atual:

- parte desse ruído parece vir de funções herdadas de `PostGIS` e objetos legados do banco
- isso não prova sozinho quebra do app
- mas prova que o banco ainda não está “limpo” do ponto de vista estrutural

## Diagnóstico executivo

Hoje o app **funciona**, mas ainda depende de mecanismos que não podem ser a base de uma operação final:

1. há **persistência local silenciosa** no backend em caso de falha do Supabase
2. a web ainda usa **stub** para a camada local de pontos
3. há **compatibilidade legada** de `magic link` e schema que mascara desalinhamento estrutural
4. o histórico de migrations local e remoto está **divergente**
5. a autenticação ainda depende de chamada remota ao Supabase por requisição

## Premissas da nova base canônica

As próximas mudanças estruturais do banco precisam respeitar as decisões já fechadas em [MODELO_DADOS_BASE_CANONICA.md](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\docs\MODELO_DADOS_BASE_CANONICA.md):

- `registro_imobiliario_ampliado` entra na base oficial
- `responsavel_tecnico_oficial` entra na base oficial
- `processo_administrativo_seapa` fica fora desta primeira leva da base canônica
- `vistoria_seapa` fica fora desta primeira leva da base canônica
- por se tratar de área rural, a base deve separar:
  - `endereco_residencial_ou_correspondencia`
  - `endereco_do_imovel_rural`

Essa separação de endereços é obrigatória para evitar mistura entre:

- endereço principal da pessoa
- localização fundiária do imóvel

## Regra de produção adotada

Para a trilha abaixo, passa a valer:

- dado operacional do domínio não pode cair em `json` local como fallback silencioso
- arquivo de produção não pode cair em filesystem local como storage final
- web não pode usar `db.web.ts` stub como se fosse persistência real
- compatibilidade de schema só pode existir com prazo de remoção definido
- falha estrutural de banco deve aparecer como erro operacional observável, não ser escondida pelo app

## Bloqueadores P0

### P0.1 — Reconciliar histórico de migrations do projeto oficial

**Achado**

`npx supabase migration list --workdir infra` mostrou divergência entre:

- local: `014` a `024`
- remoto: `001` a `010` e várias migrations timestampadas `202603...`

**Arquivos / superfícies**

- [infra/supabase/migrations](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\infra\supabase\migrations)
- histórico remoto do projeto `jrlrlsotwsiidglcbifo`

**Risco**

- `db push`, `db pull` e `migration repair` podem causar dano se executados sem estratégia definida
- o time não tem hoje uma linha única de verdade do histórico

**Task**

- definir a trilha canônica de migrations
- comparar schema remoto real com as migrations locais `014..024`
- preparar plano de reconciliação
- só depois executar `migration repair`

**Critério de aceite**

- `npx supabase migration list --workdir infra` sem divergência
- `database.types.ts` regenerado a partir da base reconciliada
- procedimento documentado no repositório

**Decisão pendente**

- aqui é obrigatório consultar antes de rodar `repair`

### P0.2 — Remover fallback local de `areas_projeto`

**Status atual**

- backend ajustado nesta rodada
- fallback local removido do runtime
- testes cobrindo falha explícita já estão passando

**Achado**

[areas_projeto.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\integracoes\areas_projeto.py) ainda usa:

- `backend/data/areas_projeto.json`
- `_carregar_store_local`
- `_salvar_area_local`
- fallback em `listar_areas_projeto`
- fallback em `obter_area`
- fallback em `salvar_area_projeto`
- fallback em `anexar_arquivos_area`

**Risco**

- dados de área podem ficar fora do Supabase sem que a operação perceba
- o app “parece funcionar”, mas a fonte única de verdade deixa de ser o banco oficial

**Task**

- remover persistência em arquivo local dessa integração
- transformar falha no Supabase em erro explícito de backend
- manter uma camada de leitura consistente apenas do banco oficial

**Critério de aceite**

- não existir mais `areas_projeto.json` como caminho ativo de persistência
- salvar/ler área só via tabela `areas_projeto`
- falhas de banco retornarem erro controlado e logado

### P0.3 — Remover fallback local de `geometrias_referencia_cliente`

**Status atual**

- backend ajustado nesta rodada
- fallback local removido do runtime
- testes cobrindo falha explícita já estão passando

**Achado**

[referencia_cliente.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\integracoes\referencia_cliente.py) ainda usa:

- `backend/data/geometrias_referencia_cliente.json`
- `_registro_local_mais_recente`
- `_salvar_registro_local`
- `_remover_registro_local`

**Risco**

- croquis e geometrias de referência podem existir só no disco local
- isso quebra rastreabilidade e continuidade de operação

**Task**

- remover fallback em JSON local
- persistir apenas em `geometrias_referencia_cliente`
- falhar explicitamente se a tabela estiver indisponível

**Critério de aceite**

- geometrias de referência só vivem no banco oficial
- leitura, escrita e remoção não dependem mais do store local

### P0.4 — Remover fallback local de arquivos cartográficos

**Status atual**

- backend ajustado nesta rodada
- `Supabase Storage` já é tratado como obrigatório no runtime
- testes cobrindo falha explícita de storage já estão passando

**Achado**

[arquivos_projeto.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\integracoes\arquivos_projeto.py) ainda grava em filesystem local quando o upload ao Storage falha:

- `UPLOADS_DIR = backend/uploads/arquivos_projeto`
- `LOCAL_STORAGE_PREFIX = "local://"`
- fallback em `salvar_arquivo_projeto`
- rotina de migração posterior de arquivos locais

**Risco**

- produção pode ficar com arquivo físico fora do bucket oficial
- bucket e banco deixam de ser a origem real dos artefatos

**Task**

- tornar `Supabase Storage` obrigatório para este fluxo
- falhar explicitamente se o upload ao bucket falhar
- manter migração de legado apenas como ferramenta administrativa, não como caminho operacional padrão

**Critério de aceite**

- novos arquivos não recebem mais `local://`
- `arquivos_projeto.storage_path` aponta apenas para `supabase://...`
- bucket e políticas estão prontos para o fluxo real

### P0.5 — Substituir `mobile/lib/db.web.ts` stub por persistência real

**Status atual**

- `db.web.ts` foi reescrito para `IndexedDB`
- `sync.ts` foi endurecido para interpretar resultado por item
- o backend já não depende mais do stub web
- ainda falta fechar a validação TypeScript do projeto web, hoje bloqueada por conflito de configuração/tipos do stack `Expo + React Native + DOM`

**Achado**

[db.web.ts](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\mobile\lib\db.web.ts) hoje é stub:

- `salvarPonto` só retorna o id
- `listarPendentes` retorna `[]`
- `contarPendentes` retorna `0`
- não há persistência real dos pontos pendentes

**Risco**

- a web aparenta ter sync/offline, mas não tem
- [sync.ts](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\mobile\lib\sync.ts) fica funcional no nativo e fake na web

**Task**

- implementar persistência real para web
- recomendação técnica: `IndexedDB` com camada equivalente à `db.ts`
- alinhar `sync.ts` para usar a mesma semântica funcional nas duas plataformas

**Critério de aceite**

- ponto salvo na web realmente persiste
- `listarPendentes`, `marcarSincronizado`, `marcarErro` e `contarPendentes` funcionam na web
- o sync web envia e baixa estado real

### P0.6 — Formalizar modelo canônico de `magic link`

**Achado**

Há dois modelos convivendo:

- canônico novo: `projeto_clientes.magic_link_token` / `magic_link_expira` + `eventos_magic_link`
- legado ainda ativo: `clientes.magic_link_token` / `magic_link_expira`

Arquivos centrais:

- [backend/integracoes/projeto_clientes.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\integracoes\projeto_clientes.py)
- [backend/routes/documentos.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\routes\documentos.py)
- [infra/supabase/database.types.ts](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\infra\supabase\database.types.ts)

**Risco**

- comportamento ambíguo
- manutenção duplicada
- fluxo de formulário depende de migração sob demanda

**Task**

- escolher o modelo canônico definitivo
- se a decisão for “participante é a única fonte”, remover o caminho legado de `clientes.magic_link_*`
- se a decisão for manter transição, documentar prazo e condição de remoção

**Estado atual**

- backend e testes já foram ajustados para tratar `projeto_clientes` como fonte operacional
- foi preparada a migration local [025_magic_link_canonico.sql](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\infra\supabase\migrations\025_magic_link_canonico.sql)
- ainda falta aplicar essa consolidação na trilha oficial de migrations reconciliada
- o legado em `clientes.magic_link_*` continua existindo só como compatibilidade de banco, não mais como fonte operacional do runtime

**Critério de aceite**

- `_validar_token` usa um único modelo de verdade
- geração, revogação, reenvio e consumo usam a mesma origem
- não há mais duplicidade de escrita de token sem justificativa explícita

**Decisão pendente**

- aqui também é obrigatório consultar antes de cortar o legado

### P0.7 — Reduzir compatibilidade de schema para estado canônico

**Achado**

[projetos.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\routes\projetos.py) ainda carrega compatibilidades como:

- `_payload_cliente_compativel`
- `_criar_cliente_compativel`
- `_inserir_projeto_compativel`
- `_atualizar_projeto_compativel`

Além disso, [documentos.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\routes\documentos.py) e [projeto_clientes.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\integracoes\projeto_clientes.py) ainda lidam com colunas antigas.

**Risco**

- o backend continua aceitando banco “quase certo”
- isso mascara desalinhamento do schema

**Task**

- depois da reconciliação de migrations, definir schema alvo
- reduzir gradualmente os caminhos compatíveis
- manter somente os campos realmente existentes no banco oficial

**Critério de aceite**

- rotas deixam de depender de fallback para colunas ausentes
- contratos e schema convergem

### P0.8 — Separar endereço principal da pessoa e endereço do imóvel rural na base canônica

**Achado**

O domínio rural do projeto exige distinguir dois contextos que hoje ainda aparecem misturados em partes do schema e dos formulários:

- endereço principal da pessoa para residência ou correspondência
- onde o imóvel rural está localizado

**Risco**

- correspondência sair para o endereço errado
- formulário usar endereço do imóvel como endereço pessoal
- peças fundiárias confundirem endereço do requerente com localização do imóvel

**Task**

- modelar `endereco_residencial_ou_correspondencia` e `endereco_do_imovel_rural` como estruturas distintas na nova base
- evitar um campo único `endereco` como solução final
- alinhar contratos e geradores documentais a essa separação

**Critério de aceite**

- a base nova distingue explicitamente endereço da pessoa e endereço do imóvel
- formulários do requerente usam `endereco_residencial_ou_correspondencia`
- peças do imóvel usam somente `endereco_do_imovel_rural`

## P1 — Segurança e plataforma de banco

### P1.1 — Trocar validação remota por validação local de JWT/JWKS

**Achado**

[auth.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\middleware\auth.py) usa `supabase.auth.get_user(token)` a cada requisição protegida.

**Risco**

- dependência externa por request
- custo operacional maior
- mais ponto de falha em produção

**Task**

- migrar para validação local de JWT/JWKS
- manter fallback de desenvolvimento apenas por configuração explícita

**Critério de aceite**

- autenticação validada localmente
- role e `sub` resolvidos sem roundtrip remoto por request

### P1.2 — Formalizar autorização por objeto

**Achado**

Há autenticação, mas ainda não há camada formal de autorização por `projeto`, `área`, `cliente`, `documento` e `arquivo`.

**Task**

- criar verificadores por recurso
- bloquear leitura/escrita fora do escopo do usuário

**Critério de aceite**

- cada rota crítica valida acesso ao recurso pedido

### P1.3 — Endurecer bucket e policies do Storage

**Achado**

O bucket esperado é `arquivos-projeto`, mas o fluxo ainda precisa de política explícita por tipo de arquivo.

**Task**

- definir estrutura de paths por:
  - uploads do cliente
  - arquivos cartográficos internos
  - documentos gerados
- revisar policies de acesso

**Critério de aceite**

- storage organizado por classe de artefato
- acesso consistente com o papel de cada ator

### P1.4 — Resolver ruído do `db lint`

**Achado**

O `db lint` não está limpo.

**Task**

- separar alertas herdados de extensão/PostGIS dos problemas realmente do projeto
- documentar os itens que podem ser ignorados e os que exigem limpeza

**Bloqueio atual**

- para rodar `npx supabase db lint --linked --workdir infra` contra o banco remoto oficial, o ambiente precisa de `SUPABASE_DB_PASSWORD`
- sem isso, a inspeção remota de lint e outras operações profundas de banco não podem ser concluídas com segurança

**Critério de aceite**

- o time sabe quais findings são reais e quais são ruído de extensão

## P1 — Contratos e consistência

### P1.5 — Alinhar contratos V1 ao schema real, não ao desejado

**Achado**

Os contratos em:

- [backend/schemas/contratos_v1.py](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\backend\schemas\contratos_v1.py)
- [mobile/types/contratos-v1.ts](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\mobile\types\contratos-v1.ts)

já avançaram bastante, mas ainda precisam ser revalidados após a estabilização do schema oficial.

**Task**

- regenerar [database.types.ts](C:\Users\User\.codex\worktrees\db9b\GeoAdmin-Pro\infra\supabase\database.types.ts) após reconciliação
- revisar contratos V1 contra o banco real
- revisar rotas que serializam `ProjetoOficialV1`, `PainelDocumentalProjetoV1` e `EstadoPortalClienteV1`

**Critério de aceite**

- banco, backend e frontend falam a mesma língua sem `best effort`

### P1.6 — Estruturar `registro_imobiliario_ampliado` e `responsavel_tecnico_oficial` como blocos oficiais

**Achado**

Os formulários e geradores do projeto já exigem dados registrais e técnicos mais ricos, mas o banco atual ainda não consolidou esses blocos como fonte única formal.

**Task**

- modelar `registro_imobiliario_ampliado` ligado ao imóvel
- modelar `responsavel_tecnico_oficial` como bloco formal do domínio
- revisar o gerador documental para consumir esses dados estruturados

**Critério de aceite**

- matrícula, cartório, CNS/CNM e origem registral deixam de depender de texto solto
- técnico responsável deixa de depender de leitura parcial de tabela/template
- documentos e peças técnicas passam a consumir esses blocos oficiais

## P2 — Qualidade operacional

### P2.1 — Consolidar testes reais de banco e storage

**Task**

- criar smoke tests para:
  - `GET /projetos`
  - `GET /projetos/{id}`
  - `POST /projetos/{id}/magic-link`
  - `GET /formulario/cliente/contexto`
  - `POST /formulario/cliente`
  - `POST /pontos/sync`
  - upload real em `arquivos_projeto`

**Critério de aceite**

- os fluxos críticos passam contra o banco oficial de desenvolvimento

### P2.2 — Padronizar ferramenta oficial de CLI

**Achado**

- `supabase` global atual: comportamento inconsistente
- `npx supabase`: comportamento correto para listar migrations

**Task**

- padronizar scripts e documentação em cima de uma única versão do CLI

**Critério de aceite**

- a equipe usa o mesmo comando e obtém o mesmo resultado

## Ordem recomendada de execução

### Pacote A — Base estrutural

1. `P0.1` reconciliar migrations
2. `P0.7` reduzir compatibilidade de schema
3. `P0.8` separar endereços do domínio rural
4. `P1.5` revalidar contratos
5. `P1.6` estruturar blocos registrais e técnicos oficiais

### Pacote B — Persistência canônica

1. `P0.2` remover fallback de `areas_projeto`
2. `P0.3` remover fallback de `geometrias_referencia_cliente`
3. `P0.4` remover fallback de `arquivos_projeto`

### Pacote C — Fluxos reais do produto

1. `P0.6` fechar modelo de magic link
2. `P0.5` implementar persistência real na web
3. validar `sync.ts` ponta a ponta

### Pacote D — Hardening

1. `P1.1` JWT/JWKS
2. `P1.2` autorização por objeto
3. `P1.3` policies de storage
4. `P1.4` lint do banco

## Itens que exigem consulta antes de agir

### Consulta obrigatória 1 — Reparo do histórico de migrations

Antes de executar qualquer `repair`, confirmar:

- qual trilha de migration será a oficial
- se o remoto deve ser ajustado para refletir `014..024`
- ou se o repositório deve absorver a linhagem remota antiga

### Consulta obrigatória 2 — Corte do legado de `magic link`

Antes de remover o caminho baseado em `clientes.magic_link_*`, confirmar:

- se ainda existe operação real dependendo dele
- ou se podemos migrar definitivamente para `projeto_clientes`

## Ferramentas necessárias

### Obrigatórias

- `npx supabase`
- `python`
- `pytest`
- `node` / `npm`

### Recomendadas

- `psql`
- `pip-audit`
- `npm audit`
- `semgrep`
- `bandit`

## Resultado esperado ao fim desta trilha

Quando este taskbook estiver concluído:

- o banco oficial será a única fonte de verdade
- a web e o mobile terão persistência coerente com o produto real
- uploads e documentos usarão storage oficial sem fallback silencioso
- o fluxo de `magic link` será único e auditável
- schema, migrations e contratos estarão alinhados
- o app deixará de “funcionar por tolerância” e passará a funcionar por arquitetura correta
