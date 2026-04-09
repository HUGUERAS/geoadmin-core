# GeoAdmin Pro - Base Canonica: Plano de Implementacao

## Objetivo

Este documento traduz a base canonica nova em um plano de implementacao concreto para o banco.

Escopo:

- estruturar `registro_imobiliario_ampliado`
- estruturar `responsavel_tecnico_oficial`
- separar endereco principal da pessoa e endereco do imovel rural
- reduzir dependencia de campos soltos e de semantica ambigua
- orientar a ordem de migrations e o impacto nos contratos V1

Fora de escopo:

- rotas de backend
- telas do app
- OCR
- fluxos de `magic link`
- processo administrativo SEAPA e ficha de vistoria

## Decisoes fechadas

- `registro_imobiliario_ampliado` entra na base oficial
- `responsavel_tecnico_oficial` entra na base oficial
- `processo_administrativo_seapa` fica fora desta leva
- `vistoria_seapa` fica fora desta leva
- endereco da pessoa e endereco do imovel rural nao podem ser confundidos
- a forma canonica do contato da pessoa fica como `endereco_residencial_ou_correspondencia`
- a localizacao fundiaria fica como `endereco_do_imovel_rural`

## Modelo logico recomendado

### 1. Pessoas

Tabela base: `pessoas`

Responsabilidade:

- identificar o requerente, proprietario, possuidor, representante ou outro participante

Campos principais:

- `id` UUID PK
- `nome` text not null
- `cpf_cnpj` text null
- `rg` text null
- `estado_civil` text null
- `profissao` text null
- `telefone` text null
- `email` text null
- `tipo_pessoa` text not null default `'fisica'`
- `criado_em` timestamptz not null default now()
- `atualizado_em` timestamptz not null default now()
- `deleted_at` timestamptz null

Constraints recomendadas:

- PK em UUID com `gen_random_uuid()`
- `cpf_cnpj` unique parcial quando nao nulo
- `tipo_pessoa` com `CHECK (tipo_pessoa in ('fisica','juridica'))`

### 2. Endereco da pessoa

Tabela base: `pessoa_enderecos`

Responsabilidade:

- guardar o endereco principal da pessoa para residencia ou correspondencia

Campos principais:

- `id` UUID PK
- `pessoa_id` UUID FK -> `pessoas.id`
- `logradouro` text not null
- `numero` text null
- `complemento` text null
- `bairro_setor` text null
- `municipio` text null
- `estado` text null
- `cep` text null
- `referencia` text null
- `principal` boolean not null default true
- `uso_endereco` text not null default `'residencial_ou_correspondencia'`
- `criado_em` timestamptz not null default now()
- `atualizado_em` timestamptz not null default now()

Valores permitidos para `uso_endereco`:

- `residencial_ou_correspondencia`
- `comercial`
- `outro`

Constraints recomendadas:

- FK com `ON DELETE CASCADE`
- `CHECK (uso_endereco in (...))`
- indice em `pessoa_id`
- unique parcial por pessoa para o endereco principal:
  - `UNIQUE (pessoa_id) WHERE principal = true`

Regra funcional:

- esta tabela nao representa o imovel
- esta tabela nao deve ser usada como gambiarra de observacao

### 3. Imoveis

Tabela base: `imoveis`

Responsabilidade:

- representar o imovel rural como entidade propria

Campos principais:

- `id` UUID PK
- `projeto_id` UUID FK -> `projetos.id`
- `nome_imovel` text not null
- `tipo_imovel` text not null default `'rural'`
- `municipio` text null
- `estado` text null
- `comarca` text null
- `endereco_do_imovel_rural` text null
- `numero_imovel` text null
- `complemento_imovel` text null
- `bairro_setor_imovel` text null
- `cep_imovel` text null
- `area_total_ha` numeric(14,4) null
- `criado_em` timestamptz not null default now()
- `atualizado_em` timestamptz not null default now()
- `deleted_at` timestamptz null

Constraints recomendadas:

- FK com `ON DELETE CASCADE`
- `CHECK (tipo_imovel in ('rural','urbano'))`
- indice em `projeto_id`
- se houver matricula principal, considerar `UNIQUE (projeto_id, nome_imovel)` ou regra equivalente

Regra funcional:

- o endereco do imovel rural e distinto do endereco da pessoa
- esse campo nao pode ser reaproveitado como endereco do requerente

### 4. Registro imobiliario ampliado

Tabela base: `registros_imobiliarios`

Responsabilidade:

- consolidar o bloco registral do imovel com mais riqueza que o modelo atual

Campos principais:

- `id` UUID PK
- `imovel_id` UUID FK -> `imoveis.id`
- `matricula` text null
- `transcricao` text null
- `cnm` text null
- `cns` text null
- `cartorio` text null
- `comarca` text null
- `livro` text null
- `folha` text null
- `data_registro` date null
- `municipio_cartorio` text null
- `uf_cartorio` text null
- `origem_registro` text null
- `observacoes` text null
- `criado_em` timestamptz not null default now()
- `atualizado_em` timestamptz not null default now()
- `deleted_at` timestamptz null

Constraints recomendadas:

- FK com `ON DELETE CASCADE`
- indice em `imovel_id`
- `UNIQUE (imovel_id)` para a versao canonica inicial
- check de `uf_cartorio` quando preenchida com 2 letras

Regra funcional:

- este bloco deve ser ligado ao imovel, nao a pessoa
- se precisar de historico futuramente, a evolucao deve adicionar vigencia/versao, nao voltar para texto solto

### 5. Responsavel tecnico oficial

Tabela base: `responsaveis_tecnicos`

Responsabilidade:

- consolidar o tecnico oficial do projeto em bloco estruturado

Campos principais:

- `id` UUID PK
- `nome` text not null
- `cpf` text null
- `profissao` text null
- `tipo_conselho` text null
- `numero_conselho` text null
- `registro_conselho` text null
- `codigo_incra` text null
- `art_trt` text null
- `qualificacao_profissional` text null
- `ativo` boolean not null default true
- `criado_em` timestamptz not null default now()
- `atualizado_em` timestamptz not null default now()
- `deleted_at` timestamptz null

Constraints recomendadas:

- `nome` not null
- indice em `ativo`
- `CHECK (ativo in (true,false))`
- se houver um tecnico principal por projeto, usar tabela de ligacao com `principal = true`

### 6. Relacao projeto-pessoa

Tabela base: `projeto_pessoas`

Responsabilidade:

- ligar pessoas ao projeto com papel operacional

Campos principais:

- `id` UUID PK
- `projeto_id` UUID FK -> `projetos.id`
- `pessoa_id` UUID FK -> `pessoas.id`
- `papel` text not null
- `principal` boolean not null default false
- `recebe_magic_link` boolean not null default false
- `ordem` integer not null default 0
- `area_id` UUID null
- `criado_em` timestamptz not null default now()
- `atualizado_em` timestamptz not null default now()
- `deleted_at` timestamptz null

Observacao:

- este documento nao define o corte do legado de `projeto_clientes`; ele define o destino canonico

Constraints recomendadas:

- indices em `projeto_id` e `pessoa_id`
- unique parcial por projeto e pessoa ativa
- uma pessoa principal por projeto

### 7. Relacao projeto-tecnico

Tabela base: `projeto_responsaveis_tecnicos`

Responsabilidade:

- vincular tecnico oficial ao projeto

Campos principais:

- `id` UUID PK
- `projeto_id` UUID FK -> `projetos.id`
- `responsavel_tecnico_id` UUID FK -> `responsaveis_tecnicos.id`
- `principal` boolean not null default true
- `vigente_desde` timestamptz null
- `vigente_ate` timestamptz null
- `observacao` text null
- `criado_em` timestamptz not null default now()
- `atualizado_em` timestamptz not null default now()

Constraints recomendadas:

- indice em `projeto_id`
- indice em `responsavel_tecnico_id`
- unique parcial para tecnico principal vigente por projeto

## Relacoes principais

```text
projetos
  ├── imoveis
  │     └── registros_imobiliarios
  ├── projeto_pessoas
  │     └── pessoas
  │           └── pessoa_enderecos
  ├── projeto_responsaveis_tecnicos
  │     └── responsaveis_tecnicos
  ├── areas_projeto
  ├── perimetros
  ├── pontos
  ├── confrontantes
  ├── documentos
  ├── documentos_gerados
  ├── arquivos_projeto
  ├── eventos_magic_link
  └── eventos_cartograficos
```

## Constraints transversais importantes

- todo PK deve ser UUID com `gen_random_uuid()`
- toda FK critica deve ter indice
- toda data/hora deve usar `timestamptz`
- todo status deve ter `CHECK` com valores permitidos
- nenhum endereco deve ser armazenado em campo solto de observacao
- nenhum dado registral deve depender apenas de template
- nenhum dado tecnico deve depender apenas de texto gerado

## Ordem recomendada de migrations

### Fase 1 - Fundacao

1. criar `pessoas`
2. criar `pessoa_enderecos`
3. criar `imoveis`
4. criar `registros_imobiliarios`
5. criar `responsaveis_tecnicos`
6. criar `projeto_pessoas`
7. criar `projeto_responsaveis_tecnicos`

### Fase 2 - Backfill e compatibilidade

1. popular `pessoas` a partir de `clientes`
2. popular `pessoa_enderecos` a partir do endereco atual do requerente
3. popular `imoveis` a partir de `projetos` e `areas_projeto`
4. popular `registros_imobiliarios` a partir de `matricula`, `comarca`, `cartorio` e campos analogos
5. popular `responsaveis_tecnicos` a partir de dados existentes em documentos e tabelas legadas

### Fase 3 - Convergencia

1. adaptar views e contratos para ler da base nova
2. reduzir dependencia de colunas soltas antigas
3. definir prazo de remocao do legado
4. somente depois disso considerar `repair` de migrations antigas

## Impacto nos contratos V1

### Mantem compatibilidade inicial

- `ProjetoOficialV1` continua sendo o contrato agregado principal
- `ResumoProjetoOperacionalV1` continua alimentando a lista e o dashboard
- `PainelDocumentalProjetoV1` continua sendo a leitura documental
- `EstadoPortalClienteV1` continua sendo o contrato externo do cliente

### Ajustes semanticos esperados

- `PessoaProjetoV1.endereco_correspondencia` deve passar a ser derivado de `pessoa_enderecos.uso_endereco = 'residencial_ou_correspondencia'`
- `ImovelProjetoV1.endereco` deve ser derivado de `imoveis.endereco_do_imovel_rural`
- `RegistroImobiliarioV1` deve ser preenchido a partir de `registros_imobiliarios`
- `ResponsavelTecnicoV1` deve ser preenchido a partir de `responsaveis_tecnicos`

### Mudancas que podem esperar a proxima revisao de contrato

- renomear explicitamente o campo de endereco do imovel em V1 para `endereco_do_imovel_rural`
- expor `endereco_residencial_ou_correspondencia` com esse nome no contrato agregado
- adicionar ids/relacoes mais formais para pessoa, imovel e tecnico em vez de apenas textos derivado

## Riscos de migracao

### 1. Divergencia entre legado e base nova

Risco:

- tabelas antigas e novas conviverem por tempo demais

Mitigacao:

- definir contratos de leitura e escrita por fase
- colocar prazo de remoção para o legado

### 2. Backfill incompleto

Risco:

- pessoas, imoveis ou tecnicos antigos nao terem dados suficientes para migrar automaticamente

Mitigacao:

- criar relatorio de cobertura de backfill
- tratar lacunas como pendencias operacionais visiveis

### 3. Confusao de endereco

Risco:

- endereco do requerente, correspondencia e imovel voltarem a ser tratados como uma coisa so

Mitigacao:

- manter a regra no schema e nos contratos
- nunca usar o endereco do imovel como endereco da pessoa

### 4. Reaproveitamento indevido de colunas soltas

Risco:

- o backend continuar aceitando colunas antigas por tolerancia

Mitigacao:

- remover compatibilidade gradualmente
- manter apenas o necessario ate concluir a migracao

### 5. Migrations antigas desalinhadas

Risco:

- tentar `repair` ou `push` sem uma linha unica de verdade

Mitigacao:

- primeiro reconciliar o historico
- depois aplicar a nova base canonica

## Definition of Done

- a modelagem nova esta documentada
- as tabelas da base canonica estao definidas
- a separacao de enderecos esta clara
- o tecnico e o registro imobiliario viraram blocos oficiais
- a ordem de migrations esta descrita
- o impacto em contratos V1 esta mapeado
- os riscos de migracao estao visiveis

## Arquivos alterados

- `docs/BASE_CANONICA_IMPLEMENTACAO.md`
