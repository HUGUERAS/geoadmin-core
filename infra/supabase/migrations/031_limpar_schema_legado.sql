-- =================================================================
-- GeoAdmin Pro — Migration 031: Limpeza de Schema Legado
-- =================================================================
--
-- OBJETIVO
-- ─────────
-- Reduzir ambiguidade no schema após as migrations 029 e 030,
-- sem apagar dados. Operações:
--
--   A) Adicionar/confirmar comentários LEGADO em clientes
--      (campos que têm substituto canônico definido)
--   B) Dropar funções PostGIS de locking (lock_row, addauth etc.)
--      que não são usadas pelo projeto e geram advisors de segurança
--   C) Criar view vw_imovel_projeto para retrocompatibilidade
--      de queries que hoje leem campos de imóvel diretamente de projetos
--
-- REGRAS
-- ──────
-- • NENHUMA linha ou coluna é apagada
-- • TUDO com IF EXISTS / IF NOT EXISTS — idempotente
-- • Apenas documentação (COMMENT), funções não-usadas (DROP IF EXISTS)
--   e views novas (CREATE OR REPLACE)
--
-- ROLLBACK (para referência futura)
-- ──────────────────────────────────
-- A) Não há rollback para COMMENT — são metadados; basta recolocar
--    o comentário anterior manualmente se necessário.
-- B) Funções PostGIS de locking: não recriar — fazem parte da
--    extensão PostGIS e podem ser reinstaladas via:
--    DROP EXTENSION postgis CASCADE; CREATE EXTENSION postgis;
--    (ATENÇÃO: destrói dados geoespaciais — usar só em dev)
-- C) DROP VIEW IF EXISTS vw_imovel_projeto;
-- =================================================================


-- -----------------------------------------------------------------
-- A) Comentários LEGADO em campos de `clientes`
--
--    Confirma e expande os marcadores legados nos campos que têm
--    substituto canônico definido nas tabelas 028-029.
--    Não altera dados nem estrutura — apenas metadados.
-- -----------------------------------------------------------------

-- A.1 magic_link_token: legado desde 025, confirmado em 027
DO $
$
BEGIN
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
            'Coluna mantida por compatibilidade — não dropar sem migration de remoção.';
END
IF;
END $$;

-- A.2 formulario_ok: legado — derivado de projeto_clientes.magic_link_token_usado_em
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
        AND table_name   = 'clientes'
        AND column_name  = 'formulario_ok'
    ) THEN
        COMMENT ON COLUMN clientes.formulario_ok IS
            'LEGADO: usar projeto_clientes.magic_link_token_usado_em como fonte. '
            'TRUE quando o cliente concluiu o formulário; '
            'campo não é mais atualizado pelo backend canônico (Fase 4+).';
END
IF;
END $$;

-- A.3 magic_link_expira: legado — fonte oficial é projeto_clientes.magic_link_expira
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
            'A fonte oficial de expiração é projeto_clientes.magic_link_expira. '
            'Marcado como legado na migration 025; reconfirmado em 027 e 031.';
END
IF;
END $$;

-- A.4 formulario_em: legado — uso operacional em projeto_clientes
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
        AND table_name   = 'clientes'
        AND column_name  = 'formulario_em'
    ) THEN
        COMMENT ON COLUMN clientes.formulario_em IS
            'LEGADO: timestamp de conclusão do formulário pelo cliente. '
            'O substituto canônico é projeto_clientes.magic_link_token_usado_em. '
            'Mantido por compatibilidade com integrações que ainda leem esta coluna.';
END
IF;
END $$;

-- A.5 Campos de endereço em `clientes`: contexto / clareza de domínio
-- (endereço da pessoa — distinto de logradouro_imovel em `imoveis`)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
        AND table_name   = 'clientes'
        AND column_name  = 'endereco'
    ) THEN
        COMMENT ON COLUMN clientes.endereco IS
            'Endereço residencial/correspondência do cliente (pessoa). '
            'NÃO representa o endereço do imóvel rural — esse fica em imoveis.logradouro_imovel. '
            'Futuro destino canônico: pessoa_enderecos.uso_endereco = ''residencial_ou_correspondencia''.';
END
IF;
END $$;

-- A.6 Tabela `tecnico`: marcar como legada em favor de responsaveis_tecnicos
COMMENT ON TABLE tecnico IS
    'LEGADO: tabela de configuração global do técnico responsável (migration 014). '
    'Substituída progressivamente por responsaveis_tecnicos (029) + '
    'projeto_responsaveis_tecnicos (029). '
    'Manter ativa durante janela de convivência — remover somente após '
    'validar que responsaveis_tecnicos está completa e o backend migrado.';


-- -----------------------------------------------------------------
-- B) Dropar funções PostGIS de locking (não usadas pelo GeoAdmin)
--
--    As funções lockrow(), addauth(), checkauth() etc. são parte
--    da extensão PostGIS (postgis_topology / postgis_locking) e
--    foram sinalizadas em advisors de segurança por exporem
--    mecanismos de lock que não fazem parte do fluxo do sistema.
--
--    SEGURANÇA: estas funções permitem manipulação de features
--    geoespaciais sem passar pelo RLS quando chamadas diretamente.
--    Remover elimina a superfície de ataque.
--
--    REF: https://postgis.net/docs/postgis_lock.html
-- -----------------------------------------------------------------

-- Funções de bloqueio de feature (PostGIS locking)
DROP FUNCTION IF EXISTS public.lockrow
(text, text, text);
DROP FUNCTION IF EXISTS public.lockrow
(text, text, text, text);
DROP FUNCTION IF EXISTS public.lockrow
(text, text, text, text, timestamp without time zone);
DROP FUNCTION IF EXISTS public.unlockrows
(text);

-- Funções de autorização PostGIS
DROP FUNCTION IF EXISTS public.addauth
(text);
DROP FUNCTION IF EXISTS public.checkauth
(text, text);
DROP FUNCTION IF EXISTS public.checkauth
(text, text, text);
DROP FUNCTION IF EXISTS public.disablelongtransactions
();
DROP FUNCTION IF EXISTS public.enablelongtransactions
();

-- Relatório B
DO $$
BEGIN
    RAISE NOTICE '[031-B] Funções PostGIS de locking removidas (IF EXISTS — sem erro se já ausentes).';
    RAISE NOTICE '[031-B] Superfície de ataque de lock direto reduzida.';
END $$;


-- -----------------------------------------------------------------
-- C) View vw_imovel_projeto — retrocompatibilidade
--
--    Queries do backend e mobile que hoje leem campos do imóvel
--    diretamente de `projetos` (nome_imovel, comarca, area_ha etc.)
--    podem ser redirecionadas para esta view sem alterar o código.
--
--    Inclui colunas de `registros_imobiliarios` via LEFT JOIN
--    para não quebrar queries que já esperam dados registrais.
--
--    ATENÇÃO: campos canônicos do imóvel agora são a fonte de
--    verdade — as colunas de `projetos` são legadas para esses dados.
-- -----------------------------------------------------------------

CREATE OR REPLACE VIEW vw_imovel_projeto AS
SELECT
    -- Identificação
    i.id                        AS imovel_id,
    i.projeto_id,
    p.nome                      AS projeto_nome,
    p.status                    AS projeto_status,
    p.numero_job,

    -- Dados do imóvel (fonte canônica: tabela imoveis)
    i.nome_imovel,
    i.tipo_imovel,
    i.comarca,
    i.municipio,
    i.estado,
    i.logradouro_imovel,
    i.numero_imovel,
    i.complemento_imovel,
    i.bairro_setor_imovel,
    i.cep_imovel,
    i.area_ha,
    i.classe_imovel,
    i.car,
    i.ccir,
    i.sncr,
    i.sigef,

    -- Bloco registral (fonte canônica: tabela registros_imobiliarios)
    ri.id                       AS registro_imobiliario_id,
    ri.matricula,
    ri.transcricao,
    ri.cartorio,
    ri.comarca                  AS comarca_cartorio,
    ri.municipio_cartorio,
    ri.uf_cartorio,
    ri.livro,
    ri.folha,
    ri.data_registro,
    ri.cnm,
    ri.cns,
    ri.origem_registro,

    -- Auditoria
    i.criado_em                 AS imovel_criado_em,
    i.atualizado_em             AS imovel_atualizado_em

FROM imoveis i
    JOIN projetos p ON p.id = i.projeto_id
    LEFT JOIN registros_imobiliarios ri
    ON ri.imovel_id = i.id
        AND ri.deleted_at IS NULL
WHERE i.deleted_at IS NULL
    AND p.deleted_at IS NULL;

COMMENT ON VIEW vw_imovel_projeto IS
    '[031] View de retrocompatibilidade: agrega imoveis + registros_imobiliarios + projetos. '
    'Substitui a leitura direta de projetos.nome_imovel, projetos.comarca etc. '
    'Útil para queries legadas de backend e relatórios enquanto as rotas não são migradas.';


-- -----------------------------------------------------------------
-- D) Verificação final
-- -----------------------------------------------------------------

DO $$
DECLARE
    v_view    BOOLEAN;
    v_lock_fn BOOLEAN;
BEGIN
    SELECT EXISTS
    (
        SELECT 1
    FROM pg_views
    WHERE schemaname = 'public' AND viewname = 'vw_imovel_projeto'
    )
    INTO v_view;

SELECT EXISTS
(
        SELECT 1
FROM pg_proc
WHERE proname = 'lockrow'
    AND pronamespace = 'public'
::regnamespace
    ) INTO v_lock_fn;

    RAISE NOTICE '[031] vw_imovel_projeto criada:             %', v_view;
    RAISE NOTICE '[031] Funções lockrow ainda existem (esperado FALSE): %', v_lock_fn;

IF NOT v_view THEN
        RAISE WARNING '[031] vw_imovel_projeto NÃO foi criada. Verifique dependências (tabelas imoveis, registros_imobiliarios, projetos).';
END
IF;

    IF v_lock_fn THEN
        RAISE WARNING '[031] lockrow() ainda existe após DROP. Pode ser uma variante com assinatura diferente. Verifique pg_proc.';
END
IF;
END $$;
