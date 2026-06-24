# Requisitos Funcionais — Fase F4 (Comissões)

**Projeto:** SecretariaOnline2 — UFPR SEPT  
**Versão:** 1.0  
**Data:** 2026-06-23  
**Gerado a partir de:** US-F4-001, US-F4-002; `fluxos_por_perfil.md` §5; `telas.md` §6; `legenda_siglas_casos_de_uso_por_ator.md`; `HUs/F4 — Comissões/00-INDICE.md`  
**Total RF neste arquivo:** 2 (2 HUs → 2 capacidades coesas)

> **Camada F4:** painéis de **pool coletivo** para comissões. A revisão individual permanece em RF-F3-004 (CAAF) e RF-F3-005 (COE).

---

## Resumo da fase

| RF | Nome | HU | UC | Tela | Prioridade |
|----|------|----|----|------|:----------:|
| RF-F4-001 | Gerenciar pool CAAF (atribuir e aprovar em lote) | US-F4-001 | UC-FOR-04 | F4.1 `/comissoes/caaf` | P2 |
| RF-F4-002 | Gerenciar pool COE (atribuir estágios) | US-F4-002 | UC-EST-03 | F4.2 `/comissoes/coe` | P2 |

---

### RF-F4-001 — Gerenciar pool CAAF (atribuir e aprovar em lote)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F4-001 |
| **Nome** | Gerenciar pool CAAF (atribuir e aprovar em lote) |
| **Prioridade** | P2 |
| **Ator(es)** | A5 Membro CAAF; A4 Professor (com `formative.review` + escopo CAAF) |
| **Módulo** | F4 — Comissões / formativas |
| **Rastreio HU** | US-F4-001 |
| **Rastreio UC** | UC-FOR-04 |
| **Tela** | F4.1 `/comissoes/caaf` |
| **API** | `GET /commissions/caaf/dashboard`; `POST /commissions/caaf/assign`; `POST /commissions/caaf/batch-decide` |
| **Legado** | T101 (CAAF legado) |

**Descrição:** O sistema deve oferecer aos membros da CAAF um painel do pool coletivo de atividades formativas submetidas pelos alunos do(s) curso(s) da comissão, permitindo self-assign, atribuição a colegas com visualização de carga, e aprovação em lote para atividades com presença já validada pelo sistema.

**Pré-condições:**
- Professor autenticado com `formative.review` vinculado a CAAF ativa no escopo do curso.
- Formativas submetidas por alunos (RF-F1-006) aguardando revisão no pool.

**Pós-condições:**
- Item atribuído move para fila individual do responsável (`/formativas?to=me` — RF-F3-004).
- Aprovação em lote: cada item com `event_log` individual; certificados emitidos via Outbox.

**Critérios de aceitação:**

*Acesso e dashboard*
1. Rota acessível somente com `formative.review` + escopo CAAF; demais perfis recebem 403; link ausente no sidebar (RN-F4.1-01, CA-01).
2. `GET /commissions/caaf/dashboard` retorna pool coletivo: itens não atribuídos + atribuídos ao usuário; itens de outros membros ocultos (RN-F4.1-02, CA-01).
3. Escopo restrito ao(s) curso(s) da comissão — sem acesso cross-curso (RN-F4.1-09).
4. KpiRow: total no pool, atribuídas a mim, prazo médio restante, aprovadas no período (RN-F4.1-03, CA-01).
5. DataTable: Aluno, Tipo atividade, Horas, Data submissão, Responsável; badges "No pool" / "Comigo" (CA-01).
6. Filtros por curso, estado e tipo; skeleton durante carregamento; empty state quando pool vazio (CA-06).

*Atribuição*
7. Self-assign via `_links.assign-member` → `POST /commissions/caaf/assign { itemId, assigneeId }`; badge "Comigo"; item em `/formativas?to=me` (RN-F4.1-04, CA-02).
8. Atribuir a outro membro: `DS/AssignmentBoard` com lista de membros e carga atual; membro sobrecarregado com badge warning (RN-F4.1-05, CA-03).
9. Ações via HATEOAS — botões somente quando `_links` existirem (RF-TR-005).

*Aprovação em lote*
10. `DS/BulkActionBar`: "Aprovar selecionados" habilitado apenas para tipo `EVENTO_INTERNO_PRESENCA_VALIDADA` (RN-F4.1-06, RN-F4.1-07, CA-04).
11. Seleção mista (presença + comprovante manual): "Aprovar" desabilitado com tooltip explicativo; "Atribuir selecionados" permanece habilitado (CA-05).
12. Confirmação modal → `POST /commissions/caaf/batch-decide { ids, decisao: "APROVADA" }`; `event_log` individual por item; `CertificateIssuerUseCase` por aluno (RN-F4.1-06, CA-04).
13. Comprovante manual: checkbox visível mas aprovação em lote bloqueada — exige RF-F3-004 (RN-F4.1-07).

*Notificações*
14. Após atribuição: Outbox `formativas.assigned` → push/e-mail ao destinatário (RN-F4.1-08).
15. Após lote aprovado: Outbox `formativas.batch_approved` → notificação aos alunos + emissão de certificado (RN-F4.1-08).

**Regras de negócio relacionadas:** RN-F4.1-01 a RN-F4.1-09

**Dependências:** RF-F1-006, RF-F3-004, RF-TR-003, RF-TR-005, RF-TR-002, RNF-CON-01, RNF-UX-04

---

### RF-F4-002 — Gerenciar pool COE (atribuir estágios)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F4-002 |
| **Nome** | Gerenciar pool COE (atribuir estágios) |
| **Prioridade** | P2 |
| **Ator(es)** | A6 Membro COE; A4 Professor (com `internship.review` + escopo COE) |
| **Módulo** | F4 — Comissões / estágio |
| **Rastreio HU** | US-F4-002 |
| **Rastreio UC** | UC-EST-03 |
| **Tela** | F4.2 `/comissoes/coe` |
| **API** | `GET /commissions/coe/dashboard`; `POST /commissions/coe/assign` |
| **Legado** | T89–T91 (COE legado) |

**Descrição:** O sistema deve oferecer aos membros do COE um painel do pool coletivo de estágios aguardando atribuição de orientador, permitindo self-assign e alocação a colegas com visualização de carga, sem aprovação em lote de pareceres (sempre individuais em RF-F3-005).

**Pré-condições:**
- Professor autenticado com `internship.review` vinculado a COE ativo no escopo curso/centro.
- Estágios cadastrados pela secretaria (F5) sem orientador atribuído ou aguardando redistribuição.

**Pós-condições:**
- Estágio atribuído move para fila do orientador (`/estagios?to=me` — RF-F3-005).
- Outbox notifica orientador e aluno.

**Critérios de aceitação:**

*Acesso e dashboard*
1. Rota acessível somente com `internship.review` + escopo COE; demais perfis recebem 403 (RN-F4.2-01, CA-01).
2. Pool coletivo: estágios sem orientador + atribuídos ao usuário; escopo curso/centro da comissão (RN-F4.2-02).
3. KpiRow: pool total, atribuídos ao usuário, documentos pendentes de parecer, concluídos no período (RN-F4.2-03, CA-01).
4. DataTable: Aluno, Empresa, Tipo estágio, Data início, Documento pendente, Responsável (RN-F4.2-04, CA-01).
5. Estágios `CONCLUIDO` ausentes do pool — apenas em histórico do orientador (RN-F4.2-10).
6. Documento com SLA vencido: célula em `status/danger` + ícone alerta + tooltip com dias de atraso (RN-F4.2-09, CA-06).
7. Empty state: "Todos os estágios do período já têm orientador atribuído." (CA-05).

*Atribuição*
8. Self-assign → `POST /commissions/coe/assign { internshipId, assigneeId }`; estágio em `/estagios?to=me`; aluno notificado com nome do orientador (RN-F4.2-05, CA-02).
9. Atribuir a outro orientador via `DS/AssignmentBoard` com carga por membro; badge "Carga alta" acima da média (RN-F4.2-06, CA-03).
10. `DS/BulkActionBar` exibe **somente** "Atribuir selecionados" — **sem** "Aprovar selecionados" (RN-F4.2-07, CA-04).
11. Atribuição em lote: `AssignmentBoard` permite mesmo orientador para N itens; `event_log` individual por estágio (CA-04).
12. Após atribuição: Outbox `estagios.assigned` → push/e-mail ao orientador com link `/estagios/:id` (RN-F4.2-08).

*Diferença intencional vs CAAF*
13. Pareceres por documento **nunca** em lote — exclusivamente RF-F3-005 (RN-F4.2-07, HU §5).

**Regras de negócio relacionadas:** RN-F4.2-01 a RN-F4.2-10

**Dependências:** RF-F1-007, RF-F3-005, RF-F4-001 (componente `DS/AssignmentBoard` compartilhado), RF-TR-005, RF-TR-002, RNF-CON-01, RNF-UX-04

---

## Fora de escopo (fase F4)

- Revisão individual de formativa ou parecer de documento — RF-F3-004 / RF-F3-005
- Criação ou configuração de comissões — função administrativa (F5/F7)
- Relatórios agregados de performance das comissões
