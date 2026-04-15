-- =================================================================
-- GeoAdmin Pro — Migration 032: Autorização por Objeto (P1.2)
-- =================================================================
--
-- OBJETIVO
-- ─────────
-- Estabelecer a fundação técnica para a feature P1.2 (per-object
-- authorization), que permitirá, futuramente, que cada projeto
-- pertença a um usuário Supabase Auth específico e que políticas
-- de acesso sejam baseadas nessa propriedade.
--
-- OPERAÇÕES
-- ─────────
--   A) Adicionar coluna `criado_por_user_id` em `projetos`
--      → Nullable para compatibilidade com projetos existentes
--      → NULL significa "acessível a todos os topógrafos autenticados"
--
--   B) Criar índice em `projetos(criado_por_user_id)`
--      → Eficiência para filtragem por proprietário quando P1.2 ativar
--
--   C) Habilitar RLS em `projetos` (GAP IDENTIFICADO: nenhuma
--      migration anterior habilitou RLS nesta tabela)
--
--   D) Criar policies de acesso em `projetos`:
--      → Leitura: todos os usuários `authenticated` veem todos os
--        projetos (comportamento atual preservado — fase de transição)
--      → Escrita: exclusivo para `service_role` (backend controlado)
--
-- COMPATIBILIDADE
-- ───────────────
-- • Projetos existentes terão `criado_por_user_id = NULL`
-- • A policy de SELECT usa `USING (true)` → todos os projetos são
--   visíveis a qualquer topógrafo autenticado (sem quebra de comportamento)
-- • A filtragem por `criado_por_user_id` é ativada na camada de
--   aplicação (backend) de forma progressiva — não pelo RLS nesta fase
--
-- PRÓXIMOS PASSOS (P1.2 completo — NÃO fazem parte desta migration)
-- ──────────────────────────────────────────────────────────────────
-- 1. Backend: popular `criado_por_user_id` em `POST /projetos`
--    com `auth.uid()` ou o UID do usuário autenticado via JWT
-- 2. Migration futura: restringir SELECT via RLS para:
--    `USING (criado_por_user_id = auth.uid() OR criado_por_user_id IS NULL)`
-- 3. Migration futura: tornar `criado_por_user_id` NOT NULL para
--    novos projetos após backfill dos existentes
--
-- REGRAS DESTA MIGRATION
-- ──────────────────────
-- • NENHUMA linha é apagada, truncada ou modificada
-- • 100% idempotente: ADD COLUMN IF NOT EXISTS, CREATE INDEX IF NOT EXISTS,
--   DROP POLICY IF EXISTS antes de CREATE POLICY
-- • RLS habilitado com FORCE OFF para `service_role` (padrão Supabase)
--
-- ROLLBACK (para referência futura)
-- ──────────────────────────────────
-- A) DROP INDEX IF EXISTS idx_projetos_criado_por_user_id;
-- B) ALTER TABLE projetos DROP COLUMN IF EXISTS criado_por_user_id;
-- C) DROP POLICY IF EXISTS "projetos_leitura_authenticated" ON projetos;
--    DROP POLICY IF EXISTS "projetos_escrita_service_role"  ON projetos;
--    ALTER TABLE projetos DISABLE ROW LEVEL SECURITY;
--
-- RISCO: NENHUMA LINHA É APAGADA OU TRUNCADA AQUI.
-- =================================================================


-- -----------------------------------------------------------------
-- A) Coluna `criado_por_user_id` em `projetos`
--
--    Tipo TEXT para compatibilidade direta com auth.uid()::TEXT do
--    Supabase Auth (UUID serializado como string). Nullable para
--    retrocompatibilidade com projetos criados antes desta migration.
-- -----------------------------------------------------------------

ALTER TABLE projetos
    ADD COLUMN IF NOT EXISTS criado_por_user_id TEXT;

COMMENT ON COLUMN projetos.criado_por_user_id IS
    '[P1.2 — 032] UID do usuário Supabase Auth que criou/é proprietário '
    'do projeto. Nullable: projetos existentes têm NULL e são acessíveis '
    'a todos os topógrafos autenticados (fase de transição). '
    'Futuramente: FK lógica para auth.users.id (não FK física — auth é '
    'schema separado). Quando P1.2 estiver completo, este campo será '
    'NOT NULL para novos projetos após backfill.';


-- -----------------------------------------------------------------
-- B) Índice em `projetos(criado_por_user_id)`
--
--    Parcial (WHERE criado_por_user_id IS NOT NULL) para eficiência:
--    ignora linhas legadas com NULL (que são maioria no início)
--    e acelera lookups de projetos por proprietário.
-- -----------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_projetos_criado_por_user_id
    ON projetos (criado_por_user_id)
    WHERE criado_por_user_id IS NOT NULL;

COMMENT ON INDEX idx_projetos_criado_por_user_id IS
    '[P1.2 — 032] Índice parcial para lookup eficiente de projetos por '
    'proprietário (criado_por_user_id IS NOT NULL). '
    'Projetos legados com NULL são excluídos do índice intencionalmente.';


-- -----------------------------------------------------------------
-- C) Habilitar RLS em `projetos`
--
--    GAP IDENTIFICADO: nenhuma migration anterior (014-031) habilitou
--    Row Level Security nesta tabela. Esta migration corrige o gap.
--
--    NOTA: `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` é idempotente
--    no Postgres — executar em tabela já com RLS ativo não causa erro.
-- -----------------------------------------------------------------

ALTER TABLE projetos ENABLE ROW LEVEL SECURITY;


-- -----------------------------------------------------------------
-- D) Policies de acesso em `projetos`
--
--    Padrão adotado (alinhado com migrations 029+):
--      → leitura: authenticated — todos os topógrafos veem todos os projetos
--      → escrita: service_role  — backend FastAPI com chave de serviço
--
--    A policy de SELECT usa USING (deleted_at IS NULL) para não
--    expor projetos soft-deleted via RLS (melhora de segurança sem
--    quebrar comportamento: projetos ativos continuam visíveis).
--
--    Política de WRITE via service_role garante que mutações passem
--    sempre pelo backend (nunca direto do cliente com anon/publishable).
-- -----------------------------------------------------------------

-- Limpeza idempotente antes de (re)criar
DROP POLICY IF EXISTS "projetos_leitura_authenticated"  ON projetos;
DROP POLICY IF EXISTS "projetos_escrita_service_role"   ON projetos;

-- Leitura: todos os topógrafos autenticados veem todos os projetos ativos
-- (comportamento atual preservado — transição segura para P1.2)
CREATE POLICY "projetos_leitura_authenticated"
    ON projetos
    FOR SELECT
    TO authenticated
    USING (deleted_at IS NULL);

-- Escrita: exclusivo para service_role (backend controlado via FastAPI)
CREATE POLICY "projetos_escrita_service_role"
    ON projetos
    FOR ALL
    TO service_role
    USING (true);

COMMENT ON TABLE projetos IS
    '[P1.2 — 032] RLS habilitado nesta migration. '
    'Policy atual: SELECT aberto a todos os authenticated (fase de transição). '
    'Fase futura P1.2: restringir SELECT por criado_por_user_id = auth.uid(). '
    'Escrita exclusiva via service_role (backend FastAPI).';


-- -----------------------------------------------------------------
-- E) Verificação inline
-- -----------------------------------------------------------------

DO $$
DECLARE
    v_col_exists   BOOLEAN;
    v_idx_exists   BOOLEAN;
    v_rls_enabled  BOOLEAN;
    v_pol_leitura  BOOLEAN;
    v_pol_escrita  BOOLEAN;
BEGIN
    -- A) coluna criado_por_user_id
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name   = 'projetos'
          AND column_name  = 'criado_por_user_id'
    ) INTO v_col_exists;

    -- B) índice parcial
    SELECT EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE schemaname = 'public'
          AND tablename  = 'projetos'
          AND indexname  = 'idx_projetos_criado_por_user_id'
    ) INTO v_idx_exists;

    -- C) RLS habilitado em projetos
    SELECT relrowsecurity
    FROM pg_class
    WHERE relname = 'projetos'
      AND relnamespace = 'public'::regnamespace
    INTO v_rls_enabled;

    -- D.1) policy leitura
    SELECT EXISTS (
        SELECT 1
        FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename  = 'projetos'
          AND policyname = 'projetos_leitura_authenticated'
    ) INTO v_pol_leitura;

    -- D.2) policy escrita
    SELECT EXISTS (
        SELECT 1
        FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename  = 'projetos'
          AND policyname = 'projetos_escrita_service_role'
    ) INTO v_pol_escrita;

    RAISE NOTICE '[032] projetos.criado_por_user_id existe:          %', v_col_exists;
    RAISE NOTICE '[032] idx_projetos_criado_por_user_id existe:      %', v_idx_exists;
    RAISE NOTICE '[032] RLS habilitado em projetos:                  %', v_rls_enabled;
    RAISE NOTICE '[032] policy projetos_leitura_authenticated existe: %', v_pol_leitura;
    RAISE NOTICE '[032] policy projetos_escrita_service_role existe:  %', v_pol_escrita;

    IF NOT v_col_exists THEN
        RAISE WARNING '[032] FALHA: coluna criado_por_user_id não encontrada em projetos.';
    END IF;

    IF NOT v_idx_exists THEN
        RAISE WARNING '[032] FALHA: índice idx_projetos_criado_por_user_id não criado.';
    END IF;

    IF NOT v_rls_enabled THEN
        RAISE WARNING '[032] FALHA: RLS não está habilitado em projetos.';
    END IF;

    IF NOT v_pol_leitura THEN
        RAISE WARNING '[032] FALHA: policy projetos_leitura_authenticated não encontrada.';
    END IF;

    IF NOT v_pol_escrita THEN
        RAISE WARNING '[032] FALHA: policy projetos_escrita_service_role não encontrada.';
    END IF;

    IF v_col_exists AND v_idx_exists AND v_rls_enabled AND v_pol_leitura AND v_pol_escrita THEN
        RAISE NOTICE '[032] ✓ Migration 032 aplicada com sucesso — fundação P1.2 ativa.';
    END IF;
END $$;
