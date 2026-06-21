# Diagramas de sequência — SecretariaOnline2



Repositório de **saída** dos diagramas gerados pelo prompt `promptParaGerarDiagramasDeSequencia.md`.



## Estrutura



```

sequenceDiagrams/

├── README.md          # fila da campanha (§7.5) + índice

├── F0/ … F8/          # 1 arquivo por HU (51)

└── transversal/       # passo 0 (2 arquivos)

```



## Campanha (ordem)



| Passo | O quê | Meta |

|------:|-------|-----:|

| 0 | Transversais §10.1 e §10.4 (`fluxos_por_perfil` → `transversal/`) | 2 |

| 1 | Uma HU por invocação (F0→F8) | 51 |



**Fonte dos transversais:** `fluxos_por_perfil.md` §10 — não criar à mão fora do prompt.



---



## Fila da campanha (fonte da verdade — §7.5)



Usada por **Modo fila** (Loop / Cursor Automation). O agente processa **um** item por execução, na ordem abaixo.



### Status permitidos



| Status | Quando usar |

|--------|-------------|

| `pendente` | Arquivo não existe ou não foi iniciado |

| `parcial` | Arquivo existe; matriz §5.1 **incompleta** — ver **Observação** |

| `feito` | Matriz §5.1 completa (SEQUENCIA/ERRO gerados; DRY linkados; NAO_APLICAVEL listado) |



**Regras:** (1) Enquanto 10.1 ou 10.4 ≠ `feito`, **não** processar HUs. (2) `parcial` tem prioridade sobre `pendente`. (3) **Nunca** `parcial` → `feito` sem fechar lacunas da Observação.



### Passo 0 — Transversais



| Ordem | ID | Arquivo saída | Status | Observação |

|------:|----|---------------|--------|------------|

| 0 | 10.1 | `transversal/10.1-outbox-notificacao.md` | feito | 10.1a (Fase TX) + 10.1b (Dispatch multicanal) |

| 0 | 10.4 | `transversal/10.4-certificado-emissao.md` | feito | 10.4a (render + sign + persist + outbox) |



*Uma execução passo 0 gera **ambos**; marcar `feito` só quando os dois estiverem completos.*



### HUs — ordem F0 → F8



| Ordem | ID | HU (`foundationDocs/…`) | Arquivo saída | Status | Observação |

|------:|----|-------------------------|---------------|--------|------------|

| 1 | US-F0-001 | `HUs/F0 — Público/US-F0-001-LOGIN.md` | `F0/US-F0-001-LOGIN.md` | feito | F0.1-a..f (6 diagramas) |

| 2 | US-F0-002 | `HUs/F0 — Público/US-F0-002-RECUPERAR-SENHA.md` | `F0/US-F0-002-RECUPERAR-SENHA.md` | feito | F0.2-a (happy path) · F0.2-b (e-mail inexistente) · F0.2-c (429) · DRY → 10.1 |

| 3 | US-F0-003 | `HUs/F0 — Público/US-F0-003-NOVA-SENHA.md` | `F0/US-F0-003-NOVA-SENHA.md` | feito | F0.3-a (happy path POST) · F0.3-b (401 token inválido/consumido) · F0.3-c (422 reuso) |

| 4 | US-F0-004 | `HUs/F0 — Público/US-F0-004-CONTATO.md` | `F0/US-F0-004-CONTATO.md` | feito | 0 diagramas — página 100% estática; todos CAs/RNs NAO_APLICAVEL |

| 5 | US-F0-005 | `HUs/F0 — Público/US-F0-005-ERRO.md` | `F0/US-F0-005-ERRO.md` | feito | F0.5-a (5xx→/erro/500+incidentId) · F0.5-b (4xx→/erro/:codigo) |

| 6 | US-F0-006 | `HUs/F0 — Público/US-F0-006-VERIFICAR-PROTOCOLO.md` | `F0/US-F0-006-VERIFICAR-PROTOCOLO.md` | feito | F0.6-a (GET 200) · F0.6-b (SHA-256 local alt confere/não confere) · F0.6-c (404) · F0.6-d (429) |

| 7 | US-F0-007 | `HUs/F0 — Público/US-F0-007-VERIFICAR-CERTIFICADO.md` | `F0/US-F0-007-VERIFICAR-CERTIFICADO.md` | feito | F0.7-a (GET+JWKS+verify valid) · F0.7-b (revogado) · F0.7-c (404) · F0.7-d (sig fail) · DRY → F0.6-b (upload) · F0.6-d (429) |

| 8 | US-F1-001 | `HUs/F1 — Aluno/US-F1-001-DASHBOARD.md` | `F1/US-F1-001-DASHBOARD.md` | feito | F1.1-D01 (happy path cache MISS) · F1.1-D02 (cache HIT) · F1.1-D03 (degradação graciosa) · F1.1-D04 (pull-to-refresh mobile) |

| 9 | US-F1-002 | `HUs/F1 — Aluno/US-F1-002-PRIMEIRO-ACESSO.md` | `F1/US-F1-002-PRIMEIRO-ACESSO.md` | feito | F1.2-D01 (happy path) · F1.2-D02 (guard mustChangePassword) · F1.2-D03 (422 senha reutilizada) |

| 10 | US-F1-003 | `HUs/F1 — Aluno/US-F1-003-PERFIL.md` | `F1/US-F1-003-PERFIL.md` | feito | F1.3-D01 (PATCH /me) · F1.3-D02 (foto MinIO presigned) · F1.4-D03 (troca senha) · F1.4-D04 (401 senha incorreta) · F1.4-D05 (sessões HATEOAS) · F1.5-D06 (notif prefs) |

| 11 | US-F1-004 | `HUs/F1 — Aluno/US-F1-004-COMUNICACAO.md` | `F1/US-F1-004-COMUNICACAO.md` | feito | F1.6-D01 (listagem GET) · F1.6-D02 (marcar lido POST) · F1.6-D03 (filtros backend query params) |

| 12 | US-F1-005 | `HUs/F1 — Aluno/US-F1-005-SOLICITACOES.md` | `F1/US-F1-005-SOLICITACOES.md` | feito | F1.7-D01 (lista paginada) · F1.8-D02 (tipos elegíveis) · F1.8-D03 (upload SHA-256+MinIO) · F1.8-D04 (POST /requests+outbox) · F1.8-D05 (rascunho) · F1.9-D06 (detalhe+HATEOAS) · F1.9-D07 (protocolo PDF) · F1.9-D08 (download anexo MinIO) |

| 13 | US-F1-006 | `HUs/F1 — Aluno/US-F1-006-FORMATIVAS.md` | `F1/US-F1-006-FORMATIVAS.md` | feito | F1.10-D01 (lista) · F1.11-D02 (submissão manual+outbox) · F1.11-D03 (confirmar pré-validada evento) · F1.12-D04 (detalhe APROVADA+_links) |

| 14 | US-F1-007 | `HUs/F1 — Aluno/US-F1-007-ESTAGIO.md` | `F1/US-F1-007-ESTAGIO.md` | feito | F1.13-D01 (lista) · F1.14-D02 (detalhe docs+pareceres+_links) · F1.14-D03 (POST /documents+outbox) |

| 15 | US-F1-008 | `HUs/F1 — Aluno/US-F1-008-TCC.md` | `F1/US-F1-008-TCC.md` | feito | F1.15-D01 (lista tccs) · F1.16-D02 (detalhe equipe+banca+timeline+_links) · F1.16-D03 (POST /upload+outbox banca) |

| 16 | US-F1-009 | `HUs/F1 — Aluno/US-F1-009-PRESENCA.md` | `F1/US-F1-009-PRESENCA.md` | feito | F1.17-D01 (lista eventos) · F1.17-D02 (modal+session+_links condicional) · F1.18-D03 (SECRET_SINGLE confirm+device+outbox) · F1.18-D04 (DUAL fase ENTRADA→PARCIAL) · F1.18-D05 ERRO (403 fora da janela) |

| 17 | US-F1-010 | `HUs/F1 — Aluno/US-F1-010-CERTIFICADOS.md` | `F1/US-F1-010-CERTIFICADOS.md` | feito | F1.19-D01 (lista+filtros) · F1.19-D02 (download MinIO presigned 15min) · F1.19-D03 (CertificateIssuerUseCase background: PDF+SHA256+ED25519+outbox) |

| 18 | US-F1-011 | `HUs/F1 — Aluno/US-F1-011-ATENDIMENTOS.md` | `F1/US-F1-011-ATENDIMENTOS.md` | feito | F1.20-D01 (lista+filtro status) · F1.20-D02 (POST acknowledge+audit_log+IDOR guard) |

| 19 | US-F2-001 | `HUs/F2 — Egresso/US-F2-001-DASHBOARD-EGRESSO.md` | `F2/US-F2-001-DASHBOARD-EGRESSO.md` | feito | F2.1-D01 (GET /alumni/me) · F2.1-D02 (download diploma MinIO) · F2.1-D03 (reemitir certificado) · F2.1-D04 (403 rota aluno) · DRY → US-F1-003, US-F1-010, US-F5-005 |

| 20 | US-F3-001 | `HUs/F3 — Professor/US-F3-001-DASHBOARD.md` | `F3/US-F3-001-DASHBOARD.md` | feito | F3.1-D01 (happy path cache MISS) · F3.1-D02 (degradação graciosa) · DRY → F1.1-D01 (blueprint DashboardA) · 10.1 (outbox) |

| 21 | US-F3-002 | `HUs/F3 — Professor/US-F3-002-EVENTOS.md` | `F3/US-F3-002-EVENTOS.md` | feito | F3.2-D01 (criar POST /events) · F3.2-D02 (CONCLUIDO imutável) · F3.2-D03 (QR_SINGLE janela+polling) · F3.2-D04 (SECRET_DUAL saída+PIN) · F3.2-D05 (encerrar+outbox) · F3.2-ERRO (403 event.host) |

| 22 | US-F3-003 | `HUs/F3 — Professor/US-F3-003-DELIBERAR-SOLICITACOES.md` | `F3/US-F3-003-DELIBERAR-SOLICITACOES.md` | feito | F3.3-D01 (fila GET) · F3.4-D02 (DEFER+TX+outbox) · F3.4-D03 (deep-link preview→login) · F3.4-D04 (FORWARD+JWT+outbox) · ERRO-a (JTI blacklist) · ERRO-b (422 guard) |

| 23 | US-F3-004 | `HUs/F3 — Professor/US-F3-004-REVISAR-FORMATIVAS.md` | `F3/US-F3-004-REVISAR-FORMATIVAS.md` | feito | F3.5-D01 (fila GET) · F3.5-D02 (aprovar+TX+outbox+cert) · F3.5-D03 (batch approve) · F3.5-D04 (rejeitar+outbox) · F3.5-ERRO (403 CAAF) |

| 24 | US-F3-005 | `HUs/F3 — Professor/US-F3-005-ESTAGIO-ORIENTACAO.md` | `F3/US-F3-005-ESTAGIO-ORIENTACAO.md` | feito | F3.6-D01 (lista GET) · F3.6-D02 (parecer doc+TX+outbox) · F3.6-D03 (arquivar+TX+outbox) · F3.6-ERRO (403 internship.review) |

| 25 | US-F3-006 | `HUs/F3 — Professor/US-F3-006-TCC-ORIENTACAO.md` | `F3/US-F3-006-TCC-ORIENTACAO.md` | feito | F3.7-D01 (lista GET canReview) · F3.7-D02 (avaliar+TX+outbox+cert trigger) · F3.7-D03 (download MinIO presigned) · F3.7-ERRO (403 tcc.supervise) · DRY → 10.1, 10.4, F1.16-D03 |

| 26 | US-F3-007 | `HUs/F3 — Professor/US-F3-007-PUBLICAR-COMUNICADO.md` | `F3/US-F3-007-PUBLICAR-COMUNICADO.md` | feito | F3.8-D01 (GET audiências) · F3.8-D02 (POST+TX+outbox fan-out) · F3.8-ERRO-A (403) · F3.8-ERRO-B (422 audience scope) · DRY → 10.1, F1.6-D01 |

| 27 | US-F4-001 | `HUs/F4 — Comissões/US-F4-001-COMISSAO-CAAF.md` | `F4/US-F4-001-COMISSAO-CAAF.md` | feito | F4.1a (dashboard pool) · F4.1b (self-assign) · F4.1c (assign a colega+board) · F4.1d (batch-decide PRESENCA_VALIDADA) · F4.1e (403 FGAC/scope) · F4.1f (422 tipos incompatíveis) · DRY → 10.1, 10.4, US-F3-004 |

| 28 | US-F4-002 | `HUs/F4 — Comissões/US-F4-002-COMISSAO-COE.md` | `F4/US-F4-002-COMISSAO-COE.md` | feito | F4.2a (dashboard pool+SLA) · F4.2b (self-assign+notif aluno) · F4.2c (assign orientador+board) · F4.2d (bulk assign BulkActionBar — sem Aprovar) · F4.2e (403 FGAC/scope) · DRY → 10.1, US-F4-001, US-F3-005 |

| 29 | US-F5-001 | `HUs/F5 — Secretaria/US-F5-001-DASHBOARD.md` | `F5/US-F5-001-DASHBOARD.md` | feito | F5.1-D01 (happy path cache MISS) · F5.1-D02 (refresh manual) · F5.1-D03 (403 FGAC) · DRY → F1.1-D01, F3.1-D01, 10.1 |

| 30 | US-F5-002 | `HUs/F5 — Secretaria/US-F5-002-SOLICITACOES.md` | `F5/US-F5-002-SOLICITACOES.md` | feito | F5.2-D01 (fila filtros+HATEOAS) · F5.3-D02 (nova interna onBehalfOf+TX+outbox) · F5.4-D03 (deliberar PATCH+TX+outbox) · F5.2-D04 (bulk assign) · F5.5-D05 (atrasados+CSV) · F5.3-ERRO (403 escopo) · F5.4-ERRO (403 senior_secretary) · DRY → F1.1-D01-D04, 10.1 |

| 31 | US-F5-003 | `HUs/F5 — Secretaria/US-F5-003-GESTAO-ALUNOS.md` | `F5/US-F5-003-GESTAO-ALUNOS.md` | feito | F5.6-D01 (busca+HATEOAS) · D02 (POST+audit+outbox) · D03 (PATCH+audit) · D04 (reset-password+Argon2id+outbox) · D05 (matricula+vagas) · ERRO-01 (409 GRR/CPF) · ERRO-02 (422 sem vagas) · ERRO-03 (403 FGAC) |

| 32 | US-F5-004 | `HUs/F5 — Secretaria/US-F5-004-DADOS-ACADEMICOS.md` | `F5/US-F5-004-DADOS-ACADEMICOS.md` | feito | F5.7-D01 (criar curso+secretários+audit) · F5.8-D02 (criar disciplina) · F5.8-D03 (desativar PATCH) · F5.8-D04 (CSV) · F5.9-D05 (período letivo+sobreposição) · F5.9-D06 (evento calendário) · ERRO-01 (409 sigla) · ERRO-02 (422 overlap) · DRY → F5.6-D01/D03/ERRO-03 |

| 33 | US-F5-005 | `HUs/F5 — Secretaria/US-F5-005-EGRESSOS-DIPLOMAS.md` | `F5/US-F5-005-EGRESSOS-DIPLOMAS.md` | feito | F5.10-D01 (listar egressos) · F5.11-D02 (elegíveis+5 critérios) · F5.11-D03 (TX colação lote+role→EGRESSO+outbox×N) · F5.11-D04 (PATCH entrega física) · ERRO-01 (403 diploma.register) · DRY → 10.1b, F2.1-D01 |

| 34 | US-F5-006 | `HUs/F5 — Secretaria/US-F5-006-AUTORIZACOES-IMAGEM.md` | `F5/US-F5-006-AUTORIZACOES-IMAGEM.md` | feito | F5.12-D01 (lista+presigned MinIO) · F5.12-D02 (bulk-deliberate SELECT FOR UPDATE+TX×N+outbox×N) · ERRO-01 (409 concorrência pré-TX) · DRY → F5.2-D01, F4.1d, 10.1 |

| 35 | US-F5-007 | `HUs/F5 — Secretaria/US-F5-007-ATENDIMENTOS.md` | `F5/US-F5-007-ATENDIMENTOS.md` | feito | F5.13-D01 (GET categorias + Combobox aluno) · F5.13-D02 (presigned PUT MinIO + POST + TX + outbox) · DRY → F5.3-D02, F1.8-D03, 10.1, F1.20-D01 |

| 36 | US-F5-008 | `HUs/F5 — Secretaria/US-F5-008-EVENTOS.md` | `F5/US-F5-008-EVENTOS.md` | feito | F5.8-D01 (lista scope secretaria) · F5.8-D04 (encerrar+formative_entry+outbox) · F5.8-ERRO (422 excluir com presença) · DRY → F3.2-D01, D03, D04, ERRO, 10.4 |

| 37 | US-F5-009 | `HUs/F5 — Secretaria/US-F5-009-IMPORTACOES.md` | `F5/US-F5-009-IMPORTACOES.md` | feito | F5.9-D01 (baixar modelo) · F5.9-D02 (upload+polling+preview) · F5.9-D03 (confirmar lotes+audit_log+outbox) · F5.9-ERRO-D04 (PARTIAL TX lote 2 falha) · F5.9-ERRO-403 (import.run) · DRY → 10.1 |

| 38 | US-F5-010 | `HUs/F5 — Secretaria/US-F5-010-EXPORTACOES.md` | `F5/US-F5-010-EXPORTACOES.md` | feito | F5.10-D01 (POST /exports→202) · F5.10-D02 (worker CSV→MinIO→PRONTO+outbox) · F5.10-D03 (polling PRONTO+download presigned) · F5.10-D04 (scheduler EXPIRADO) · F5.10-ERRO-403 · DRY → 10.1 |

| 39 | US-F5-011 | `HUs/F5 — Secretaria/US-F5-011-ESTATISTICAS.md` | `F5/US-F5-011-ESTATISTICAS.md` | feito | F5.11-D01 (cache MISS GET /reports/secretary + 4 datasets) · F5.11-D02 (cache HIT + refresh manual) · F5.11-ERRO-403 · DRY → F1.1-D01/D02, F6.2 |

| 40 | US-F5-012 | `HUs/F5 — Secretaria/US-F5-012-TAREFAS.md` | `F5/US-F5-012-TAREFAS.md` | feito | F5.19-D01 (GET kanban) . D02 (POST criar) . D03 (PATCH estado) . D04 (DELETE PENDENTE) . ERRO-01..04 |

| 41 | US-F6-001 | `HUs/F6 — Coordenação/US-F6-001-CONFIGURAR-CURSO.md` | `F6/US-F6-001-CONFIGURAR-CURSO.md` | feito | F6.1-D01 (GET config) · F6.1-D02 (PATCH+TX+audit_log) · F6.1-ERRO (403 curso alheio) |

| 42 | US-F6-002 | `HUs/F6 — Coordenação/US-F6-002-RELATORIOS.md` | `F6/US-F6-002-RELATORIOS.md` | feito | F6.2-D01 (GET cache MISS + métricas analíticas) · F6.2-D02 DRY→F5.11-D02 · F6.2-ERRO DRY→F5.11-ERRO-403 |

| 43 | US-F7-001 | `HUs/F7 — Admin/US-F7-001-IAM-USUARIOS.md` | `F7/US-F7-001-IAM-USUARIOS.md` | feito | F7.1-D01 (listar+filtrar) · D02 (criar+outbox) · D03 (desativar+JTI blacklist) · F7.8-D04 (reset senha+JWT 1-uso+outbox) · ERRO-01 (403 FGAC) · DRY → F0.3-b (CA-05) · CA-06 DRY→D01 |

| 44 | US-F7-002 | `HUs/F7 — Admin/US-F7-002-IAM-PERFIS-AUTORIDADES.md` | `F7/US-F7-002-IAM-PERFIS-AUTORIDADES.md` | feito | F7.2-D01 (listar perfis+HATEOAS) · D02 (criar perfil customizado) · D03 (listar authorities+matrix) · D04 (PATCH role×authority+cache inval) · D05 (PUT roles usuário+cache inval) · ERRO-01 (422 role_in_use) · ERRO-02 (403 FGAC) |

| 45 | US-F7-003 | `HUs/F7 — Admin/US-F7-003-WORKFLOW-ENGINE.md` | `F7/US-F7-003-WORKFLOW-ENGINE.md` | feito | F7.4-D01 (listar+carregar editor) · D02 (criar DRAFT) · D03 (salvar rascunho) · D04 (publish+versionamento atômico) · ERRO-01 (403 FGAC) · ERRO-02 (422 schema inválido) · ERRO-03 (422 delete com histórico) · DRY → F7.1-ERRO-01 |

| 46 | US-F7-004 | `HUs/F7 — Admin/US-F7-004-TEMPLATES-COMUNICACAO.md` | `F7/US-F7-004-TEMPLATES-COMUNICACAO.md` | feito | F7.5-D01 (listar+carregar editor) · D02 (criar template) · D03 (salvar revisão+versionamento imutável) · D04 (carregar versão anterior readonly) · ERRO-01 (403 FGAC) · DRY → F7.1-ERRO-01 |

| 47 | US-F7-005 | `HUs/F7 — Admin/US-F7-005-JOBS-OUTBOX.md` | `F7/US-F7-005-JOBS-OUTBOX.md` | feito | F7.6-D01 (listar outbox events+HATEOAS+meta lag) · D02 (reentregar DEAD→PENDING+SELECT FOR UPDATE) · D03 (scheduled jobs dashboard) · ERRO-01 (403 FGAC) · DRY → 10.1b, F7.1-ERRO-01 |

| 48 | US-F7-006 | `HUs/F7 — Admin/US-F7-006-AUDIT-LOG.md` | `F7/US-F7-006-AUDIT-LOG.md` | feito | F7.7-D01 (listar audit log+payloads diff+filtros) · ERRO-01 (403 FGAC) · DRY → F7.1-ERRO-01 · CA-03/04/05/06 NAO_APLICAVEL/DRY |

| 49 | US-F7-007 | `HUs/F7 — Admin/US-F7-007-SAUDE-SISTEMA.md` | `F7/US-F7-007-SAUDE-SISTEMA.md` | feito | F7.9-D01 (KPIs Actuator+SLA summary) · ERRO-01 (403 system.admin) · DRY → F7.1-ERRO-01 · CA-02/03/04 NAO_APLICAVEL/DRY · P3 extra-MVP |

| 50 | US-F8-001 | `HUs/F8 — Cross-cutting/US-F8-001-BUSCA-GLOBAL.md` | `F8/US-F8-001-BUSCA-GLOBAL.md` | feito | F8.1-D01 (debounce+fan-out+resultados) · D02 (FGAC fan-out Aluno) · D03 (empty state) · D04 (timeout 5s) |

| 51 | US-F8-002 | `HUs/F8 — Cross-cutting/US-F8-002-SUPORTE-FAQ.md` | `F8/US-F8-002-SUPORTE-FAQ.md` | feito | F8.2-D01 (FAQ GET por perfil) · D02 (POST ticket+TX+outbox) · D03 (429 rate limit) · DRY → 10.1, F7-003 |



---

## Modo manual — passo a passo

**1 chat = 1 execução.** Use a tabela **Fila** acima; atualize **Status** e **Cobertura** ao terminar cada chat.

### Ordem obrigatória

1. **Chat 1 — passo 0** (transversais 10.1 + 10.4) — enquanto ≠ `feito`, não abrir chats de HU.
2. **Chats 2–52** — uma HU por chat, ordem **1 → 51** na fila (F0→F8).  
   US-F2-001 já está `parcial` — no chat dela, pedir **completar** F2.1a antes de marcar `feito`.

### Modelo — passo 0 (só uma vez)

```
@foundationDocs/prompts/promptParaGerarDiagramasDeSequencia.md
@foundationDocs/analysis/fluxos_por_perfil.md
@.cursor/skills/fullstack-sequence-diagrams/

Gere e salve os 2 diagramas transversais (§7.2) em sequenceDiagrams/transversal/.
Fonte: fluxos §10.1 e §10.4 — layout skill.
```

Depois: marcar 10.1 e 10.4 como `feito` na fila.

### Modelo — cada HU (copiar e trocar 3 linhas)

```
@foundationDocs/prompts/promptParaGerarDiagramasDeSequencia.md
@.cursor/skills/fullstack-sequence-diagrams/
@foundationDocs/HUs/<pasta>/US-Fx-NNN-<SLUG>.md
@foundationDocs/analysis/fluxos_por_perfil.md

Cobertura completa US-Fx-NNN (§5.1). Matriz + DRY + salvar em sequenceDiagrams/<Fx>/US-Fx-NNN-<SLUG>.md.
```

| Fase | § em `fluxos_por_perfil.md` |
|------|----------------------------|
| F0 | §1 |
| F1 | §2 |
| F2 | §3 |
| F3 | §4 |
| F4 | §5 |
| F5 | §6 |
| F6 | §7 |
| F7 | §8 |
| F8 | §9 |

Opcional: `(§2 F1)` na linha do `fluxos` — foca a seção certa.

### Casos especiais (prompt §7.3 / §7.4)

| HU | Extra no chat |
|----|----------------|
| OUTBOX | Após passo 0: link `transversal/10.1` em DRY |
| CERT | Link `transversal/10.4` quando existir |
| US-F5-005 | §7.4 — `@` US-F2-001 só como trigger downstream |

### Checklist pós-chat

- [ ] Arquivo em `sequenceDiagrams/<Fx>/`
- [ ] Matriz §5.1 completa (ou `parcial` + Observação)
- [ ] README: Status + **Cobertura**
- [ ] **Novo chat** para a próxima HU

---

## Cobertura



| Métrica | Atual | Meta |

|---------|------:|-----:|

| HUs `feito` | 39 | 51 |

| Transversais `feito` | 2 | 2 |

| HUs `parcial` | 0 | 0 |



*Atualizar após cada execução (manual ou §7.5).*













