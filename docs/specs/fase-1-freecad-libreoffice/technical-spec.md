# Technical Spec — Fase 1 FreeCAD + LibreOffice

## Arquitetura da fase

O `GeoAdmin Pro` continua como sistema principal. A integracao sera feita por exportacao controlada no `backend`.

Fluxo base:

`Supabase/PostGIS -> FastAPI -> JSON oficial -> FreeCAD/LibreOffice`

## Decisao arquitetural

Nao integrar por banco compartilhado.

Nao mover regra de negocio para `FreeCAD` ou `LibreOffice`.

Toda consolidacao de dados do projeto deve ocorrer no `backend`.

## Contrato central

Criar um contrato chamado `projeto_oficial`.

Esse contrato sera a estrutura comum usada por:

- exportacao tecnica
- geracao documental
- futuras automacoes

O contrato deve refletir a realidade observada nos documentos finais e oficiais:

- um projeto pode ter um ou mais `proponentes`
- um projeto pode ter `representantes` e `procuradores`
- o imovel pode carregar dados de `registro`, `CAR`, `CCIR`, `SNCR`, `SIGEF` e outros cadastros
- o pacote final pode incluir pecas administrativas, tecnicas e cartograficas

## Estrutura recomendada do JSON oficial

```json
{
  "meta": {
    "versao": "1.2",
    "gerado_em": "2026-04-02T12:00:00Z",
    "origem": "GeoAdmin Pro"
  },
  "projeto": {
    "id": "uuid",
    "nome": "Fazenda Exemplo",
    "codigo": "JOB-001",
    "status": "medicao",
    "tipo_fluxo": "SEAPA"
  },
  "proponentes": [],
  "representantes": [],
  "imovel": {
    "nome": "Fazenda Exemplo",
    "municipio": "Municipio",
    "estado": "GO",
    "comarca": "",
    "tipo_imovel": "rural"
  },
  "registro_imobiliario": {},
  "cadastros_oficiais": {},
  "processos_administrativos": [],
  "sistema_coordenadas": {
    "datum": "SIRGAS2000",
    "tipo": "UTM",
    "zona": "23S"
  },
  "perimetro_ativo": {
    "tipo": "poligono",
    "area_m2": 0,
    "area_ha": 0,
    "perimetro_m": 0,
    "vertices": [
      {
        "codigo": "P1",
        "norte": 0,
        "este": 0,
        "cota": null
      }
    ]
  },
  "camadas_cartograficas": [],
  "confrontantes": [],
  "documentos": {},
  "protocolos": []
}
```

## Regras do contrato

- coordenadas oficiais em `UTM`
- nomes de campos em portugues
- valores derivados como `area_m2`, `area_ha` e `perimetro_m` devem sair do backend
- campos ausentes devem ser serializados de forma previsivel
- listas devem existir mesmo vazias
- `GeoJSON` e `DXF` sao derivados do contrato e nao a fonte primaria
- o contrato deve suportar tanto `imoveis_rurais` quanto futura extensao para `imoveis_urbanos`

## Blocos obrigatorios do contrato

### `proponentes[]`

Lista de ocupantes, proprietarios, possuidores ou interessados principais.

Campos recomendados:

- `id`
- `nome`
- `cpf_cnpj`
- `rg`
- `estado_civil`
- `profissao`
- `telefone`
- `email`
- `endereco_correspondencia`
- `papel`

### `representantes[]`

Lista de procuradores, representantes legais ou tecnicos vinculados ao fluxo administrativo.

Campos recomendados:

- `id`
- `nome`
- `cpf`
- `rg`
- `tipo`
- `validade`
- `poderes`

### `registro_imobiliario`

Campos recomendados:

- `matricula`
- `cnm`
- `cns`
- `cartorio`
- `comarca`
- `livro_ou_ficha`
- `data_registro`
- `municipio_cartorio`
- `uf_cartorio`

### `cadastros_oficiais`

Campos recomendados:

- `car`
- `situacao_car`
- `condicao_externa_car`
- `data_inscricao_car`
- `data_retificacao_car`
- `ccir`
- `codigo_imovel_incra`
- `sncr`
- `area_certificada_ha`
- `reserva_legal_ha`
- `app_ha`
- `area_rural_consolidada_ha`
- `passivo_reserva_legal_ha`

### `processos_administrativos[]`

Campos recomendados:

- `orgao`
- `numero_processo`
- `numero_notificacao`
- `tipo`
- `status`
- `prazo_resposta`
- `documentos_exigidos`

### `camadas_cartograficas[]`

Lista de geometrias derivadas para produto final.

Campos recomendados:

- `tipo`
- `nome`
- `origem`
- `formato_geometria`
- `atributos`

Exemplos iniciais:

- `perimetro`
- `reserva_legal`
- `app`
- `benfeitorias`
- `estradas`
- `cursos_dagua`

## Endpoints da fase

### 1. JSON oficial

`GET /projetos/{projeto_id}/exportacao/projeto.json`

Resposta:

- `application/json`
- payload `projeto_oficial`

### 2. Pacote FreeCAD

`GET /projetos/{projeto_id}/exportacao/freecad`

Resposta inicial recomendada:

- `application/zip`

Conteudo minimo:

- `projeto.json`
- `perimetro.dxf`
- `readme.txt`

Opcional nesta fase:

- `perimetro.geojson`
- `camadas.geojson`
- `proponentes.json`

### 3. Documento base ODT

`GET /projetos/{projeto_id}/documentos/memorial.odt`

Resposta:

- `application/vnd.oasis.opendocument.text`

### 4. PDF do memorial

`GET /projetos/{projeto_id}/documentos/memorial.pdf`

Resposta:

- `application/pdf`

## Organizacao de codigo proposta

### Backend

- `backend/integracoes/modelo_projeto_oficial.py`
- `backend/integracoes/exportador_projeto.py`
- `backend/integracoes/exportador_freecad.py`
- `backend/integracoes/gerador_odt_pdf.py`

### Rotas

- expandir `backend/routes/exportacao/routes.py`
- expandir `backend/routes/documentos.py`

### Templates

- `backend/static/templates/memorial_base.odt`

### Testes

- `backend/tests/test_exportador_projeto_oficial.py`
- `backend/tests/test_exportador_freecad.py`
- `backend/tests/test_gerador_odt_pdf.py`

## Estrategia para FreeCAD

A Fase 1 nao exige abrir o `FreeCAD` automaticamente.

O primeiro contrato tecnico sera por pacote de arquivos.

Isso reduz risco, evita acoplamento precoce e ja prepara o caminho para uma Fase 2 com script `Python` do `FreeCAD`.

## Estrategia para LibreOffice

Preferencia:

1. gerar `ODT` a partir de template
2. converter para `PDF`

Se a conversao automatica de `PDF` ficar instavel no ambiente de deploy, a fase ainda pode ser considerada valida com:

- `ODT` obrigatorio
- `PDF` como entrega condicional por ambiente

## Dependencias provaveis

Backend:

- biblioteca para `ODT` templating ou montagem simples
- conversao para `PDF` via `LibreOffice` em modo headless, se disponivel

Observacao:

- a fase deve isolar a dependencia externa em um modulo unico para nao espalhar acoplamento pelo backend

## Decisoes nao funcionais

- manter codigo e campos em portugues
- manter tema e fluxo do produto sem alterar a regra existente
- nao quebrar endpoints atuais de exportacao do Métrica
- nao substituir o gerador atual de `.docx` nesta fase; o novo fluxo pode coexistir
- preservar compatibilidade conceitual com dados de `SEAPA`, `ETR`, `SIGEF`, `SNCR`, `CAR`, `CCIR` e `ONR`
