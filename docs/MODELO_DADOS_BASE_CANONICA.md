# GeoAdmin Pro — Modelo de Dados da Base Canônica

## Decisões já fechadas

Entram obrigatoriamente nesta base:

- `registro_imobiliario_ampliado`
- `responsavel_tecnico_oficial`

Ficam fora desta leva da base canônica:

- `processo_administrativo_seapa`
- `vistoria_seapa`

## Regra de domínio que precisa ficar explícita

Por se tratar de contexto rural, **nem sempre o requerente mora no imóvel**.

Então o sistema não pode tratar endereço como um campo único.

Precisamos separar, no mínimo, estes dois conceitos:

1. `endereco_residencial_ou_correspondencia`
2. `endereco_do_imovel_rural`

### Significado de cada um

#### `endereco_residencial_ou_correspondencia`

Endereço principal da pessoa para contato formal.

Na prática, este campo cobre:

- onde a pessoa mora
- ou onde ela prefere receber correspondência

Se residência e correspondência forem diferentes, nesta fase da base canônica prevalece o endereço de correspondência informado para o processo.

Exemplos de uso:

- contato do requerente
- notificações
- correspondência formal
- qualificação pessoal quando o formulário pedir endereço do requerente

#### `endereco_do_imovel_rural`

Localização do imóvel rural em si.

Exemplos de uso:

- memorial
- planta
- requerimentos fundiários
- declarações do imóvel
- peças cartográficas

## Regra de modelagem

Nunca usar um único campo `endereco` para representar pessoa e imóvel ao mesmo tempo.

No banco novo:

- endereço da pessoa e endereço do imóvel são entidades lógicas diferentes
- o endereço principal da pessoa deve servir para residência ou correspondência
- o endereço do imóvel rural deve continuar separado

## Estrutura recomendada

### 1. Pessoa

Tabela sugerida: `pessoas`

Campos principais:

- `id`
- `nome`
- `cpf_cnpj`
- `rg`
- `estado_civil`
- `profissao`
- `telefone`
- `email`
- `tipo_pessoa`

### 2. Endereço da pessoa

Tabela sugerida: `pessoa_enderecos`

Campos:

- `id`
- `pessoa_id`
- `logradouro`
- `numero`
- `complemento`
- `bairro_setor`
- `municipio`
- `estado`
- `cep`
- `referencia`
- `principal`
- `uso_endereco`

Valores sugeridos para `uso_endereco`:

- `residencial_ou_correspondencia`
- `comercial`
- `outro`

## Regra funcional

Para formulários, notificações e correspondência do requerente:

- usar `endereco_residencial_ou_correspondencia`

Para formulários e peças do imóvel:

- usar `endereco_do_imovel_rural`

## Estrutura do imóvel

Tabela sugerida: `imoveis`

Campos principais:

- `id`
- `projeto_id`
- `nome_imovel`
- `tipo_imovel`
- `municipio`
- `estado`
- `comarca`
- `logradouro_imovel`
- `numero_imovel`
- `complemento_imovel`
- `bairro_setor_imovel`
- `cep_imovel`
- `area_total_ha`

## Registro imobiliário ampliado

Tabela sugerida: `registros_imobiliarios`

Campos principais:

- `id`
- `imovel_id`
- `matricula`
- `transcricao`
- `cnm`
- `cns`
- `cartorio`
- `comarca`
- `livro`
- `folha`
- `data_registro`
- `municipio_cartorio`
- `uf_cartorio`
- `origem_registro`
- `observacoes`

## Responsável técnico oficial

Tabela sugerida: `responsaveis_tecnicos`

Campos principais:

- `id`
- `nome`
- `cpf`
- `profissao`
- `tipo_conselho`
- `numero_conselho`
- `registro_conselho`
- `codigo_incra`
- `art_trt`
- `qualificacao_profissional`
- `ativo`

## Relações principais da base

```text
projetos
  ├── imoveis
  │     └── registros_imobiliarios
  ├── projeto_pessoas
  │     └── pessoas
  │           └── pessoa_enderecos
  ├── responsaveis_tecnicos_projeto
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

## Regras obrigatórias para implementação

- `endereco_residencial_ou_correspondencia` não pode ser gambiarra em campo de observação
- `endereco_do_imovel_rural` não pode ser reaproveitado como endereço do requerente
- `registro_imobiliario_ampliado` deve ficar ligado ao imóvel, não à pessoa
- `responsavel_tecnico_oficial` deve ser bloco formal, não apenas texto de template

## Resultado esperado

Quando esta base estiver implementada:

- o app vai distinguir corretamente o endereço principal da pessoa e a localização do imóvel rural
- os formulários rurais deixarão de misturar contexto pessoal com contexto fundiário
- `registro_imobiliario_ampliado` e `responsavel_tecnico_oficial` passarão a ter fonte oficial de verdade no banco
