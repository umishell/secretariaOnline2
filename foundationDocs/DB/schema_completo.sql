-- =============================================================================
-- schema_completo.sql
-- FIGURA/ARTEFATO TCC — Banco transacional SecretariaOnline2 (SO2)
-- PostgreSQL 16
-- =============================================================================
-- Fontes:
--   - foundationDocs/DB/modelo-fisico.dbml
--   - foundationDocs/DB/00-inventario-e-decisoes.md
--   - foundationDocs/analysis/analise_arquitetural_secretariaonline2.md (§5.3)
--   - agents/database-engineer.md
--
-- Regras aplicadas:
--   - UUIDv7 em todas as PKs (uuid_generate_v7())
--   - TIMESTAMPTZ para data/hora
--   - JSONB com defaults explícitos ('{}'::jsonb / '[]'::jsonb)
--   - IAM técnico: refresh_token + jti_blacklist (sem password_reset_token)
--   - request_attachment.status com PENDING/CONFIRMED (I11)
--   - Dependência circular curso ↔ usuario resolvida via FK tardia (ALTER TABLE)
--
-- Execução:
--   psql -d <database> -f foundationDocs/DB/schema_completo.sql
-- =============================================================================

-- =============================================================================
-- 0) EXTENSÕES + FUNÇÃO UUIDv7 (inline da V000)
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

-- =============================================================================
-- 1) CREATE TABLES — ordem §4 (com ajustes I7/I8)
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1.1 ACADÊMICO (parcial para quebrar circularidade I7)
-- ---------------------------------------------------------------------------

CREATE TABLE curso (
    id                   UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    nome                 VARCHAR(200) NOT NULL,
    sigla                VARCHAR(20) UNIQUE NOT NULL,
    codigo_sie           VARCHAR(20),
    tipo_calendario      SMALLINT NOT NULL,
    horas_formativas_req INTEGER NOT NULL DEFAULT 0,
    ativo                BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE disciplina (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    codigo        VARCHAR(30) NOT NULL,
    nome          VARCHAR(200) NOT NULL,
    id_curso      UUID NOT NULL REFERENCES curso(id),
    periodo       SMALLINT,
    carga_horaria INTEGER,
    ativa         BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (id_curso, codigo)
);

CREATE TABLE periodo_letivo (
    id       UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    ano      SMALLINT NOT NULL,
    semestre SMALLINT NOT NULL CHECK (semestre IN (1,2)),
    data_ini DATE NOT NULL,
    data_fim DATE NOT NULL,
    UNIQUE (ano, semestre)
);

-- ROLLBACK (manual):
-- DROP TABLE IF EXISTS periodo_letivo CASCADE;
-- DROP TABLE IF EXISTS disciplina CASCADE;
-- DROP TABLE IF EXISTS curso CASCADE;

-- ---------------------------------------------------------------------------
-- 1.2 IAM + SESSÃO
-- ---------------------------------------------------------------------------

CREATE TABLE usuario (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    nome                VARCHAR(200) NOT NULL,
    cpf                 VARCHAR(11) UNIQUE,
    email               CITEXT UNIQUE NOT NULL,
    email_ufpr          CITEXT UNIQUE,
    grr                 VARCHAR(20) UNIQUE,
    senha_hash          VARCHAR(200) NOT NULL,
    senha_alterada      BOOLEAN NOT NULL DEFAULT FALSE,
    telefone            VARCHAR(30),
    id_curso            UUID REFERENCES curso(id),
    metadata            JSONB NOT NULL DEFAULT '{}'::jsonb,
    password_history    JSONB NOT NULL DEFAULT '[]'::jsonb,
    falhas_consecutivas INTEGER NOT NULL DEFAULT 0,
    bloqueado_ate       TIMESTAMPTZ,
    ativo               BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE TABLE role (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    code        VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(200) NOT NULL
);

CREATE TABLE authority (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    code        VARCHAR(100) UNIQUE NOT NULL,
    description VARCHAR(200) NOT NULL
);

CREATE TABLE role_authority (
    id_role      UUID NOT NULL REFERENCES role(id),
    id_authority UUID NOT NULL REFERENCES authority(id),
    PRIMARY KEY (id_role, id_authority)
);

CREATE TABLE usuario_role (
    id_usuario UUID NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    id_role    UUID NOT NULL REFERENCES role(id) ON DELETE CASCADE,
    escopo     JSONB NOT NULL DEFAULT '{}'::jsonb,
    PRIMARY KEY (id_usuario, id_role)
);

CREATE TABLE refresh_token (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    id_usuario  UUID NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    token_hash  VARCHAR(200) NOT NULL,
    expira_em   TIMESTAMPTZ NOT NULL,
    usado_em    TIMESTAMPTZ,
    revogado_em TIMESTAMPTZ,
    ip          INET,
    user_agent  TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE jti_blacklist (
    jti        UUID PRIMARY KEY,
    expira_em  TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ROLLBACK (manual):
-- DROP TABLE IF EXISTS jti_blacklist CASCADE;
-- DROP TABLE IF EXISTS refresh_token CASCADE;
-- DROP TABLE IF EXISTS usuario_role CASCADE;
-- DROP TABLE IF EXISTS role_authority CASCADE;
-- DROP TABLE IF EXISTS authority CASCADE;
-- DROP TABLE IF EXISTS role CASCADE;
-- DROP TABLE IF EXISTS usuario CASCADE;

-- ---------------------------------------------------------------------------
-- 1.3 SOLICITAÇÕES (config primeiro para resolver I8)
-- ---------------------------------------------------------------------------

CREATE TABLE request_type (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    code          VARCHAR(50) UNIQUE NOT NULL,
    descricao     VARCHAR(200) NOT NULL,
    prazo_dias    INTEGER NOT NULL DEFAULT 15,
    interna       BOOLEAN NOT NULL DEFAULT FALSE,
    form_schema   JSONB NOT NULL,
    workflow_json JSONB NOT NULL,
    required_auth JSONB NOT NULL DEFAULT '[]'::jsonb,
    ativo         BOOLEAN NOT NULL DEFAULT TRUE
);

-- ROLLBACK (manual):
-- DROP TABLE IF EXISTS request_type CASCADE;

-- ---------------------------------------------------------------------------
-- 1.4 ACADÊMICO (restante — agora pode referenciar request_type)
-- ---------------------------------------------------------------------------

CREATE TABLE calendario_academico (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    id_periodo      UUID NOT NULL REFERENCES periodo_letivo(id),
    id_request_type UUID NOT NULL REFERENCES request_type(id),
    dt_ini          DATE NOT NULL,
    dt_fim          DATE NOT NULL,
    observacao      TEXT,
    CHECK (dt_fim >= dt_ini)
);

-- ROLLBACK (manual):
-- DROP TABLE IF EXISTS calendario_academico CASCADE;

-- ---------------------------------------------------------------------------
-- 1.5 SOLICITAÇÕES (restante)
-- ---------------------------------------------------------------------------

CREATE TABLE request (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    numero_anual    INTEGER NOT NULL,
    ano             SMALLINT NOT NULL,
    id_solicitante  UUID NOT NULL REFERENCES usuario(id),
    id_request_type UUID NOT NULL REFERENCES request_type(id),
    id_curso        UUID NOT NULL REFERENCES curso(id),
    estado          VARCHAR(50) NOT NULL,
    dados           JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    concluded_at    TIMESTAMPTZ,
    prazo_em        TIMESTAMPTZ NOT NULL,
    UNIQUE (ano, numero_anual)
);

CREATE TABLE request_event (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    id_request      UUID NOT NULL REFERENCES request(id) ON DELETE CASCADE,
    id_ator         UUID REFERENCES usuario(id),
    tipo            VARCHAR(50) NOT NULL,
    estado_anterior VARCHAR(50),
    estado_novo     VARCHAR(50),
    parecer         TEXT,
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
    at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE request_line_item (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    id_request    UUID NOT NULL REFERENCES request(id) ON DELETE CASCADE,
    id_disciplina UUID REFERENCES disciplina(id),
    operacao      VARCHAR(20),
    turma         VARCHAR(10),
    estado        VARCHAR(30) NOT NULL DEFAULT 'PENDENTE',
    parecer       TEXT,
    metadata      JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE request_attachment (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    id_request    UUID NOT NULL REFERENCES request(id) ON DELETE CASCADE,
    categoria     VARCHAR(50) NOT NULL,
    nome_original VARCHAR(255) NOT NULL,
    storage_key   VARCHAR(500) NOT NULL,
    mime_type     VARCHAR(100) NOT NULL,
    tamanho_bytes BIGINT NOT NULL,
    sha256        CHAR(64) NOT NULL,
    uploaded_by   UUID NOT NULL REFERENCES usuario(id),
    status        VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED'
                  CHECK (status IN ('PENDING', 'CONFIRMED')),
    uploaded_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ROLLBACK (manual):
-- DROP TABLE IF EXISTS request_attachment CASCADE;
-- DROP TABLE IF EXISTS request_line_item CASCADE;
-- DROP TABLE IF EXISTS request_event CASCADE;
-- DROP TABLE IF EXISTS request CASCADE;

-- ---------------------------------------------------------------------------
-- 1.6 FORMATIVAS
-- ---------------------------------------------------------------------------

CREATE TABLE formative_activity (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    id_curso          UUID NOT NULL REFERENCES curso(id),
    descricao         VARCHAR(300) NOT NULL,
    qtd_horas_max     INTEGER NOT NULL,
    doc_comprobatorio VARCHAR(300),
    ativa             BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE formative_entry (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    id_aluno         UUID NOT NULL REFERENCES usuario(id),
    id_activity      UUID NOT NULL REFERENCES formative_activity(id),
    horas_declaradas INTEGER NOT NULL,
    horas_validadas  INTEGER,
    estado           VARCHAR(30) NOT NULL DEFAULT 'SUBMETIDA',
    parecer          TEXT,
    id_storage_key   UUID,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reviewed_at      TIMESTAMPTZ,
    reviewed_by      UUID REFERENCES usuario(id)
);

-- ROLLBACK (manual):
-- DROP TABLE IF EXISTS formative_entry CASCADE;
-- DROP TABLE IF EXISTS formative_activity CASCADE;

-- ---------------------------------------------------------------------------
-- 1.7 ESTÁGIO
-- ---------------------------------------------------------------------------

CREATE TABLE internship (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    id_aluno          UUID NOT NULL REFERENCES usuario(id),
    id_orientador     UUID NOT NULL REFERENCES usuario(id),
    id_coe            UUID REFERENCES usuario(id),
    empresa_nome      VARCHAR(200) NOT NULL,
    supervisor_nome   VARCHAR(200),
    supervisor_email  CITEXT,
    supervisor_tel    VARCHAR(30),
    data_ini          DATE NOT NULL,
    data_fim_prevista DATE,
    data_fim          DATE,
    ch_semanal        INTEGER,
    valor_bolsa_cents INTEGER,
    obrigatorio       BOOLEAN NOT NULL,
    num_contrato      VARCHAR(50),
    num_processo_sei  VARCHAR(50),
    estado            VARCHAR(30) NOT NULL,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE internship_document (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    id_internship UUID NOT NULL REFERENCES internship(id) ON DELETE CASCADE,
    categoria     VARCHAR(50) NOT NULL,
    storage_key   VARCHAR(500) NOT NULL,
    sha256        CHAR(64) NOT NULL,
    emitido_em    DATE
);

-- ROLLBACK (manual):
-- DROP TABLE IF EXISTS internship_document CASCADE;
-- DROP TABLE IF EXISTS internship CASCADE;

-- ---------------------------------------------------------------------------
-- 1.8 TCC
-- ---------------------------------------------------------------------------

CREATE TABLE tcc (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    id_curso    UUID NOT NULL REFERENCES curso(id),
    tema        VARCHAR(300) NOT NULL,
    data_defesa TIMESTAMPTZ,
    id_sala     UUID,
    link_artigo VARCHAR(500),
    storage_key VARCHAR(500),
    estado      VARCHAR(30) NOT NULL
);

CREATE TABLE tcc_member (
    id_tcc   UUID NOT NULL REFERENCES tcc(id) ON DELETE CASCADE,
    id_aluno UUID NOT NULL REFERENCES usuario(id),
    PRIMARY KEY (id_tcc, id_aluno)
);

CREATE TABLE tcc_examiner (
    id_tcc       UUID NOT NULL REFERENCES tcc(id) ON DELETE CASCADE,
    id_professor UUID NOT NULL REFERENCES usuario(id),
    orientador   BOOLEAN NOT NULL,
    PRIMARY KEY (id_tcc, id_professor)
);

-- ROLLBACK (manual):
-- DROP TABLE IF EXISTS tcc_examiner CASCADE;
-- DROP TABLE IF EXISTS tcc_member CASCADE;
-- DROP TABLE IF EXISTS tcc CASCADE;

-- ---------------------------------------------------------------------------
-- 1.9 COMUNICAÇÃO + OUTBOX
-- ---------------------------------------------------------------------------

CREATE TABLE communication (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    tipo          VARCHAR(30) NOT NULL,
    prioridade    SMALLINT NOT NULL,
    titulo        VARCHAR(200) NOT NULL,
    corpo_md      TEXT NOT NULL,
    id_curso_alvo UUID REFERENCES curso(id),
    audiencia     JSONB NOT NULL DEFAULT '{}'::jsonb,
    publicado_em  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expira_em     TIMESTAMPTZ,
    id_autor      UUID NOT NULL REFERENCES usuario(id)
);

CREATE TABLE communication_delivery (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    id_comm         UUID NOT NULL REFERENCES communication(id) ON DELETE CASCADE,
    id_destinatario UUID NOT NULL REFERENCES usuario(id),
    canal           VARCHAR(20) NOT NULL,
    estado          VARCHAR(20) NOT NULL,
    tentativas      SMALLINT NOT NULL DEFAULT 0,
    last_error      TEXT,
    sent_at         TIMESTAMPTZ,
    read_at         TIMESTAMPTZ
);

CREATE TABLE notification_preference (
    id_usuario UUID PRIMARY KEY REFERENCES usuario(id) ON DELETE CASCADE,
    email_on   JSONB NOT NULL DEFAULT '{"critical":true,"high":true}'::jsonb,
    push_on    JSONB NOT NULL DEFAULT '{"critical":true,"high":true,"medium":true}'::jsonb,
    dnd_from   TIME,
    dnd_to     TIME
);

CREATE TABLE outbox_event (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    aggregate_type  VARCHAR(50) NOT NULL,
    aggregate_id    UUID NOT NULL,
    event_type      VARCHAR(100) NOT NULL,
    payload         JSONB NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                    CHECK (status IN ('PENDING', 'SENT', 'FAILED', 'DEAD')),
    tentativas      SMALLINT NOT NULL DEFAULT 0,
    next_attempt_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at    TIMESTAMPTZ
);

-- ROLLBACK (manual):
-- DROP TABLE IF EXISTS outbox_event CASCADE;
-- DROP TABLE IF EXISTS notification_preference CASCADE;
-- DROP TABLE IF EXISTS communication_delivery CASCADE;
-- DROP TABLE IF EXISTS communication CASCADE;

-- ---------------------------------------------------------------------------
-- 1.10 PRESENÇA / EVENTOS v4.1
-- ---------------------------------------------------------------------------

CREATE TABLE event_attendance (
    id                 UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    titulo             VARCHAR(200) NOT NULL,
    id_curso           UUID REFERENCES curso(id),
    organizador        UUID NOT NULL REFERENCES usuario(id),
    ini_em             TIMESTAMPTZ NOT NULL,
    fim_em             TIMESTAMPTZ NOT NULL,
    ch_creditadas      NUMERIC(5,2) NOT NULL,
    attendance_mode    VARCHAR(30) NOT NULL
                     CHECK (attendance_mode IN ('QR_SINGLE','QR_DUAL','SECRET_SINGLE','SECRET_DUAL')),
    validation_windows JSONB,
    estado             VARCHAR(30) NOT NULL DEFAULT 'AGENDADO'
                     CHECK (estado IN ('AGENDADO','EM_ANDAMENTO','CONCLUIDO')),
    pin_entrada_hash   VARCHAR(128),
    pin_saida_hash     VARCHAR(128),
    janela_entrada_ini TIMESTAMPTZ,
    janela_entrada_fim TIMESTAMPTZ,
    janela_saida_ini   TIMESTAMPTZ,
    janela_saida_fim   TIMESTAMPTZ
);

CREATE TABLE attendance_session (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    id_evento   UUID NOT NULL REFERENCES event_attendance(id) ON DELETE CASCADE,
    id_aluno    UUID NOT NULL REFERENCES usuario(id),
    device_uuid UUID NOT NULL,
    entrada_em  TIMESTAMPTZ,
    saida_em    TIMESTAMPTZ,
    estado      VARCHAR(40) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (id_evento, id_aluno),
    UNIQUE (id_evento, device_uuid)
);

-- ROLLBACK (manual):
-- DROP TABLE IF EXISTS attendance_session CASCADE;
-- DROP TABLE IF EXISTS event_attendance CASCADE;

-- ---------------------------------------------------------------------------
-- 1.11 CERTIFICADOS
-- ---------------------------------------------------------------------------

CREATE TABLE certificate (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    id_beneficiario UUID NOT NULL REFERENCES usuario(id),
    id_evento       UUID REFERENCES event_attendance(id),
    id_formativa    UUID REFERENCES formative_entry(id),
    titulo          VARCHAR(200) NOT NULL,
    ch_horas        NUMERIC(5,2) NOT NULL,
    emitido_em      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    emitente_nome   VARCHAR(200) NOT NULL,
    hash_sha256     CHAR(64) NOT NULL,
    signature_alg   VARCHAR(30) NOT NULL,
    signature_b64   TEXT NOT NULL,
    verifier_url    VARCHAR(300) NOT NULL,
    storage_key     VARCHAR(500) NOT NULL
);

-- ROLLBACK (manual):
-- DROP TABLE IF EXISTS certificate CASCADE;

-- ---------------------------------------------------------------------------
-- 1.12 AUDITORIA
-- ---------------------------------------------------------------------------

CREATE TABLE audit_log (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    id_ator    UUID REFERENCES usuario(id),
    acao       VARCHAR(100) NOT NULL,
    alvo_tipo  VARCHAR(50) NOT NULL,
    alvo_id    UUID,
    ip         INET,
    user_agent TEXT,
    payload    JSONB DEFAULT '{}'::jsonb,
    resultado  VARCHAR(20) NOT NULL
               CHECK (resultado IN ('OK','DENIED','ERROR'))
);

-- ROLLBACK (manual):
-- DROP TABLE IF EXISTS audit_log CASCADE;

-- ---------------------------------------------------------------------------
-- 1.13 FK tardia — resolve circularidade curso ↔ usuario (I7)
-- ---------------------------------------------------------------------------

ALTER TABLE curso
  ADD COLUMN id_coordenador UUID REFERENCES usuario(id);

-- ROLLBACK (manual):
-- ALTER TABLE curso DROP COLUMN IF EXISTS id_coordenador;

-- =============================================================================
-- 2) CREATE INDEX — após tabelas (conforme Etapa 5)
-- =============================================================================

-- IAM
CREATE INDEX idx_usuario_curso ON usuario(id_curso) WHERE deleted_at IS NULL;
CREATE INDEX idx_usuario_nome_trgm ON usuario USING GIN (nome gin_trgm_ops);
CREATE INDEX idx_role_authority_role ON role_authority(id_role);
CREATE INDEX idx_role_authority_authority ON role_authority(id_authority);
CREATE INDEX idx_usuario_role_role ON usuario_role(id_role);
CREATE INDEX idx_refresh_token_usuario ON refresh_token(id_usuario);
CREATE INDEX idx_refresh_token_expira_em ON refresh_token(expira_em);
CREATE INDEX idx_refresh_token_revogado_em ON refresh_token(revogado_em);
CREATE INDEX idx_jti_blacklist_expira_em ON jti_blacklist(expira_em);

-- Acadêmico
CREATE INDEX idx_curso_coordenador ON curso(id_coordenador);
CREATE INDEX idx_disciplina_curso ON disciplina(id_curso);
CREATE INDEX idx_calendario_periodo ON calendario_academico(id_periodo);
CREATE INDEX idx_calendario_request_type ON calendario_academico(id_request_type);
CREATE INDEX idx_calendario_periodo_tipo ON calendario_academico(id_periodo, id_request_type);

-- Solicitações
CREATE INDEX idx_request_type_ativo ON request_type(ativo);
CREATE INDEX idx_request_type_form_schema_gin ON request_type USING GIN(form_schema);
CREATE INDEX idx_request_type_workflow_json_gin ON request_type USING GIN(workflow_json);

CREATE INDEX idx_request_solicitante ON request(id_solicitante);
CREATE INDEX idx_request_tipo ON request(id_request_type);
CREATE INDEX idx_request_curso ON request(id_curso);
CREATE INDEX idx_request_estado ON request(estado);
CREATE INDEX idx_request_curso_estado ON request(id_curso, estado);
CREATE INDEX idx_request_prazo_abertas ON request(prazo_em) WHERE concluded_at IS NULL;
CREATE INDEX idx_request_dados_gin ON request USING GIN(dados);

CREATE INDEX idx_request_event_req ON request_event(id_request, at DESC);
CREATE INDEX idx_request_event_ator ON request_event(id_ator);

CREATE INDEX idx_request_line_item_request ON request_line_item(id_request);
CREATE INDEX idx_request_line_item_disciplina ON request_line_item(id_disciplina);
CREATE INDEX idx_request_line_item_estado ON request_line_item(estado);

CREATE INDEX idx_request_attachment_request ON request_attachment(id_request);
CREATE INDEX idx_request_attachment_uploaded_by ON request_attachment(uploaded_by);
CREATE INDEX idx_request_attachment_status ON request_attachment(status);
CREATE INDEX idx_request_attachment_sha256 ON request_attachment(sha256);

-- Formativas
CREATE INDEX idx_formative_activity_curso ON formative_activity(id_curso);
CREATE INDEX idx_formative_activity_ativa ON formative_activity(ativa);
CREATE INDEX idx_formative_entry_aluno ON formative_entry(id_aluno);
CREATE INDEX idx_formative_entry_activity ON formative_entry(id_activity);
CREATE INDEX idx_formative_entry_reviewed_by ON formative_entry(reviewed_by);
CREATE INDEX idx_formative_entry_estado ON formative_entry(estado);

-- Estágio
CREATE INDEX idx_internship_aluno ON internship(id_aluno);
CREATE INDEX idx_internship_orientador ON internship(id_orientador);
CREATE INDEX idx_internship_coe ON internship(id_coe);
CREATE INDEX idx_internship_estado ON internship(estado);
CREATE INDEX idx_internship_data_ini ON internship(data_ini);
CREATE INDEX idx_internship_document_internship ON internship_document(id_internship);
CREATE INDEX idx_internship_document_categoria ON internship_document(categoria);
CREATE INDEX idx_internship_document_sha256 ON internship_document(sha256);

-- TCC
CREATE INDEX idx_tcc_curso ON tcc(id_curso);
CREATE INDEX idx_tcc_estado ON tcc(estado);
CREATE INDEX idx_tcc_data_defesa ON tcc(data_defesa);
CREATE INDEX idx_tcc_member_aluno ON tcc_member(id_aluno);
CREATE INDEX idx_tcc_examiner_professor ON tcc_examiner(id_professor);

-- Comunicação + Outbox
CREATE INDEX idx_communication_curso_alvo ON communication(id_curso_alvo);
CREATE INDEX idx_communication_autor ON communication(id_autor);
CREATE INDEX idx_communication_publicado_em ON communication(publicado_em);
CREATE INDEX idx_communication_expira_em ON communication(expira_em);
CREATE INDEX idx_communication_audiencia_gin ON communication USING GIN(audiencia);

CREATE INDEX idx_communication_delivery_comm ON communication_delivery(id_comm);
CREATE INDEX idx_communication_delivery_destinatario ON communication_delivery(id_destinatario);
CREATE INDEX idx_communication_delivery_estado ON communication_delivery(estado);
CREATE INDEX idx_communication_delivery_dest_estado ON communication_delivery(id_destinatario, estado);

CREATE INDEX idx_outbox_aggregate ON outbox_event(aggregate_type, aggregate_id);
CREATE INDEX idx_outbox_event_type ON outbox_event(event_type);
CREATE INDEX idx_outbox_status ON outbox_event(status);
CREATE INDEX idx_outbox_pending ON outbox_event(next_attempt_at) WHERE status = 'PENDING';
CREATE INDEX idx_outbox_payload_gin ON outbox_event USING GIN(payload);

-- Presença
CREATE INDEX idx_event_attendance_curso ON event_attendance(id_curso);
CREATE INDEX idx_event_attendance_organizador ON event_attendance(organizador);
CREATE INDEX idx_event_attendance_estado ON event_attendance(estado);
CREATE INDEX idx_event_attendance_mode ON event_attendance(attendance_mode);
CREATE INDEX idx_event_attendance_janela ON event_attendance(ini_em, fim_em);
CREATE INDEX idx_event_attendance_windows_gin ON event_attendance USING GIN(validation_windows);

CREATE INDEX idx_attendance_session_aluno ON attendance_session(id_aluno);
CREATE INDEX idx_attendance_session_estado ON attendance_session(estado);

-- Certificados + Auditoria
CREATE UNIQUE INDEX idx_cert_hash ON certificate(hash_sha256);
CREATE INDEX idx_certificate_beneficiario ON certificate(id_beneficiario);
CREATE INDEX idx_certificate_evento ON certificate(id_evento);
CREATE INDEX idx_certificate_formativa ON certificate(id_formativa);
CREATE INDEX idx_certificate_emitido_em ON certificate(emitido_em);

CREATE INDEX idx_audit_ator ON audit_log(id_ator);
CREATE INDEX idx_audit_ator_at_desc ON audit_log(id_ator, at DESC);
CREATE INDEX idx_audit_alvo ON audit_log(alvo_tipo, alvo_id);
CREATE INDEX idx_audit_at ON audit_log(at);
CREATE INDEX idx_audit_payload_gin ON audit_log USING GIN(payload);

-- ROLLBACK (manual):
-- DROP INDEX IF EXISTS idx_audit_payload_gin;
-- DROP INDEX IF EXISTS idx_audit_at;
-- DROP INDEX IF EXISTS idx_audit_alvo;
-- DROP INDEX IF EXISTS idx_audit_ator_at_desc;
-- DROP INDEX IF EXISTS idx_audit_ator;
-- DROP INDEX IF EXISTS idx_certificate_emitido_em;
-- DROP INDEX IF EXISTS idx_certificate_formativa;
-- DROP INDEX IF EXISTS idx_certificate_evento;
-- DROP INDEX IF EXISTS idx_certificate_beneficiario;
-- DROP INDEX IF EXISTS idx_cert_hash;
-- DROP INDEX IF EXISTS idx_attendance_session_estado;
-- DROP INDEX IF EXISTS idx_attendance_session_aluno;
-- DROP INDEX IF EXISTS idx_event_attendance_windows_gin;
-- DROP INDEX IF EXISTS idx_event_attendance_janela;
-- DROP INDEX IF EXISTS idx_event_attendance_mode;
-- DROP INDEX IF EXISTS idx_event_attendance_estado;
-- DROP INDEX IF EXISTS idx_event_attendance_organizador;
-- DROP INDEX IF EXISTS idx_event_attendance_curso;
-- DROP INDEX IF EXISTS idx_outbox_payload_gin;
-- DROP INDEX IF EXISTS idx_outbox_pending;
-- DROP INDEX IF EXISTS idx_outbox_status;
-- DROP INDEX IF EXISTS idx_outbox_event_type;
-- DROP INDEX IF EXISTS idx_outbox_aggregate;
-- DROP INDEX IF EXISTS idx_communication_delivery_dest_estado;
-- DROP INDEX IF EXISTS idx_communication_delivery_estado;
-- DROP INDEX IF EXISTS idx_communication_delivery_destinatario;
-- DROP INDEX IF EXISTS idx_communication_delivery_comm;
-- DROP INDEX IF EXISTS idx_communication_audiencia_gin;
-- DROP INDEX IF EXISTS idx_communication_expira_em;
-- DROP INDEX IF EXISTS idx_communication_publicado_em;
-- DROP INDEX IF EXISTS idx_communication_autor;
-- DROP INDEX IF EXISTS idx_communication_curso_alvo;
-- DROP INDEX IF EXISTS idx_tcc_examiner_professor;
-- DROP INDEX IF EXISTS idx_tcc_member_aluno;
-- DROP INDEX IF EXISTS idx_tcc_data_defesa;
-- DROP INDEX IF EXISTS idx_tcc_estado;
-- DROP INDEX IF EXISTS idx_tcc_curso;
-- DROP INDEX IF EXISTS idx_internship_document_sha256;
-- DROP INDEX IF EXISTS idx_internship_document_categoria;
-- DROP INDEX IF EXISTS idx_internship_document_internship;
-- DROP INDEX IF EXISTS idx_internship_data_ini;
-- DROP INDEX IF EXISTS idx_internship_estado;
-- DROP INDEX IF EXISTS idx_internship_coe;
-- DROP INDEX IF EXISTS idx_internship_orientador;
-- DROP INDEX IF EXISTS idx_internship_aluno;
-- DROP INDEX IF EXISTS idx_formative_entry_estado;
-- DROP INDEX IF EXISTS idx_formative_entry_reviewed_by;
-- DROP INDEX IF EXISTS idx_formative_entry_activity;
-- DROP INDEX IF EXISTS idx_formative_entry_aluno;
-- DROP INDEX IF EXISTS idx_formative_activity_ativa;
-- DROP INDEX IF EXISTS idx_formative_activity_curso;
-- DROP INDEX IF EXISTS idx_request_attachment_sha256;
-- DROP INDEX IF EXISTS idx_request_attachment_status;
-- DROP INDEX IF EXISTS idx_request_attachment_uploaded_by;
-- DROP INDEX IF EXISTS idx_request_attachment_request;
-- DROP INDEX IF EXISTS idx_request_line_item_estado;
-- DROP INDEX IF EXISTS idx_request_line_item_disciplina;
-- DROP INDEX IF EXISTS idx_request_line_item_request;
-- DROP INDEX IF EXISTS idx_request_event_ator;
-- DROP INDEX IF EXISTS idx_request_event_req;
-- DROP INDEX IF EXISTS idx_request_dados_gin;
-- DROP INDEX IF EXISTS idx_request_prazo_abertas;
-- DROP INDEX IF EXISTS idx_request_curso_estado;
-- DROP INDEX IF EXISTS idx_request_estado;
-- DROP INDEX IF EXISTS idx_request_curso;
-- DROP INDEX IF EXISTS idx_request_tipo;
-- DROP INDEX IF EXISTS idx_request_solicitante;
-- DROP INDEX IF EXISTS idx_request_type_workflow_json_gin;
-- DROP INDEX IF EXISTS idx_request_type_form_schema_gin;
-- DROP INDEX IF EXISTS idx_request_type_ativo;
-- DROP INDEX IF EXISTS idx_calendario_periodo_tipo;
-- DROP INDEX IF EXISTS idx_calendario_request_type;
-- DROP INDEX IF EXISTS idx_calendario_periodo;
-- DROP INDEX IF EXISTS idx_disciplina_curso;
-- DROP INDEX IF EXISTS idx_curso_coordenador;
-- DROP INDEX IF EXISTS idx_jti_blacklist_expira_em;
-- DROP INDEX IF EXISTS idx_refresh_token_revogado_em;
-- DROP INDEX IF EXISTS idx_refresh_token_expira_em;
-- DROP INDEX IF EXISTS idx_refresh_token_usuario;
-- DROP INDEX IF EXISTS idx_usuario_role_role;
-- DROP INDEX IF EXISTS idx_role_authority_authority;
-- DROP INDEX IF EXISTS idx_role_authority_role;
-- DROP INDEX IF EXISTS idx_usuario_nome_trgm;
-- DROP INDEX IF EXISTS idx_usuario_curso;

-- =============================================================================
-- FIM DO SCHEMA
-- =============================================================================

