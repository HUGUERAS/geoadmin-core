-- =================================================================
-- GeoAdmin Pro — Migration 028: Fase 4 Portal do Cliente
-- 
-- 1. Adiciona campos de RG (órgão emissor + data emissão) em clientes
-- 2. Estende tipo_evento em eventos_magic_link com
--    'formulario_cliente_concluido' para notificação do escritório
-- =================================================================

-- -----------------------------------------------------------------
-- 1. Novos campos de identificação em clientes
-- -----------------------------------------------------------------
ALTER TABLE clientes
    ADD COLUMN
IF NOT EXISTS rg_orgao_emissor   TEXT,
ADD COLUMN
IF NOT EXISTS rg_data_emissao    DATE;

COMMENT ON COLUMN clientes.rg_orgao_emissor IS 'Órgão emissor do RG (ex: SSP/GO)';
COMMENT ON COLUMN clientes.rg_data_emissao   IS 'Data de emissão do RG';

-- -----------------------------------------------------------------
-- 2. Estender CHECK constraint de tipo_evento
--    A abordagem segura é dropar + recriar a constraint nomeada.
-- -----------------------------------------------------------------

-- Postgres permite recriar constraint inline via ADD CONSTRAINT IF NOT EXISTS
-- mas o nome original não é conhecido; usamos ALTER TABLE direto.

DO $$
BEGIN
    -- Remove qualquer constraint de check no tipo_evento para recriar expandida
    ALTER TABLE eventos_magic_link
        DROP CONSTRAINT IF EXISTS eventos_magic_link_tipo_evento_check;

    ALTER TABLE eventos_magic_link
        ADD CONSTRAINT eventos_magic_link_tipo_evento_check
        CHECK (tipo_evento IN (
            'gerado',
            'reenviado',
            'revogado',
            'consumido',
            'legado',
            'formulario_cliente_concluido'   -- [Fase-4] notificação de conclusão para o escritório
        ));
    EXCEPTION WHEN OTHERS THEN
    -- Se falhar (ex: constraint com nome diferente), continua silenciosamente.
    -- O backend normaliza tipos desconhecidos para 'gerado' como fallback.
    RAISE WARNING 'Não foi possível recriar constraint tipo_evento: %', SQLERRM;
END;
$$;
