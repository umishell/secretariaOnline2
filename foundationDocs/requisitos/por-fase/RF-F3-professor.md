# Requisitos Funcionais — Fase F3 (Professor)

**Projeto:** SecretariaOnline2 — UFPR SEPT  
**Versão:** 1.0  
**Data:** 2026-06-23  
**Gerado a partir de:** US-F3-001 a US-F3-007; `fluxos_por_perfil.md` §4; `telas.md` §5; `legenda_siglas_casos_de_uso_por_ator.md`; `endpoints_canonicos_presenca_eventos_v4.md`  
**Total RF neste arquivo:** 9 (7 HUs → 9 capacidades)

---

## Resumo da fase

| RF | Nome | HU | UC | Tela(s) | Prioridade |
|----|------|----|----|---------|:----------:|
| RF-F3-001 | Visualizar dashboard unificado do professor | US-F3-001 | UC-DASH-01 | F3.1 `/inicio` | P2 |
| RF-F3-002-a | Gerenciar eventos formativos (CRUD) | US-F3-002 | UC-PRE-01 | F3.2a `/professor/eventos` · F3.2b `/professor/eventos/:id` | P2 |
| RF-F3-002-b | Operar validação de presença ao vivo | US-F3-002 | UC-PRE-02, UC-PRE-04 | F3.2c `/professor/eventos/:id/operacao` | P2 |
| RF-F3-003-a | Listar fila de solicitações para deliberação | US-F3-003 | UC-SOL-04 | F3.3 `/solicitacoes?to=me` | P2 |
| RF-F3-003-b | Deliberar solicitação (incl. deep-link JWT) | US-F3-003 | UC-SOL-04 | F3.4 `/solicitacoes/:id/deliberar` | P2 |
| RF-F3-004 | Revisar atividades formativas (CAAF) | US-F3-004 | UC-FOR-03 | F3.5 `/formativas?to=me` | P2 |
| RF-F3-005 | Emitir pareceres de estágio (orientador/COE) | US-F3-005 | UC-EST-02 | F3.6 `/estagios?to=me` · `/estagios/:id` | P2 |
| RF-F3-006 | Avaliar TCC (orientador/banca) | US-F3-006 | UC-TCC-02 | F3.7 `/tccs?to=me` · `/tccs/:id` | P2 |
| RF-F3-007 | Publicar comunicado para turma ou curso | US-F3-007 | UC-COM-02 | F3.8 `/comunicacao/publicar` | P2 |

---

### RF-F3-001 — Visualizar dashboard unificado do professor

| Campo | Valor |
|-------|-------|
| **ID** | RF-F3-001 |
| **Nome** | Visualizar dashboard unificado do professor |
| **Prioridade** | P2 |
| **Ator(es)** | A4 Professor |
| **Módulo** | F3 — Professor |
| **Rastreio HU** | US-F3-001 |
| **Rastreio UC** | UC-DASH-01 |
| **Tela** | F3.1 `/inicio` |
| **API** | `GET /bff/dashboard/professor` |
| **Legado** | T08 `home.jsp` (visão PRF/COO) |

**Descrição:** O sistema deve apresentar ao professor autenticado um painel unificado com filas de trabalho (solicitações para deliberar, eventos do dia, formativas CAAF, estágios, TCCs), KPIs de SLA e atalhos — agregados pelo BFF em uma única chamada, com blocos e CTAs renderizados exclusivamente a partir de `_links` HATEOAS.

**Pré-condições:**
- Professor autenticado com `mustChangePassword = false`.
- Capability `dashboard.view_self_professor` concedida.

**Pós-condições:**
- Dashboard renderizado com blocos presentes na resposta do BFF ou estados vazios/degradação por seção.
- CTAs derivados de `_links`; blocos sem capability correspondente ausentes.

**Critérios de aceitação:**
1. `GET /bff/dashboard/professor` retorna KPIs (pendentes deliberar, formativas revisar, eventos hoje, SLA urgentes), fila de solicitações, meus eventos, bloco formativas CAAF (quando aplicável) e `_links` (RN-F3.1-01, RN-F3.1-02).
2. Estrutura visual DashboardA (mesma do aluno F1.1); conteúdo diferenciado pelo BFF — UI nunca usa `user.role` para decidir blocos (RN-F3.1-01).
3. Bloco "Formativas CAAF" renderizado somente se professor tem `formative.review` e há itens pendentes (RN-F3.1-03, CA-01).
4. Bloco "Fila de solicitações" exibe itens com `canDeliberate=true` para o professor (RN-F3.1-04).
5. Bloco "Meus eventos" exibe eventos com `event.manage`; badge "Em andamento" quando estado `EM_ANDAMENTO` e janela ativa (RN-F3.1-05, CA-03).
6. KpiCard SLA: quando `slaUrgentes > 0`, badge warning e link para `/solicitacoes?to=me` com filtro de urgência (CA-02).
7. CTA "Operar evento" somente se `_links.operar` existir; navega para `/professor/eventos/:id/operacao` (CA-03).
8. Degradação graciosa: falha em módulo exibe `DS/AlertBanner` warning no bloco afetado; demais blocos renderizam (RN-F3.1-06, CA-04).
9. Durante carregamento: `DS/Skeleton` por bloco; empty state quando seção vazia.
10. Responsivo desde 375 px; FCP < 1,5 s (RNF-DES-04).

**Regras de negócio relacionadas:** RN-F3.1-01 a RN-F3.1-06

**Dependências:** RF-F0-001, RF-F1-002, RF-TR-005, RF-TR-006, RNF-DES-04, RNF-UX-04

---

### RF-F3-002-a — Gerenciar eventos formativos (CRUD)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F3-002-a |
| **Nome** | Gerenciar eventos formativos (CRUD) |
| **Prioridade** | P2 |
| **Ator(es)** | A4 Professor |
| **Módulo** | F3 — Professor / presença |
| **Rastreio HU** | US-F3-002 (HU-A) |
| **Rastreio UC** | UC-PRE-01 |
| **Tela** | F3.2a `/professor/eventos` · F3.2b `/professor/eventos/:id` |
| **API** | `GET/POST /events`, `GET/PATCH/DELETE /events/{id}` |
| **Legado** | — |

**Descrição:** O sistema deve permitir que o professor com `event.manage` crie, edite, liste e exclua eventos formativos, configurando modo de presença (`attendanceMode`), janelas de validação, carga horária creditada e público-alvo, respeitando regras de imutabilidade por estado do evento.

**Pré-condições:**
- Professor autenticado com `event.manage`.
- Para edição/exclusão: usuário é organizador do evento ou política institucional equivalente.

**Pós-condições:**
- Evento persistido em estado `AGENDADO` (criação) ou atualizado conforme política de estado.
- Exclusão lógica apenas quando permitido por `_links.excluir`.

**Critérios de aceitação:**
1. Lista `/professor/eventos`: filtro `onlyMine=true` por padrão; exibe somente eventos do professor (RN-F3.2-01, CA-01).
2. Criação: campos obrigatórios título, descrição, curso/público, `inicioEm`, `fimEm`, `chCreditadas`, `attendanceMode`; `POST /events` retorna 201 e redireciona para detalhe (RN-F3.2-02, CA-01).
3. `attendanceMode` aceita `QR_SINGLE`, `QR_DUAL`, `SECRET_SINGLE`, `SECRET_DUAL`; formulário adapta campos conforme modo (RN-F3.2-03).
4. Janelas: "dia inteiro" ou duas sub-janelas; modos DUAL exigem janelas entrada e saída (RN-F3.2-04, CA-02).
5. Validação backend: `fimEm > inicioEm`, janelas dentro do intervalo, `chCreditadas > 0` (RN-F3.2-07).
6. Estado `AGENDADO`: edição livre; `EM_ANDAMENTO`: apenas campos operacionais; `CONCLUIDO`: somente leitura, formulário disabled, banner info (RN-F3.2-05, CA-03).
7. Exclusão via `_links.excluir` somente se estado `AGENDADO`; eventos em andamento/concluídos não excluíveis (RN-F3.2-06).
8. Botão "Novo evento" somente se `_links.novoEvento` existir (HATEOAS).
9. **Fora de escopo:** geofence, trust score, aula regular (SIGA).

**Regras de negócio relacionadas:** RN-F3.2-01 a RN-F3.2-07

**Dependências:** RF-TR-005, RF-TR-008, `endpoints_canonicos_presenca_eventos_v4.md`, RNF-UX-04

---

### RF-F3-002-b — Operar validação de presença ao vivo

| Campo | Valor |
|-------|-------|
| **ID** | RF-F3-002-b |
| **Nome** | Operar validação de presença ao vivo |
| **Prioridade** | P2 |
| **Ator(es)** | A4 Professor |
| **Módulo** | F3 — Professor / presença |
| **Rastreio HU** | US-F3-002 (HU-B) |
| **Rastreio UC** | UC-PRE-02, UC-PRE-04 |
| **Tela** | F3.2c `/professor/eventos/:id/operacao` |
| **API** | `POST /events/{id}/attendance/windows/entry`, `.../exit`; `GET /events/{id}/qr/entry`, `.../qr/exit`; `POST /events/{id}/close` |
| **Legado** | — |

**Descrição:** O sistema deve permitir que o professor organizador conduza a operação ao vivo do evento — abrir janelas de validação, exibir QR ou PIN aos alunos, acompanhar contagens em tempo real e encerrar o evento disparando emissão automática de certificados.

**Pré-condições:**
- Professor autenticado com `event.host` (ou `event.manage` para eventos próprios).
- Evento em estado `EM_ANDAMENTO`.

**Pós-condições:**
- Janela aberta com token QR/PIN ativo conforme `attendanceMode`.
- Encerramento: estado `CONCLUIDO`; Outbox dispara emissão de certificados para alunos com presença completa.

**Critérios de aceitação:**
1. Acesso à tela exige `event.host`; RouteGuard retorna 403 sem capability (RN-F3.2-08).
2. Modos QR: `POST .../windows/entry` (e/ou exit) → `DS/QRDisplay` 280×280px; token renovado via polling (~5 min) (RN-F3.2-09, RN-F3.2-11, CA-04).
3. Modos SECRET: PIN exibido em `DS/PINDisplay` (mono 32px); fase saída após entrada em modos DUAL (RN-F3.2-10, CA-05).
4. Abertura de janela: valida evento `EM_ANDAMENTO` e janela não aberta anteriormente (RN-F3.2-11).
5. Contadores em polling 5s: presenças completas, parciais (duplos), inelegíveis; lista ao vivo dos últimos confirmados (RN-F3.2-12, CA-06).
6. Encerrar: `POST /events/{id}/close` via `_links.encerrar-evento` → `CONCLUIDO` → `CertificateIssuerUseCase` por aluno elegível (RN-F3.2-13, CA-07, RF-TR-003).
7. Tela otimizada para projeção 1280px+ com alto contraste; QR legível à distância (RN-F3.2-14).
8. **Fora de escopo:** geofence, trust score, aula regular.

**Regras de negócio relacionadas:** RN-F3.2-08 a RN-F3.2-14

**Dependências:** RF-F3-002-a, RF-F1-009, RF-TR-003, RF-TR-008, RNF-UX-04

---

### RF-F3-003-a — Listar fila de solicitações para deliberação

| Campo | Valor |
|-------|-------|
| **ID** | RF-F3-003-a |
| **Nome** | Listar fila de solicitações para deliberação |
| **Prioridade** | P2 |
| **Ator(es)** | A4 Professor |
| **Módulo** | F3 — Professor / solicitações |
| **Rastreio HU** | US-F3-003 (HU-A) |
| **Rastreio UC** | UC-SOL-04 |
| **Tela** | F3.3 `/solicitacoes?to=me` |
| **API** | `GET /requests?canDeliberate=true` |
| **Legado** | T12–T15 (deliberação legada) |

**Descrição:** O sistema deve exibir ao professor deliberante a fila de solicitações que aguardam sua decisão, com indicadores de SLA, filtros e suporte a deliberação em lote quando configurado no workflow.

**Pré-condições:**
- Professor autenticado com `request.deliberate`.

**Pós-condições:**
- Lista ordenada e filtrada exibida; clique em item navega para RF-F3-003-b.

**Critérios de aceitação:**
1. `GET /requests?canDeliberate=true` retorna somente solicitações deliberáveis pelo professor (RN-F3.3-01, CA-01).
2. Colunas: Número, Aluno (nome parcial), Tipo, Prazo, SLA; prazo vencido (`prazo_em < now`) em variant danger (RN-F3.3-02, CA-01).
3. Ordenação padrão por prazo ascendente; filtros por tipo, curso e atraso (CA-01).
4. Ações em lote quando `RequestType.workflow_json` define `batchDeliberate=true` (RN-F3.3-03).
5. Empty state quando fila vazia; skeleton durante carregamento.
6. Sem `request.deliberate`: rota retorna 403.

**Regras de negócio relacionadas:** RN-F3.3-01 a RN-F3.3-03

**Dependências:** RF-TR-001, RF-TR-005, RF-F3-003-b, RNF-UX-04

---

### RF-F3-003-b — Deliberar solicitação (incl. deep-link JWT)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F3-003-b |
| **Nome** | Deliberar solicitação (incl. deep-link JWT) |
| **Prioridade** | P2 |
| **Ator(es)** | A4 Professor |
| **Módulo** | F3 — Professor / solicitações |
| **Rastreio HU** | US-F3-003 (HU-B) |
| **Rastreio UC** | UC-SOL-04 |
| **Tela** | F3.4 `/solicitacoes/:id/deliberar` |
| **API** | `GET /requests/{id}`, `POST /requests/{id}/transitions` |
| **Legado** | T12–T15 |

**Descrição:** O sistema deve permitir que o professor deliberante defira, indefira, solicite ajustes ou encaminhe uma solicitação com parecer fundamentado, acessível pela fila ou por deep-link JWT de uso único enviado por e-mail, com registro imutável em auditoria.

**Pré-condições:**
- Professor autenticado com `request.deliberate` (ou preview via deep-link antes do login).
- Solicitação em estado que permite transição conforme workflow.

**Pós-condições:**
- Transição aplicada; `request_event` e `audit_log` gravados; notificações enfileiradas via Outbox.
- JTI do deep-link consumido e blacklistado após uso bem-sucedido.

**Critérios de aceitação:**
1. Acesso por fila ou URL `/solicitacoes/:id/deliberar?token=JWT` (`audience=request-action`, TTL 7d, JTI único) (RN-F3.4-01, CA-04).
2. Deep-link sem login: modo preview read-only + banner "Faça login para deliberar"; após login retorna à mesma URL (RN-F3.4-02, CA-04).
3. Ações (Deferir, Indeferir, Solicitar ajustes, Encaminhar) renderizadas exclusivamente de `_links` (RN-F3.4-03, CA-02).
4. Parecer obrigatório; indeferir exige mínimo 20 caracteres (RN-F3.4-04, CA-07).
5. `POST /requests/{id}/transitions`: valida authority, guard do workflow e JTI; falha → 422 RFC 7807 (RN-F3.4-05).
6. Encaminhar: `action=FORWARD`, `targetUserId`; novo JWT 1-uso + Outbox e-mail ao destinatário (RN-F3.4-06, CA-06).
7. Solicitar ajustes: estado `EM_AJUSTE`; aluno notificado push/e-mail (RN-F3.4-07).
8. Cada transição grava `request_event` + `audit_log` imutável (RN-F3.4-08).
9. Painel de decisão sticky (desktop) ou bottom sheet (mobile) (RN-F3.4-09).
10. JTI já utilizado: 401 "Token já utilizado" + empty state com link para fila (CA-05).
11. Deferir: notificação ao aluno; redirecionamento à fila com confirmação (CA-03).

**Regras de negócio relacionadas:** RN-F3.4-01 a RN-F3.4-09

**Dependências:** RF-F3-003-a, RF-TR-001, RF-TR-002, RF-TR-004, RF-TR-005, RNF-SEC-06, RNF-CON-01

---

### RF-F3-004 — Revisar atividades formativas (CAAF)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F3-004 |
| **Nome** | Revisar atividades formativas (CAAF) |
| **Prioridade** | P2 |
| **Ator(es)** | A4 Professor (membro CAAF) |
| **Módulo** | F3 — Professor / formativas |
| **Rastreio HU** | US-F3-004 |
| **Rastreio UC** | UC-FOR-03 |
| **Tela** | F3.5 `/formativas?to=me` |
| **API** | `GET /formative-entries?canReview=true`, `POST /formative-entries/{id}/approve`, `POST /formative-entries/{id}/reject` |
| **Legado** | T88–T90 (CAAF legado) |

**Descrição:** O sistema deve permitir que professores membros da CAAF revisem atividades formativas submetidas por alunos do seu curso, aprovando com horas validadas ou rejeitando com parecer, disparando emissão automática de certificado quando aprovada.

**Pré-condições:**
- Professor autenticado com `formative.review` no escopo do curso/comissão.

**Pós-condições:**
- Decisão registrada em `formative_entry.event_log`; aluno notificado; certificado emitido se aprovada.

**Critérios de aceitação:**
1. Rota invisível sem `formative.review`: 403; BFF não retorna bloco no dashboard (RN-F3.5-01, CA-01).
2. Listagem restrita ao escopo curso/comissão do professor (RN-F3.5-02, CA-01).
3. Aprovar individual: `horasValidadas` informadas; estado `APROVADA`; `CertificateIssuerUseCase` disparado (RN-F3.5-04, CA-02).
4. Aprovar em lote para tipo `EVENTO_INTERNO_PRESENCA_VALIDADA` quando selecionados múltiplos itens (RN-F3.5-03, CA-03).
5. Rejeitar: parecer obrigatório (mín. 20 caracteres); estado `REJEITADA`; push/e-mail ao aluno (RN-F3.5-05, CA-04).
6. Cada decisão gera `event_log` com tipo, horas, parecer, `actor_id`, timestamp (RN-F3.5-06).
7. Ações via `_links.aprovar` / `_links.rejeitar`.

**Regras de negócio relacionadas:** RN-F3.5-01 a RN-F3.5-06

**Dependências:** RF-F1-006, RF-F1-010, RF-TR-003, RF-TR-005, RNF-CON-01

---

### RF-F3-005 — Emitir pareceres de estágio (orientador/COE)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F3-005 |
| **Nome** | Emitir pareceres de estágio (orientador/COE) |
| **Prioridade** | P2 |
| **Ator(es)** | A4 Professor; A6 Membro COE |
| **Módulo** | F3 — Professor / estágio |
| **Rastreio HU** | US-F3-005 |
| **Rastreio UC** | UC-EST-02 |
| **Tela** | F3.6 `/estagios?to=me` · `/estagios/:id` |
| **API** | `GET /internships?canReview=true`, `POST /internships/{id}/documents/{docId}/review`, `POST /internships/{id}/close` |
| **Legado** | T86–T87 |

**Descrição:** O sistema deve permitir que orientadores e membros do COE visualizem estágios sob sua responsabilidade, emitam pareceres por documento e arquivem estágios concluídos.

**Pré-condições:**
- Professor autenticado com `internship.review` como orientador ou membro COE.
- Estágio cadastrado pela secretaria; documentos enviados pelo aluno.

**Pós-condições:**
- Parecer registrado; aluno notificado; estágio arquivado quando elegível.

**Critérios de aceitação:**
1. Lista `/estagios?to=me`: colunas Aluno, Empresa, Documento pendente; empty state quando vazio (RN-F3.6-01, RN-F3.6-02, CA-01).
2. Detalhe `/estagios/:id`: tabs Documentos e Pareceres, timeline, dados da empresa (RN-F3.6-03).
3. Parecer por documento: texto obrigatório + decisão APROVADO/REPROVADO via `_links.revisar` (RN-F3.6-04, CA-02).
4. Arquivar via `_links.arquivar` → `POST /internships/{id}/close` quando todos documentos obrigatórios aprovados (RN-F3.6-05, CA-03).
5. Cada parecer dispara notificação push/e-mail ao aluno (RN-F3.6-06).

**Regras de negócio relacionadas:** RN-F3.6-01 a RN-F3.6-06

**Dependências:** RF-F1-007, RF-TR-002, RNF-CON-01, RNF-UX-04

---

### RF-F3-006 — Avaliar TCC (orientador/banca)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F3-006 |
| **Nome** | Avaliar TCC (orientador/banca) |
| **Prioridade** | P2 |
| **Ator(es)** | A4 Professor |
| **Módulo** | F3 — Professor / TCC |
| **Rastreio HU** | US-F3-006 |
| **Rastreio UC** | UC-TCC-02 |
| **Tela** | F3.7 `/tccs?to=me` · `/tccs/:id` |
| **API** | `GET /tccs?canReview=true`, `POST /tccs/{id}/review` |
| **Legado** | T107–T111 |

**Descrição:** O sistema deve permitir que orientadores e membros de banca visualizem TCCs sob sua responsabilidade, baixem o arquivo final, registrem nota e parecer, e disparem emissão de certificado de conclusão quando aprovado e elegível.

**Pré-condições:**
- Professor autenticado com `tcc.supervise` e `canReview=true` no TCC.
- Aluno enviou versão final do TCC.

**Pós-condições:**
- Avaliação registrada em `tcc_evaluation`; estado do TCC atualizado; certificado emitido se aprovado.

**Critérios de aceitação:**
1. Lista: colunas Aluno, Título, Papel (Orientador/Banca), Situação; empty state quando vazio (RN-F3.7-01, RN-F3.7-02, CA-01).
2. Download do arquivo via URL pré-assinada MinIO (TTL 15 min) (RN-F3.7-03, CA-03).
3. Avaliação via `_links.avaliar`: nota 0–10 (uma casa decimal) + parecer; situação derivada da nota mínima configurada (RN-F3.7-04, CA-02).
4. Se aprovado e elegível: `CertificateIssuerUseCase` disparado (RN-F3.7-05).
5. Registro em `tcc_evaluation` com `actor_id`, nota, parecer, timestamp (RN-F3.7-06).
6. Aluno notificado com resultado.

**Regras de negócio relacionadas:** RN-F3.7-01 a RN-F3.7-06

**Dependências:** RF-F1-008, RF-TR-003, RNF-CON-01, RNF-UX-04

---

### RF-F3-007 — Publicar comunicado para turma ou curso

| Campo | Valor |
|-------|-------|
| **ID** | RF-F3-007 |
| **Nome** | Publicar comunicado para turma ou curso |
| **Prioridade** | P2 |
| **Ator(es)** | A4 Professor |
| **Módulo** | F3 — Professor / comunicação |
| **Rastreio HU** | US-F3-007 |
| **Rastreio UC** | UC-COM-02 |
| **Tela** | F3.8 `/comunicacao/publicar` |
| **API** | `POST /communications` |
| **Legado** | — |

**Descrição:** O sistema deve permitir que o professor redija e publique comunicados em Markdown para turmas ou cursos sob sua responsabilidade, definindo prioridade e expiração, com entrega assíncrona via Outbox aos destinatários.

**Pré-condições:**
- Professor autenticado com `communication.publish_class`.

**Pós-condições:**
- `Communication` criada; Outbox `comunicacao.published` enfileirado; fan-out assíncrono por destinatário.

**Critérios de aceitação:**
1. Formulário: título, editor Markdown, preview em tempo real, audiência, prioridade, expiração (CA-01).
2. Preview renderiza Markdown com tipografia Body; somente leitura (RN-F3.8-04, CA-03).
3. Botão "Publicar" habilitado somente com título e corpo preenchidos (CA-01).
4. `POST /communications` retorna 201; banner success; comunicado visível em `/comunicacao` para destinatários (RN-F3.8-05, RN-F3.8-06, CA-02).
5. Audiência restrita a turmas/cursos do professor; opção broadcast universitária ausente sem `system.broadcast` (RN-F3.8-01, CA-04).
6. Prioridade CRITICAL/HIGH/MEDIUM/LOW define canais de entrega conforme RN-F3.8-02.
7. Após `expiraEm`, comunicado permanece no histórico mas perde status "não lido" (RN-F3.8-03).
8. Mobile <768px: editor e preview em tabs Editor | Preview com `aria-selected` (CA-05).

**Regras de negócio relacionadas:** RN-F3.8-01 a RN-F3.8-06

**Dependências:** RF-F1-004, RF-TR-002, RF-TR-007, RNF-UX-04, RNF-CON-01

---

## Fora de escopo (fase F3)

- Criação de solicitação pelo professor (exclusividade do aluno — RF-F1-005-b)
- Edição/exclusão de comunicado após publicação
- Geofence, trust score e presença em aula regular (SIGA)
- Painéis de comissão dedicados (F4 — CAAF/COE agregados)
