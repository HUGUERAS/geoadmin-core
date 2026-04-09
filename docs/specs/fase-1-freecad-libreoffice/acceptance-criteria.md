# Acceptance Criteria — Fase 1 FreeCAD + LibreOffice

## Criterios funcionais

### JSON oficial do projeto

- deve existir um endpoint dedicado para exportar o `JSON oficial`
- o payload deve conter `meta`, `projeto`, `proponentes`, `imovel`, `registro_imobiliario`, `cadastros_oficiais`, `sistema_coordenadas` e `perimetro_ativo`
- o payload deve manter nomes de campos em portugues
- listas devem vir como lista vazia, nunca como ausencia silenciosa
- o payload deve suportar `multiplos proponentes`
- o payload deve suportar `processos_administrativos`

### Exportacao para FreeCAD

- deve existir um endpoint dedicado para pacote `FreeCAD`
- o pacote deve conter ao menos `projeto.json` e `perimetro.dxf`
- o `DXF` deve representar o perimetro ativo do projeto
- o arquivo deve ser gerado sem depender de edicao manual do usuario
- o desenho deve estar alinhado ao fluxo fundiario real, com possibilidade de expansao para camadas tecnicas

### Documento ODT/PDF

- deve existir rota para gerar `ODT`
- deve existir rota para gerar `PDF` ou retorno explicito de indisponibilidade por ambiente
- o documento deve usar dados do contrato oficial do projeto
- nome do projeto, nome do imovel, municipio, area e identificacao do cliente devem aparecer corretamente
- quando houver, os campos de `CAR`, `CCIR`, `processo` e `responsavel tecnico` devem estar disponiveis para templates

## Criterios tecnicos

- nenhuma regra de negocio principal deve ser duplicada no frontend
- a consolidacao do contrato deve ocorrer no backend
- a Fase 1 nao pode quebrar os endpoints existentes do fluxo Métrica
- o novo fluxo deve ter testes automatizados no backend

## Criterios de qualidade

- falhas de exportacao devem retornar mensagens claras
- o contrato `JSON` deve ser deterministico para o mesmo projeto
- o sistema deve funcionar com projeto real ja existente no banco
- o contrato deve ser capaz de representar casos reais com `procurador`, `notificacao` e `cadastros oficiais`

## Criterios de aceite por cenário

### Cenario 1 — Projeto valido

Dado um projeto com cliente e perimetro ativo validos
Quando o usuario solicitar o `JSON oficial`
Entao o sistema deve retornar um payload completo e consistente

### Cenario 2 — Exportacao tecnica

Dado um projeto com vertices validos
Quando o usuario solicitar o pacote `FreeCAD`
Entao o sistema deve retornar um `.zip` com `JSON` e `DXF`

### Cenario 3 — Documento base

Dado um projeto com dados documentais minimos preenchidos
Quando o usuario solicitar o memorial
Entao o sistema deve retornar um `ODT` valido

### Cenario 4 — PDF indisponivel

Dado um ambiente sem conversor `PDF`
Quando o usuario solicitar o `PDF`
Entao o sistema deve responder com erro controlado ou fallback definido em spec

### Cenario 5 — Projeto incompleto

Dado um projeto sem perimetro ativo ou sem dados documentais minimos
Quando o usuario solicitar exportacao
Entao o sistema deve falhar com mensagem objetiva e acionavel

## Definition of Done da fase

A Fase 1 sera considerada pronta quando:

1. os quatro documentos desta pasta estiverem aceitos
2. o contrato `projeto_oficial` estiver implementado
3. a exportacao `FreeCAD` estiver implementada
4. a geracao `ODT` estiver implementada
5. o `PDF` estiver implementado ou formalmente marcado como dependente de ambiente
6. os testes essenciais estiverem passando
