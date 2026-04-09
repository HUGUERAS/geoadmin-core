-- =================================================================
-- GeoAdmin Pro — Migration 025: magic link canônico por vínculo
-- Consolida `projeto_clientes` como fonte operacional do magic link.
-- Não remove fisicamente as colunas legadas de `clientes` nesta etapa.
-- =================================================================

-- -----------------------------------------------------------------
-- 1. Backfill canônico do participante principal por projeto
-- -----------------------------------------------------------------

INSERT INTO projeto_clientes (
    projeto_id,
    cliente_id,
    papel,
    principal,
    recebe_magic_link,
    ordem,
    magic_link_token,
    magic_link_expira
)
SELECT
    p.id,
    p.cliente_id,
    'principal',
    TRUE,
    CASE
        WHEN c.magic_link_token IS NOT NULL THEN TRUE
        ELSE TRUE
    END,
    0,
    c.magic_link_token,
    c.magic_link_expira
FROM projetos p
JOIN clientes c ON c.id = p.cliente_id
WHERE p.deleted_at IS NULL
  AND p.cliente_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM projeto_clientes pc
      WHERE pc.projeto_id = p.id
        AND pc.deleted_at IS NULL
  );

-- -----------------------------------------------------------------
-- 2. Copiar tokens antigos para o vínculo canônico quando faltar
-- -----------------------------------------------------------------

WITH participante_alvo AS (
    SELECT DISTINCT ON (pc.projeto_id)
        pc.id,
        pc.cliente_id
    FROM projeto_clientes pc
    JOIN projetos p ON p.id = pc.projeto_id
    WHERE pc.deleted_at IS NULL
      AND p.deleted_at IS NULL
    ORDER BY pc.projeto_id, pc.principal DESC, pc.ordem ASC, pc.criado_em ASC
)
UPDATE projeto_clientes pc
SET
    magic_link_token = COALESCE(pc.magic_link_token, c.magic_link_token),
    magic_link_expira = COALESCE(pc.magic_link_expira, c.magic_link_expira),
    recebe_magic_link = CASE
        WHEN COALESCE(pc.magic_link_token, c.magic_link_token) IS NOT NULL THEN TRUE
        ELSE pc.recebe_magic_link
    END
FROM participante_alvo alvo
JOIN clientes c ON c.id = alvo.cliente_id
WHERE pc.id = alvo.id;

-- -----------------------------------------------------------------
-- 3. Views canônicas sem fallback operacional para `clientes`
-- -----------------------------------------------------------------

CREATE OR REPLACE VIEW vw_projeto_clientes AS
SELECT
    p.id AS projeto_id,
    p.nome AS projeto_nome,
    c.id AS cliente_id,
    c.nome AS cliente_nome,
    COALESCE(c.cpf, c.cpf_cnpj) AS cliente_cpf,
    c.telefone,
    c.email,
    pc.id AS projeto_cliente_id,
    pc.papel AS vinculo,
    pc.principal,
    pc.recebe_magic_link,
    pc.ordem,
    pc.area_id,
    pc.magic_link_token,
    pc.magic_link_expira,
    pc.criado_em,
    pc.atualizado_em
FROM projeto_clientes pc
JOIN clientes c ON c.id = pc.cliente_id
JOIN projetos p ON p.id = pc.projeto_id
WHERE pc.deleted_at IS NULL
  AND p.deleted_at IS NULL
  AND COALESCE(c.deleted_at, NULL) IS NULL;

CREATE OR REPLACE VIEW vw_formulario_cliente AS
SELECT
    p.id AS projeto_id,
    p.nome AS projeto_nome,
    p.nome_imovel,
    p.municipio AS imovel_municipio,
    p.estado AS imovel_estado,
    p.comarca,
    p.matricula,
    p.area_ha,
    c.id AS cliente_id,
    c.nome AS cliente_nome,
    COALESCE(c.cpf, c.cpf_cnpj) AS cliente_cpf,
    c.rg AS cliente_rg,
    c.estado_civil,
    c.profissao,
    c.telefone,
    c.email,
    c.endereco,
    c.endereco_numero,
    c.municipio AS cliente_municipio,
    c.estado AS cliente_estado,
    c.cep,
    c.conjuge_nome,
    c.conjuge_cpf,
    c.formulario_ok,
    c.formulario_em,
    pc.magic_link_token,
    pc.magic_link_expira,
    p.endereco_imovel,
    p.endereco_imovel_numero,
    p.cep_imovel
FROM projetos p
LEFT JOIN LATERAL (
    SELECT
        pc.id,
        pc.cliente_id,
        pc.magic_link_token,
        pc.magic_link_expira
    FROM projeto_clientes pc
    WHERE pc.projeto_id = p.id
      AND pc.deleted_at IS NULL
    ORDER BY pc.principal DESC, pc.ordem ASC, pc.criado_em ASC
    LIMIT 1
) pc ON TRUE
LEFT JOIN clientes c ON c.id = pc.cliente_id
WHERE p.deleted_at IS NULL;

-- -----------------------------------------------------------------
-- 4. Marcação explícita de legado
-- -----------------------------------------------------------------

COMMENT ON COLUMN clientes.magic_link_token IS
'LEGADO: nao usar como fonte operacional. A fonte oficial do token e projeto_clientes.magic_link_token.';

COMMENT ON COLUMN clientes.magic_link_expira IS
'LEGADO: nao usar como fonte operacional. A fonte oficial da expiracao e projeto_clientes.magic_link_expira.';
