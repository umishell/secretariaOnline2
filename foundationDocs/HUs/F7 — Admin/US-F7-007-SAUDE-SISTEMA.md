# US-F7-007 — Saúde do Sistema

| Campo | Valor |
|-------|-------|
| **ID** | US-F7-007 |
| **Épico** | ADMIN-OPS |
| **Telas** | F7.9 — Saúde do Sistema |
| **Rota** | `/admin/sistema/saude` |
| **Prioridade** | **P3 (extra-MVP)** |
| **Capability** | `system.admin` |
| **APIs** | Spring Boot Actuator (`/actuator/health`, `/actuator/metrics`) |
| **Frames Figma** | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-7123) |

> ⚠️ **Esta história é de prioridade P3 e está fora do MVP.** Anotação Figma confirma: `"P3 — extra-MVP · Actuator + link Grafana"`. Pode ser omitida do desenvolvimento inicial e implementada em iteração posterior.

---

## História de Usuário

> **Como** administrador da plataforma,  
> **quero** visualizar KPIs operacionais em tempo real (latência P95 da API, eventos pendentes no Outbox, erros 5xx e uptime) e acessar diretamente o Grafana para análise aprofundada,  
> **para que** eu possa detectar rapidamente degradações de performance ou falhas críticas sem precisar monitorar logs manualmente.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F7-007-01 | Somente usuários com capability `system.admin` acessam esta tela. |
| RN-F7-007-02 | Os KPIs são consumidos via **Spring Boot Actuator** endpoints expostos internamente: `/actuator/health`, `/actuator/metrics/http.server.requests`, `/actuator/metrics/outbox.pending`. |
| RN-F7-007-03 | **KpiRow (4 cards)** — conforme Figma `731:7233`–`731:7243`: (1) **API P95** — latência do percentil 95 das requisições HTTP (alvo < 300 ms); (2) **Outbox pending** — eventos aguardando despacho (alvo ≤ 10); (3) **5xx (1h)** — contagem de erros HTTP 5xx na última hora (alvo = 0); (4) **Uptime** — percentual de disponibilidade. |
| RN-F7-007-04 | Os valores exibidos no Figma são exemplos realistas: API P95 = 240 ms, Outbox pending = 3, 5xx (1h) = 0, Uptime = 99,9%. |
| RN-F7-007-05 | KPIs são atualizados via polling a cada 30 s (live region `aria-live="polite"`). |
| RN-F7-007-06 | Um KPI fora do alvo exibe o valor em `status/danger` (ex.: API P95 > 300 ms → vermelho; Outbox pending > 10 → laranja). |
| RN-F7-007-07 | A tela exibe um link externo "→ Abrir Grafana" (conforme texto Figma `731:7246`) que abre o dashboard Grafana configurado em nova aba. A URL do Grafana é configurada via variável de ambiente `GRAFANA_URL`. |
| RN-F7-007-08 | Esta tela não substitui o Grafana — é um resumo rápido. Para análise detalhada de séries temporais, o link do Grafana é o caminho canônico. |

---

## Critérios de Aceitação

### CA-F7-007-01 — Exibição dos KPIs

```gherkin
Dado que o admin acessa /admin/sistema/saude
Quando a tela carrega
Então os 4 KpiCards exibem: API P95 (ms), Outbox pending, 5xx última hora, Uptime (%)
E os valores refletem o estado atual via Actuator
```

### CA-F7-007-02 — KPI fora do alvo

```gherkin
Dado que a latência P95 da API está em 420 ms (acima do alvo de 300 ms)
Quando os KPIs renderizam
Então o KpiCard de API P95 exibe o valor em status/danger (cor vermelha)
```

### CA-F7-007-03 — Polling automático

```gherkin
Dado que o admin está visualizando a tela há 35 s
Quando o polling dispara
Então os valores de todos os KpiCards são atualizados silenciosamente
E o leitor de tela anuncia a atualização via aria-live="polite"
```

### CA-F7-007-04 — Link para Grafana

```gherkin
Dado que GRAFANA_URL está configurado como "https://grafana.ufpr.br"
Quando o admin clica em "→ Abrir Grafana"
Então o navegador abre "https://grafana.ufpr.br" em nova aba
```

### CA-F7-007-05 — Capability restrita

```gherkin
Dado que um usuário com capability system.observe (mas não system.admin) tenta acessar a rota
Quando a API é consultada
Então retorna HTTP 403
E a UI exibe AlertBanner "Permissão insuficiente"
```

---

## Componentes de UI

- `Shell/AdminLayout`
- `DS/KpiCard` (4×) com cores semânticas por alvo
- Link externo "→ Abrir Grafana" (`target="_blank"`, `rel="noopener noreferrer"`)
- `aria-live` region para atualizações de polling

---

## Métricas do Actuator

```
GET /actuator/metrics/http.server.requests
  ?tag=quantile:0.95 → API P95

GET /actuator/metrics/outbox.pending
  → Outbox pending count

GET /actuator/metrics/http.server.requests
  ?tag=status:5xx&window=1h → 5xx count

GET /actuator/health
  → uptime / componentes
```

---

## Alvos de SLA (Performance Goals)

| Métrica | Alvo | Cor se violado |
|---------|------|----------------|
| API P95 | < 300 ms | `status/danger` |
| Outbox pending | ≤ 10 | `status/warning` |
| 5xx (1h) | = 0 | `status/danger` |
| Uptime | ≥ 99,5% | `status/danger` |

---

## Fora de Escopo

- Configuração de alertas automáticos por SMS/e-mail quando SLA é violado
- Histórico de métricas (ver Grafana)
- Visualização de logs de aplicação (ver Loki no Grafana)

---

## Definition of Done

- [ ] KpiRow com 4 cards consumindo Actuator
- [ ] Cores semânticas para KPIs fora do alvo
- [ ] Polling a cada 30 s com `aria-live`
- [ ] Link para Grafana configurável via `GRAFANA_URL`
- [ ] Restrição a `system.admin` (403 para `system.observe`)
- [ ] Testes: KPI fora do alvo, polling, link Grafana

---

## Referências

- Frame principal: [F7.9 Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-7123)
- Actuator config: `foundationDocs/analysis/analise_arquitetural_secretariaonline2.md` §Observabilidade
- Saúde do Outbox (complementar): US-F7-005
