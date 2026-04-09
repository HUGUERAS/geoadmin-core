# Spec Driven Development — Fase 1

Esta pasta define a Fase 1 da integracao do `GeoAdmin Pro` com `FreeCAD` e `LibreOffice`.

Objetivo: preparar uma base pequena, estavel e orientada a contrato para que a implementacao comece sem ambiguidade.

Documentos desta pasta:

- `product-spec.md`: problema, objetivo, usuarios, escopo e valor da fase
- `technical-spec.md`: arquitetura, contratos, endpoints e decisoes tecnicas
- `workflow-spec.md`: fluxo operacional real do usuario
- `acceptance-criteria.md`: criterios de aceite funcionais e tecnicos

Principio central desta fase:

- o `GeoAdmin Pro` continua sendo a fonte unica de verdade
- `FreeCAD` entra como motor tecnico auxiliar
- `LibreOffice` entra como motor documental
- nenhuma integracao externa passa a ser dona dos dados

Base de validacao desta fase:

- documentos reais de entrega em `D:\pastas de trabalho`
- documentos oficiais e operacionais em `C:\Users\User\Downloads`
- material normativo e cadastral de `SIGEF`, `CAR`, `CCIR`, `SNCR`, `SEAPA`, `ETR` e schemas `ONR`

Escopo reduzido da Fase 1:

1. `JSON oficial do projeto`
2. endpoint de exportacao para `FreeCAD`
3. geracao de documento `ODT/PDF`

Guardrails obrigatorios para a implementacao:

- mudancas em exportacao tecnica, documentos, downloads, `proxy`, rotas publicas ou integracoes externas devem seguir [docs/GOVERNANCA_SEGURANCA.md](c:\Users\User\GeoAdmin-Pro\docs\GOVERNANCA_SEGURANCA.md)
- toda entrega sensivel desta fase deve passar por pelo menos um agente de seguranca
- contratos novos devem ser validados em runtime no backend e, quando houver cliente `TypeScript`, tambem no frontend

Documento complementar:

- `projeto-oficial-v1.2.json`: exemplo do contrato consolidado recomendado

Fora de escopo nesta fase:

- automacao completa do `FreeCAD` com montagem de prancha complexa
- edicao bidirecional entre `GeoAdmin Pro` e `FreeCAD`
- viewer 3D
- sincronizacao em tempo real com software externo
- pacote final de obra com multiplos documentos e assinaturas
