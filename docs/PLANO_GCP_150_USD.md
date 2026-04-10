# Plano GCP — GeoAdmin dentro de US$150

## Direcao escolhida

Para manter o `GeoAdmin Core` inteiro na `Google Cloud` sem quebrar a governanca atual do repositorio:

- `web`: `Firebase Hosting`
- `api`: `Cloud Run`
- `container images`: `Artifact Registry`
- `segredos`: `Secret Manager`
- `job de RAG`: `Cloud Run Job`
- `agendamento`: `Cloud Scheduler`
- `video`: `Compute Engine Spot com GPU`, sob demanda
- `banco`, `auth` e `storage`: `Supabase`

## Motivo da decisao

O projeto ja assume `Supabase` como fonte unica de verdade. Isso significa que a primeira fase mais segura e mais barata e mover a camada de execucao para a `GCP`, sem recriar banco e storage na pressa.

## Faixas de custo alvo

- base serverless do app: `US$20-40/mes`
- operacao de RAG leve: `US$10-30/mes`
- margem para logs, egress e storage: `US$10-20/mes`
- VM de video Spot ligada quando necessario

## Execucao pratica

1. bootstrap de `infra/gcp`
2. publicar API no `Cloud Run`
3. publicar web no `Firebase Hosting`
4. ativar `Cloud Run Job` do `RAG`
5. criar VM GPU apenas quando houver demanda real de video

## Observacao importante

`Ollama` pode existir na VM para LLM local, mas a geracao de video promocional deve priorizar `ComfyUI`, `Diffusers`, `LTX-Video` ou `Wan2.1`.
