# GeoAdmin Core — Checklist de Subida Local do Núcleo

## 1. Pré-requisitos

- `Python 3.12.x` ou `Python 3.13.x`
- `Node` e `npm` instalados
- `Supabase CLI` instalado
- `backend/.env` configurado

## 2. Bootstrap

Rodar:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap_local.ps1
```

Resultado esperado:

- `.venv/` criado
- dependências do backend instaladas
- `pytest` disponível para a suíte do backend
- dependências do mobile instaladas

## 3. Validar backend/.env

Campos mínimos:

- `SUPABASE_URL`
- `SUPABASE_KEY`
- `AUTH_OBRIGATORIO`
- `ALLOWED_HOSTS`
- `ALLOWED_ORIGINS`

Arquivo de referência:

- [backend/.env.example](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\.env.example)

## 4. Subir o backend local

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start_backend.ps1
```

Validar:

- [http://127.0.0.1:8001/health](http://127.0.0.1:8001/health)

Resultado esperado:

- `{"status":"ok"}`

## 5. Gerar o build web

```powershell
cd .\mobile
npm run build:web
```

Resultado esperado:

- pasta `mobile/dist` gerada

## 6. Subir o gateway web local

Usando backend local:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start_web_gateway.ps1
```

Usando backend remoto atual:

```powershell
.\.venv\Scripts\python.exe .\scripts\dev_web_gateway.py --host 127.0.0.1 --port 8000 --upstream https://geoadmin-pro-production.up.railway.app
```

## 7. Validar a web local

Abrir:

- [http://127.0.0.1:8000/projeto](http://127.0.0.1:8000/projeto)
- [http://127.0.0.1:8000/projeto/novo](http://127.0.0.1:8000/projeto/novo)
- [http://127.0.0.1:8000/mapa](http://127.0.0.1:8000/mapa)
- [http://127.0.0.1:8000/clientes](http://127.0.0.1:8000/clientes)

## 8. Validar a API principal

Testes mínimos:

- `GET /health`
- `GET /projetos`
- `GET /projetos/{id}` com um id válido

## 9. Validar a trilha do banco

```powershell
supabase migration list --workdir infra
```

## 10. Validar a trilha do app

```powershell
cd .\mobile
npm start
```

## 11. Bloqueios conhecidos

 - se houver `.venv` criada com `Python 3.14`, o bootstrap agora recria o ambiente usando `py -3.13` ou `py -3.12` quando disponíveis
 - se não houver Python 3.12/3.13 instalado, instalar uma dessas versões antes de seguir
 - se o backend não subir por credencial, revisar `backend/.env`
 - se a web abrir mas a API falhar, testar o gateway apontando explicitamente para o backend remoto
