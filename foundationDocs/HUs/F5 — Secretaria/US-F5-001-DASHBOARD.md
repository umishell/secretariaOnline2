# US-F5-001 — Dashboard Operacional da Secretaria

| Campo | Valor |
|-------|-------|
| **ID** | US-F5-001 |
| **Épico** | SECR-DASH |
| **Telas** | F5.1 — Dashboard Secretaria |
| **Rota** | `/inicio` |
| **Prioridade** | P2 |
| **Capability** | `dashboard.view_secretary` |
| **API primária** | `GET /bff/dashboard/secretary` |
| **Frames Figma** | [Default](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-449) · [Skeleton](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=585-15348) · [Empty](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=585-15361) |

---

## História de Usuário

> **Como** secretária acadêmica,  
> **quero** ver no meu painel de início os KPIs de solicitações abertas, atrasadas, concluídas hoje e eventos do dia, com alertas visuais de SLA,  
> **para que** eu possa priorizar meu trabalho sem precisar varrer todas as filas manualmente.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F5-001-01 | Somente usuários com capability `dashboard.view_secretary` acessam esta rota; demais papéis recebem redirecionamento para o dashboard do seu perfil. |
| RN-F5-001-02 | O BFF agrega em uma única chamada: contadores KPI, fila de solicitações priorizadas (≤ 10 registros), alertas SLA ativos e agenda de eventos do dia. |
| RN-F5-001-03 | A fila priorizada ordena por `prazo_em ASC` (breach primeiro), depois por `criado_em ASC`. |
| RN-F5-001-04 | Solicitações com `prazo_em < now()` exibem destaque vermelho (`status/danger`); dentro de 24 h exibem `status/warning`. |
| RN-F5-001-05 | O dashboard respeita o escopo de cursos vinculados ao usuário — a secretaria só vê solicitações dos cursos para os quais possui permissão. |
| RN-F5-001-06 | O estado Empty (`585:15361`) é exibido quando não há solicitações abertas; neste caso os KPIs de atrasadas e abertas mostram `0`. |
| RN-F5-001-07 | QuickTiles de navegação rápida (CRUD frequentes) são renderizadas somente se o `_link` correspondente estiver presente na resposta da API, garantindo HATEOAS. |
| RN-F5-001-08 | Dados do dashboard têm cache de 60 s no TanStack Query; um botão de refresh manual invalida o cache imediatamente. |

---

## Critérios de Aceitação

### CA-F5-001-01 — Carregamento e exibição de KPIs

```gherkin
Dado que a secretária está autenticada com capability dashboard.view_secretary
Quando ela acessa /inicio
Então o sistema exibe o estado Skeleton por até 2 s durante o carregamento
E após a resposta do BFF exibe os KPIs: abertas, atrasadas, concluídas hoje, eventos do dia
E os valores refletem apenas os cursos vinculados à secretária
```

### CA-F5-001-02 — Destaque de SLA breach

```gherkin
Dado que existem solicitações com prazo_em < now()
Quando o dashboard é exibido
Então cada item na fila priorizada com SLA vencido aparece com texto na cor status/danger
E um banner de alerta SLA fica visível acima da fila com a contagem de itens em breach
```

### CA-F5-001-03 — Estado Empty

```gherkin
Dado que não existem solicitações abertas vinculadas aos cursos da secretária
Quando o dashboard carrega
Então o componente EmptyState é exibido na seção de fila
E os KPIs de abertas e atrasadas mostram 0
```

### CA-F5-001-04 — QuickTiles HATEOAS

```gherkin
Dado que a resposta do BFF contém _links para cursos e alunos mas não para importações
Quando o dashboard renderiza os QuickTiles
Então os tiles de Cursos e Alunos são exibidos
E o tile de Importações não é exibido
```

### CA-F5-001-05 — Refresh manual

```gherkin
Dado que o dashboard está exibindo dados em cache
Quando a secretária clica no botão de refresh
Então o cache do TanStack Query é invalidado
E os dados são recarregados com o estado Skeleton
```

---

## Componentes de UI

- `DS/KpiCard` (4× KPIs)
- `DS/DataTable` ou lista resumida para fila priorizada
- `DS/Badge` (status solicitação)
- `DS/AlertBanner` (SLA breach)
- `DS/Skeleton` (loading)
- `DS/EmptyState` (sem solicitações abertas)
- QuickTiles (navegação rápida)

---

## Contrato de API

```
GET /bff/dashboard/secretary
Authorization: Bearer <token>

Response 200:
{
  "kpis": {
    "abertas": 12,
    "atrasadas": 3,
    "concluidasHoje": 7,
    "eventosHoje": 2
  },
  "filaPriorizada": [ { "id", "numero", "tipo", "aluno", "prazo_em", "sla_status" } ],
  "alertasSla": [ { "id", "numero", "diasAtraso" } ],
  "agendaHoje": [ { "id", "titulo", "horario", "modo" } ],
  "_links": {
    "solicitacoes": { "href": "/solicitacoes" },
    "alunos": { "href": "/secretaria/alunos" },
    "cursos": { "href": "/secretaria/cursos" },
    "importacoes": { "href": "/secretaria/importacoes" }
  }
}
```

---

## Fora de Escopo

- Gráficos históricos (ver US-F5-011)
- Exportação de dados do dashboard
- Edição inline de solicitações pelo dashboard

---

## Definition of Done

- [ ] BFF endpoint retorna payload documentado acima
- [ ] KPIs filtrados por cursos vinculados ao usuário
- [ ] SLA breach destacado visualmente (`status/danger`)
- [ ] HATEOAS: QuickTiles ocultos sem `_link`
- [ ] Estados Skeleton, Loaded e Empty implementados
- [ ] Testes unitários para lógica de prioridade de fila
- [ ] WCAG 2.1 AA: contraste e aria-labels nos KPIs

---

## Referências

- Frame principal: [F5.1 Default](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-449)
- Fluxo F5.1 Triagem: `foundationDocs/analysis/fluxos_por_perfil.md` §6.1
- Análogo: US-F1-001 (Dashboard Aluno), US-F3-001 (Dashboard Professor)
