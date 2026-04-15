-- =================================================================
-- GeoAdmin Pro — Migration 030: Backfill — Migrar Dados Legados
-- =================================================================
--
-- OBJETIVO
-- ─────────
-- Popular as tabelas canônicas criadas em 029 a partir dos dados
-- legados existentes no schema atual. Apenas inserts + selects,
-- NENHUMA linha é deletada ou modificada nas tabelas de origem.
--
-- OPERAÇÕES:
--   A) imoveis         ← projetos (campos do imóvel)
--   B) registros_imobiliarios ← projetos (via imoveis recém-criados)
--   C) responsaveis_tecnicos  ← tecnico (tabela legada 014)
--   D) projeto_responsaveis_tecnicos ← vínculo projetos ↔ tecnico
--   E) Diagnóstico de clientes (apenas SELECT, sem mover dados)
--
-- NOTA SOBRE RESPONSAVEL_TECNICO
-- ─────────────────────────────────
-- A instrução original previa migrar de projetos.responsavel_tecnico_nome
-- e projetos.responsavel_tecnico_crea, mas esses campos NÃO existem
-- na tabela `projetos`. A tabela legada de técnicos é `tecnico` (criada
-- em migration 014). O backfill usa essa fonte real.
--
-- IDEMPOTÊNCIA
-- ────────────
-- Todos os INSERTs usam NOT EXISTS para evitar duplicatas.
-- Seguro para re-execução.
--
-- ROLLBACK (para referência futura)
-- ──────────────────────────────────
-- DELETE FROM projeto_responsaveis_tecnicos
--   WHERE observacao LIKE '%[backfill-030]%';
-- DELETE FROM responsaveis_tecnicos
--   WHERE observacao LIKE '%[backfill-030]%'; -- campo não existe, usar criado_em range
-- DELETE FROM registros_imobiliarios ri
--   USING imoveis i WHERE ri.imovel_id = i.id
--   AND i.projeto_id IS NOT NULL
--   AND ri.observacoes LIKE '%[backfill-030]%';
-- DELETE FROM imoveis WHERE projeto_id IS NOT NULL
--   AND observacoes IS NOT NULL LIKE '%[backfill-030]%';
-- (Usar timestamp do deploy como marcador temporal é a alternativa segura)
-- =================================================================


-- -----------------------------------------------------------------
-- A) Popular `imoveis` a partir de `projetos`
--
--    Migra os campos do imóvel rural que historicamente ficaram
--    na tabela `projetos` por ausência de entidade separada.
--    Campos mapeados:
--      projetos.nome_imovel        → imoveis.nome_imovel
--      projetos.comarca            → imoveis.comarca
--      projetos.municipio          → imoveis.municipio
--      projetos.estado             → imoveis.estado
--      projetos.area_ha            → imoveis.area_ha
--      projetos.classe_imovel      → imoveis.classe_imovel
--      projetos.endereco_imovel    → imoveis.logradouro_imovel
--      projetos.endereco_imovel_numero → imoveis.numero_imovel
--      projetos.cep_imovel         → imoveis.cep_imovel
--
--    Condição de entrada: nome_imovel preenchido (dado mínimo
--    para identificar o imóvel; projetos sem nome_imovel são
--    dados incompletos que não devem ser migrados agora)
--
--    Guarda: NOT EXISTS por projeto_id evita duplicatas.
-- -----------------------------------------------------------------

INSERT INTO imoveis (
    projeto_id,
    nome_imovel,
    tipo_imovel,
    comarca,
    municipio,
    estado,
    area_ha,
    classe_imovel,
    logradouro_imovel,
    numero_imovel,
    cep_imovel
)
SELECT
    p.id                        AS projeto_id,
    p.nome_imovel,
    'rural'                     AS tipo_imovel,         -- default para projetos GPRF
    p.comarca,
    p.municipio,
    COALESCE(p.estado, 'GO')    AS estado,
    p.area_ha::NUMERIC(12,4),
    p.classe_imovel,
    p.endereco_imovel           AS logradouro_imovel,   -- campo canônico do imóvel
    p.endereco_imovel_numero    AS numero_imovel,
    p.cep_imovel
FROM projetos p
WHERE p.nome_imovel IS NOT NULL
  AND p.deleted_at IS NULL
  AND NOT EXISTS (
      SELECT 1
      FROM imoveis i
      WHERE i.projeto_id = p.id
        AND i.deleted_at IS NULL
  );

-- Relatório A
DO $$
DECLARE v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM imoveis WHERE projeto_id IS NOT NULL;
    RAISE NOTICE '[030-A] Total de imóveis após backfill: %', v_count;
END $$;


-- -----------------------------------------------------------------
-- B) Popular `registros_imobiliarios` a partir de `projetos`
--    via os imóveis recém-migrados em A)
--
--    Apenas migra projetos que tenham matricula preenchida.
--    A relação é: imovel (por projeto_id) → registro
--
--    Campos mapeados:
--      projetos.matricula  → registros_imobiliarios.matricula
--      projetos.comarca    → registros_imobiliarios.comarca
--      (cartório, livro, folha não existiam em `projetos`)
--
--    Guarda: NOT EXISTS por imovel_id evita duplicatas
--    (constraint UNIQUE(imovel_id) também protege).
-- -----------------------------------------------------------------

INSERT INTO registros_imobiliarios (
    imovel_id,
    matricula,
    comarca,
    observacoes
)
SELECT
    i.id            AS imovel_id,
    p.matricula,
    p.comarca,
    '[backfill-030] Migrado automaticamente de projetos.matricula'
FROM projetos p
JOIN imoveis i ON i.projeto_id = p.id
WHERE p.matricula IS NOT NULL
  AND p.deleted_at IS NULL
  AND i.deleted_at IS NULL
  AND NOT EXISTS (
      SELECT 1
      FROM registros_imobiliarios ri
      WHERE ri.imovel_id = i.id
        AND ri.deleted_at IS NULL
  );

-- Relatório B
DO $$
DECLARE v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM registros_imobiliarios WHERE observacoes LIKE '%[backfill-030]%';
    RAISE NOTICE '[030-B] Registros imobiliários migrados do backfill: %', v_count;
END $$;


-- -----------------------------------------------------------------
-- C) Popular `responsaveis_tecnicos` a partir de `tecnico`
--
--    A tabela `tecnico` (criada na migration 014) é a fonte legada
--    de dados de técnicos responsáveis. Ela é uma tabela de
--    configuração global (geralmente 1 registro por escritório).
--
--    Campos mapeados:
--      tecnico.nome          → responsaveis_tecnicos.nome
--      tecnico.cpf           → responsaveis_tecnicos.cpf
--      tecnico.crea          → responsaveis_tecnicos.crea + numero_conselho
--      tecnico.crt           → responsaveis_tecnicos.registro_conselho
--      tecnico.codigo_incra  → responsaveis_tecnicos.codigo_incra
--      tecnico.email         → responsaveis_tecnicos.email
--      tecnico.telefone      → responsaveis_tecnicos.telefone
--
--    Guarda: NOT EXISTS por nome evita duplicatas entre execuções.
--    NOTA: se dois técnicos tiverem o mesmo nome exato, apenas o
--    primeiro (por id) será migrado nesta janela.
-- -----------------------------------------------------------------

INSERT INTO responsaveis_tecnicos (
    nome,
    cpf,
    crea,
    numero_conselho,
    tipo_conselho,
    registro_conselho,
    codigo_incra,
    email,
    telefone,
    ativo,
    criado_em
)
SELECT DISTINCT ON (t.nome)
    t.nome,
    t.cpf,
    t.crea                      AS crea,
    t.crea                      AS numero_conselho,     -- crea como número canônico
    CASE
        WHEN t.crea IS NOT NULL AND t.crt IS NOT NULL THEN 'CREA/CFTA'
        WHEN t.crea IS NOT NULL THEN 'CREA'
        WHEN t.crt  IS NOT NULL THEN 'CFTA'
        ELSE NULL
    END                         AS tipo_conselho,
    t.crt                       AS registro_conselho,   -- CRT = Conselho de Técnicos
    t.codigo_incra,
    t.email,
    t.telefone,
    COALESCE(t.ativo, TRUE)     AS ativo,
    COALESCE(t.criado_em, NOW()) AS criado_em
FROM tecnico t
WHERE t.nome IS NOT NULL
  AND t.deleted_at IS NULL
  AND NOT EXISTS (
      SELECT 1
      FROM responsaveis_tecnicos rt
      WHERE rt.nome = t.nome
        AND rt.deleted_at IS NULL
  )
ORDER BY t.nome, t.criado_em ASC;

-- Relatório C
DO $$
DECLARE v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM responsaveis_tecnicos;
    RAISE NOTICE '[030-C] Total de responsáveis técnicos após backfill: %', v_count;
END $$;


-- -----------------------------------------------------------------
-- D) Vincular projetos ao técnico em projeto_responsaveis_tecnicos
--
--    Como a tabela `tecnico` é global (1 técnico de escritório),
--    vincula todos os projetos ativos ao técnico ativo correspondente.
--    O vínculo é feito por nome (bridge legado → canônico).
--
--    Guarda: NOT EXISTS por (projeto_id, responsavel_tecnico_id)
--    + UNIQUE constraint da tabela protegem contra duplicatas.
-- -----------------------------------------------------------------

INSERT INTO projeto_responsaveis_tecnicos (
    projeto_id,
    responsavel_tecnico_id,
    papel,
    principal,
    observacao,
    criado_em
)
SELECT
    p.id            AS projeto_id,
    rt.id           AS responsavel_tecnico_id,
    'principal'     AS papel,
    TRUE            AS principal,
    '[backfill-030] Vinculado automaticamente via tabela tecnico legada'
                    AS observacao,
    NOW()           AS criado_em
FROM projetos p
-- Une com o técnico ativo da tabela legada
JOIN tecnico t ON t.ativo = TRUE AND t.deleted_at IS NULL
-- Busca o canônico correspondente pelo nome
JOIN responsaveis_tecnicos rt ON rt.nome = t.nome AND rt.deleted_at IS NULL
WHERE p.deleted_at IS NULL
  -- Sem vínculo principal já existente
  AND NOT EXISTS (
      SELECT 1
      FROM projeto_responsaveis_tecnicos prt
      WHERE prt.projeto_id = p.id
        AND prt.principal = TRUE
  )
  -- Protege contra conflito do unique index uq_prt_principal_por_projeto
  AND NOT EXISTS (
      SELECT 1
      FROM projeto_responsaveis_tecnicos prt2
      WHERE prt2.projeto_id = p.id
        AND prt2.responsavel_tecnico_id = rt.id
  );

-- Relatório D
DO $$
DECLARE v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM projeto_responsaveis_tecnicos
    WHERE observacao LIKE '%[backfill-030]%';
    RAISE NOTICE '[030-D] Vínculos projeto↔técnico criados no backfill: %', v_count;
END $$;


-- -----------------------------------------------------------------
-- E) Diagnóstico de clientes — dados candidatos à tabela `pessoas`
--
--    Esta seção NÃO move dados. É apenas um levantamento para
--    planejar a Fase 6 (migração de clientes → pessoas).
--
--    Campos relevantes em `clientes` que precisarão ir para `pessoas`:
--      nome, cpf/cpf_cnpj, rg, estado_civil, profissao,
--      telefone, email, endereco*, municipio, estado, cep, setor,
--      conjuge_nome, conjuge_cpf
--
--    OPERAÇÃO DE ALTA COMPLEXIDADE — mantida fora desta migration:
--    • Cada `cliente` pode ter múltiplos projetos via projeto_clientes
--    • A desnormalização atual (cliente ↔ projeto 1:N) exige
--      reconciliação antes de criar `pessoas` + `pessoa_enderecos`
--    • Risco de duplicatas por CPF / nome similar
--    • Campos como formulario_ok, magic_link_token são de projeto_clientes
-- -----------------------------------------------------------------

DO $$
DECLARE
    v_total          INTEGER;
    v_com_cpf        INTEGER;
    v_com_endereco   INTEGER;
    v_com_conjuge    INTEGER;
    v_com_profissao  INTEGER;
    v_formulario_ok  INTEGER;
    v_sem_projeto    INTEGER;
BEGIN
    SELECT COUNT(*)
        INTO v_total
        FROM clientes WHERE deleted_at IS NULL;

    SELECT COUNT(*)
        INTO v_com_cpf
        FROM clientes
        WHERE deleted_at IS NULL
          AND COALESCE(cpf, cpf_cnpj) IS NOT NULL
          AND COALESCE(cpf, cpf_cnpj) != '';

    SELECT COUNT(*)
        INTO v_com_endereco
        FROM clientes
        WHERE deleted_at IS NULL
          AND (endereco IS NOT NULL OR municipio IS NOT NULL);

    SELECT COUNT(*)
        INTO v_com_conjuge
        FROM clientes
        WHERE deleted_at IS NULL
          AND conjuge_nome IS NOT NULL;

    SELECT COUNT(*)
        INTO v_com_profissao
        FROM clientes
        WHERE deleted_at IS NULL
          AND profissao IS NOT NULL;

    SELECT COUNT(*)
        INTO v_formulario_ok
        FROM clientes
        WHERE deleted_at IS NULL
          AND formulario_ok = TRUE;

    SELECT COUNT(*)
        INTO v_sem_projeto
        FROM clientes c
        WHERE c.deleted_at IS NULL
          AND NOT EXISTS (
              SELECT 1
              FROM projeto_clientes pc
              WHERE pc.cliente_id = c.id
                AND pc.deleted_at IS NULL
          );

    RAISE NOTICE '======================================================';
    RAISE NOTICE '[030-E] DIAGNÓSTICO: Clientes → candidatos a pessoas';
    RAISE NOTICE '------------------------------------------------------';
    RAISE NOTICE '  Total de clientes ativos:              %', v_total;
    RAISE NOTICE '  Com CPF/CNPJ preenchido:               %', v_com_cpf;
    RAISE NOTICE '  Com endereço (base para pessoa_enderecos): %', v_com_endereco;
    RAISE NOTICE '  Com dados de cônjuge:                  %', v_com_conjuge;
    RAISE NOTICE '  Com profissão preenchida:              %', v_com_profissao;
    RAISE NOTICE '  Com formulário concluído (formulario_ok): %', v_formulario_ok;
    RAISE NOTICE '  Sem projeto vinculado (orfãos):        %', v_sem_projeto;
    RAISE NOTICE '------------------------------------------------------';
    RAISE NOTICE '  PRÓXIMO PASSO (Fase 6):';
    RAISE NOTICE '  → Criar tabelas pessoas + pessoa_enderecos + projeto_pessoas';
    RAISE NOTICE '  → Reconciliar duplicatas por cpf_cnpj antes de migrar';
    RAISE NOTICE '  → Migrar clientes.endereco → pessoa_enderecos';
    RAISE NOTICE '    uso_endereco = ''residencial_ou_correspondencia''';
    RAISE NOTICE '======================================================';
END $$;
