# Requisitos Funcionais — Fase F6 (Coordenação)

**Projeto:** SecretariaOnline2 — UFPR SEPT  
**Versão:** 1.0  
**Data:** 2026-06-23  
**Gerado a partir de:** US-F6-001, US-F6-002; `fluxos_por_perfil.md` §7; `telas.md` §8; `legenda_siglas_casos_de_uso_por_ator.md`; `HUs/F6 — Coordenação/00-INDICE.md`  
**Total RF neste arquivo:** 2 (2 HUs → 2 capacidades coesas)

> **Princípio arquitetural:** Coordenação **herda** capabilities de secretaria (F5) e adiciona telas exclusivas F6.1–F6.2. Gestão de comissões (F6.3) é delegada a F7 (`commission.manage`).

---

## Resumo da fase

| RF | Nome | HU | UC | Tela | Prioridade |
|----|------|----|----|------|:----------:|
| RF-F6-001 | Configurar parâmetros curriculares do curso | US-F6-001 | UC-CAD-05 | F6.1 `/coordenacao/cursos/:id/configurar` | P2 |
| RF-F6-002 | Visualizar relatórios analíticos de coordenação | US-F6-002 | UC-ADM-09 | F6.2 `/coordenacao/relatorios` | P2 |

---

### RF-F6-001 — Configurar parâmetros curriculares do curso

| Campo | Valor |
|-------|-------|
| **ID** | RF-F6-001 |
| **Nome** | Configurar parâmetros curriculares do curso |
| **Prioridade** | P2 |
| **Ator(es)** | A8 Coordenador |
| **Módulo** | F6 — Coordenação |
| **Rastreio HU** | US-F6-001 |
| **Rastreio UC** | UC-CAD-05 |
| **Tela** | F6.1 `/coordenacao/cursos/:id/configurar` |
| **API** | `GET /courses/{id}/config`; `PATCH /courses/{id}/config` |
| **Legado** | — |

**Descrição:** O sistema deve permitir que o coordenador designado configure parâmetros curriculares do curso — horas formativas mínimas, duração do calendário letivo, regras de banca de TCC e texto de regimento — com auditoria de alterações e sem retroação de elegibilidade já conquistada.

**Pré-condições:**
- Coordenador autenticado com `course.config`.
- `course.coordenador_id` corresponde ao usuário autenticado para o curso alvo.

**Pós-condições:**
- Configuração persistida; `audit_log` com valores anterior/novo por campo alterado.
- Novos cálculos de elegibilidade (colação, TCC) usam parâmetros atualizados.

**Critérios de aceitação:**

*Acesso e formulário*
1. `GET /courses/{id}/config` retorna valores atuais: horas formativas, duração calendário, membros externos banca, modalidade banca, regimento (CA-F6-001-01).
2. Acesso a curso não coordenado → HTTP 403 + `DS/AlertBanner` (RN-F6-001-01, CA-F6-001-04).
3. Formulário em 4 seções: horas formativas (0–1000), calendário (15/18 semanas), regras banca (membros externos 1–2, modalidade PRESENCIAL/REMOTO/HÍBRIDO), regimento Markdown (máx. 10.000 chars) (RN-F6-001-02 a RN-F6-001-05).
4. Breadcrumb: Início → Cursos → [Nome] → Configurar (RN-F6-001-08).

*Persistência e validação*
5. `PATCH` envia apenas campos alterados (dirty); botão Salvar habilitado somente com dirty state (RN-F6-001-09, CA-F6-001-02).
6. Cancelar com dirty state → dialog de confirmação; sem dirty → descarta sem dialog (RN-F6-001-09, CA-F6-001-03).
7. Horas formativas fora de 0–1000 → erro inline; Salvar bloqueado (CA-F6-001-06).
8. `audit_log`: campo, valor anterior, valor novo, `userId`, timestamp (RN-F6-001-06).

*Regras de negócio transversais*
9. Horas formativas mínimas afetam elegibilidade colação (RF-F5-005-b) — **sem retroação** para alunos já elegíveis (RN-F6-001-07, CA-F6-001-05).
10. Duração calendário (15/18 semanas) usada como padrão em RF-F5-004-c (RN-F6-001-03).
11. Regras de banca consumidas pelo módulo TCC (RF-F3-006, RF-F1-008).

**Regras de negócio relacionadas:** RN-F6-001-01 a RN-F6-001-09

**Dependências:** RF-F5-004-a, RF-F5-004-c, RF-F5-005-b, RF-TR-004, RNF-UX-04

---

### RF-F6-002 — Visualizar relatórios analíticos de coordenação

| Campo | Valor |
|-------|-------|
| **ID** | RF-F6-002 |
| **Nome** | Visualizar relatórios analíticos de coordenação |
| **Prioridade** | P2 |
| **Ator(es)** | A8 Coordenador |
| **Módulo** | F6 — Coordenação |
| **Rastreio HU** | US-F6-002 |
| **Rastreio UC** | UC-ADM-09 |
| **Tela** | F6.2 `/coordenacao/relatorios` |
| **API** | `GET /reports/coordinator` |
| **Legado** | T148 (parcial) |

**Descrição:** O sistema deve oferecer ao coordenador dashboards analíticos com KPIs, gráficos de séries históricas (evasão, formativas, comparativo entre cursos, aprovação de formativas), alertas de threshold, pendências operacionais e atalhos HATEOAS — estendendo o padrão de RF-F5-011 com métricas exclusivas de coordenação.

**Pré-condições:**
- Coordenador autenticado com `report.view_coordinator`.
- Escopo limitado aos cursos coordenados.

**Pós-condições:**
- Relatórios renderizados conforme filtros; drill-down e navegação para resolução de pendências quando aplicável.

**Critérios de aceitação:**

*Carregamento e filtros*
1. `GET /reports/coordinator` com filtros: tipo relatório, período letivo, curso, intervalo datas; persistidos na URL (RN-F6-002-03, CA-F6-002-07).
2. Loading: `DS/Skeleton/block` por área de gráfico; KPIs com placeholder (RN-F6-002-12, CA-F6-002-01).
3. Cache 5 min; refresh invalida (RN-F6-002-12).

*KPIs e gráficos*
4. KpiRow: tempo médio deliberação, taxa indeferimento, horas formativas validadas, taxa conclusão presença (RN-F6-002-04, CA-F6-002-02).
5. ChartsGrid 2×2 Recharts: evasão por período (line), séries formativas (bar), comparativo cursos (bar horizontal), taxa aprovação formativas (pie) (RN-F6-002-05).
6. Cores via tokens DS — sem hex hardcoded (CA-F6-002-02).
7. Resumo textual acessível por gráfico (CA-F6-002-05).

*Alertas e pendências*
8. Se `taxaIndeferimento > threshold_curso` (de RF-F6-001): `DS/AlertBanner` warning + KpiCard danger (RN-F6-002-06, CA-F6-002-03).
9. Seção Pendências: bancas sem composição, períodos sem calendário, comissões com vagas — itens clicáveis navegam para resolução (RN-F6-002-07, CA-F6-002-04).

*Seções complementares*
10. Top 5 solicitações por SLA → link `/solicitacoes/:id` (RN-F6-002-08).
11. Próximos 3 eventos dos cursos coordenados (RN-F6-002-09).
12. Coluna direita: prazos acadêmicos, highlight métrica crítica, QuickTiles (RN-F6-002-10).
13. QuickTiles renderizados somente via `_links` (RN-F6-002-11, CA-F6-002-06).
14. Drill-down carga por deliberador: nome, total deliberações, tempo médio; paginação 20 (RN-F6-002-13, CA-F6-002-08).

**Regras de negócio relacionadas:** RN-F6-002-01 a RN-F6-002-13

**Dependências:** RF-F6-001, RF-F5-011, RF-F5-002-a, RF-TR-005, RF-TR-006, RNF-UX-01, RNF-UX-02, RNF-UX-04

---

## Fora de escopo (fase F6)

- CRUD de nome/sigla/coordenador do curso — RF-F5-004-a
- Gestão de membros CAAF/COE — F7 (`commission.manage`, US-F7-002)
- Exportação PDF de relatórios — RF-F5-010
- Alertas automáticos por e-mail ao ultrapassar threshold
- Telas exclusivas de fila/solicitações/eventos — reutilizam F5/F3
