# Product Spec — Fase 1 FreeCAD + LibreOffice

## Visao

A Fase 1 cria uma ponte oficial entre o `GeoAdmin Pro`, o `FreeCAD` e o `LibreOffice`, sem quebrar a arquitetura do produto.

O sistema deve permitir que um projeto tecnico seja:

- consolidado em um `JSON oficial`
- exportado para um fluxo tecnico consumivel pelo `FreeCAD`
- convertido em documento base `ODT/PDF` para uso documental

Os documentos analisados mostram que o produto final observado funciona como um `dossie fundiario`, composto por:

- pecas juridico-administrativas
- pecas tecnico-narrativas
- pecas cartograficas
- recibos, comprovantes e protocolos oficiais

## Problema

Hoje o projeto ja gera arquivos tecnicos e documentos em partes, mas ainda nao existe um contrato unico que organize:

- a exportacao tecnica
- a automacao futura do `FreeCAD`
- a geracao documental em `LibreOffice`

Sem esse contrato, o risco e:

- duplicar regras de negocio
- espalhar dados em formatos inconsistentes
- acoplar demais a interface a uma integracao especifica

## Objetivo da Fase 1

Entregar um fluxo minimo viavel e confiavel para:

1. extrair um projeto em formato padrao
2. disponibilizar um pacote tecnico para `FreeCAD`
3. gerar um documento base `ODT/PDF` a partir do mesmo conjunto de dados

O objetivo adicional desta fase e preparar o `GeoAdmin Pro` para consolidar:

- dados do imovel
- dados de proponentes e representantes
- dados registrais e cadastrais oficiais
- dados geoespaciais e cartograficos
- dados de processo administrativo

## Usuarios principais

- tecnico responsavel pelo projeto
- operador do escritorio que prepara planta e documentacao
- futuro agente interno que automatizara saidas tecnicas

## Principios de produto

- `GeoAdmin Pro` e a fonte unica de verdade
- o usuario nao deve redigitar dados em outro sistema
- o CAD e o documento devem consumir o mesmo contrato base
- a primeira versao deve ser simples de operar e simples de manter

## Escopo

### Dentro do escopo

- definicao do `JSON oficial do projeto`
- endpoint de exportacao do projeto em `JSON`
- endpoint de exportacao para `FreeCAD`
- geracao de memorial base em `ODT`
- geracao de `PDF` a partir do memorial base
- botoes de acao no detalhe do projeto ou no mapa
- suporte no contrato a `multiplos proponentes`
- suporte no contrato a `registro_imobiliario`, `cadastros_oficiais` e `processos_administrativos`

### Fora do escopo

- sincronizacao reversa do `FreeCAD` para o `GeoAdmin Pro`
- modelagem `3D` automatica completa
- compatibilidade com `IFC`, `STEP` e `glTF`
- montagem de cadernos completos com varias pecas
- assinatura digital e workflow juridico

## Valor esperado

- reduz retrabalho tecnico
- cria base para automacao com `FreeCAD`
- organiza a camada documental para evoluir com seguranca
- permite que fases futuras avancem com menos improviso
- reduz risco de retrabalho em pecas exigidas por `SEAPA`, `ETR`, `SIGEF`, `SNCR`, `CCIR` e `CAR`

## Riscos aceitos

- a primeira versao do pacote para `FreeCAD` pode ser simples demais visualmente
- o documento `ODT` inicial pode ter layout basico
- parte da automacao pode depender do ambiente Windows/escritorio

## Medidas de sucesso

- um projeto real consegue ser exportado em `JSON` sem ajuste manual
- o pacote tecnico e aberto no fluxo do `FreeCAD`
- o memorial base sai em `ODT` e `PDF` com os campos centrais preenchidos
- nenhuma informacao chave precisa ser redigitada fora do `GeoAdmin Pro`
