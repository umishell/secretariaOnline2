# US-F6-002 — Relatórios Analíticos de Coordenação

| Campo | Valor |
|-------|-------|
| **ID** | US-F6-002 |
| **Épico** | COORD-RELATORIOS |
| **Telas** | F6.2 — Relatórios Coordenação |
| **Rota** | `/coordenacao/relatorios` |
| **Prioridade** | P2 |
| **Capability** | `report.view_coordinator` |
| **API primária** | `GET /reports/coordinator` |
| **Frames Figma** | [Default](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=718-5166) · [Loading](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=721-1209) |

---

## História de Usuário

> **Como** coordenador de curso,  
> **quero** visualizar relatórios analíticos com séries históricas de evasão, validação de horas formativas, comparativo entre turmas e carga de deliberadores,  
> **para que** eu possa tomar decisões acadêmicas baseadas em dados e identificar tendências que exigem intervenção antecipada.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F6-002-01 | Somente usuários com capability `report.view_coordinator` acessam esta tela. |
| RN-F6-002-02 | Esta tela é uma **extensão de F5.18** (Estatísticas Secretaria); os componentes e padrões são idênticos, mas o endpoint (`/reports/coordinator`) retorna métricas analíticas adicionais exclusivas do coordenador. |
| RN-F6-002-03 | **FilterBar de 4 seletores:** Tipo de relatório, Período letivo, Curso (todos os cursos coordenados), Intervalo de datas (de–até). Filtros persistem na URL query string. |
| RN-F6-002-04 | **KpiRow (4 cards):** Tempo médio de deliberação (dias), Taxa de indeferimento (%), Horas formativas validadas (total), Taxa de conclusão de presença em eventos (%). |
| RN-F6-002-05 | **ChartsGrid 2×2 (Recharts):**<br>• (1,1) **Evasão por período** — line chart de alunos ativos vs evadidos por semestre<br>• (1,2) **Séries históricas formativas** — bar chart de horas validadas por período vs meta<br>• (2,1) **Comparativo entre cursos** — bar chart horizontal por curso (se coordenador gere >1 curso)<br>• (2,2) **Taxa de aprovação de formativas** — pie/donut chart (aprovadas / reprovadas / pendentes) |
| RN-F6-002-06 | **Alerta de taxa de indeferimento:** se `taxaIndeferimento > threshold_curso` (configurável via F6.1), um `DS/AlertBanner` de aviso é exibido no topo da coluna esquerda com o valor e link para detalhar. |
| RN-F6-002-07 | **Seção Pendências:** lista de pendências operacionais do coordenador (ex.: bancas de TCC sem composição, períodos sem calendário configurado, comissões com vagas abertas). Cada item é clicável e navega para a tela de resolução. |
| RN-F6-002-08 | **Seção Solicitações** (`DS/DataTable/Compact`): mostra as solicitações com maior tempo de deliberação (top 5 por SLA). Link para `/solicitacoes/:id`. |
| RN-F6-002-09 | **Seção Eventos** (`DS/EventoRow`): próximos 3 eventos dos cursos coordenados. |
| RN-F6-002-10 | **Coluna direita:** `DS/Card/Prazos` com próximos prazos acadêmicos do calendário; `DS/HighlightCard` com a métrica mais crítica (maior desvio em relação à média histórica); `QuickTilesGrid` com 6 atalhos (Configurar curso, Tipos solicitação, Gerir comissões, Exportar, Alunos, Calendários). |
| RN-F6-002-11 | Cada QuickTile é renderizado somente se o `_link` correspondente está presente na resposta da API (HATEOAS). |
| RN-F6-002-12 | Os dados têm cache de 5 min (igual a F5.18). O estado Loading (`721:1209`) exibe `DS/Skeleton/block` em cada área de gráfico. |
| RN-F6-002-13 | **Carga por professor deliberador:** métrica derivada que mostra quantas solicitações cada professor deliberou no período. Exibida na tabela de drill-down ao clicar em gráfico relevante. |

---

## Critérios de Aceitação

### CA-F6-002-01 — Carregamento e estado Loading

```gherkin
Dado que o coordenador acessa /coordenacao/relatorios
Quando a requisição está em andamento
Então o frame Loading (721:1209) é exibido:
  DS/Skeleton/block em cada uma das 4 áreas de gráfico
E os KpiCards exibem placeholders animados
```

### CA-F6-002-02 — Exibição de KPIs e gráficos

```gherkin
Dado que o coordenador aplica os filtros "Período: 2025/2" e "Curso: TADS"
Quando a resposta da API é recebida
Então os 4 KpiCards exibem: tempo médio, taxa indeferimento, horas validadas, taxa presença
E os 4 gráficos são renderizados com dados do período 2025/2 para TADS
E as cores dos gráficos usam tokens do design system (sem hex hardcoded)
```

### CA-F6-002-03 — Alerta de taxa de indeferimento

```gherkin
Dado que o threshold de indeferimento configurado para TADS é 20%
E a taxa atual do período é 35%
Quando os relatórios carregam
Então um DS/AlertBanner de aviso aparece no topo da coluna esquerda:
  "Taxa de indeferimento: 35% (acima do limite 20%)"
E o KpiCard de taxa de indeferimento exibe a cor status/danger
```

### CA-F6-002-04 — Seção Pendências clicável

```gherkin
Dado que existem 2 bancas de TCC sem composição definida
Quando o coordenador visualiza a seção Pendências
Então aparecem 2 DS/PendenciaItem com descrição "Banca sem composição — [título do TCC]"
Quando ele clica em um item
Então é redirecionado para a tela de composição da banca
```

### CA-F6-002-05 — Gráfico Evasão por período (série histórica)

```gherkin
Dado que existem dados de 4 semestres anteriores para TADS
Quando o gráfico (1,1) "Evasão por período" renderiza
Então exibe uma linha de alunos ativos e outra de evadidos para cada semestre
E o eixo X mostra os rótulos dos semestres (ex.: "2024/1", "2024/2", "2025/1", "2025/2")
E um resumo textual acessível descreve o ponto de maior evasão
```

### CA-F6-002-06 — QuickTiles HATEOAS

```gherkin
Dado que a resposta da API não contém _link para "tipos-solicitacao"
Quando a seção de QuickTiles renderiza
Então o tile "Tipos de Solicitação" não é exibido
E os 5 tiles restantes com _links disponíveis aparecem normalmente
```

### CA-F6-002-07 — Filtros persistem na URL

```gherkin
Dado que o coordenador aplica "Período: 2025/2" e "Curso: TADS"
Quando ele copia a URL e abre em nova aba
Então a nova aba carrega os mesmos filtros aplicados
```

### CA-F6-002-08 — Drill-down de carga por deliberador

```gherkin
Dado que o coordenador clica no gráfico (2,1) "Comparativo entre cursos"
Quando a tabela de drill-down atualiza
Então ela exibe por deliberador: nome, quantidade de deliberações, tempo médio (dias)
E a tabela é paginada com 20 registros por página
```

---

## Métricas do Endpoint `/reports/coordinator`

Métricas exclusivas do coordenador (não presentes em `/reports/secretary`):

| Métrica | Descrição |
|---------|-----------|
| `tempoMedioDeliberacao` | Média em dias por tipo de solicitação |
| `taxaIndeferimento` | % de indeferimentos no período |
| `thresholdIndeferimento` | Limite configurado via F6.1 |
| `cargaPorDeliberador` | Solicitações por professor deliberador |
| `evasaoPorPeriodo` | Alunos ativos vs evadidos por semestre |
| `seriesHistoricasFormativas` | Horas validadas por período vs meta |
| `comparativoCursos` | Métricas dos cursos coordenados (se >1) |
| `taxaAprovacaoFormativas` | Aprovadas / Reprovadas / Pendentes |
| `taxaConclusaoPresenca` | % alunos com presença confirmada por evento |
| `pendencias` | Bancas sem composição, períodos sem calendário, etc. |

---

## Componentes de UI

- `DS/KpiCard` (4×)
- `DS/Select` (4 filtros)
- `DS/Chart` wrappers (Recharts) — LineChart, BarChart, BarChartHorizontal, PieChart
- `DS/Skeleton/block` (Loading state por gráfico)
- `DS/AlertBanner` (threshold indeferimento)
- `DS/PendenciaItem` (seção pendências)
- `DS/DataTable/Compact` (top 5 SLA)
- `DS/EventoRow` (próximos eventos)
- `DS/Card/Prazos` (coluna direita)
- `DS/HighlightCard` (métrica mais crítica)
- `DS/QuickTile` (6 atalhos HATEOAS)

---

## Contrato de API

```
GET /reports/coordinator
  ?periodo=2025-2
  &curso=TADS
  &tipo=evasao|formativas|comparativo|presenca
  &de=2025-08-01
  &ate=2025-11-30

Response 200:
{
  "kpis": { "tempoMedioDeliberacao": 4.2, "taxaIndeferimento": 35, "horasFormativasValidadas": 3800, "taxaConclusaoPresenca": 78 },
  "thresholdIndeferimento": 20,
  "evasaoPorPeriodo": [ { "periodo": "2025/2", "ativos": 120, "evadidos": 8 }, ... ],
  "seriesHistoricasFormativas": [ { "periodo": "2025/2", "validadas": 3800, "meta": 4200 }, ... ],
  "comparativoCursos": [ { "curso": "TADS", "taxaAprovacao": 82 }, ... ],
  "taxaAprovacaoFormativas": { "aprovadas": 450, "reprovadas": 30, "pendentes": 20 },
  "cargaPorDeliberador": [ { "professorId": "...", "nome": "...", "total": 45, "tempoMedio": 3.1 }, ... ],
  "pendencias": [ { "tipo": "BANCA_SEM_COMPOSICAO", "referencia": "TCC-2025-001", "href": "..." }, ... ],
  "solicitacoesTopSla": [ { "id", "numero", "tipo", "diasAtraso" }, ... ],
  "proximosEventos": [ { "id", "titulo", "inicio", "modo" }, ... ],
  "proximosPrazos": [ { "tipo", "data", "descricao" }, ... ],
  "_links": {
    "configurar-curso": ..., "tipos-solicitacao": ..., "comissoes": ..., "exportar": ..., "alunos": ..., "calendarios": ...
  }
}
```

---

## Diferenças em Relação a F5.18 (Estatísticas Secretaria)

| Aspecto | F5.18 (Secretaria) | F6.2 (Coordenação) |
|---------|--------------------|---------------------|
| Endpoint | `/reports/secretary` | `/reports/coordinator` |
| Métricas extras | Não | Evasão, séries históricas, carga por deliberador, taxa presença |
| Gráficos | 4 operacionais | 4 analíticos (evasão, formativas, comparativo, aprovação) |
| Alertas | Nenhum | AlertBanner se taxa indeferimento > threshold |
| Pendências | Não | Seção Pendências com bancas/calendários incompletos |
| QuickTiles | Não | 6 atalhos coordenação |
| Frame Figma | `542:4046` | `718:5166` (derivado, anotação "Clone F5.18") |

---

## Fora de Escopo

- Exportação dos relatórios como PDF (ver US-F5-010 exportação assíncrona)
- Alertas automáticos por e-mail quando threshold é ultrapassado
- Dados de turmas específicas (granularidade por turma)

---

## Definition of Done

- [ ] Endpoint `/reports/coordinator` retorna todas as métricas documentadas
- [ ] 4 gráficos Recharts com séries históricas e comparativos
- [ ] AlertBanner condicional ao threshold de indeferimento
- [ ] Seção Pendências com itens clicáveis que navegam para resolução
- [ ] QuickTiles HATEOAS (só exibe se `_link` presente)
- [ ] Loading state com DS/Skeleton/block por área de gráfico
- [ ] Filtros persistidos na URL
- [ ] Drill-down de carga por deliberador
- [ ] Resumos textuais acessíveis por gráfico
- [ ] Testes: alerta de indeferimento, pendências, filtros na URL

---

## Referências

- Frame Default: [F6.2 Default](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=718-5166)
- Frame Loading: [F6.2 Loading](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=721-1209)
- Fluxo F6.2 Relatórios analíticos: `foundationDocs/analysis/fluxos_por_perfil.md` §7.2
- Base (Estatísticas Secretaria): US-F5-011
