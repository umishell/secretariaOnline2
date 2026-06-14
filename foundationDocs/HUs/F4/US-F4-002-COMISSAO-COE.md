# US-F4-002 — Pool COE: Atribuir e Acompanhar Estágios em Lote

| Campo | Valor |
|-------|-------|
| **ID** | US-F4-002 |
| **Épico** | COE-POOL |
| **Tela** | F4.2 — `/comissoes/coe` |
| **Prioridade** | P2 |
| **Plataforma** | Web (desktop-first) |
| **Capability** | `internship.review` + escopo COE do curso/centro |
| **API primária** | `GET /commissions/coe/dashboard`, `POST /commissions/coe/assign` |
| **Frames Figma** | [Loaded/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=481-1093) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=481-1311) · [Empty/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=481-1436) · [Seleção/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=481-1560) · [Atribuir/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=524-2254) |
| **Spec de tela** | `telasFigma/telas4/F4.2-comissoes-coe.md` |

---

## 1. História de Usuário

> **Como** professor membro do COE (Comitê de Orientação de Estágios),  
> **Quero** visualizar o pool coletivo de estágios do meu curso/centro aguardando atribuição de orientador, alocar cada estágio a um colega orientador ou a mim mesmo,  
> **Para** garantir que todo aluno tenha um orientador responsável e que os prazos de análise de documentos sejam cumpridos.

---

## 2. Regras de Negócio

| ID | Regra |
|----|-------|
| **RN-F4.2-01** | A rota `/comissoes/coe` é acessível **somente** a professores com `internship.review` vinculados a um COE ativo. Outros perfis recebem 403. |
| **RN-F4.2-02** | O dashboard exibe o **pool coletivo do COE** — estágios cujo orientador ainda não foi atribuído, mais os já atribuídos ao próprio usuário. O escopo é limitado ao(s) curso(s)/centro(s) da comissão. |
| **RN-F4.2-03** | O **KpiRow** exibe: estágios no pool, atribuídos ao usuário atual, documentos pendentes de parecer (no total dos seus estágios), estágios concluídos no período. |
| **RN-F4.2-04** | Colunas da DataTable: Aluno, Empresa, Tipo de estágio, Data início, Documento pendente, Responsável (pool ou nome). |
| **RN-F4.2-05** | **Self-assign**: o membro do COE clica em "Atribuir a mim" → `POST /commissions/coe/assign { internshipId, assigneeId: "meu-id" }` → estágio aparece na fila individual em `/estagios?to=me` (F3.6). |
| **RN-F4.2-06** | **Atribuir a outro orientador**: mesmo fluxo do CAAF — abre `DS/AssignmentBoard` com lista de membros do COE e suas cargas atuais. Confirmar dispara `POST /commissions/coe/assign { internshipId, assigneeId }`. |
| **RN-F4.2-07** | **Aprovação em lote (COE)**: diferente do CAAF, o COE **não** oferece aprovação em lote de pareceres por documento — cada documento exige análise individual por ser juridicamente sensível. O `DS/BulkActionBar` oferece apenas "Atribuir selecionados" (sem "Aprovar selecionados"). |
| **RN-F4.2-08** | Após atribuição, o sistema dispara Outbox: `estagios.assigned` → o orientador destinatário recebe push/e-mail com link para `/estagios/:id`. |
| **RN-F4.2-09** | A coluna "Documento pendente" destaca em `status/danger` quando o SLA de análise do documento está vencido. |
| **RN-F4.2-10** | Estágios já concluídos (`CONCLUIDO`) não aparecem no pool — ficam disponíveis somente no histórico do orientador via `/estagios?to=me`. |

---

## 3. Critérios de Aceitação

### CA-01 — Pool COE carregado com KPIs

```gherkin
Dado que o professor com internship.review acessa /comissoes/coe
Quando a página carrega
Então o KpiRow exibe: pool total, atribuídos ao usuário, documentos pendentes, concluídos no período
  E a DataTable exibe: Aluno, Empresa, Tipo estágio, Data início, Documento pendente, Responsável
  E estágios sem orientador exibem DS/Badge "No pool"
  E documento com SLA vencido exibe célula em status/danger
```

### CA-02 — Self-assign de estágio

```gherkin
Dado que o professor está na lista do pool e _links.assign-member existe para um estágio
Quando clica em "Atribuir a mim"
Então o sistema realiza POST /commissions/coe/assign { internshipId, assigneeId: "meu-id" }
  E o badge da linha muda para "Comigo"
  E o contador "Atribuídos a mim" incrementa no KpiRow
  E o estágio passa a aparecer em /estagios?to=me (F3.6)
  E o aluno recebe notificação: "Seu orientador de estágio foi definido: [nome]"
```

### CA-03 — Atribuir a outro orientador via AssignmentBoard

```gherkin
Dado que o COE tem múltiplos membros
Quando o responsável seleciona um estágio e clica em "Atribuir..."
Então DS/AssignmentBoard abre como overlay lateral
  E exibe lista de membros do COE com: nome, estágios ativos (carga atual)
  E membro com mais estágios que a média recebe badge warning "Carga alta"
Quando seleciona um membro e confirma
Então POST /commissions/coe/assign { internshipId, assigneeId }
  E overlay fecha, linha atualiza com nome do orientador
  E Outbox enfileira notificação para o orientador designado
```

### CA-04 — BulkActionBar somente com "Atribuir" (sem "Aprovar")

```gherkin
Dado que o professor seleciona 5 estágios no pool
Quando a DS/BulkActionBar aparece
Então exibe somente "Atribuir selecionados" habilitado
  E NÃO exibe "Aprovar selecionados" (pareceres de estágio são sempre individuais)
Quando clica em "Atribuir selecionados" com 5 itens selecionados
Então DS/AssignmentBoard abre com capacidade de atribuir todos de uma vez ao mesmo orientador
  E o sistema realiza POST para cada item (ou endpoint batch) mantendo event_log individual
```

### CA-05 — Estado Empty (pool vazio)

```gherkin
Dado que não há estágios sem orientador no escopo do COE
Quando o professor acessa /comissoes/coe
Então DS/EmptyState: "Todos os estágios do período já têm orientador atribuído."
  E KpiRow permanece visível mostrando carga de cada orientador
```

### CA-06 — Documento com SLA vencido destacado

```gherkin
Dado que um estágio tem documento com prazo de parecer vencido há 3 dias
Quando o pool carrega
Então a célula "Documento pendente" desse estágio exibe texto em status/danger
  E um ícone de alerta indica o atraso
  E um tooltip informa: "Prazo de parecer vencido há 3 dias"
```

---

## 4. Componentes de UI (Design System)

| Componente | Uso |
|------------|-----|
| `DS/KpiCard` | Pool total, atribuídos ao usuário, docs pendentes, concluídos |
| `DS/DataTable/Full` | Lista de estágios com checkbox de seleção múltipla |
| `DS/BulkActionBar` | "Atribuir selecionados" (sem "Aprovar" — diferença chave vs CAAF) |
| `DS/FilterBar` | Filtros: tipo de estágio, documento pendente, responsável |
| `DS/AssignmentBoard` | Overlay de atribuição com carga atual de cada orientador |
| `DS/Badge` | "No pool" (secondary), "Comigo" (primary), "Carga alta" (warning) |
| `DS/EmptyState` | Estado sem estágios no pool |
| `DS/Skeleton/block` | Estado de carregamento |

---

## 5. Diferenças em relação ao CAAF (F4.1)

| Aspecto | CAAF (F4.1) | COE (F4.2) |
|---------|-------------|------------|
| Domínio | Atividades formativas | Estágios |
| Aprovação em lote | Sim (tipo presença validada) | **Não** (pareceres sempre individuais) |
| Colunas específicas | Tipo atividade, Horas | Empresa, Tipo estágio |
| API | `/commissions/caaf/*` | `/commissions/coe/*` |
| Fluxo individual | → F3.5 (`/formativas/:id`) | → F3.6 (`/estagios/:id`) |

---

## 6. Fora de escopo

- Parecer por documento de estágio — continua em [US-F3-005](../F3/US-F3-005-ESTAGIO-ORIENTACAO.md)
- Configuração/criação da comissão COE — função administrativa
- Relatórios agregados de estágio (taxa de conclusão, tempo médio) — não previsto no MVP

---

## 7. Definição de Pronto (DoD)

- [ ] Frames Figma aprovados: Loaded, Skeleton, Empty, Seleção, Atribuir (overlay)
- [ ] `DS/AssignmentBoard` reutilizado do F4.1 (mesmos props, label diferente)
- [ ] `DS/BulkActionBar` SEM botão "Aprovar" (diferença intencional vs CAAF)
- [ ] SLA vencido: célula Documento pendente em `status/danger` com tooltip
- [ ] Outbox: notificação ao orientador designado + notificação ao aluno
- [ ] 403 retornado para professor sem `internship.review` + escopo COE

---

## 8. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas4/F4.2-comissoes-coe.md` |
| Fluxo F4 | `foundationDocs/analysis/fluxos_por_perfil.md` §5 |
| CAAF (estrutura análoga) | [US-F4-001](./US-F4-001-COMISSAO-CAAF.md) |
| Revisão individual COE | [US-F3-005](../F3/US-F3-005-ESTAGIO-ORIENTACAO.md) |
| Upload documentos aluno | [US-F1-007](../F1/US-F1-007-ESTAGIO.md) |
| Página Figma F4 | [Telas / F4 — Comissões](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=473-447) |
| Frame principal | [F4.2 — Comissão COE / Loaded / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=481-1093) |
