# Documentação do Banco de Dados — SecretariaOnline2 (TCC)

**Projeto:** SecretariaOnline2 — modernização do sistema acadêmico (UFPR SEPT)  
**Autores:** Os autores (2026)  
**Última atualização:** 2026-06-22  
**Pipeline:** Etapas 0–7 de `foundationDocs/prompts/PROMPT_gerar_documentacao_banco_dados.md`

Este diretório reúne o modelo de dados transacional do SO2 em três níveis (conceitual, lógico e físico), o DDL executável e o inventário de decisões arquiteturais.

---

## 1. Visão dos três níveis

| Nível | Artefato | O que representa | Detalhe |
|-------|----------|------------------|---------|
| **Conceitual** | `modelo-conceitual.mmd` / `.md` | Entidades e relacionamentos (Chen) | Sem atributos; decisões I1–I11 aplicadas (ex.: `ATTENDANCE_SESSION`, sem `DELIBERATION`) |
| **Lógico** | `modelo-logico.dbml` | Tabelas, colunas, tipos lógicos, FKs | 31 tabelas; merge dos módulos `_parcial/*.dbml`; sem índices parciais |
| **Físico** | `modelo-fisico.dbml` + `schema_completo.sql` | PostgreSQL 16 executável | Tipos exatos (`citext`, `timestamptz`, `jsonb`), defaults, CHECK, índices GIN/parciais, `ON DELETE CASCADE` |

**Fluxo de derivação:**

```
Fontes (§5.3, MVP v1/v2, F0, workflow-engine)
        ↓
00-inventario-e-decisoes.md  (Etapa 0 — decisões I1–I11)
        ↓
modelo-conceitual.mmd        (Etapa 1)
        ↓
_parcial/*.dbml              (Etapa 2 — por módulo)
        ↓
modelo-logico.dbml           (Etapa 3 — merge)
        ↓
modelo-fisico.dbml           (Etapa 4)
        ↓
schema_completo.sql          (Etapa 5)
```

---

## 2. Mapa arquivo → figura TCC

| Arquivo | Figura / papel no TCC | Uso recomendado no PDF |
|---------|----------------------|------------------------|
| `modelo-conceitual.md` / `.mmd` | **FIGURA 2** — Modelo conceitual | Diagrama ER de alto nível (entidades e cardinalidades) |
| `modelo-logico.dbml` | **FIGURA 3** — Modelo lógico | Diagrama com atributos e FKs (dbdiagram.io) |
| `modelo-fisico.dbml` | **FIGURA 4** — Modelo físico | Mesmo diagrama com tipos Postgres, índices e constraints documentados |
| `schema_completo.sql` | **ARTEFATO DDL** — Script transacional completo | Listagem no anexo ou apêndice técnico; prova de executabilidade |
| `V000__extensions_and_functions.sql` | Migração Flyway base | Extensões + função `uuid_generate_v7()` (modularidade futura) |
| `00-inventario-e-decisoes.md` | Tabela de decisões | Referência textual (não é figura); justifica escolhas I1–I11 |
| `foreignKey_crossModulo.md` | Apoio à validação | FKs entre bounded contexts |
| `exports/modelo-conceitual-validacao.svg` | Pré-visualização (opcional) | PNG/SVG exportado do conceitual |
| `_parcial/*.dbml` | Artefatos intermediários | Não publicar no TCC; usados na geração da FIGURA 3 |

**Resumo quantitativo:** 29 tabelas de domínio + 2 técnicas (`refresh_token`, `jti_blacklist`) = **31 tabelas** no `schema_completo.sql`.

---

## 3. Como renderizar os diagramas

### 3.1 Modelo conceitual — [mermaid.live](https://mermaid.live)

1. Abra `modelo-conceitual.md` ou `modelo-conceitual.mmd`.
2. Copie o bloco `erDiagram` (sem os cercas ` ```mermaid `).
3. Cole em [https://mermaid.live](https://mermaid.live).
4. Exporte PNG/SVG (**Actions → Export**) para inserir como **FIGURA 2** no PDF.

Alternativa: o arquivo `exports/modelo-conceitual-validacao.svg` já contém uma renderização validada.

### 3.2 Modelos lógico e físico — [dbdiagram.io](https://dbdiagram.io)

1. Acesse [https://dbdiagram.io/d](https://dbdiagram.io/d).
2. **FIGURA 3:** importe ou cole o conteúdo de `modelo-logico.dbml`.
3. **FIGURA 4:** importe ou cole o conteúdo de `modelo-fisico.dbml`.
4. Ajuste o zoom e exporte PNG (**Export → PNG**) para o PDF do TCC.

> Dica: o modelo físico é extenso (31 tabelas). Para o PDF, considere exportar por módulo (`_parcial/*.dbml`) ou usar zoom reduzido com legenda indicando “modelo completo disponível no repositório”.

### 3.3 DDL executável — PostgreSQL 16

```bash
# Banco vazio (dev/TCC)
createdb secretariaonline2
psql -d secretariaonline2 -f foundationDocs/DB/schema_completo.sql
```

O script é autocontido: extensões, função `uuid_generate_v7()`, `CREATE TABLE`, `ALTER TABLE` (dependência circular `curso ↔ usuario`) e índices.

---

## 4. Stack tecnológica

| Componente | Versão / escolha | Observação |
|------------|------------------|------------|
| **SGBD** | PostgreSQL 16 | `TIMESTAMPTZ`, `JSONB`, `CITEXT`, `pg_trgm` |
| **Migrations** | Flyway | `V000__extensions_and_functions.sql` como base; `schema_completo.sql` como artefato TCC (migrações incrementais futuras: `V001__…`) |
| **PKs** | UUIDv7 | Função `uuid_generate_v7()` em `V000`; time-sortable, sem contenção de sequence |
| **Senhas** | Argon2id | Coluna `usuario.senha_hash` (aplicação) |
| **Sessão** | `refresh_token` + JWT | Rotação com detecção de reuso |
| **Tokens one-shot** | `jti_blacklist` | Reset de senha e deep-links (sem `password_reset_token`) |
| **Workflow** | JSONB em `request_type` | `form_schema` + `workflow_json` (ADR-003 DRY) |
| **Assíncrono** | Outbox pattern | `outbox_event` (sem RabbitMQ no MVP) |

**Extensões PostgreSQL** (criadas em `V000`):

- `uuid-ossp`, `pgcrypto`, `citext`, `pg_trgm`

---

## 5. Referências aos documentos fonte

| Prioridade | Documento | Contribuição |
|:----------:|-----------|--------------|
| 1 | `foundationDocs/analysis/analise_arquitetural_secretariaonline2.md` (§5.2 ER, §5.3 DDL) | Modelo canônico TCC |
| 2 | `foundationDocs/analysis/endpoints_canonicos_presenca_eventos_v4.md` | Presença v4.1 (`attendance_session`, modos QR/SECRET) |
| 3 | `foundationDocs/analysis/mvp_v1_walking_skeleton_aluno.md` | IAM: `refresh_token`, colunas de `usuario` |
| 4 | `foundationDocs/analysis/mvp_v2_solicitacoes_workflow_engine.md` | Solicitações: `request_attachment.status` (I11) |
| 5 | `agents/workflow-engine-specialist.md` | `form_schema`, `workflow_json`, sem tabela `DELIBERATION` |
| 6 | `agents/database-engineer.md` | Convenções Postgres, índices, Flyway |
| 7 | `foundationDocs/analysis/jpaInterfaces_PostgresEntities.md` | Mapeamento repositório ↔ tabela |
| 8 | `foundationDocs/sequenceDiagrams/F0 — Público/US-F0-00*.md` | `jti_blacklist`, bloqueio de login, `password_history` |
| 9 | `foundationDocs/otherDiagrams/Diagrama de Classes - Secretaria Online 2.md` | Composições UML → `ON DELETE CASCADE` |
| 10 | `foundationDocs/prompts/PROMPT_gerar_documentacao_banco_dados.md` | Pipeline Etapas 0–7 |

Decisões consolidadas e rastreabilidade: `00-inventario-e-decisoes.md`.

---

## 6. Status da QA (Etapa 6)

**Resultado global: PASS (9/9 checks)**

| # | Item | Status |
|---|------|:------:|
| 1 | Contagem de tabelas (31 em todos os artefatos) | PASS |
| 2 | FKs do SQL presentes no DBML físico | PASS |
| 3 | Nomes presença v4.1 (`attendance_session`) | PASS |
| 4 | `refresh_token` + `jti_blacklist`; sem `password_reset_token` | PASS |
| 5 | Solicitações §5.3 + `request_attachment.status` (I11) + `request_line_item` | PASS |
| 6 | Sem `DELIBERATION` / `FORM_SCHEMA` como tabelas | PASS |
| 7 | Tipos `citext` / `timestamptz` / `jsonb` corretos | PASS |
| 8 | JPA doc ↔ SQL (29 domínio + 2 técnicas) | PASS |
| 9 | Conceitual ↔ SQL (cobertura 1:1) | PASS |

**Correções pós-QA aplicadas:**

- **Patch A:** nomes de índices GIN/parciais no `schema_completo.sql` alinhados ao `modelo-fisico.dbml` (sufixos `_gin`, `_abertas`, `_desc`).
- **Patch B:** removido índice redundante `idx_request_event_request` do DBML físico.

**Pendência opcional:** exportar PNGs de `dbdiagram.io` em `exports/` para inserção direta no PDF do TCC.

---

## 7. Estrutura do diretório

```
foundationDocs/DB/
├── README.md                          ← este arquivo (Etapa 7)
├── 00-inventario-e-decisoes.md        ← Etapa 0
├── V000__extensions_and_functions.sql ← extensões + uuid_generate_v7()
├── schema_completo.sql                ← DDL completo (Etapa 5)
├── modelo-conceitual.mmd              ← FIGURA 2 (fonte)
├── modelo-conceitual.md               ← FIGURA 2 (wrapper TCC)
├── modelo-logico.dbml                 ← FIGURA 3
├── modelo-fisico.dbml                 ← FIGURA 4
├── foreignKey_crossModulo.md          ← FKs cross-módulo
├── _parcial/                          ← DBML por módulo (Etapa 2)
│   ├── iam.dbml
│   ├── academico.dbml
│   ├── solicitacoes.dbml
│   ├── formativas.dbml
│   ├── estagio.dbml
│   ├── tcc.dbml
│   ├── comunicacao.dbml
│   ├── presenca.dbml
│   └── certificado_auditoria.dbml
└── exports/                           ← PNG/SVG opcionais para o PDF
    └── modelo-conceitual-validacao.svg
```

---

## 8. Módulos (bounded contexts)

| Módulo | Tabelas | Arquivo parcial |
|--------|:-------:|-----------------|
| M1 IAM + Sessão | 7 | `_parcial/iam.dbml` |
| M2 Acadêmico | 4 | `_parcial/academico.dbml` |
| M3 Solicitações | 5 | `_parcial/solicitacoes.dbml` |
| M4 Formativas | 2 | `_parcial/formativas.dbml` |
| M5 Estágio | 2 | `_parcial/estagio.dbml` |
| M6 TCC | 3 | `_parcial/tcc.dbml` |
| M7 Comunicação/Outbox | 4 | `_parcial/comunicacao.dbml` |
| M8 Presença v4.1 | 2 | `_parcial/presenca.dbml` |
| M9 Certificado/Auditoria | 2 | `_parcial/certificado_auditoria.dbml` |

---

*Documentação gerada conforme pipeline PROMPT_gerar_documentacao_banco_dados.md v1.1.*
