# US-F7-005 — Observabilidade do Outbox e Jobs Agendados

| Campo | Valor |
|-------|-------|
| **ID** | US-F7-005 |
| **Épico** | ADMIN-JOBS |
| **Telas** | F7.6 — Jobs Outbox |
| **Rota** | `/admin/jobs` |
| **Prioridade** | P2 |
| **Capability** | `system.observe` |
| **APIs** | `GET /admin/outbox` · `POST /admin/outbox/:id/retry` · `GET /admin/scheduled-jobs` |
| **Frames Figma** | [FAILED tab](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6384) |

---

## História de Usuário

> **Como** administrador da plataforma,  
> **quero** monitorar o estado dos eventos do Outbox (PENDING, SENT, FAILED, DEAD) e dos jobs agendados, com a capacidade de reenviar eventos falhos,  
> **para que** eu possa diagnosticar e corrigir falhas na entrega de e-mails e notificações sem precisar de acesso direto ao banco de dados.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F7-005-01 | Somente usuários com capability `system.observe` acessam esta tela. |
| RN-F7-005-02 | **Seção Outbox Events** (`DS/OutboxEventTable`): tabela de eventos com colunas: ID, Aggregate Type (ex.: `solicitacoes`, `egressos`), Payload resumido, Status, Tentativas, Criado em, Último envio. |
| RN-F7-005-03 | A `DS/FilterBar` filtra por: Status (PENDING / SENT / FAILED / DEAD), Aggregate Type e intervalo de datas. O frame Figma `731:6384` está na aba FAILED por padrão, indicando que FAILED é o estado mais operacionalmente crítico. |
| RN-F7-005-04 | **Status FAILED:** evento com erro na última tentativa mas ainda dentro do limite de retentativas. Exibido com badge `status/danger`. |
| RN-F7-005-05 | **Status DEAD:** evento que esgotou todas as tentativas (padrão: 5). Exibido com badge neutro cinza. Requer ação manual explícita do admin para reentrar na fila. |
| RN-F7-005-06 | **Botão "Reentregar":** disponível via `_link retry` somente para eventos com status FAILED ou DEAD. Recoloca o evento no status PENDING. O botão fica em estado de loading enquanto a ação é processada. |
| RN-F7-005-07 | **SLA do dispatcher:** o scheduler do Outbox processa eventos PENDING a cada 5 s. Latência esperada < 5 s para PENDING → SENT em fila vazia. Se a latência for > 30 s, um alerta é exibido na tela. |
| RN-F7-005-08 | **Seção Scheduled Jobs** (`DS/ScheduledJobCard`): cards para cada job recorrente com: nome, frequência (ex.: `@Scheduled(fixedDelay=5000)`), último run, próximo run, status (OK / ATRASADO / FALHOU). |
| RN-F7-005-09 | Jobs agendados documentados: `OutboxDispatcher` (5 s), `SlaBreachChecker` (diário), `ExportJobCleaner` (diário), `EventAutoCloser` (23:59 diário). |
| RN-F7-005-10 | A tabela de outbox events suporta paginação (20 por página). Eventos SENT são retidos por 7 dias e depois arquivados automaticamente. |

---

## Critérios de Aceitação

### CA-F7-005-01 — Visualizar eventos por status

```gherkin
Dado que o admin acessa /admin/jobs
Quando a aba FAILED está ativa
Então o DS/OutboxEventTable exibe apenas eventos com status FAILED
E cada linha mostra ID, Aggregate Type, Payload resumido, Tentativas, Criado em
E as linhas FAILED têm badge status/danger
```

### CA-F7-005-02 — Filtrar por aggregate type

```gherkin
Dado que o admin seleciona o filtro "Aggregate Type: solicitacoes"
Quando o filtro é aplicado
Então a tabela exibe somente eventos com aggregate_type = "solicitacoes"
```

### CA-F7-005-03 — Reentregar evento DEAD

```gherkin
Dado que existe um evento com status DEAD (5 tentativas esgotadas)
Quando o admin clica em "Reentregar" na linha do evento
Então a API recebe POST /admin/outbox/:id/retry
E o evento muda para status PENDING
E o badge atualiza imediatamente na tabela
E um toast "Evento reenfileirado" é exibido
```

### CA-F7-005-04 — Alerta de latência do dispatcher

```gherkin
Dado que o Outbox tem eventos PENDING há mais de 30 s sem processamento
Quando o admin visualiza a tela
Então um DS/AlertBanner de aviso aparece: "Dispatcher com latência > 30s — verificar OutboxDispatcher"
```

### CA-F7-005-05 — Scheduled Jobs

```gherkin
Dado que a seção de Scheduled Jobs é exibida
Quando o admin visualiza os DS/ScheduledJobCard
Então cada card exibe: nome do job, frequência, último run, próximo run, status
E o job "EventAutoCloser" com status ATRASADO exibe badge status/warning
```

### CA-F7-005-06 — Botão Reentregar somente para FAILED/DEAD

```gherkin
Dado que um evento tem status SENT
Quando o admin visualiza a linha
Então o botão "Reentregar" não é exibido (rel "retry" ausente via HATEOAS)
```

---

## Componentes de UI

- `Shell/AdminLayout`
- `DS/FilterBar` (filtros de status e aggregate type)
- `DS/OutboxEventTable` (tabela de eventos Outbox)
- `DS/Badge` (PENDING/SENT/FAILED/DEAD)
- `DS/Button` ("Reentregar" — HATEOAS)
- `DS/Pagination`
- `DS/ScheduledJobCard` (cards de jobs agendados)
- `DS/AlertBanner` (latência do dispatcher)

---

## Contrato de API

```
GET /admin/outbox?status=FAILED&aggregateType=solicitacoes&page=0&size=20
Response: { content: [ { id, aggregateType, payload, status, tentativas, criadoEm, _links } ] }

POST /admin/outbox/:id/retry
Response 200: { id, status: "PENDING" }

GET /admin/scheduled-jobs
Response: [ { nome, frequencia, ultimoRun, proximoRun, status: "OK|ATRASADO|FALHOU" } ]
```

---

## Fora de Escopo

- Visualização do payload completo de um evento (apenas resumo; logs detalhados em Loki)
- Cancelar um evento PENDING em processamento
- Configurar a frequência dos scheduled jobs pela UI

---

## Definition of Done

- [ ] Tabela de events por status com filtros
- [ ] Botão "Reentregar" via HATEOAS somente para FAILED/DEAD
- [ ] Cards de scheduled jobs com status atual
- [ ] Alerta de latência > 30 s no dispatcher
- [ ] Paginação com 20 eventos por página
- [ ] Testes: reentregar DEAD, reentregar SENT bloqueado, alerta de latência

---

## Referências

- Frame principal: [F7.6 FAILED tab](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6384)
- Fluxo F7.4 Observabilidade do Outbox: `foundationDocs/analysis/fluxos_por_perfil.md` §8.4
- Outbox Pattern: `foundationDocs/analysis/analise_arquitetural_secretariaonline2.md` §3 (Outbox)
