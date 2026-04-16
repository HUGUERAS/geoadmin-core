-- =================================================================
-- GeoAdmin Pro — Migration 027: Reconciliação e baseline estrutural
-- =================================================================
--
-- CONTEXTO DE RECONCILIAÇÃO
-- ─────────────────────────
-- As migrations deste repositório começam em 014 porque as 001-013
-- foram aplicadas no repositório de origem (GeoAdmin-Pro monorepo)
-- antes da criação do geoadmin-core.
--
-- O histórico local atual é: 014 → 026
-- O histórico remoto inclui: 001-013 (origem) + timestamps (Supabase Cloud)
--
-- Estratégia canônica decidida:
--   - As migrations 014-026 representam o delta local aplicado ao
--     projeto oficial jrlrlsotwsiidglcbifo
--   - NÃO fazer db push / db pull cego sem antes confirmar alinhamento
--   - Reconciliar via: supabase migration repair --workdir infra
--     (deve ser feito com consulta ao responsável antes de executar)
--
-- ESTA MIGRATION:
--   1. Corrige inconsistências estruturais identificadas na auditoria
--      das migrations 014-026
--   2. Complementa a cobertura de índices para o fluxo de magic link
--      (o índice parcial de 026 cobre tokens PENDENTES; este adiciona
--      cobertura para tokens JÁ CONSUMIDOS, necessário para HTTP 410)
--   3. Aplica soft-delete e auditoria na tabela `tecnico` (014),
--      que ficou sem `deleted_at` e `atualizado_em`
--   4. Adiciona coluna de uso em `clientes` com marcação LEGACY clara
--      (idempotente — só adiciona se não existir)
--   5. 100% idempotente: usa ADD COLUMN IF NOT EXISTS, CREATE INDEX
--      IF NOT EXISTS, CREATE OR REPLACE VIEW, DO $$ ... END $$
--
-- NOTA SEC-02:
--   A coluna `magic_link_token_usado_em` e o índice parcial
--   `idx_pc_magic_link_nao_usado` já foram criados na migration 026.
--   Esta migration NÃO os recria — apenas complementa.
--
-- RISCO: NENHUMA LINHA É APAGADA OU TRUNCADA AQUI.
-- =================================================================

-- -----------------------------------------------------------------
-- 1. Tabela `tecnico` — alinhar com padrão de auditoria do projeto
--    (criada em 014 sem deleted_at, atualizado_em, ativo_em)
-- -----------------------------------------------------------------

ALTER TABLE tecnico
    ADD COLUMN IF NOT EXISTS atualizado_em  TIMESTAMPTZ DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS deleted_at     TIMESTAMPTZ;

-- Preencher atualizado_em para linhas existentes (idempotente via COALESCE)
UPDATE tecnico
SET atualizado_em = COALESCE(atualizado_em, criado_em, NOW())
WHERE atualizado_em IS NULL;

-- Trigger de atualização automática
CREATE OR REPLACE FUNCTION public.set_tecnico_atualizado_em()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    NEW.atualizado_em = NOW();
RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_tecnico_atualizado_em
ON tecnico;
CREATE TRIGGER trg_tecnico_atualizado_em
    BEFORE
UPDATE ON tecnico
    FOR EACH ROW
EXECUTE
FUNCTION public.set_tecnico_atualizado_em
();

COMMENT ON COLUMN tecnico.deleted_at IS
    'Soft-delete: preenchido quando o técnico é desativado. '
    'Adicionado na migration 027 para alinhar com o padrão do projeto.';

COMMENT ON COLUMN tecnico.atualizado_em IS
    'Timestamp da última atualização do registro do técnico.';

-- -----------------------------------------------------------------
-- 2. Índice geral em projeto_clientes(magic_link_token)
--    para lookup de tokens JÁ CONSUMIDOS (necessário para HTTP 410)
--
--    CONTEXTO: a migration 026 criou o índice parcial:
--      idx_pc_magic_link_nao_usado  → WHERE token_usado_em IS NULL
--    Esse índice ACELERA a busca de tokens pendentes, mas NÃO
--    ajuda quando o token já foi usado e queremos retornar 410.
--    Para o fluxo completo (validar E retornar erro semântico),
--    precisamos de um índice sem o filtro de consumo.
-- -----------------------------------------------------------------

CREATE INDEX
IF NOT EXISTS idx_pc_magic_link_token_lookup
    ON projeto_clientes
(magic_link_token)
    WHERE deleted_at IS NULL
      AND magic_link_token IS NOT NULL;

COMMENT ON INDEX idx_pc_magic_link_token_lookup IS
    '[027] Índice geral para lookup de token (inclui tokens já consumidos). '
    'Complementa idx_pc_magic_link_nao_usado (026) para o fluxo HTTP 410.';

-- -----------------------------------------------------------------
-- 3. Garantir que clientes.magic_link_token tenha comentário LEGACY
--    (pode não ter chegado a todos os ambientes via migration 025)
-- -----------------------------------------------------------------

DO $$
BEGIN
    -- Só comenta se a coluna existir (defensivo para ambientes parciais)
    IF EXISTS (
        SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
        AND table_name   = 'clientes'
        AND column_name  = 'magic_link_token'
    ) THEN
        COMMENT ON COLUMN clientes.magic_link_token IS
            'LEGADO: não usar como fonte operacional. '
            'A fonte oficial do token é projeto_clientes.magic_link_token. '
            'Marcado como legado na migration 025; confirmado na 027.';
END
IF;
END $$;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
        AND table_name   = 'clientes'
        AND column_name  = 'magic_link_expira'
    ) THEN
        COMMENT ON COLUMN clientes.magic_link_expira IS
            'LEGADO: não usar como fonte operacional. '
            'A fonte oficial da expiração é projeto_clientes.magic_link_expira. '
            'Marcado como legado na migration 025; confirmado na 027.';
END
IF;
END $$;

-- -----------------------------------------------------------------
-- 4. Garantir que o índice único de magic_link_token em
--    projeto_clientes exista (foi criado em 019, mas valida aqui
--    para ambientes com histórico parcial de migrations)
-- -----------------------------------------------------------------

CREATE UNIQUE INDEX
IF NOT EXISTS uq_projeto_clientes_magic_link
    ON projeto_clientes
(magic_link_token)
    WHERE deleted_at IS NULL
      AND magic_link_token IS NOT NULL;

-- -----------------------------------------------------------------
-- 5. View canônica vw_projeto_clientes — garantir que a versão
--    mais atual (025) esteja presente em todos os ambientes
--    (CREATE OR REPLACE é idempotente)
-- -----------------------------------------------------------------

CREATE OR REPLACE VIEW vw_projeto_clientes AS
SELECT
    p.id                           AS projeto_id,
    p.nome                         AS projeto_nome,
    c.id                           AS cliente_id,
    c.nome                         AS cliente_nome,
    COALESCE(c.cpf, c.cpf_cnpj)    AS cliente_cpf,
    c.telefone,
    c.email,
    pc.id                          AS projeto_cliente_id,
    pc.papel                       AS vinculo,
    pc.principal,
    pc.recebe_magic_link,
    pc.ordem,
    pc.area_id,
    pc.magic_link_token,
    pc.magic_link_expira,
    pc.magic_link_token_usado_em, -- [SEC-02] exposto para rastreio de consumo
    pc.criado_em,
    pc.atualizado_em
FROM projeto_clientes pc
    JOIN clientes c ON c.id = pc.cliente_id
    JOIN projetos p ON p.id = pc.projeto_id
WHERE pc.deleted_at IS NULL
    AND p.deleted_at  IS NULL
    AND COALESCE(c.deleted_at, NULL) IS NULL;

COMMENT ON VIEW vw_projeto_clientes IS
    'View canônica dos participantes por projeto. '
    'Inclui magic_link_token_usado_em (SEC-02) desde a migration 027.';

-- -----------------------------------------------------------------
-- 6. Verificação inline (não bloqueia a migration em caso de dif.)
-- -----------------------------------------------------------------

DO $$
DECLARE
    v_col_exists    BOOLEAN;
    v_idx_exists    BOOLEAN;
    v_tecnico_del   BOOLEAN;
BEGIN
    -- magic_link_token_usado_em
    SELECT EXISTS
    (
        SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
        AND table_name   = 'projeto_clientes'
        AND column_name  = 'magic_link_token_usado_em'
    )
    INTO v_col_exists;

-- índice geral de lookup
SELECT EXISTS
(
        SELECT 1
FROM pg_indexes
WHERE schemaname = 'public'
    AND tablename  = 'projeto_clientes'
    AND indexname  = 'idx_pc_magic_link_token_lookup'
    )
INTO v_idx_exists;

-- deleted_at em tecnico
SELECT EXISTS
(
        SELECT 1
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name   = 'tecnico'
    AND column_name  = 'deleted_at'
    )
INTO v_tecnico_del;

    RAISE NOTICE '[027] magic_link_token_usado_em existe: %',  v_col_exists;
    RAISE NOTICE '[027] idx_pc_magic_link_token_lookup existe: %', v_idx_exists;
    RAISE NOTICE '[027] tecnico.deleted_at existe: %',          v_tecnico_del;

IF NOT v_col_exists THEN
        RAISE WARNING '[027] ATENÇÃO: magic_link_token_usado_em NÃO encontrada em projeto_clientes. '
                      'Verifique se migration 026 foi aplicada.';
END
IF;
END $$;
