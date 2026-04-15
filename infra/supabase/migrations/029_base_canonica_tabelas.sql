-- =================================================================
-- GeoAdmin Pro — Migration 029: Base Canônica — Tabelas Estruturais
-- =================================================================
--
-- OBJETIVO
-- ─────────
-- Criar as 4 tabelas canônicas da Fase 5 que faltavam no schema:
--   1. responsaveis_tecnicos        — técnico oficial do projeto
--   2. projeto_responsaveis_tecnicos — ligação projeto ↔ técnico
--   3. imoveis                      — imóvel rural como entidade própria
--   4. registros_imobiliarios       — bloco registral do imóvel
--
-- DECISÕES DE DESIGN
-- ──────────────────
-- • Alinhadas com docs/BASE_CANONICA_IMPLEMENTACAO.md e
--   docs/MODELO_DADOS_BASE_CANONICA.md (Fase 1 — Fundação)
-- • responsaveis_tecnicos contém campos canônicos do modelo
--   MAIS os campos legados crea/cfta para compatibilidade com
--   a tabela `tecnico` (014) durante a janela de convivência
-- • imoveis: usa area_ha NUMERIC(12,4) alinhado com projetos;
--   inclui campos canônicos do imóvel rural (tipo_imovel,
--   logradouro_imovel etc.) além dos campos básicos
-- • registros_imobiliarios: usa `matricula` como nome canônico
--   (o campo `numero_matricula` foi descartado em favor do
--   modelo oficial); inclui todos os campos do bloco registral
--   ampliado definidos na base canônica
--
-- REGRAS DE SEGURANÇA
-- ────────────────────
-- • Todas as tabelas com RLS habilitado
-- • Policy padrão: authenticated pode SELECT (leitura)
-- • Escrita controlada pelo backend via service_role
-- • Dados de clientes/PII: nenhuma dessas tabelas expõe magic
--   link, CPF ou dados pessoais diretamente — pertencem ao bloco
--   técnico/fundiário
--
-- IDEMPOTÊNCIA
-- ────────────
-- • 100% idempotente: CREATE TABLE/INDEX IF NOT EXISTS
-- • CREATE OR REPLACE para funções e triggers
-- • DROP TRIGGER IF EXISTS antes de recriar triggers
--
-- ROLLBACK (para referência futura)
-- ──────────────────────────────────
-- DROP VIEW IF EXISTS vw_imovel_projeto;   -- criada em 031
-- DROP TABLE IF EXISTS registros_imobiliarios;
-- DROP TABLE IF EXISTS projeto_responsaveis_tecnicos;
-- DROP TABLE IF EXISTS imoveis;
-- DROP TABLE IF EXISTS responsaveis_tecnicos;
-- DROP FUNCTION IF EXISTS public.trigger_set_timestamp();
-- =================================================================


-- -----------------------------------------------------------------
-- 0. Função genérica de timestamp para triggers
--    (padrão para todas as novas tabelas canônicas)
--    Uso: EXECUTE FUNCTION public.trigger_set_timestamp()
-- -----------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.trigger_set_timestamp()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.trigger_set_timestamp() IS
    '[029] Função genérica de atualização de atualizado_em. '
    'Adotada como padrão para as tabelas da base canônica (Fase 5+).';


-- =================================================================
-- 1. TABELA: responsaveis_tecnicos
--    Técnico oficial do projeto — bloco formal, não apenas texto
-- =================================================================

CREATE TABLE IF NOT EXISTS responsaveis_tecnicos (
    id                       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Identificação pessoal
    nome                     TEXT        NOT NULL,
    cpf                      TEXT,

    -- Qualificação profissional
    profissao                TEXT,
    tipo_conselho            TEXT,       -- 'CREA', 'CFTA', 'CAU', etc.
    numero_conselho          TEXT,       -- número do registro no conselho
    registro_conselho        TEXT,       -- complemento / tipo de registro
    crea                     TEXT,       -- LEGADO: compat. com tabela `tecnico`
    cfta                     TEXT,       -- Conselho Federal dos Técnicos Agrícolas
    codigo_incra             TEXT,       -- código cadastrado no INCRA
    art_trt                  TEXT,       -- número da ART/TRT vinculada
    qualificacao_profissional TEXT,

    -- Contato
    email                    TEXT,
    telefone                 TEXT,

    -- Controle
    ativo                    BOOLEAN     NOT NULL DEFAULT TRUE,
    criado_em                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at               TIMESTAMPTZ
);

COMMENT ON TABLE responsaveis_tecnicos IS
    '[029] Técnicos responsáveis pelo projeto. Substitui progressivamente '
    'a tabela `tecnico` (014) como fonte canônica. '
    'Campos crea/cfta mantidos por compatibilidade durante migração.';

COMMENT ON COLUMN responsaveis_tecnicos.crea IS
    'Registro no CREA. Espelhado de tecnico.crea durante backfill (030). '
    'Para novas entradas, preferir numero_conselho + tipo_conselho = ''CREA''.';
COMMENT ON COLUMN responsaveis_tecnicos.cfta IS
    'Registro no CFTA (Conselho Federal dos Técnicos Agrícolas).';
COMMENT ON COLUMN responsaveis_tecnicos.codigo_incra IS
    'Código de credenciamento cadastrado no INCRA.';
COMMENT ON COLUMN responsaveis_tecnicos.art_trt IS
    'Número da ART (CREA) ou TRT (CFTA) do serviço.';

-- Índice em ativo (usado em queries de filtro)
CREATE INDEX IF NOT EXISTS idx_resp_tecnicos_ativo
    ON responsaveis_tecnicos (ativo)
    WHERE deleted_at IS NULL;

-- Trigger de atualização automática
DROP TRIGGER IF EXISTS trg_resp_tecnicos_atualizado_em ON responsaveis_tecnicos;
CREATE TRIGGER trg_resp_tecnicos_atualizado_em
    BEFORE UPDATE ON responsaveis_tecnicos
    FOR EACH ROW
    EXECUTE FUNCTION public.trigger_set_timestamp();

-- RLS
ALTER TABLE responsaveis_tecnicos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "resp_tecnicos_leitura_authenticated"
    ON responsaveis_tecnicos
    FOR SELECT
    TO authenticated
    USING (deleted_at IS NULL);

CREATE POLICY "resp_tecnicos_escrita_service_role"
    ON responsaveis_tecnicos
    FOR ALL
    TO service_role
    USING (true);


-- =================================================================
-- 2. TABELA: projeto_responsaveis_tecnicos
--    Ligação projeto ↔ técnico com papéis e vigência
-- =================================================================

CREATE TABLE IF NOT EXISTS projeto_responsaveis_tecnicos (
    id                       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),

    projeto_id               UUID        NOT NULL REFERENCES projetos(id) ON DELETE CASCADE,
    responsavel_tecnico_id   UUID        NOT NULL REFERENCES responsaveis_tecnicos(id),

    -- Papel e vigência
    papel                    TEXT        NOT NULL DEFAULT 'principal'
                             CHECK (papel IN ('principal', 'auxiliar', 'fiscal', 'outro')),
    principal                BOOLEAN     NOT NULL DEFAULT TRUE,
    vigente_desde            TIMESTAMPTZ,
    vigente_ate              TIMESTAMPTZ,
    observacao               TEXT,

    -- Auditoria
    criado_em                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em            TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Unicidade: um técnico por projeto (permite múltiplos com papel diferente)
    UNIQUE (projeto_id, responsavel_tecnico_id)
);

COMMENT ON TABLE projeto_responsaveis_tecnicos IS
    '[029] Vínculo entre projeto e técnico responsável. '
    'Permite múltiplos técnicos por projeto com papéis distintos. '
    'Substitui a ligação implícita via tabela global `tecnico`.';

COMMENT ON COLUMN projeto_responsaveis_tecnicos.principal IS
    'TRUE = técnico principal do projeto. Máximo 1 por projeto (enforced por índice parcial).';
COMMENT ON COLUMN projeto_responsaveis_tecnicos.vigente_desde IS
    'Data de início da responsabilidade técnica neste projeto.';
COMMENT ON COLUMN projeto_responsaveis_tecnicos.vigente_ate IS
    'Data de encerramento da responsabilidade (NULL = ainda vigente).';

-- Índices em FK
CREATE INDEX IF NOT EXISTS idx_prt_projeto_id
    ON projeto_responsaveis_tecnicos (projeto_id);

CREATE INDEX IF NOT EXISTS idx_prt_responsavel_tecnico_id
    ON projeto_responsaveis_tecnicos (responsavel_tecnico_id);

-- Garante 1 técnico principal por projeto
CREATE UNIQUE INDEX IF NOT EXISTS uq_prt_principal_por_projeto
    ON projeto_responsaveis_tecnicos (projeto_id)
    WHERE principal = TRUE;

-- Trigger de atualização automática
DROP TRIGGER IF EXISTS trg_prt_atualizado_em ON projeto_responsaveis_tecnicos;
CREATE TRIGGER trg_prt_atualizado_em
    BEFORE UPDATE ON projeto_responsaveis_tecnicos
    FOR EACH ROW
    EXECUTE FUNCTION public.trigger_set_timestamp();

-- RLS
ALTER TABLE projeto_responsaveis_tecnicos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "prt_leitura_authenticated"
    ON projeto_responsaveis_tecnicos
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "prt_escrita_service_role"
    ON projeto_responsaveis_tecnicos
    FOR ALL
    TO service_role
    USING (true);


-- =================================================================
-- 3. TABELA: imoveis
--    Imóvel rural como entidade própria, separado do projeto
-- =================================================================

CREATE TABLE IF NOT EXISTS imoveis (
    id                       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    projeto_id               UUID        REFERENCES projetos(id) ON DELETE CASCADE,

    -- Identificação do imóvel
    nome_imovel              TEXT,
    tipo_imovel              TEXT        NOT NULL DEFAULT 'rural'
                             CHECK (tipo_imovel IN ('rural', 'urbano')),

    -- Localização fundiária (distinta do endereço da pessoa)
    comarca                  TEXT,
    municipio                TEXT,
    estado                   TEXT        DEFAULT 'GO',

    -- Endereço do imóvel rural (≠ endereço do requerente)
    logradouro_imovel        TEXT,       -- campo canônico: endereco_do_imovel_rural
    numero_imovel            TEXT,
    complemento_imovel       TEXT,
    bairro_setor_imovel      TEXT,
    cep_imovel               TEXT,

    -- Área e classificação
    area_ha                  NUMERIC(12,4),
    classe_imovel            TEXT,

    -- Registros fundiários (campos de identificação simples)
    car                      TEXT,       -- Cadastro Ambiental Rural
    ccir                     TEXT,       -- Certificado de Cadastro de Imóvel Rural
    sncr                     TEXT,       -- Sistema Nacional de Cadastro Rural
    sigef                    TEXT,       -- Sistema de Gestão Fundiária INCRA

    -- Auditoria
    criado_em                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at               TIMESTAMPTZ
);

COMMENT ON TABLE imoveis IS
    '[029] Imóvel rural como entidade própria. '
    'REGRA: logradouro_imovel representa o endereço do imóvel rural — '
    'NÃO pode ser reaproveitado como endereço do requerente. '
    'Endereço da pessoa fica em pessoa_enderecos (futura migration).';

COMMENT ON COLUMN imoveis.logradouro_imovel IS
    'Endereço/localidade do imóvel rural. '
    'ATENÇÃO: campo de localização fundiária, não de correspondência pessoal.';
COMMENT ON COLUMN imoveis.car IS 'Cadastro Ambiental Rural (CAR).';
COMMENT ON COLUMN imoveis.ccir IS 'Certificado de Cadastro de Imóvel Rural (CCIR/INCRA).';
COMMENT ON COLUMN imoveis.sncr IS 'Sistema Nacional de Cadastro Rural (SNCR).';
COMMENT ON COLUMN imoveis.sigef IS 'Código SIGEF (Sistema de Gestão Fundiária INCRA).';

-- Índice em FK
CREATE INDEX IF NOT EXISTS idx_imoveis_projeto_id
    ON imoveis (projeto_id)
    WHERE deleted_at IS NULL;

-- Trigger de atualização automática
DROP TRIGGER IF EXISTS trg_imoveis_atualizado_em ON imoveis;
CREATE TRIGGER trg_imoveis_atualizado_em
    BEFORE UPDATE ON imoveis
    FOR EACH ROW
    EXECUTE FUNCTION public.trigger_set_timestamp();

-- RLS
ALTER TABLE imoveis ENABLE ROW LEVEL SECURITY;

CREATE POLICY "imoveis_leitura_authenticated"
    ON imoveis
    FOR SELECT
    TO authenticated
    USING (deleted_at IS NULL);

CREATE POLICY "imoveis_escrita_service_role"
    ON imoveis
    FOR ALL
    TO service_role
    USING (true);


-- =================================================================
-- 4. TABELA: registros_imobiliarios
--    Bloco registral ampliado — ligado ao imóvel, não à pessoa
-- =================================================================

CREATE TABLE IF NOT EXISTS registros_imobiliarios (
    id                       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),

    -- FKs canônicas
    imovel_id                UUID        REFERENCES imoveis(id) ON DELETE CASCADE,
    area_projeto_id          UUID        REFERENCES areas_projeto(id),

    -- Bloco registral principal
    matricula                TEXT,       -- número da matrícula (nome canônico)
    transcricao              TEXT,       -- número da transcrição (pré-LRP 1973)
    cnm                      TEXT,       -- Código Nacional de Matrícula
    cns                      TEXT,       -- Código Nacional de Serventias

    -- Identificação do cartório
    cartorio                 TEXT,
    comarca                  TEXT,
    municipio_cartorio        TEXT,
    uf_cartorio              TEXT        CHECK (uf_cartorio IS NULL OR char_length(uf_cartorio) = 2),
    livro                    TEXT,
    folha                    TEXT,

    -- Cronologia
    data_registro            DATE,
    origem_registro          TEXT,       -- ex: 'transcrição', 'abertura', 'desmembramento'

    -- Observações e contexto
    observacoes              TEXT,

    -- Auditoria
    criado_em                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at               TIMESTAMPTZ,

    -- Um registro canônico por imóvel (pode ser relaxado futuramente para histórico)
    CONSTRAINT uq_registro_por_imovel UNIQUE (imovel_id)
);

COMMENT ON TABLE registros_imobiliarios IS
    '[029] Bloco registral ampliado do imóvel. '
    'REGRA: sempre ligado ao imóvel, não diretamente à pessoa. '
    'O campo `matricula` é o nome canônico (substitui numero_matricula). '
    'Para histórico de registros futuramente: remover UNIQUE e adicionar vigência.';

COMMENT ON COLUMN registros_imobiliarios.matricula IS
    'Número da matrícula no CRI. Nome canônico adotado na base nova.';
COMMENT ON COLUMN registros_imobiliarios.transcricao IS
    'Número da transcrição (regime anterior à Lei 6.015/1973).';
COMMENT ON COLUMN registros_imobiliarios.cnm IS
    'Código Nacional de Matrícula (CNM).';
COMMENT ON COLUMN registros_imobiliarios.cns IS
    'Código Nacional de Serventias (CNS).';
COMMENT ON COLUMN registros_imobiliarios.uf_cartorio IS
    'UF do cartório: obrigatoriamente 2 caracteres se preenchido.';
COMMENT ON COLUMN registros_imobiliarios.area_projeto_id IS
    'Referência opcional à área_projeto para rastreio cartográfico.';

-- Índice em FK
CREATE INDEX IF NOT EXISTS idx_reg_imob_imovel_id
    ON registros_imobiliarios (imovel_id)
    WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_reg_imob_area_projeto_id
    ON registros_imobiliarios (area_projeto_id)
    WHERE area_projeto_id IS NOT NULL AND deleted_at IS NULL;

-- Trigger de atualização automática
DROP TRIGGER IF EXISTS trg_reg_imob_atualizado_em ON registros_imobiliarios;
CREATE TRIGGER trg_reg_imob_atualizado_em
    BEFORE UPDATE ON registros_imobiliarios
    FOR EACH ROW
    EXECUTE FUNCTION public.trigger_set_timestamp();

-- RLS
ALTER TABLE registros_imobiliarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "reg_imob_leitura_authenticated"
    ON registros_imobiliarios
    FOR SELECT
    TO authenticated
    USING (deleted_at IS NULL);

CREATE POLICY "reg_imob_escrita_service_role"
    ON registros_imobiliarios
    FOR ALL
    TO service_role
    USING (true);


-- =================================================================
-- 5. Verificação inline
-- =================================================================

DO $$
DECLARE
    v_resp      BOOLEAN;
    v_prt       BOOLEAN;
    v_imoveis   BOOLEAN;
    v_reg       BOOLEAN;
    v_fn        BOOLEAN;
BEGIN
    SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename='responsaveis_tecnicos')
        INTO v_resp;
    SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename='projeto_responsaveis_tecnicos')
        INTO v_prt;
    SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename='imoveis')
        INTO v_imoveis;
    SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename='registros_imobiliarios')
        INTO v_reg;
    SELECT EXISTS (SELECT 1 FROM pg_proc WHERE proname='trigger_set_timestamp' AND pronamespace='public'::regnamespace)
        INTO v_fn;

    RAISE NOTICE '[029] responsaveis_tecnicos criada:         %', v_resp;
    RAISE NOTICE '[029] projeto_responsaveis_tecnicos criada: %', v_prt;
    RAISE NOTICE '[029] imoveis criada:                       %', v_imoveis;
    RAISE NOTICE '[029] registros_imobiliarios criada:        %', v_reg;
    RAISE NOTICE '[029] trigger_set_timestamp() criada:       %', v_fn;

    IF NOT (v_resp AND v_prt AND v_imoveis AND v_reg AND v_fn) THEN
        RAISE WARNING '[029] Uma ou mais tabelas/funções NÃO foram criadas. Verifique o log acima.';
    END IF;
END $$;
