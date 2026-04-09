# GeoAdmin Core — Hardening Mínimo Obrigatório

## Já aplicado no núcleo

- docs da API fechadas por padrão
- `TrustedHostMiddleware` no backend
- erro `500` genérico por padrão
- separação explícita entre núcleo e `RAG`
- governança de banco e continuidade de contexto documentadas

## Ainda obrigatório antes de considerar o core estável

### 1. Autenticação

- sair de `supabase.auth.get_user(token)` por requisição
- migrar para validação local de JWT/JWKS quando possível

### 2. Autorização por objeto

- validar acesso por `projeto`, `cliente`, `documento`, `arquivo`, `área` e `confrontação`

### 3. Rate limit real

- substituir o limitador em memória por mecanismo distribuído

### 4. Banco

- reconciliar migrations locais e remotas
- consolidar a base canônica obrigatória:
  - `registro_imobiliario_ampliado`
  - `responsavel_tecnico_oficial`
  - `endereco_residencial_ou_correspondencia`
  - `endereco_do_imovel_rural`

### 5. Storage

- impedir qualquer fallback operacional silencioso para filesystem local

### 6. Uploads e documentos

- revisar MIME, extensão, tamanho e trilha de armazenamento dos arquivos

## Decisão operacional

Nenhuma dessas pendências justifica voltar a usar `mock`, `stub` ou `skip` como solução final do produto. Quando um ponto falhar, ele deve ser tratado como bloqueio real de implementação.
