# US-F4-001 — Pool CAAF: Atribuir e Aprovar Atividades Formativas em Lote

| Campo | Valor |
|-------|-------|
| **ID** | US-F4-001 |
| **Épico** | CAAF-POOL |
| **Tela** | F4.1 — `/comissoes/caaf` |
| **Prioridade** | P2 |
| **Plataforma** | Web (desktop-first) |
| **Capability** | `formative.review` + escopo CAAF do curso |
| **API primária** | `GET /commissions/caaf/dashboard`, `POST /commissions/caaf/assign`, `POST /commissions/caaf/batch-decide` |
| **Frames Figma** | [Loaded/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=473-6859) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=476-723) · [Empty/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=479-828) · [Seleção/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=480-936) · [Atribuir/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=524-1988) |
| **Specs de tela** | `telasFigma/telas4/F4.1-comissoes-caaf.md` |

---

## 1. História de Usuário

> **Como** professor membro da CAAF (Comissão de Atividades de Formação),  
> **Quero** visualizar o pool coletivo de atividades formativas submetidas pelos alunos do meu curso, atribuir itens a colegas da comissão ou a mim mesmo, e aprovar em lote atividades pré-validadas por presença,  
> **Para** garantir que nenhuma submissão fique sem responsável, distribuir a carga de trabalho entre os membros e acelerar decisões para tipos de atividade que dispensam análise individual.

---

## 2. Regras de Negócio

| ID | Regra |
|----|-------|
| **RN-F4.1-01** | A rota `/comissoes/caaf` é acessível **somente** a professores com `formative.review` vinculados a uma CAAF ativa. Professores sem esse vínculo recebem 403 e nunca veem o link no sidebar. |
| **RN-F4.1-02** | O dashboard exibe o **pool coletivo da comissão** — todas as formativas submetidas para o(s) curso(s) da comissão que ainda não foram atribuídas a um membro, mais as já atribuídas ao próprio usuário. Formativas atribuídas a outro membro **não** aparecem nesta lista. |
| **RN-F4.1-03** | O **KpiRow** exibe: total no pool, atribuídas ao usuário atual, prazo médio restante, total aprovadas no período. |
| **RN-F4.1-04** | **Self-assign**: o membro clica em uma linha e escolhe "Atribuir a mim". O sistema registra `formativa.assigned` com `assignee_id = usuario.id` e move o item para a fila individual do professor (F3.5). |
| **RN-F4.1-05** | **Atribuir a outro membro**: abre o `DS/AssignmentBoard` (overlay lateral) com a lista de membros da comissão e suas cargas atuais. O responsável seleciona um membro e confirma → `POST /commissions/caaf/assign { itemId, assigneeId }`. |
| **RN-F4.1-06** | **Aprovação em lote (`DS/BulkActionBar`)**: disponível apenas para atividades do tipo `EVENTO_INTERNO_PRESENCA_VALIDADA` (presença já auditada pelo sistema). O membro seleciona N itens via checkbox e clica em "Aprovar selecionados". O backend executa `POST /commissions/caaf/batch-decide { ids: [...], decisao: "APROVADA" }`. Cada item ganha seu próprio `formative_entry.event_log`. |
| **RN-F4.1-07** | Para atividades com comprovante manual (não presença validada), o checkbox aparece mas a ação "Aprovar selecionados" fica desabilitada — o sistema exibe tooltip: "Este tipo de atividade exige revisão individual". |
| **RN-F4.1-08** | Após atribuição ou aprovação em lote, o sistema dispara Outbox: `formativas.assigned` → professor destinatário recebe push/e-mail; `formativas.batch_approved` → alunos afetados recebem notificação + certificado é emitido. |
| **RN-F4.1-09** | **Escopo de curso**: um membro da CAAF só vê e atribui itens do(s) curso(s) ao qual a comissão está vinculada. Não há acesso cross-curso. |

---

## 3. Critérios de Aceitação

### CA-01 — Pool CAAF carregado com KPIs

```gherkin
Dado que o professor com formative.review acessa /comissoes/caaf
Quando a página carrega
Então o KpiRow exibe: pool total, atribuídas a mim, prazo médio, aprovadas no período
  E a DataTable exibe: Aluno, Tipo atividade, Horas, Data submissão, Responsável (pool ou nome)
  E itens sem responsável exibem DS/Badge "No pool"
  E itens atribuídos ao usuário exibem DS/Badge "Comigo"
  E professor sem formative.review recebe HTTP 403
```

### CA-02 — Self-assign

```gherkin
Dado que o professor está na lista do pool
  E _links.assign-member existe para um item
Quando clica em "Atribuir a mim" na linha
Então o sistema realiza POST /commissions/caaf/assign { itemId, assigneeId: "meu-id" }
  E o badge da linha muda para "Comigo"
  E o contador "Atribuídas a mim" no KpiRow incrementa
  E o item aparece na fila individual em /formativas?to=me (F3.5)
```

### CA-03 — Atribuir a outro membro via AssignmentBoard

```gherkin
Dado que o professor está na lista e há outros membros na comissão
  E _links.assign-member existe
Quando clica em "Atribuir..." na linha ou no BulkActionBar com 1+ selecionados
Então o DS/AssignmentBoard abre como overlay lateral
  E exibe lista de membros da comissão com nome e carga atual (N itens)
  E o membro com maior carga recebe badge warning
Quando seleciona um colega e clica em "Confirmar"
Então o sistema realiza POST /commissions/caaf/assign { itemId, assigneeId: "id-colega" }
  E o overlay fecha e a linha atualiza badge com nome do responsável
  E Outbox enfileira notificação para o colega destinatário
```

### CA-04 — Aprovação em lote (presença validada)

```gherkin
Dado que existem 10 formativas do tipo EVENTO_INTERNO_PRESENCA_VALIDADA no pool
Quando o professor seleciona todas via checkbox "selecionar todos"
  E a DS/BulkActionBar aparece com "Aprovar selecionados" habilitado
  E clica em "Aprovar selecionados"
Então um modal de confirmação exibe: "Aprovar 10 atividades de evento com presença validada?"
  E ao confirmar: POST /commissions/caaf/batch-decide { ids: [...], decisao: "APROVADA" }
  E cada item recebe seu event_log individual
  E CertificateIssuerUseCase é disparado para cada aluno
  E DS/AlertBanner success: "10 atividades aprovadas. Certificados sendo gerados."
```

### CA-05 — Lote com tipo de atividade incompatível

```gherkin
Dado que o professor seleciona formativas de tipo misto (presença validada + comprovante manual)
Quando a DS/BulkActionBar atualiza
Então "Aprovar selecionados" fica desabilitado
  E tooltip: "Selecione apenas atividades de evento com presença validada para aprovação em lote."
  E "Atribuir selecionados" continua habilitado para todos os tipos
```

### CA-06 — Estado Empty (pool vazio)

```gherkin
Dado que não há formativas no pool da comissão
Quando o professor acessa /comissoes/caaf
Então DS/EmptyState exibe: "Nenhuma atividade aguardando revisão no pool."
  E KpiRow permanece visível com zeros
```

---

## 4. Componentes de UI (Design System)

| Componente | Uso |
|------------|-----|
| `DS/KpiCard` | Total pool, atribuídas ao usuário, prazo médio, aprovadas |
| `DS/DataTable/Full` | Lista de formativas com checkbox de seleção múltipla |
| `DS/BulkActionBar` | Toolbar de ações em lote (aparece ao selecionar ≥ 1 item) |
| `DS/FilterBar` | Filtros: curso, estado, tipo atividade |
| `DS/AssignmentBoard` | Overlay de atribuição com carga de cada membro |
| `DS/Badge` | "No pool" (secondary), "Comigo" (primary), "Atribuído" (info) |
| `DS/EmptyState` | Estado vazio |
| `DS/Skeleton/block` | Estado de carregamento |

---

## 5. Fora de escopo

- Revisão individual de cada formativa — continua em [US-F3-004](../F3/US-F3-004-REVISAR-FORMATIVAS.md)
- Criação ou configuração da comissão — função administrativa (F5 ou admin)
- Relatórios de performance da comissão — não previsto no MVP

---

## 6. Definição de Pronto (DoD)

- [ ] Frames Figma aprovados: Loaded, Skeleton, Empty, Seleção (BulkActionBar ativo), Atribuir (overlay)
- [ ] `DS/AssignmentBoard` implementado com lista de membros + carga
- [ ] `DS/BulkActionBar` habilita/desabilita "Aprovar" conforme tipo dos selecionados
- [ ] Batch-decide: cada item tem event_log individual mesmo em aprovação coletiva
- [ ] Outbox: notificação ao membro designado + certificado aos alunos
- [ ] 403 retornado para professor sem `formative.review` + escopo CAAF

---

## 7. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas4/F4.1-comissoes-caaf.md` |
| Fluxo F4 | `foundationDocs/analysis/fluxos_por_perfil.md` §5 |
| Revisão individual CAAF | [US-F3-004](../F3/US-F3-004-REVISAR-FORMATIVAS.md) |
| Submissão aluno | [US-F1-006](../F1/US-F1-006-FORMATIVAS.md) |
| Página Figma F4 | [Telas / F4 — Comissões](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=473-447) |
| Frame principal | [F4.1 — Comissão CAAF / Loaded / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=473-6859) |
