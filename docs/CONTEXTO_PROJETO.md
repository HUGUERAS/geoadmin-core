# GeoAdmin Core — Contexto de Continuidade

Use este arquivo como resumo rápido do núcleo oficial do produto.

## Identidade do repositório

- Repositório oficial do núcleo: `geoadmin-core`
- Repositório anterior `GeoAdmin-Pro`: referência histórica e incubadora
- Idioma de trabalho: português

## O que é o produto

- Sistema para topografia, georreferenciamento e gestão de projetos rurais
- Fonte única de verdade para:
  - projetos
  - clientes
  - confrontações
  - documentos
  - exportações técnicas
  - banco e contratos

## Stack oficial

- Mobile/web: `Expo 54 + Expo Router` em [mobile](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile)
- Backend: `FastAPI` em [backend](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend)
- Banco/Auth/Storage: `Supabase`
- API em nuvem: `Google Cloud Run`
- Web publicada: `Vercel`

## Ambientes ativos conhecidos

- Cloud Run:
  - serviço `geoadmin-api`
  - projeto `geoadmin-core-2026`
  - URL pública: `https://geoadmin-api-800479022570.us-central1.run.app`
- Vercel:
  - projeto `geo-admin-pro`
  - domínio principal: `https://geo-admin-pro.vercel.app`
- Firebase Hosting também responde:
  - `https://geoadmin-core-2026.web.app`
  - `https://geoadmin-core-2026.firebaseapp.com`

## Configuração de backend

- `SUPABASE_URL`: URL do projeto Supabase oficial
- `SUPABASE_KEY`: usar `service role key` no backend
- Nunca commitar `.env`
- Buckets e segredos devem existir no ambiente, não no Git

## Regras de continuidade

- O documento central de referência é [REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md)
- Depois de qualquer compactação de contexto, este arquivo e a referência oficial devem ser lidos antes de continuar
- O `RAG Topografia` fica fora do escopo do core por enquanto

## Estado atual conhecido

- Há produção real na nuvem
- A trilha de promoção ainda está bifurcada entre:
  - `main`
  - branches `codex/*`
  - deploy manual do Cloud Run
- O backend implantado está online, mas a configuração atual ainda precisa de alinhamento de segurança antes da próxima promoção

## Documentos mais importantes

- [ARQUITETURA_OFICIAL_DO_PROJETO.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\ARQUITETURA_OFICIAL_DO_PROJETO.md)
- [REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\REFERENCIA_OFICIAL_SEGURANCA_SUPABASE.md)
- [BASELINE_OFICIAL_AMBIENTE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\BASELINE_OFICIAL_AMBIENTE.md)
- [CHECKLIST_SUBIDA_LOCAL_DO_NUCLEO.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\CHECKLIST_SUBIDA_LOCAL_DO_NUCLEO.md)
- [HARDENING_MINIMO_CORE.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\HARDENING_MINIMO_CORE.md)
- [MAPA_PROMOCAO_AMBIENTES.md](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\docs\MAPA_PROMOCAO_AMBIENTES.md)
