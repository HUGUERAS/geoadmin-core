-- =================================================================
-- GeoAdmin Pro — Migration 026: Rastreio de consumo do magic link
-- [SEC-02] Adiciona coluna para registrar quando o token foi usado,
-- permitindo invalidação permanente e retorno HTTP 410 em reuso.
-- =================================================================

-- Adiciona coluna de timestamp de uso (idempotente)
ALTER TABLE projeto_clientes
    ADD COLUMN
IF NOT EXISTS magic_link_token_usado_em TIMESTAMPTZ;

COMMENT ON COLUMN projeto_clientes.magic_link_token_usado_em IS
'[SEC-02] Preenchido com NOW() no momento em que o cliente submete o formulário. '
'Quando não-nulo indica que o link já foi consumido e não pode ser reutilizado. '
'Resetado para NULL ao gerar um novo magic link.';

-- Índice parcial: acelera busca de tokens pendentes (não consumidos)
CREATE INDEX
IF NOT EXISTS idx_pc_magic_link_nao_usado
    ON projeto_clientes
(magic_link_token)
    WHERE deleted_at IS NULL
      AND magic_link_token IS NOT NULL
      AND magic_link_token_usado_em IS NULL;

-- Atualiza a view canônica para expor o campo
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
    pc.magic_link_token_usado_em, -- [SEC-02] expõe rastreio de consumo
    p.endereco_imovel,
    p.endereco_imovel_numero,
    p.cep_imovel
FROM projetos p
    LEFT JOIN LATERAL (
    SELECT
        pc .id,
    pc.cliente_id,
    pc.magic_link_token,
    pc.magic_link_expira,
    pc.magic_link_token_usado_em
    FROM projeto_clientes pc
WHERE pc.projeto_id = p.id
    AND pc.deleted_at IS NULL
ORDER BY pc.principal DESC, pc.ordem ASC, pc.criado_em ASC
    LIMIT 1
) pc
ON TRUE
LEFT JOIN clientes c ON c.id = pc.cliente_id
WHERE p.deleted_at IS NULL;
