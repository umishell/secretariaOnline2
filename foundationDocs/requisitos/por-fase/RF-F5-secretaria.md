# Requisitos Funcionais — Fase F5 (Secretaria)

**Projeto:** SecretariaOnline2 — UFPR SEPT  
**Versão:** 1.0  
**Data:** 2026-06-23  
**Gerado a partir de:** US-F5-001 a US-F5-012; `fluxos_por_perfil.md` §6; `telas.md` §7; `legenda_siglas_casos_de_uso_por_ator.md`; `endpoints_canonicos_presenca_eventos_v4.md`  
**Total RF neste arquivo:** 18 (12 HUs → 18 capacidades)

---

## Resumo da fase

| RF | Nome | HU | UC | Tela(s) | Prioridade |
|----|------|----|----|---------|:----------:|
| RF-F5-001 | Visualizar dashboard operacional da secretaria | US-F5-001 | UC-DASH-01 | F5.1 `/inicio` | P2 |
| RF-F5-002-a | Triar fila de solicitações e monitorar atrasados | US-F5-002 | UC-SOL-06 | F5.2 `/solicitacoes` · F5.5 `/secretaria/atrasados` | P2 |
| RF-F5-002-b | Abrir solicitação interna em nome do aluno | US-F5-002 | UC-SOL-02 | F5.3 `/solicitacoes/nova` | P2 |
| RF-F5-002-c | Deliberar solicitação (secretaria, sem deep-link) | US-F5-002 | UC-SOL-04 | F5.4 `/solicitacoes/:id/deliberar` | P2 |
| RF-F5-003 | Gerenciar cadastro de alunos | US-F5-003 | UC-CAD-01 | F5.6 `/secretaria/alunos` | P2 |
| RF-F5-004-a | Manter cadastro de cursos | US-F5-004 | UC-CAD-02 | F5.7 `/secretaria/cursos` | P2 |
| RF-F5-004-b | Manter cadastro de disciplinas | US-F5-004 | UC-CAD-03 | F5.8 `/secretaria/disciplinas` | P2 |
| RF-F5-004-c | Manter períodos e calendário acadêmico | US-F5-004 | UC-CAD-04 | F5.9 `/secretaria/calendarios` | P2 |
| RF-F5-005-a | Listar e exportar egressos | US-F5-005 | UC-EGR-03 | F5.10 `/secretaria/egressos` | P2 |
| RF-F5-005-b | Registrar colação de grau e entrega de diploma | US-F5-005 | UC-EGR-02 | F5.11 `/secretaria/diplomas` | P2 |
| RF-F5-006 | Revisar autorizações de imagem em lote | US-F5-006 | UC-SOL-07 | F5.12 `/secretaria/autorizacoes-imagem` | P2 |
| RF-F5-007 | Registrar atendimento presencial | US-F5-007 | UC-ATD-01 | F5.13 `/secretaria/atendimentos` | P2 |
| RF-F5-008-a | Gerenciar eventos institucionais (CRUD) | US-F5-008 | UC-PRE-01 | F5.14 `/secretaria/eventos` | P2 |
| RF-F5-008-b | Operar validação de presença (secretaria) | US-F5-008 | UC-PRE-02, UC-PRE-04 | F5.15 `/secretaria/eventos/:id/operacao` | P2 |
| RF-F5-009 | Importar dados em lote via planilha | US-F5-009 | UC-ADM-06 | F5.16 `/secretaria/importacoes` | P2 |
| RF-F5-010 | Solicitar exportações assíncronas | US-F5-010 | UC-ADM-07 | F5.17 `/secretaria/exportacoes` | P2 |
| RF-F5-011 | Visualizar estatísticas operacionais | US-F5-011 | UC-ADM-08 | F5.18 `/secretaria/estatisticas` | P2 |
| RF-F5-012 | Gerenciar tarefas internas (kanban) | US-F5-012 | UC-ADM-12 | F5.19 `/secretaria/tarefas` | P3 |

---

### RF-F5-001 — Visualizar dashboard operacional da secretaria

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-001 |
| **Nome** | Visualizar dashboard operacional da secretaria |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria |
| **Módulo** | F5 — Secretaria |
| **Rastreio HU** | US-F5-001 |
| **Rastreio UC** | UC-DASH-01 |
| **Tela** | F5.1 `/inicio` |
| **API** | `GET /bff/dashboard/secretary` |
| **Legado** | T08 (visão SEC) |

**Descrição:** O sistema deve apresentar à secretária um painel com KPIs operacionais, fila priorizada de solicitações, alertas SLA e agenda de eventos do dia, agregados pelo BFF e filtrados pelos cursos vinculados ao usuário.

**Pré-condições:** Secretária autenticada com `dashboard.view_secretary`.

**Pós-condições:** Dashboard renderizado com dados ou estados empty/skeleton; QuickTiles conforme `_links`.

**Critérios de aceitação:**
1. BFF retorna KPIs (abertas, atrasadas, concluídas hoje, eventos hoje), fila priorizada (≤10), alertas SLA e agenda (RN-F5-001-02).
2. Escopo restrito aos cursos vinculados à secretária (RN-F5-001-05).
3. Fila ordenada por `prazo_em ASC`, depois `criado_em ASC`; breach em `status/danger`, <24h em `status/warning` (RN-F5-001-03, RN-F5-001-04).
4. Banner SLA quando itens em breach; empty state quando sem solicitações abertas (RN-F5-001-06).
5. QuickTiles renderizados somente via `_links` (RN-F5-001-07, RF-TR-005).
6. Cache TanStack Query 60s; refresh manual invalida cache (RN-F5-001-08).
7. Skeleton durante carregamento; WCAG 2.1 AA nos KPIs.

**Regras de negócio relacionadas:** RN-F5-001-01 a RN-F5-001-08

**Dependências:** RF-TR-006, RF-TR-005, RNF-DES-04, RNF-UX-04

---

### RF-F5-002-a — Triar fila de solicitações e monitorar atrasados

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-002-a |
| **Nome** | Triar fila de solicitações e monitorar atrasados |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria |
| **Módulo** | F5 — Secretaria / solicitações |
| **Rastreio HU** | US-F5-002 |
| **Rastreio UC** | UC-SOL-06 |
| **Tela** | F5.2 `/solicitacoes` · F5.5 `/secretaria/atrasados` |
| **API** | `GET /requests`; `PATCH /requests/bulk`; `GET /requests?slaBreached=true&format=csv` |
| **Legado** | T12–T15 |

**Descrição:** O sistema deve permitir que a secretária consulte, filtre e priorize a fila central de solicitações dos cursos de sua competência, aplique ações em massa de atribuição/encaminhamento e monitore solicitações com SLA vencido com exportação CSV.

**Pré-condições:** `request.view_curso` concedida.

**Critérios de aceitação:**
1. Fila exibe solicitações dos cursos vinculados; filtro padrão `estado=ABERTA`, ordenação `prazo_em ASC` (RN-F5-002-01, RN-F5-002-02).
2. Colunas: Número, Aluno, Tipo, Estado, Deliberador, SLA com cores semânticas (RN-F5-002-03).
3. Ações por linha e bulk via `_links` (`deliberate`, `assign`, `bulk_assign`) (RN-F5-002-04, RN-F5-002-08).
4. `/secretaria/atrasados`: filtro fixo `slaBreached=true`; exportar CSV síncrono com colunas documentadas (RN-F5-002-09, RN-F5-002-10).
5. Filtros persistem em `localStorage` na sessão; empty state quando fila vazia.
6. Bulk assign: `PATCH /requests/bulk` atualiza deliberador das linhas selecionadas.

**Regras de negócio relacionadas:** RN-F5-002-01 a RN-F5-002-04, RN-F5-002-08 a RN-F5-002-10

**Dependências:** RF-F5-002-c, RF-TR-001, RF-TR-005, RNF-UX-04

---

### RF-F5-002-b — Abrir solicitação interna em nome do aluno

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-002-b |
| **Nome** | Abrir solicitação interna em nome do aluno |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria |
| **Módulo** | F5 — Secretaria / solicitações |
| **Rastreio HU** | US-F5-002 |
| **Rastreio UC** | UC-SOL-02 |
| **Tela** | F5.3 `/solicitacoes/nova` |
| **API** | `POST /requests` com `onBehalfOf` |
| **Legado** | — |

**Descrição:** O sistema deve permitir que a secretária abra solicitações via wizard dinâmico em nome de alunos dos cursos de sua competência, reutilizando o fluxo do aluno com campo adicional de titular.

**Pré-condições:** `request.internal_open`; aluno pertencente a curso da competência da secretária.

**Critérios de aceitação:**
1. Wizard reutiliza F1.8 + `Combobox` busca aluno por GRR/nome (RN-F5-002-05).
2. `POST /requests` inclui `onBehalfOf` com ID do aluno; solicitação aparece na fila com aluno titular (RN-F5-002-05).
3. Aluno de curso fora da competência: HTTP 403 (RN-F5-002-06).
4. Motor de workflow genérico (RF-TR-001) aplica `form_schema` e transições.

**Regras de negócio relacionadas:** RN-F5-002-05, RN-F5-002-06

**Dependências:** RF-F1-005-b, RF-TR-001, RF-TR-005

---

### RF-F5-002-c — Deliberar solicitação (secretaria, sem deep-link)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-002-c |
| **Nome** | Deliberar solicitação (secretaria, sem deep-link) |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria |
| **Módulo** | F5 — Secretaria / solicitações |
| **Rastreio HU** | US-F5-002 |
| **Rastreio UC** | UC-SOL-04 |
| **Tela** | F5.4 `/solicitacoes/:id/deliberar` |
| **API** | `GET /requests/{id}`; `POST /requests/{id}/transitions` |
| **Legado** | T12–T15 |

**Descrição:** O sistema deve permitir que a secretária delimere solicitações pela fila (sem deep-link JWT), reutilizando a tela de deliberação do professor com parecer fundamentado e registro em auditoria.

**Pré-condições:** `request.deliberate` (alguns tipos exigem `senior_secretary` adicional).

**Critérios de aceitação:**
1. Tela reutiliza frame F3.4/F5.4 sem duplicação de design (RN-F5-002-07).
2. Acesso direto pela fila — sem fluxo de deep-link JWT (distinção vs RF-F3-003-b).
3. Ações exclusivamente de `_links`; transições validam workflow e authority (RF-TR-001).
4. Parecer obrigatório; indeferir mín. 20 caracteres; `audit_log` + `request_event` imutáveis.
5. Notificação ao aluno via Outbox após deliberação.

**Regras de negócio relacionadas:** RN-F5-002-07

**Dependências:** RF-F3-003-b, RF-F5-002-a, RF-TR-001, RF-TR-004, RF-TR-005

---

### RF-F5-003 — Gerenciar cadastro de alunos

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-003 |
| **Nome** | Gerenciar cadastro de alunos |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria |
| **Módulo** | F5 — Secretaria / cadastros |
| **Rastreio HU** | US-F5-003 |
| **Rastreio UC** | UC-CAD-01 |
| **Tela** | F5.6 `/secretaria/alunos` |
| **API** | `GET/POST/PATCH /students`; `POST /students/{id}/reset-password`; `POST /students/{id}/matricula` |
| **Legado** | T03–T07 |

**Descrição:** O sistema deve permitir busca, cadastro, edição, reset de senha e matrícula em disciplinas de alunos, com escopo por curso e auditoria de mutações.

**Pré-condições:** `user.manage_students`.

**Critérios de aceitação:**
1. Busca por GRR (exato), nome (trigrama) ou e-mail (prefix); combinação OR (RN-F5-003-02).
2. CRUD via `DS/Drawer`: nome, GRR, CPF, e-mail, curso, período, situação (RN-F5-003-03).
3. CPF/GRR únicos → HTTP 409 com erro inline (RN-F5-003-04).
4. Reset senha: temporária Argon2id, `mustChangePassword=true`, e-mail via Outbox, `audit_log` (RN-F5-003-05).
5. Matrícula: valida vagas; HTTP 422 se indisponível (RN-F5-003-06).
6. Todas mutações em `audit_log` (RN-F5-003-07).
7. Alunos de outros cursos: visíveis na busca sem `_links` de edição (RN-F5-003-08, HATEOAS).
8. Novo aluno: e-mail boas-vindas com senha temporária via Outbox.

**Regras de negócio relacionadas:** RN-F5-003-01 a RN-F5-003-09

**Dependências:** RF-TR-005, RF-TR-004, RNF-SEC-01, RNF-CON-01

---

### RF-F5-004-a — Manter cadastro de cursos

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-004-a |
| **Nome** | Manter cadastro de cursos |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria; A8 Coordenador |
| **Módulo** | F5 — Secretaria / acadêmico |
| **Rastreio HU** | US-F5-004 |
| **Rastreio UC** | UC-CAD-02 |
| **Tela** | F5.7 `/secretaria/cursos` |
| **API** | `/secretaria/cursos` CRUD |
| **Legado** | T20–T25 |

**Descrição:** O sistema deve permitir CRUD de cursos com vínculo de coordenador, secretários e parâmetros de horas formativas, controlando escopo de `request.view_curso`.

**Critérios de aceitação:**
1. Campos obrigatórios: nome, sigla (única), coordenador, horas formativas mínimas, duração (RN-F5-004-02).
2. Multi-select secretários define escopo de capabilities (RN-F5-004-03).
3. Desativar curso preserva histórico (RN-F5-004-04).
4. Sigla duplicada → HTTP 409.

**Regras de negócio relacionadas:** RN-F5-004-01 a RN-F5-004-04

**Dependências:** RF-TR-005, RF-TR-004

---

### RF-F5-004-b — Manter cadastro de disciplinas

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-004-b |
| **Nome** | Manter cadastro de disciplinas |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria |
| **Módulo** | F5 — Secretaria / acadêmico |
| **Rastreio HU** | US-F5-004 |
| **Rastreio UC** | UC-CAD-03 |
| **Tela** | F5.8 `/secretaria/disciplinas` |
| **API** | `/secretaria/disciplinas` CRUD |
| **Legado** | T26–T30 |

**Descrição:** O sistema deve permitir CRUD de disciplinas vinculadas a cursos, com código único por curso, carga horária e flag ativa/inativa.

**Critérios de aceitação:**
1. Campos: nome, código (único/curso), curso, período sugerido, CH, ativa (RN-F5-004-06).
2. Inativar disciplina não desmatricula alunos automaticamente (RN-F5-004-07).
3. Exportação CSV via barra de ações (RN-F5-004-08).
4. `subject.manage` obrigatório (RN-F5-004-05).

**Regras de negócio relacionadas:** RN-F5-004-05 a RN-F5-004-08

**Dependências:** RF-F5-004-a, RF-TR-005

---

### RF-F5-004-c — Manter períodos e calendário acadêmico

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-004-c |
| **Nome** | Manter períodos e calendário acadêmico |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria; A8 Coordenador |
| **Módulo** | F5 — Secretaria / acadêmico |
| **Rastreio HU** | US-F5-004 |
| **Rastreio UC** | UC-CAD-04 |
| **Tela** | F5.9 `/secretaria/calendarios` |
| **API** | `/calendars` CRUD; `POST /calendars/periods` |
| **Legado** | T31–T35 |

**Descrição:** O sistema deve permitir gestão de períodos letivos e eventos de calendário com tipos semânticos, impedindo sobreposição de períodos e alertando ausência de período vigente.

**Critérios de aceitação:**
1. Abas Períodos letivos e Eventos (RN-F5-004-10).
2. Tipos de evento com cores: FERIADO, COLACAO, PRAZO, INSTITUCIONAL (RN-F5-004-11).
3. Períodos sobrepostos no mesmo curso → HTTP 422 (RN-F5-004-12).
4. SLAs e janelas referenciam período vigente; alerta no dashboard se ausente (RN-F5-004-13).
5. `calendar.manage` obrigatório (RN-F5-004-09).

**Regras de negócio relacionadas:** RN-F5-004-09 a RN-F5-004-13

**Dependências:** RF-F5-001, RF-TR-004

---

### RF-F5-005-a — Listar e exportar egressos

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-005-a |
| **Nome** | Listar e exportar egressos |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria |
| **Módulo** | F5 — Secretaria / egressos |
| **Rastreio HU** | US-F5-005 |
| **Rastreio UC** | UC-EGR-03 |
| **Tela** | F5.10 `/secretaria/egressos` |
| **API** | `GET /secretaria/egressos` |
| **Legado** | T124 |

**Descrição:** O sistema deve listar egressos com filtros e exportação CSV, exibindo situação do diploma e permitindo criação manual excepcional.

**Critérios de aceitação:**
1. Colunas: nome, curso, ano colação, situação diploma (PENDENTE/ENTREGUE/RETIRADO) (RN-F5-005-02).
2. Filtros: curso, ano, situação (RN-F5-005-03).
3. Exportação CSV via `export.run` (RN-F5-005-05).
4. `alumni.list` obrigatório (RN-F5-005-01).

**Regras de negócio relacionadas:** RN-F5-005-01 a RN-F5-005-05

**Dependências:** RF-F5-010, RF-F2-001

---

### RF-F5-005-b — Registrar colação de grau e entrega de diploma

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-005-b |
| **Nome** | Registrar colação de grau e entrega de diploma |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria |
| **Módulo** | F5 — Secretaria / egressos |
| **Rastreio HU** | US-F5-005 |
| **Rastreio UC** | UC-EGR-02 |
| **Tela** | F5.11 `/secretaria/diplomas` |
| **API** | `GET /students?eligibleForGraduation=true`; `POST /graduations`; `PATCH /graduations/{id}/confirm-delivery` |
| **Legado** | T125–T127 |

**Descrição:** O sistema deve permitir wizard de colação em lote com validação de elegibilidade, transição ALUNO → EGRESSO, registro de entrega física do diploma e notificação ao egresso.

**Pré-condições:** `diploma.register`; alunos elegíveis conforme critérios acadêmicos.

**Pós-condições:** `graduation_record` criado; `role=EGRESSO`; Outbox `egressos.graduated`; RF-F2-001 habilitado.

**Critérios de aceitação:**
1. Elegibilidade: TCC aprovado, currículo completo, horas formativas ≥ mínimo, sem bloqueios (RN-F5-005-07).
2. Wizard 2 passos: selecionar elegíveis → confirmar data/livro/folha/ata (RN-F5-005-08).
3. Inelegíveis: checkbox desabilitado + tooltip com razão (RN-F5-005-12).
4. `POST /graduations`: TX atômica — `graduation_record`, `role=EGRESSO`, `audit_log` (RN-F5-005-09).
5. Outbox e-mail boas-vindas portal egresso (RN-F5-005-10).
6. `PATCH .../confirm-delivery`: método e data; situação ENTREGUE (RN-F5-005-11).
7. Revoga capabilities de aluno; concede `alumni.view_own` (RF-F2-001, RN-F2.1-01).

**Regras de negócio relacionadas:** RN-F5-005-06 a RN-F5-005-12

**Dependências:** RF-F2-001, RF-TR-002, RF-TR-004, RNF-CON-01

---

### RF-F5-006 — Revisar autorizações de imagem em lote

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-006 |
| **Nome** | Revisar autorizações de imagem em lote |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria |
| **Módulo** | F5 — Secretaria / solicitações |
| **Rastreio HU** | US-F5-006 |
| **Rastreio UC** | UC-SOL-07 |
| **Tela** | F5.12 `/secretaria/autorizacoes-imagem` |
| **API** | `GET /requests?type=AUTORIZACAO_IMAGEM`; `PATCH /requests/bulk-deliberate` |
| **Legado** | — |

**Descrição:** O sistema deve exibir fila compacta de solicitações AUTORIZACAO_IMAGEM com thumbnails e permitir aprovação/rejeição em lote transacional.

**Critérios de aceitação:**
1. Filtro exclusivo `type=AUTORIZACAO_IMAGEM` (RN-F5-006-02).
2. Thumbnail 48px via URL pré-assinada MinIO (15 min); placeholder se expirado (RN-F5-006-03, RN-F5-006-04).
3. Bulk approve/reject via `_links.bulk_deliberate`; TX atômica — falha parcial reverte tudo (RN-F5-006-05, RN-F5-006-06).
4. Outbox `autorizacoes.deliberated` por aluno (RN-F5-006-07).
5. Itens não-ABERTA: somente leitura, sem checkbox (RN-F5-006-08).
6. Rejeitar com justificativa opcional repassada ao aluno.

**Regras de negócio relacionadas:** RN-F5-006-01 a RN-F5-006-08

**Dependências:** RF-F5-002-a, RF-TR-002, RNF-CON-01

---

### RF-F5-007 — Registrar atendimento presencial

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-007 |
| **Nome** | Registrar atendimento presencial |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria |
| **Módulo** | F5 — Secretaria / atendimento |
| **Rastreio HU** | US-F5-007 |
| **Rastreio UC** | UC-ATD-01 |
| **Tela** | F5.13 `/secretaria/atendimentos` |
| **API** | `POST /service-records`; `GET /service-records` |
| **Legado** | T134/T135 |

**Descrição:** O sistema deve permitir registro imutável de atendimentos presenciais com busca de aluno, categoria, resposta, anexo opcional e preview de notificação ao aluno.

**Critérios de aceitação:**
1. Campos obrigatórios: aluno (Combobox GRR/nome), assunto (categoria + livre), resposta (RN-F5-007-02).
2. Categorias via `GET /service-record-categories` (RN-F5-007-03).
3. Anexo opcional PDF/JPEG/PNG ≤10 MB → MinIO (RN-F5-007-04).
4. Preview de notificação em tempo real antes de confirmar (RN-F5-007-05).
5. Outbox `atendimento.registrado` → e-mail ao aluno (RN-F5-007-06).
6. Aluno consulta em RF-F1-011; registro imutável após criação (RN-F5-007-07, RN-F5-007-08).
7. `service_record.create` obrigatório (RN-F5-007-01).

**Regras de negócio relacionadas:** RN-F5-007-01 a RN-F5-007-08

**Dependências:** RF-F1-011, RF-TR-002, RF-TR-004, RNF-CON-01

---

### RF-F5-008-a — Gerenciar eventos institucionais (CRUD)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-008-a |
| **Nome** | Gerenciar eventos institucionais (CRUD) |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria |
| **Módulo** | F5 — Secretaria / presença |
| **Rastreio HU** | US-F5-008 |
| **Rastreio UC** | UC-PRE-01 |
| **Tela** | F5.14 `/secretaria/eventos` |
| **API** | `GET/POST/PATCH/DELETE /events` |
| **Legado** | — |

**Descrição:** O sistema deve permitir CRUD de eventos formativos institucionais no escopo dos cursos vinculados à secretária, reutilizando componentes de RF-F3-002-a.

**Critérios de aceitação:**
1. Lista com filtros curso, estado, `onlyMine`; colunas título, período, modo, estado, organizador (RN-F5-008-02, RN-F5-008-03).
2. Reutiliza formulário F3.2a; escopo multi-curso da secretaria (RN-F5-008-04).
3. `CONCLUIDO`: somente leitura; sem `_links` editar/excluir (RN-F5-008-05).
4. Excluir só em `AGENDADO` sem presenças → HTTP 422 se violado (RN-F5-008-06).
5. **Fora de escopo:** geofence, trust score, aula regular.

**Regras de negócio relacionadas:** RN-F5-008-01 a RN-F5-008-06

**Dependências:** RF-F3-002-a, RF-TR-008, RF-TR-005

---

### RF-F5-008-b — Operar validação de presença (secretaria)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-008-b |
| **Nome** | Operar validação de presença (secretaria) |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria |
| **Módulo** | F5 — Secretaria / presença |
| **Rastreio HU** | US-F5-008 |
| **Rastreio UC** | UC-PRE-02, UC-PRE-04 |
| **Tela** | F5.15 `/secretaria/eventos/:id/operacao` |
| **API** | Endpoints presença v4.1; `POST /events/{id}/close` |
| **Legado** | — |

**Descrição:** O sistema deve permitir operação ao vivo de eventos pela secretária, paridade funcional com RF-F3-002-b, incluindo encerramento com emissão automática de certificados anti-fraude.

**Critérios de aceitação:**
1. `event.host` obrigatório; painel idêntico a F3.2c (RN-F5-008-07, RN-F5-008-08).
2. Modos v4.1: QR_SINGLE, QR_DUAL, SECRET_SINGLE, SECRET_DUAL (RN-F5-008-09).
3. Encerrar: presenças contabilizadas, `formative_entry` + certificado SHA-256 + ED25519 (RN-F5-008-10, RN-F5-008-11, RF-TR-003).
4. Scheduler encerra eventos não fechados às 23:59 (RN-F5-008-12).
5. Polling contadores; QR renovação ~5 min.

**Regras de negócio relacionadas:** RN-F5-008-07 a RN-F5-008-12

**Dependências:** RF-F3-002-b, RF-F5-008-a, RF-TR-003, RF-TR-008

---

### RF-F5-009 — Importar dados em lote via planilha

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-009 |
| **Nome** | Importar dados em lote via planilha |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria; A9 Administrador |
| **Módulo** | F5 — Secretaria / importações |
| **Rastreio HU** | US-F5-009 |
| **Rastreio UC** | UC-ADM-06 |
| **Tela** | F5.16 `/secretaria/importacoes` |
| **API** | `GET /imports/templates/{kind}`; `POST /imports/{kind}`; `GET /imports/{jobId}`; `POST /imports/{jobId}/confirm` |
| **Legado** | — |

**Descrição:** O sistema deve oferecer wizard de importação CSV/XLSX com preview linha a linha, validação assíncrona e confirmação transacional por lotes.

**Critérios de aceitação:**
1. Kinds: `alunos`, `disciplinas`, `usuarios`, `alocacao_professor` (RN-F5-009-02).
2. Wizard 4 passos: kind+modelo → upload → preview → confirmar (RN-F5-009-03).
3. CSV UTF-8 ou XLSX; máx. 20 MB; máx. 10.000 linhas (RN-F5-009-04).
4. Polling até `status=VALIDATED`; linhas verde/amarelo/vermelho (RN-F5-009-05, RN-F5-009-06).
5. Confirmar só se `errorCount=0`; avisos permitidos com ciência (RN-F5-009-07).
6. Processamento lotes 1.000; status SUCCESS/PARTIAL/FAILED; `audit_log` com checksum SHA-256 (RN-F5-009-08, RN-F5-009-09).
7. Outbox `imports.completed` com sumário (RN-F5-009-10).
8. Modelo dinâmico com cabeçalho e exemplo (RN-F5-009-11).
9. `import.run` obrigatório (RN-F5-009-01).

**Regras de negócio relacionadas:** RN-F5-009-01 a RN-F5-009-11

**Dependências:** RF-TR-004, RF-TR-002, RNF-CON-01

---

### RF-F5-010 — Solicitar exportações assíncronas

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-010 |
| **Nome** | Solicitar exportações assíncronas |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria; A8 Coordenador |
| **Módulo** | F5 — Secretaria / exportações |
| **Rastreio HU** | US-F5-010 |
| **Rastreio UC** | UC-ADM-07 |
| **Tela** | F5.17 `/secretaria/exportacoes` |
| **API** | `POST /exports/{kind}`; `GET /exports`; `GET /exports/{jobId}/download` |
| **Legado** | — |

**Descrição:** O sistema deve permitir solicitar exportações volumosas de forma assíncrona com histórico de jobs, download via URL pré-assinada e notificação por e-mail.

**Critérios de aceitação:**
1. Kinds: `alunos`, `solicitacoes`, `presencas`, `certificados`, `egressos`, `formativas` (RN-F5-010-02).
2. Filtros opcionais (período, curso) por card; `POST` retorna 202 + `jobId` (RN-F5-010-03, RN-F5-010-04).
3. Status: PROCESSANDO, PRONTO, EXPIRADO; polling 10s com `aria-live="polite"` (RN-F5-010-05, RN-F5-010-07).
4. Download expira em 7 dias; arquivo removido do MinIO (RN-F5-010-06).
5. Outbox `exports.ready` com link (RN-F5-010-08).
6. Jobs expirados visíveis 30 dias para auditoria (RN-F5-010-09).
7. `export.run` obrigatório (RN-F5-010-01).

**Regras de negócio relacionadas:** RN-F5-010-01 a RN-F5-010-09

**Dependências:** RF-TR-002, RNF-UX-02, RNF-CON-01

---

### RF-F5-011 — Visualizar estatísticas operacionais

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-011 |
| **Nome** | Visualizar estatísticas operacionais |
| **Prioridade** | P2 |
| **Ator(es)** | A7 Secretaria; A8 Coordenador |
| **Módulo** | F5 — Secretaria / relatórios |
| **Rastreio HU** | US-F5-011 |
| **Rastreio UC** | UC-ADM-08 |
| **Tela** | F5.18 `/secretaria/estatisticas` |
| **API** | `GET /reports/secretary` |
| **Legado** | — |

**Descrição:** O sistema deve exibir dashboards quantitativos com gráficos Recharts filtrados por período e curso, drill-down tabular e resumos acessíveis.

**Critérios de aceitação:**
1. Filtros período e curso persistidos na URL (RN-F5-011-02).
2. Grade 2×2: solicitações por tipo, evolução temporal, distribuição por estado, horas formativas (RN-F5-011-03).
3. Drill-down: clique em gráfico atualiza tabela paginada (RN-F5-011-04).
4. Cores via tokens DS — sem hex hardcoded (RN-F5-011-05).
5. Resumo textual por gráfico para leitores de tela (RN-F5-011-06).
6. Cache 5 min; refresh invalida (RN-F5-011-07).
7. Skeleton durante carregamento (RN-F5-011-08).
8. `report.view_secretary` obrigatório (RN-F5-011-01).

**Regras de negócio relacionadas:** RN-F5-011-01 a RN-F5-011-08

**Dependências:** RNF-UX-01, RNF-UX-02, RNF-UX-04

---

### RF-F5-012 — Gerenciar tarefas internas (kanban)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F5-012 |
| **Nome** | Gerenciar tarefas internas (kanban) |
| **Prioridade** | P3 |
| **Ator(es)** | A7 Secretaria |
| **Módulo** | F5 — Secretaria / tarefas |
| **Rastreio HU** | US-F5-012 |
| **Rastreio UC** | UC-ADM-12 |
| **Tela** | F5.19 `/secretaria/tarefas` |
| **API** | `/tasks` CRUD |
| **Legado** | — |

**Descrição:** O sistema deve oferecer kanban de tarefas internas da secretaria (pendente/concluída), controlado por feature flag `tasks.enabled`, sem bloquear demais fluxos do MVP.

**Critérios de aceitação:**
1. Feature flag `tasks.enabled=false` → rota 404; item de menu oculto (RN-F5-012-01).
2. Campos: título (obrig.), descrição, vencimento, responsável, estado PENDENTE/CONCLUIDA (RN-F5-012-03).
3. Duas colunas com drag-and-drop; alternativa botões Concluir/Reabrir (RN-F5-012-04 a RN-F5-012-06).
4. Vencimento ultrapassado em `status/danger` (RN-F5-012-07).
5. Visibilidade exclusiva secretaria (RN-F5-012-08).
6. `task.manage` obrigatório (RN-F5-012-02).

**Regras de negócio relacionadas:** RN-F5-012-01 a RN-F5-012-08

**Dependências:** RNF-UX-02, RNF-UX-04

---

## Fora de escopo (fase F5)

- Configuração de comissões CAAF/COE (admin)
- Edição de solicitação já aberta pelo aluno
- Exclusão permanente de atendimentos ou alunos
- Geofence, trust score e presença em aula regular
