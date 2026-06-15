# US-F5-011 — Estatísticas da Secretaria

| Campo | Valor |
|-------|-------|
| **ID** | US-F5-011 |
| **Épico** | SECR-ESTATISTICAS |
| **Telas** | F5.18 — Estatísticas |
| **Rota** | `/secretaria/estatisticas` |
| **Prioridade** | P2 |
| **Capability** | `report.view_secretary` |
| **APIs** | `GET /reports/secretary` |
| **Frames Figma** | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=542-4046) |

---

## História de Usuário

> **Como** secretária acadêmica,  
> **quero** visualizar dashboards quantitativos com gráficos de solicitações, presenças e horas formativas filtrados por período e curso,  
> **para que** eu possa monitorar indicadores operacionais e identificar tendências sem precisar exportar planilhas manualmente.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F5-011-01 | Somente usuários com capability `report.view_secretary` acessam esta tela. |
| RN-F5-011-02 | Filtros disponíveis: período letivo (select) e curso (select ou "Todos os cursos vinculados"). Os filtros persistem no estado da URL (`?periodo=2025-2&curso=TADS`). |
| RN-F5-011-03 | A grade exibe **4 gráficos** em layout 2×2: (1) Solicitações por tipo (bar chart), (2) Evolução temporal de solicitações (line chart), (3) Distribuição por estado (pie chart), (4) Horas formativas por curso (bar chart horizontal). |
| RN-F5-011-04 | Abaixo dos gráficos, uma tabela de drill-down exibe os dados do gráfico selecionado com paginação. Clicar em uma barra/fatia seleciona o gráfico e atualiza a tabela. |
| RN-F5-011-05 | Os gráficos são renderizados com Recharts; as cores usam tokens `--color-brand-*` e `--color-status-*` do design system (sem hex hardcoded). |
| RN-F5-011-06 | Cada gráfico tem um resumo textual acessível (ex.: "Tipo mais frequente: Declaração de vínculo — 45 solicitações") para leitores de tela. |
| RN-F5-011-07 | Os dados têm cache de 5 min; um botão de refresh invalida o cache. |
| RN-F5-011-08 | Durante o carregamento, cada área de gráfico exibe um `DS/Skeleton` retangular com animação. |

---

## Critérios de Aceitação

### CA-F5-011-01 — Exibição de gráficos com filtros

```gherkin
Dado que a secretária acessa /secretaria/estatisticas
Quando ela seleciona o filtro "Período: 2025/2" e "Curso: TADS"
Então a API recebe GET /reports/secretary?periodo=2025-2&curso=TADS
E os 4 gráficos são renderizados com os dados filtrados
E as cores dos gráficos usam os tokens do design system
```

### CA-F5-011-02 — Drill-down ao clicar em gráfico

```gherkin
Dado que o gráfico de "Solicitações por tipo" está exibido
Quando a secretária clica na barra "Declaração de vínculo"
Então a tabela de drill-down abaixo é atualizada com as solicitações desse tipo
E a tabela é paginada com 20 registros por página
```

### CA-F5-011-03 — Estado skeleton durante carregamento

```gherkin
Dado que a secretária aplica um filtro diferente
Quando a requisição está em andamento
Então cada área de gráfico exibe DS/Skeleton com animação de pulso
E a tabela de drill-down exibe linhas skeleton
```

### CA-F5-011-04 — Acessibilidade dos gráficos

```gherkin
Dado que os gráficos estão exibidos
Quando um leitor de tela navega pela página
Então cada gráfico tem uma região com resumo textual descrevendo o dado mais relevante
E o título do gráfico está em um elemento com role="heading"
```

### CA-F5-011-05 — Persistência de filtros na URL

```gherkin
Dado que a secretária seleciona os filtros "2025/2" e "TADS"
Quando ela copia a URL e abre em outra aba
Então a nova aba carrega os mesmos filtros aplicados
```

---

## Componentes de UI

- `DS/Chart` wrappers (Recharts)
  - BarChart (solicitações por tipo)
  - LineChart (evolução temporal)
  - PieChart (distribuição por estado)
  - BarChart horizontal (horas formativas)
- `DS/Select` (filtros de período e curso)
- `DS/DataTable` (drill-down)
- `DS/Skeleton` (loading de cada gráfico)
- `DS/Button` (refresh)
- Resumos textuais acessíveis (`aria-label`)

---

## Contrato de API

```
GET /reports/secretary?periodo=2025-2&curso=TADS

Response 200:
{
  "solicitacoesPorTipo": [ { "tipo": "DECLARACAO_VINCULO", "total": 45 }, ... ],
  "evolucaoTemporal": [ { "mes": "2025-08", "abertas": 12, "concluidas": 10 }, ... ],
  "distribuicaoPorEstado": [ { "estado": "DEFERIDA", "total": 80 }, ... ],
  "horasFormativasPorCurso": [ { "curso": "TADS", "validadas": 3200, "maxPossivel": 4000 }, ... ]
}
```

---

## Fora de Escopo

- Relatórios analíticos de coordenação (ver F6 — US-F6 futura)
- Exportação dos gráficos como imagem/PDF
- Alertas automáticos quando métricas excedem limites

---

## Definition of Done

- [ ] 4 gráficos Recharts com tokens de cor do design system
- [ ] Filtros persistidos na URL
- [ ] Drill-down na tabela ao clicar em gráfico
- [ ] Resumo textual acessível por gráfico
- [ ] Skeleton de carregamento por área de gráfico
- [ ] Cache de 5 min com refresh manual
- [ ] Testes: filtros na URL, drill-down correto por tipo

---

## Referências

- Frame principal: [F5.18 Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=542-4046)
- Análogo coordenação: F6 relatórios analíticos (`fluxos_por_perfil.md` §7.2)
