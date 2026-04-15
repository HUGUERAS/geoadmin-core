# GeoAdmin Pro — Contexto para todas as sessões

Use este arquivo em novas conversas: abra ou referencie com `@CONTEXTO_PROJETO.md` para o assistente retomar o contexto rapidamente.

---

## Quem

- **Autor/Responsável:** Hugo (Desenrola Team)
- **Preferência:** Respostas sempre em **português**.

---

## O que é o projeto

- **GeoAdmin Pro:** sistema para topografia, georreferenciamento e gestão de projetos rurais (INCRA, SIGEF, memoriais).
- **Objetivo central:** uma única fonte de dados — digitar uma vez no app/backend e não repetir no Métrica TOPO, planilhas ou outros sistemas.

---

## Prioridades estratégicas atuais

### 1. Dados e formulários do cliente destravam a operação

- formulários, cadastro e dados documentais do cliente são críticos
- sem esses dados o trabalho trava antes de chegar na parte técnica
- melhorar essa frente acelera a operação diária e ajuda a trazer mais clientes

### 2. Geometria é a base do valor técnico do produto

- a base do trabalho do autor do projeto como topógrafo e agrimensor é a criação de mapas, memoriais e documentos com precisão
- essa precisão depende dos cálculos e da geometria
- o ambiente CAD é a peça que transforma referência, pontos e cálculo em produto técnico utilizável

### 3. O CAD mobile pode ser simples, mas precisa gerar valor real

- a versão mobile do CAD não precisa competir com um CAD profissional em profundidade
- mesmo assim, cada ferramenta útil aumenta o valor do app
- o critério para evoluir o CAD é sempre: `isso melhora o trabalho técnico real do topógrafo?`

### 4. Dor principal a atacar no CAD

- quando o cliente fornece dados e um esboço da área, uma das maiores dores do topógrafo é identificar confrontantes
- isso fica ainda mais crítico em projetos grandes
- o produto deve caminhar para que o ambiente CAD seja um lugar onde:
  - os dados do cliente entram
  - o esboço da área vira referência geométrica
  - a identificação de confrontantes fique mais clara e mais rápida

### 5. Sequência estratégica das fases

- agora:
  - intake do cliente
  - formulários
  - geometria útil
  - apoio à identificação de confrontantes
- depois:
  - integração com ambiente CAD profissional
- depois:
  - retomada da implantação do RAG

---

## Stack

- **Mobile:** React Native (Expo), 4 abas: Projeto | Mapa | Cálculos | Clientes. Tema dark + laranja `#EF9F27`.
- **Backend:** FastAPI (Python), em `backend/`.
- **Banco:** Supabase (Postgres + PostGIS). Projeto: `https://jrlrlsotwsiidglcbifo.supabase.co`.
- **Integração Métrica TOPO:** exportação de pontos em TXT (e depois CSV, DXF, KML) no formato que o Métrica importa.

---

## Estrutura do backend (resumo)

```
backend/
  main.py              ← app FastAPI, get_supabase(), /health, /geo/inverso
  .env                 ← SUPABASE_URL, SUPABASE_KEY (nunca commitar)
  .env.example         ← modelo sem valores reais
  requirements.txt    ← fastapi, uvicorn, supabase, python-dotenv, ezdxf
  integracoes/
    integracao_metrica.py   ← geradores TXT, CSV, DXF, KML (usa views do Supabase)
  routes/
    exportacao.py          ← GET/POST /projetos/{id}/metrica/... (depende do Supabase)
    metrica_simples.py      ← POST /metrica/txt (JSON → TXT, sem banco)
```

- **Rodar servidor:** `cd backend` e `python -m uvicorn main:app --reload`. API em `http://127.0.0.1:8000`.
- **Docs interativos:** `http://127.0.0.1:8000/docs`.

---

## Supabase

- **URL do projeto:** `https://jrlrlsotwsiidglcbifo.supabase.co`.
- **Chave:** usar a **anon public** (Settings → API no Dashboard). Colocar em `backend/.env` como `SUPABASE_KEY`.
- **Nunca** commitar `.env`; está em `backend/.gitignore`. No GitHub usar apenas Secrets para CI/deploy.
- **Views esperadas** pela integração completa: `vw_projetos_completo`, `vw_pontos_utm`. Se não existirem, o endpoint `GET /projetos/{id}/metrica/txt` pode retornar 500.

---

## Integração Métrica TOPO (como ficou)

- **Modo simples (funciona sem Supabase):**  
  `POST /metrica/txt` — envia JSON com `projeto_nome`, `numero_job`, `zona_utm`, `pontos[]`. Resposta: arquivo .txt pronto para importar no Métrica.
- **Modo completo (com Supabase):**  
  `GET /projetos/{id}/metrica/txt` (e preparar, csv, dxf, kml) — lê dados das views e gera os arquivos. Só funciona com banco e views configurados.
- **Formato TXT:** colunas Nome, Norte, Este, Cota, Código; cabeçalho com projeto/job; gerado por GeoAdmin Pro.

---

## Documentos de referência no repo

- `Master_Plan_v2.md` — fases 0 a 3, critérios de aceitação, tarefas por agente.
- `.cursorrules` — 6 agentes (UI/UX, Geográfico, Automação, Dados, Auditor, RAG) e regras de trabalho.
- `Comandos_Agentes.md` — prompts prontos por agente.
- `Fluxo_Agentes_Fases.md` — ordem de execução dos prompts por fase.

---

## Decisões importantes

- Fonte única de dados: GeoAdmin Pro; Métrica consome arquivos gerados pelo backend.
- Endpoint simples primeiro: `POST /metrica/txt` com JSON; depois conectar Supabase no GET por projeto.
- Favicon 404 na API é normal; ignorar. Erro 500 em `/projetos/.../metrica/txt` em geral é Supabase/views ou .env.
- Governança de segurança documentada em [GOVERNANCA_SEGURANCA.md](./GOVERNANCA_SEGURANCA.md).
- Mudanças em `auth`, `magic links`, uploads, documentos, exportações, versão web e integrações externas exigem revisão dedicada de segurança.
- O produto não deve ser pensado como `cliente versus CAD`.
- A leitura correta é:
  - `dados do cliente destravam o caso`
  - `geometria e CAD entregam o valor técnico`
  - `confrontantes` conectam a entrada do cliente ao trabalho técnico do topógrafo.

---

*Última atualização: contexto consolidado em abril de 2026. Ajuste este arquivo quando houver mudanças relevantes.*
