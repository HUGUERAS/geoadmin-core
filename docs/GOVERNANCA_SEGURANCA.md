# GeoAdmin Pro — Governança de Segurança

## Objetivo

Este documento estabelece a governança mínima de segurança do `GeoAdmin Pro` para desenvolvimento, revisão e deploy.

O objetivo é tornar explícito que:

- segurança não é etapa final
- mudanças sensíveis exigem revisão dedicada
- `GeoAdmin Pro` deve evoluir com `secure by default`
- documentos, cadastros oficiais e dados pessoais exigem cuidado reforçado

## Princípios

- `GeoAdmin Pro` é a fonte única de verdade
- credenciais vivem apenas em `.env` e secrets do ambiente
- nenhum segredo deve aparecer em código cliente, logs ou documentação pública
- autenticação e autorização são diferentes e devem ser tratadas separadamente
- `CORS` não é controle de acesso
- toda integração nova deve ser avaliada por superfície de ataque, dados envolvidos e impacto operacional

## Superfícies mais sensíveis do projeto

- autenticação e autorização
- `magic links`
- uploads e anexos
- geração de documentos
- exportação técnica e downloads
- cadastros oficiais como `CAR`, `CCIR`, `SNCR`, `SIGEF`
- dados de proponentes, procuradores, matrículas, recibos e protocolos
- versão web pública

## Skills de segurança

Estas skills devem ser tratadas como padrão operacional do projeto.

### `geoadmin-security-baseline`

Skill de desenvolvimento seguro por padrão.

Usar quando houver:

- criação ou alteração de rotas FastAPI
- mudanças em `auth`, `CORS`, `proxy`, uploads, downloads ou exportações
- criação de novos contratos `JSON`
- novas integrações com `FreeCAD`, `LibreOffice`, `Supabase`, `SIGEF`, `CAR`, `SNCR`, `CCIR`
- mudanças no cliente `TypeScript` que consumam API, token ou dados sensíveis

Foco:

- evitar que código inseguro entre no fluxo normal
- validar defaults seguros
- exigir contratos explícitos e validação em runtime

### `geoadmin-security-review`

Skill de revisão de segurança.

Usar quando houver:

- PR relevante
- refactor estrutural
- deploy web
- abertura de nova rota pública
- mudança em fluxo documental
- mudança em armazenamento de token, sessão ou arquivos

Foco:

- encontrar regressões
- localizar exposição indevida de dados
- revisar superfícies públicas e integrações

### `geoadmin-document-data-security`

Skill opcional, mas recomendada.

Usar quando houver:

- novos documentos automatizados
- procurações
- recibos de protocolo
- documentos de `CAR`, `CCIR`, `SNCR`, `SIGEF`
- anexos de cliente e confrontante

Foco:

- minimização de dados
- trilha de auditoria
- classificação de sensibilidade documental
- proteção de downloads, anexos e dados pessoais

## Agentes de revisão

### `security-backend-reviewer`

Responsável por revisar:

- `backend/main.py`
- `backend/middleware/`
- `backend/routes/`
- `backend/integracoes/`
- variáveis de ambiente
- uploads, downloads, exports e documentos

Checklist principal:

- autenticação obrigatória
- autorização por objeto
- `CORS` e `Host` restritos
- erros sem vazamento de detalhe interno
- rate limit adequado
- uploads com validação real
- logs sem segredos
- dependências críticas atualizadas

### `security-frontend-docs-reviewer`

Responsável por revisar:

- `mobile/`
- versão web
- contratos `TypeScript`
- cliente da API
- rotas públicas e formulários
- documentação operacional com impacto de segurança

Checklist principal:

- nenhum segredo no bundle
- token não persistido em storage fraco sem necessidade
- validação de payload com schema
- navegação segura
- links e URLs controladas
- XSS evitado por padrão
- `proxy` e consumo de API consistentes
- documentação refletindo políticas reais

## Gatilhos obrigatórios de revisão

Toda mudança nas áreas abaixo deve passar por pelo menos um agente de segurança:

- `backend/main.py`
- `backend/middleware/auth.py`
- `backend/middleware/limiter.py`
- `backend/routes/documentos.py`
- `backend/routes/exportacao/`
- `backend/routes/importar.py`
- `backend/routes/clientes/`
- `mobile/lib/api.ts`
- telas públicas ou de `magic link`
- uploads, anexos e downloads
- geração de `ODT/PDF`
- novas integrações externas

## Controles mínimos obrigatórios

### Backend

- autenticação obrigatória por padrão
- docs da API fechadas ou protegidas em produção
- `TrustedHostMiddleware` ou controle equivalente
- `CORS` por allowlist explícita
- mensagens de erro genéricas ao cliente
- validação forte de entrada e saída
- autorização por objeto em recursos sensíveis
- rate limit real para rotas públicas e pesadas

### Frontend e web

- nenhum segredo em `TypeScript`, `React` ou bundle
- cliente da API centralizado
- tokens em memória por padrão
- schemas compartilhados e validação em runtime
- evitar sinks inseguros de DOM
- política de navegação e URL segura
- headers de segurança aplicados no edge quando houver web pública

### Documentos e dados

- classificar documentos por sensibilidade
- evitar expor anexos por caminho previsível
- preferir identificadores opacos
- registrar geração, acesso e download de documentos sensíveis
- diferenciar documentos totalmente automatizados de documentos semiautomatizados

## Arquitetura recomendada para segurança

- `Python` continua como núcleo de processamento e validação de domínio
- `TypeScript` reforça contratos, UI e consumo seguro da API
- contratos importantes devem ter validação nos dois lados:
  - `Pydantic` no backend
  - `Zod` ou equivalente no frontend

## Definition of Done de segurança

Uma entrega sensível só deve ser considerada pronta quando:

1. passou por revisão de pelo menos um agente de segurança
2. teve contratos validados em runtime onde aplicável
3. não expõe segredo, stack trace ou dados indevidos ao cliente
4. tem documentação mínima atualizada se alterar política, fluxo ou superfície pública

## Observação prática

Estas regras não substituem auditoria completa, mas criam uma camada operacional contínua de proteção.

O princípio é simples:

- mudança sensível não entra sem revisão de segurança
