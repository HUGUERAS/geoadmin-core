# Costurar as Ilhas — CAD → Geometria → Documento → Cliente → Projeto

**Data:** 2026-04-15
**Autor:** Hugo (topógrafo) + Claude
**Branch:** `codex/cloud-run-cutover-foundation`
**Restrição fundamental:** Zero tabelas novas, zero colunas novas, zero endpoints novos.

---

## 1. Problema

O GeoAdmin Pro opera hoje como 5 ilhas desconectadas:

| Ilha | O que faz | Onde para |
|------|-----------|-----------|
| **CAD (mobile)** | Edita vértices no mapa | `POST /perimetros/` — cria perímetro solto |
| **Áreas** | `areas_projeto` com `geometria_final` | Nunca recebe dados do CAD |
| **Documentos** | Gera memorial/GPRF | Usa vértices avulsos, não `geometria_final` |
| **Portal cliente** | Mostra documentos | Não reflete pendências reais |
| **Confrontantes** | `confrontantes.vertices_json` | Precisa de geometria final para funcionar |

**Resultado:** o topógrafo edita no mapa, mas o dado nunca chega em `areas_projeto.geometria_final`. Documentos e confrontantes ficam desconectados da geometria real.

---

## 2. Arquitetura: 5 Costuras

### Costura 1 — CAD → `areas_projeto.geometria_final` (CRÍTICA)

**Arquivo:** `mobile/app/(tabs)/mapa/[id].tsx`

**Problema atual (linhas 672-714):**

```typescript
// salvarEdit hoje — escreve em lugar errado
const res = await fetch(`${API_URL}/perimetros/`, {
  method: 'POST',
  body: JSON.stringify({
    projeto_id: id,
    nome: (projeto?.projeto_nome || id) + ' — editado',
    tipo: 'editado',
    vertices: editVerts,  // tipo Vertice { lon, lat, nome }
  }),
})
```

**Refatoração necessária:**

```typescript
// salvarEdit novo — escreve no lugar certo
const areaId = resolverAreaId(projeto);  // ver seção 2.1
const res = await fetch(
  `${API_URL}/projetos/${id}/areas/${areaId}`,
  {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      geometria_final: editVerts.map(v => ({ lon: v.lon, lat: v.lat })),
    }),
  }
);
```

**Por que funciona sem mudanças no backend:**

- `PATCH /{projeto_id}/areas/{area_id}` (projetos.py:2072) já aceita `geometria_final: list[VerticePayload]`
- `VerticePayload` (projetos.py:129) = `{ lon: float, lat: float }` — compatível com mobile `Vertice { lon, lat, nome }` (campo extra ignorado pelo Pydantic)
- `AreaProjetoUpdate` (projetos.py:167-186) — todos os campos Optional, então enviar só `geometria_final` preserva todo o resto
- `salvar_area_projeto` (areas_projeto.py:636) recalcula `status_operacional` e `status_documental` automaticamente

**Também corrigir:** `entrarEdit` (linhas 598-621) faz `POST /perimetros/` prematuro ao entrar no modo edição — remover essa chamada (salva perímetro "original" desnecessariamente).

#### 2.1 Resolução de `area_id` no mobile

**Gap:** o mobile hoje não tem conceito de `area_id`. Usa apenas `perimetro_ativo` (linhas 566-575).

**Decisão pendente (Hugo):**

- **Opção A (recomendada):** Auto-resolve para projeto com área única. Se `data.areas.length === 1`, usa `areas[0].id`. Se > 1, mostra seletor.
- **Opção B:** Multi-layer desde o início — seletor sempre visível.

**Em ambas opções:** o `useEffect` (linhas 566-575) precisa ler `data.areas` da resposta do `GET /projetos/${id}`, que hoje é ignorado.

```typescript
// Novo no useEffect que carrega o projeto
const [areaAtiva, setAreaAtiva] = useState<string | null>(null);

// Dentro do useEffect após fetch:
if (data.areas?.length === 1) {
  setAreaAtiva(data.areas[0].id);
} else if (data.areas?.length > 1) {
  // Opção A: mostra seletor
  // Opção B: mostra multi-layer
}
```

---

### Costura 2 — `geometria_final` → Geração de documentos

**Estado atual:** A rota de geração de documentos (`routes/documentos.py`) já importa `salvar_area_projeto` (documentos.py:31) e lê `geometria_final` via `_geometria_preferencial` (areas_projeto.py). O fluxo `_geometria_preferencial(area)` retorna `("final", vertices)` quando `geometria_final` existe.

**O que a Costura 1 habilita:** Uma vez que o CAD escreve em `geometria_final`, a geração de documentos automaticamente usa os vértices corretos — sem mudanças em documentos.py.

**Verificação:** confirmar que `gerar_memorial` e `gerar_gprf` usam `_geometria_preferencial` e não acessam `perimetro_ativo` diretamente.

---

### Costura 3 — `geometria_final` → Confrontantes

**Estado atual:** `confrontantes.vertices_json` (migration 014) armazena segmentos de vértice com confrontante associado. A migration 024 adicionou `status_revisao` para workflow de revisão.

**Fluxo após Costura 1:**

1. CAD salva → `geometria_final` atualizado
2. `GET /{projeto_id}/confrontacoes` (projetos.py:2126) usa `_enriquecer_projeto` → `sintetizar_areas_do_projeto` que lê `geometria_final`
3. Confrontantes detectados automaticamente via adjacência geométrica

**Nenhuma mudança necessária** — o endpoint de confrontações já depende de `geometria_final`.

---

### Costura 4 — Status da área → Portal do cliente

**Estado atual:** `status_operacional` e `status_documental` (migration 021) são campos em `areas_projeto`. O backend recalcula automaticamente em `salvar_area_projeto`.

**Fluxo após Costura 1:**

1. CAD salva `geometria_final` → backend recalcula status para `"geometria_final"`
2. Portal do cliente lê status via `projeto_clientes` → mostra progresso real
3. Pendências (`pendencias_area`) refletem o estado real do dado

**Ajuste necessário no portal:** garantir que a tela de pendências lê `status_operacional` e não um campo hardcoded.

---

### Costura 5 — Ciclo fechado: Portal → Aprovação → Projeto

**Estado atual:** `projeto_clientes` (migration 021) tem `permissoes_portal JSONB` para controlar o que o cliente vê/aprova.

**Fluxo completo:**

1. Topógrafo edita no CAD → `geometria_final` atualizada (Costura 1)
2. Backend recalcula status → documentos regeneráveis (Costura 2)
3. Confrontantes detectados (Costura 3)
4. Portal mostra progresso + pendências (Costura 4)
5. Cliente aprova via portal → `status_documental` avança
6. Topógrafo vê aprovação → ciclo fecha

---

## 3. Alinhamento com TASKS_BANCO P0

O documento `TASKS_BANCO_FUNCIONAMENTO_REAL.md` define bloqueadores P0 que impactam as costuras:

| P0 | Descrição | Impacto nas Costuras |
|----|-----------|---------------------|
| **P0.1** | Reconciliação de migrations (local 014-024 vs remote 001-010) | **Bloqueia deploy.** Sem reconciliação, o schema não está garantido no remote. Requer consulta antes de `supabase migration repair`. |
| **P0.2** | Remover fallback local de `areas_projeto` | **Impacto direto na Costura 1.** Se o fallback local existir, a geometria pode ir para JSON local em vez do Supabase. Funções afetadas: `_carregar_store_local`, `_salvar_area_local`, fallbacks em `listar_areas_projeto`, `obter_area`, `salvar_area_projeto`, `anexar_arquivos_area`. |
| **P0.5** | Substituir `db.web.ts` stub | Impacto no portal (Costura 4/5). Reescrito para IndexedDB, falta validação TypeScript. |
| **P0.6** | Formalizar magic link | Impacto na Costura 5. `projeto_clientes` é fonte operacional, mas `clientes.magic_link_*` legacy ainda existe. Requer consulta antes de cortar. |

### Ordem de execução recomendada

```
P0.1 (migration reconciliation) ←── BLOQUEIO: precisa consulta Hugo
  ↓
P0.2 (remover fallbacks areas_projeto) ←── DESBLOQUEIA Costura 1
  ↓
Costura 1 (CAD → geometria_final) ←── HABILITA Costuras 2-5
  ↓
Costuras 2-5 (parallelizáveis)
  ↓
P0.5/P0.6 (portal + magic link) ←── COMPLETA Costuras 4-5
```

---

## 4. Arquivos afetados

### Alterações de código (implementação)

| Arquivo | Mudança | Costura |
|---------|---------|---------|
| `mobile/app/(tabs)/mapa/[id].tsx` | Refatorar `salvarEdit` (L672-714) + `iniciarEdicao` (L598-613) + adicionar `areaAtiva` state | 1 |
| `mobile/app/(tabs)/mapa/[id].tsx` | `useEffect` (L566-575): ler `data.areas` da resposta API | 1 |

### Verificações (sem mudança esperada)

| Arquivo | Verificar | Costura |
|---------|-----------|---------|
| `backend/routes/documentos.py` | `gerar_memorial`/`gerar_gprf` usam `_geometria_preferencial` | 2 |
| `backend/integracoes/areas_projeto.py` | `_geometria_preferencial` retorna `("final", verts)` quando tem `geometria_final` | 2 |
| `backend/routes/projetos.py:2126` | `listar_confrontacoes` usa `_enriquecer_projeto` → `sintetizar_areas_do_projeto` | 3 |

### Backend (sem alterações necessárias)

- `PATCH /{projeto_id}/areas/{area_id}` (projetos.py:2072) — já pronto
- `VerticePayload` (projetos.py:129) — já compatível
- `AreaProjetoUpdate` (projetos.py:167) — já aceita `geometria_final` opcional
- `salvar_area_projeto` (areas_projeto.py:636) — já recalcula status

---

## 5. Riscos e mitigações

| Risco | Mitigação |
|-------|-----------|
| Migration reconciliation (P0.1) incompleta | Não fazer deploy sem resolver. Primeiro passo é consultar Hugo sobre remote. |
| Fallback local (P0.2) intercepta gravação | Remover fallbacks antes de implementar Costura 1 |
| Mobile sem `area_id` para projetos com múltiplas áreas | Opção A (auto-resolve) cobre 90%+ dos casos (maioria tem 1 área) |
| `iniciarEdicao` faz POST prematuro | Remover na mesma PR da Costura 1 |

---

## 6. Decisões pendentes

- [ ] **Hugo:** Opção A ou B para resolução de `area_id` no mobile
- [ ] **Hugo:** Confirmar que P0.1 (migration reconciliation) pode ser resolvido antes de Costura 1
- [ ] **Hugo:** Validar que remover P0.2 fallbacks não quebra workflow offline

---

## 7. Critérios de sucesso

1. Topógrafo edita vértices no CAD → `areas_projeto.geometria_final` é atualizado no Supabase
2. `status_operacional` reflete automaticamente `"geometria_final"` após salvar
3. Geração de memorial/GPRF usa `geometria_final` sem intervenção manual
4. Portal do cliente mostra progresso real baseado em `status_operacional`
5. Zero dados operacionais caem em JSON local como fallback silencioso (regra P0)
