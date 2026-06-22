-- =============================================================================
-- V000__extensions_and_functions.sql
-- SecretariaOnline2 (TCC) — PostgreSQL 16
-- =============================================================================
-- Objetivo:
--   1) Criar extensões necessárias ao schema do SO2
--   2) Disponibilizar função uuid_generate_v7() (UUID ordenável por tempo)
--
-- Observação:
--   O conteúdo desta V000 também está inline em schema_completo.sql (Etapa 5),
--   mantendo o arquivo único autocontido para execução direta.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "citext";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

CREATE OR REPLACE FUNCTION uuid_generate_v7() RETURNS uuid AS $$
  SELECT encode(
    set_bit(set_bit(
      overlay(uuid_send(gen_random_uuid()) placing
        substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
        from 1 for 6),
      52, 1), 53, 1), 'hex')::uuid;
$$ LANGUAGE sql VOLATILE;

-- ROLLBACK (manual):
-- DROP FUNCTION IF EXISTS uuid_generate_v7();
-- DROP EXTENSION IF EXISTS pg_trgm;
-- DROP EXTENSION IF EXISTS citext;
-- DROP EXTENSION IF EXISTS pgcrypto;
-- DROP EXTENSION IF EXISTS "uuid-ossp";

