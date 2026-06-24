# Requisitos Funcionais — Fase F7 (Admin / Plataforma)

**Projeto:** SecretariaOnline2 — UFPR SEPT  
**Versão:** 1.0  
**Data:** 2026-06-23  
**Gerado a partir de:** US-F7-001 a US-F7-007; `fluxos_por_perfil.md` §8; `telas.md` §9; `legenda_siglas_casos_de_uso_por_ator.md`; `analise_arquitetural_secretariaonline2.md` §14 (ADR-003); `agents/workflow-engine-specialist.md`  
**Total RF neste arquivo:** 8 (7 HUs → 8 capacidades)

---

## Resumo da fase

| RF | Nome | HU | UC | Tela(s) | Prioridade |
|----|------|----|----|---------|:----------:|
| RF-F7-001 | Gerenciar usuários e reset de senha administrativo | US-F7-001 | UC-ADM-01 | F7.1 `/admin/usuarios` · F7.8 reset modal | P2 |
| RF-F7-002-a | Gerenciar perfis (roles) e atribuir a usuários | US-F7-002 | UC-ADM-02 | F7.2 `/admin/perfis` | P2 |
| RF-F7-002-b | Gerenciar authorities e matriz FGAC | US-F7-002 | UC-ADM-02 | F7.3 `/admin/autoridades` | P2 |
| RF-F7-003 | Configurar tipos de solicitação (workflow engine) | US-F7-003 | UC-ADM-03 | F7.4 `/admin/tipos-solicitacao` | P2 |
| RF-F7-004 | Gerenciar templates de comunicação | US-F7-004 | UC-COM-03 | F7.5 `/admin/templates-comunicacao` | P2 |
| RF-F7-005 | Monitorar Outbox e jobs agendados | US-F7-005 | UC-ADM-04 | F7.6 `/admin/jobs` | P2 |
| RF-F7-006 | Pesquisar trilha de auditoria | US-F7-006 | UC-ADM-05 | F7.7 `/admin/audit-log` | P2 |
| RF-F7-007 | Visualizar saúde do sistema (KPIs operacionais) | US-F7-007 | — | F7.9 `/admin/sistema/saude` | P3 |

> **RF-TR-001** (Etapa 11) consolida o motor genérico de solicitações; RF-F7-003 é a interface administrativa de configuração.

---

### RF-F7-001 — Gerenciar usuários e reset de senha administrativo

| Campo | Valor |
|-------|-------|
| **ID** | RF-F7-001 |
| **Nome** | Gerenciar usuários e reset de senha administrativo |
| **Prioridade** | P2 |
| **Ator(es)** | A9 Administrador |
| **Módulo** | F7 — Admin / IAM |
| **Rastreio HU** | US-F7-001 |
| **Rastreio UC** | UC-ADM-01 |
| **Tela** | F7.1 `/admin/usuarios` · F7.8 modal reset |
| **API** | `/admin/usuarios` CRUD; `POST /users/{id}/password-reset` |
| **Legado** | T03–T07 (gestão usuários legado) |

**Descrição:** O sistema deve permitir que o administrador gerencie todos os usuários (criar, editar, desativar, atribuir perfis via link) e dispare reset de senha por link JWT de uso único — sem nunca visualizar ou definir senhas em texto claro.

**Pré-condições:** `user.manage_all` (reset exige `user.reset_password`).

**Critérios de aceitação:**
1. Tabela: nome, e-mail, tipo, situação, último acesso; busca por nome/e-mail/GRR (RN-F7-001-02, RN-F7-001-03).
2. Ações via `_links`: edit, deactivate, reset-password, manage-roles (RN-F7-001-04).
3. Criar usuário: senha temporária Argon2id via Outbox; `mustChangePassword=true`; operador nunca vê senha (RN-F7-001-05).
4. Desativar: `status=INATIVO`; JTI blacklist invalida JWTs ativos (RN-F7-001-06).
5. Reset (F7.8): modal sem campo senha; link JWT 1-uso 24h → RF-F0-003; AlertBanner pós-envio (RN-F7-001-07, RN-F7-001-08).
6. `audit_log` em todas mutações (RN-F7-001-09).
7. Paginação 20/página; ordenação nome/último acesso (RN-F7-001-10).
8. Usuário INATIVO: sem `_link` deactivate (HATEOAS).

**Regras de negócio relacionadas:** RN-F7-001-01 a RN-F7-001-10

**Dependências:** RF-F0-003, RF-F7-002-a, RF-TR-004, RF-TR-005, RNF-SEC-01, RNF-SEC-06

---

### RF-F7-002-a — Gerenciar perfis (roles) e atribuir a usuários

| Campo | Valor |
|-------|-------|
| **ID** | RF-F7-002-a |
| **Nome** | Gerenciar perfis (roles) e atribuir a usuários |
| **Prioridade** | P2 |
| **Ator(es)** | A9 Administrador; A8 Coordenador (`commission.manage` parcial) |
| **Módulo** | F7 — Admin / IAM |
| **Rastreio HU** | US-F7-002 |
| **Rastreio UC** | UC-ADM-02 |
| **Tela** | F7.2 `/admin/perfis` · modal `/admin/usuarios/:id/roles` |
| **API** | `/admin/perfis` CRUD; `PUT /users/{id}/roles` |
| **Legado** | — |

**Descrição:** O sistema deve permitir CRUD de perfis (agregadores de authorities), proteger perfis pré-definidos do sistema e atribuir perfis a usuários via matriz checkbox, invalidando cache de capabilities.

**Critérios de aceitação:**
1. `iam.manage_roles` obrigatório (RN-F7-002-01).
2. Perfil: nome único snake_case, descrição, authorities vinculadas (RN-F7-002-02).
3. Perfis sistema (ALUNO, PROFESSOR, etc.) não excluíveis; badge "Sistema" (RN-F7-002-03).
4. Perfis customizados criáveis (ex.: MEMBRO_CAAF) (RN-F7-002-04).
5. Excluir customizado só sem usuários ativos → HTTP 422 (RN-F7-002-06).
6. Modal "Gerenciar roles" via `_link manage-roles` em F7.1; `PUT /users/{id}/roles` (RN-F7-002-11).
7. Alterações invalidam cache capabilities do usuário (RN-F7-002-12).
8. `audit_log` em mutações (RN-F7-002-13).
9. Coordenador com `commission.manage` usa mesma tela para membros CAAF/COE (F6.3 delegado).

**Regras de negócio relacionadas:** RN-F7-002-01 a RN-F7-002-06, RN-F7-002-11 a RN-F7-002-13

**Dependências:** RF-F7-001, RF-F7-002-b, RF-TR-005, RF-TR-004

---

### RF-F7-002-b — Gerenciar authorities e matriz FGAC

| Campo | Valor |
|-------|-------|
| **ID** | RF-F7-002-b |
| **Nome** | Gerenciar authorities e matriz FGAC |
| **Prioridade** | P2 |
| **Ator(es)** | A9 Administrador |
| **Módulo** | F7 — Admin / IAM |
| **Rastreio HU** | US-F7-002 |
| **Rastreio UC** | UC-ADM-02 |
| **Tela** | F7.3 `/admin/autoridades` |
| **API** | `/admin/autoridades` CRUD; `PATCH /admin/perfis/{roleId}/authorities` |
| **Legado** | — |

**Descrição:** O sistema deve permitir visualizar e configurar capabilities granulares (authorities) e a matriz role×authority para controle de acesso fino (FGAC) sem alteração de código.

**Critérios de aceitação:**
1. `iam.manage_authorities` obrigatório (RN-F7-002-07).
2. Authority: nome dot-notation único, descrição, módulo enum (RN-F7-002-08).
3. `DS/RoleAuthorityMatrix`: grade checkbox role×authority; atribuição em massa (RN-F7-002-09).
4. Authorities de código: nome somente leitura; descrição editável (RN-F7-002-10).
5. `PATCH .../authorities` com add/remove; invalida cache de usuários afetados (RN-F7-002-12).
6. `audit_log` em mutações (RN-F7-002-13).

**Regras de negócio relacionadas:** RN-F7-002-07 a RN-F7-002-10, RN-F7-002-12, RN-F7-002-13

**Dependências:** RF-F7-002-a, RF-TR-005, RF-TR-004

---

### RF-F7-003 — Configurar tipos de solicitação (workflow engine)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F7-003 |
| **Nome** | Configurar tipos de solicitação (workflow engine) |
| **Prioridade** | P2 |
| **Ator(es)** | A9 Administrador |
| **Módulo** | F7 — Admin / workflow |
| **Rastreio HU** | US-F7-003 |
| **Rastreio UC** | UC-ADM-03 |
| **Tela** | F7.4 `/admin/tipos-solicitacao` |
| **API** | `/request-types` CRUD; `POST /request-types/{id}/publish` |
| **Legado** | — (substitui 19× implementações legadas) |

**Descrição:** O sistema deve oferecer editor de 3 painéis para definir `form_schema` (JSON Schema) e `workflow_json` (state machine) de cada tipo de solicitação, com preview ao vivo, versionamento atômico e publicação controlada — núcleo ADR-003 DRY.

**Critérios de aceitação:**
1. `request_type.manage` obrigatório; largura mínima 1440px (RN-F7-003-01).
2. Painéis: lista tipos · editores JSON · preview + grafo workflow (RN-F7-003-02).
3. `form_schema` draft-07 válido; inválido bloqueia publicação com borda danger (RN-F7-003-03, RN-F7-003-05).
4. `workflow_json`: estados, transições, capabilities, guards, notificações (RN-F7-003-04).
5. Preview ao vivo sem salvar; grafo sincronizado com JSON (RN-F7-003-05, RN-F7-003-06).
6. Publicar: versão imutável; abertas mantêm versão original (RN-F7-003-07, RN-F7-003-08).
7. DRAFT oculto do wizard; PUBLISHED visível em RF-F1-005-b, RF-F5-002-b (RN-F7-003-08).
8. Excluir só DRAFT sem histórico (RN-F7-003-09).
9. `audit_log` com payload completo schema/workflow (RN-F7-003-10).

**Regras de negócio relacionadas:** RN-F7-003-01 a RN-F7-003-11

**Dependências:** RF-TR-001, RF-F1-005-b, RF-F5-002-b, RF-F3-003-b, RF-TR-004

---

### RF-F7-004 — Gerenciar templates de comunicação

| Campo | Valor |
|-------|-------|
| **ID** | RF-F7-004 |
| **Nome** | Gerenciar templates de comunicação |
| **Prioridade** | P2 |
| **Ator(es)** | A9 Administrador |
| **Módulo** | F7 — Admin / comunicação |
| **Rastreio HU** | US-F7-004 |
| **Rastreio UC** | UC-COM-03 |
| **Tela** | F7.5 `/admin/templates-comunicacao` |
| **API** | `/communication-templates` CRUD; `GET /communication-templates/{id}/versions` |
| **Legado** | — |

**Descrição:** O sistema deve permitir CRUD de templates de e-mail/push em Markdown com placeholders dinâmicos, preview com variáveis de exemplo e versionamento imutável por revisão.

**Critérios de aceitação:**
1. `communication.manage_templates` obrigatório (RN-F7-004-01).
2. Campos: nome único, assunto, corpo Markdown, variáveis, canal EMAIL/PUSH/AMBOS (RN-F7-004-02).
3. Editor 2 colunas: MarkdownEditor + TemplatePreview | histórico versões (RN-F7-004-03).
4. Autocomplete placeholders ao digitar `{{` (RN-F7-004-04).
5. Preview substitui variáveis por exemplos em tempo real (RN-F7-004-05).
6. Salvar cria revisão imutável; CURRENT/ARCHIVED (RN-F7-004-06, RN-F7-004-07).
7. Placeholder inválido destacado danger no preview (RN-F7-004-08).
8. Referenciados em `workflow_json` por nome (RN-F7-004-09).
9. `audit_log` em criação/edição (RN-F7-004-10).

**Regras de negócio relacionadas:** RN-F7-004-01 a RN-F7-004-10

**Dependências:** RF-F7-003, RF-TR-002, RF-TR-007, RF-TR-004

---

### RF-F7-005 — Monitorar Outbox e jobs agendados

| Campo | Valor |
|-------|-------|
| **ID** | RF-F7-005 |
| **Nome** | Monitorar Outbox e jobs agendados |
| **Prioridade** | P2 |
| **Ator(es)** | A9 Administrador |
| **Módulo** | F7 — Admin / observabilidade |
| **Rastreio HU** | US-F7-005 |
| **Rastreio UC** | UC-ADM-04 |
| **Tela** | F7.6 `/admin/jobs` |
| **API** | `GET /admin/outbox`; `POST /admin/outbox/{id}/retry`; `GET /admin/scheduled-jobs` |
| **Legado** | — |

**Descrição:** O sistema deve exibir eventos Outbox (PENDING/SENT/FAILED/DEAD) e jobs agendados, permitindo reentrega manual de eventos falhos e alertando latência do dispatcher.

**Critérios de aceitação:**
1. `system.observe` obrigatório (RN-F7-005-01).
2. Tabela Outbox: ID, aggregate type, payload resumo, status, tentativas, timestamps (RN-F7-005-02).
3. Filtros status, aggregate type, datas; aba FAILED padrão (RN-F7-005-03).
4. FAILED (danger) vs DEAD (cinza, 5 tentativas) (RN-F7-005-04, RN-F7-005-05).
5. Reentregar via `_links.retry` → PENDING (RN-F7-005-06).
6. Alerta se latência PENDING→SENT > 30s (RN-F7-005-07).
7. ScheduledJobCards: OutboxDispatcher, SlaBreachChecker, ExportJobCleaner, EventAutoCloser (RN-F7-005-08, RN-F7-005-09).
8. Paginação 20; SENT retidos 7 dias (RN-F7-005-10).

**Regras de negócio relacionadas:** RN-F7-005-01 a RN-F7-005-10

**Dependências:** RF-TR-002, RF-TR-004, RNF-CON-01, RNF-DES-01

---

### RF-F7-006 — Pesquisar trilha de auditoria

| Campo | Valor |
|-------|-------|
| **ID** | RF-F7-006 |
| **Nome** | Pesquisar trilha de auditoria |
| **Prioridade** | P2 |
| **Ator(es)** | A9 Administrador |
| **Módulo** | F7 — Admin / auditoria |
| **Rastreio HU** | US-F7-006 |
| **Rastreio UC** | UC-ADM-05 |
| **Tela** | F7.7 `/admin/audit-log` |
| **API** | `GET /audit-log` |
| **Legado** | — |

**Descrição:** O sistema deve permitir pesquisa imutável na trilha de auditoria com filtros por ator, ação, entidade e período, exibindo diff JSON antes/depois em drawer lateral.

**Critérios de aceitação:**
1. `audit.read` obrigatório; log imutável — sem DELETE/PATCH na API (RN-F7-006-01, RN-F7-006-02).
2. Colunas: ator, ação, entidade alvo, timestamp, IP (RN-F7-006-03).
3. Filtros combinados AND; padrão último ano; retenção 5 anos (RN-F7-006-04, RN-F7-006-09).
4. Clique na linha → Drawer 420px com AuditDiffViewer side-by-side (RN-F7-006-05, RN-F7-006-07).
5. Diff: verde adicionado, vermelho removido, amarelo alterado (RN-F7-006-06).
6. Tabela somente leitura; sem botões de ação no header (RN-F7-006-08).
7. Paginação 50; ordenação timestamp DESC (RN-F7-006-10).

**Regras de negócio relacionadas:** RN-F7-006-01 a RN-F7-006-10

**Dependências:** RF-TR-004, RNF-LGL-01, RNF-UX-02

---

### RF-F7-007 — Visualizar saúde do sistema (KPIs operacionais)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F7-007 |
| **Nome** | Visualizar saúde do sistema (KPIs operacionais) |
| **Prioridade** | P3 |
| **Ator(es)** | A9 Administrador |
| **Módulo** | F7 — Admin / ops |
| **Rastreio HU** | US-F7-007 |
| **Rastreio UC** | — (extra-MVP; sem UC formal — Actuator/Grafana) |
| **Tela** | F7.9 `/admin/sistema/saude` |
| **API** | `/actuator/health`; `/actuator/metrics/*` |
| **Legado** | — |

**Descrição:** O sistema deve exibir KPIs operacionais (latência P95, Outbox pending, erros 5xx, uptime) via Spring Boot Actuator com polling e link para Grafana — **fora do MVP** (P3).

**Critérios de aceitação:**
1. `system.admin` obrigatório; `system.observe` insuficiente → 403 (RN-F7-007-01).
2. KpiRow: API P95 (<300ms), Outbox pending (≤10), 5xx/1h (=0 alvo), uptime (RN-F7-007-03, RN-F7-007-04).
3. Polling 30s; `aria-live="polite"` (RN-F7-007-05).
4. Valores fora do alvo em cores semânticas danger/warning (RN-F7-007-06).
5. Link "Abrir Grafana" via `GRAFANA_URL` em nova aba (RN-F7-007-07).
6. Resumo rápido — análise detalhada no Grafana (RN-F7-007-08).

**Regras de negócio relacionadas:** RN-F7-007-01 a RN-F7-007-08

**Dependências:** RF-F7-005, RNF-DES-01, RNF-DIS-01, RNF-UX-02

---

## Fora de escopo (fase F7)

- Exclusão permanente de usuários ou registros de auditoria
- Hierarquia/herança de perfis IAM
- Sandbox de simulação de workflow
- Importação de schema via arquivo
- Alertas automáticos por e-mail ao ultrapassar thresholds de saúde
