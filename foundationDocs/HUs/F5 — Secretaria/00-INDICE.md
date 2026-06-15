# F5 — Secretaria: Índice de Histórias de Usuário

> **Perfil-alvo:** Secretária / Secretário acadêmico (capabilities `dashboard.view_secretary`, `request.*`, `user.manage_students`, `course.manage`, `subject.manage`, `calendar.manage`, `alumni.list`, `diploma.register`, `image_authorization.review`, `service_record.create`, `event.manage`, `event.host`, `import.run`, `export.run`, `report.view_secretary`, `task.manage`)  
> **Fase Figma:** `Telas / F5 — Secretaria` · [node 539:447](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-447)  
> **Sprint-alvo MVP:** Walking Skeleton + Sprint 3–4  
> **Telas cobertas:** F5.1 – F5.19 (19 telas)

---

## Épicos

| ID Épico | Nome | Escopo |
|----------|------|--------|
| SECR-DASH | Dashboard operacional | Visão geral com KPIs, fila priorizada e SLA |
| SECR-SOLICITACOES | Gestão de solicitações | Fila, nova interna, deliberar, atrasados |
| SECR-CADASTROS | Gestão de alunos | CRUD aluno, reset senha, matrícula |
| SECR-ACADEMICO | Dados acadêmicos | Cursos, disciplinas, calendários acadêmicos |
| SECR-EGRESSOS | Egressos & diplomas | Lista egressos, colação de grau, entrega diploma |
| SECR-AUTORIZACOES | Autorizações de imagem | Revisão em lote de AUTORIZACAO_IMAGEM |
| SECR-ATENDIMENTOS | Atendimento presencial | Registro de atendimento balcão/guichê |
| SECR-EVENTOS | Eventos institucionais | CRUD evento + operação ao vivo (QR/PIN) |
| SECR-IMPORTACOES | Importações em lote | Wizard CSV/XLSX com preview de validação |
| SECR-EXPORTACOES | Exportações assíncronas | Catálogo de relatórios, jobs, download |
| SECR-ESTATISTICAS | Estatísticas | Dashboard quantitativo Recharts |
| SECR-TAREFAS | Tarefas internas | Kanban pendente/concluída (P3 opcional) |

---

## Histórias de Usuário

| ID | Título | Épico | Telas Cobertas | Prioridade | Frames Figma |
|----|--------|-------|----------------|------------|--------------|
| [US-F5-001](./US-F5-001-DASHBOARD.md) | Dashboard Secretaria | SECR-DASH | F5.1 | P2 | [Default](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-449) · [Skeleton](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=585-15348) · [Empty](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=585-15361) |
| [US-F5-002](./US-F5-002-SOLICITACOES.md) | Fila + Atrasados + Deliberar | SECR-SOLICITACOES | F5.2, F5.3, F5.4, F5.5 | P2 | [Fila Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-764) · [Fila Skeleton](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=585-15485) · [Fila Empty](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=585-15571) · [Nova Passo 1](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-886) · [Deliberar](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-1010) · [Atrasados](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-1124) |
| [US-F5-003](./US-F5-003-GESTAO-ALUNOS.md) | Gestão de Alunos | SECR-CADASTROS | F5.6 | P2 | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1598) · [Drawer aberto](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=581-4554) |
| [US-F5-004](./US-F5-004-DADOS-ACADEMICOS.md) | Dados Acadêmicos (Cursos/Disciplinas/Calendários) | SECR-ACADEMICO | F5.7, F5.8, F5.9 | P2 | [Cursos](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1718) · [Disciplinas](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1838) · [Calendários](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2603) |
| [US-F5-005](./US-F5-005-EGRESSOS-DIPLOMAS.md) | Egressos & Colação de Grau | SECR-EGRESSOS | F5.10, F5.11 | P2 | [Egressos](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1958) · [Diplomas Passo 1](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2723) |
| [US-F5-006](./US-F5-006-AUTORIZACOES-IMAGEM.md) | Autorizações de Imagem | SECR-AUTORIZACOES | F5.12 | P2 | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-2078) |
| [US-F5-007](./US-F5-007-ATENDIMENTOS.md) | Atendimento Presencial | SECR-ATENDIMENTOS | F5.13 | P2 | [Novo](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2847) |
| [US-F5-008](./US-F5-008-EVENTOS.md) | Gestão de Eventos Institucionais | SECR-EVENTOS | F5.14, F5.15 | P2 | [Lista](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2960) · [Operação QR_SINGLE](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-3073) |
| [US-F5-009](./US-F5-009-IMPORTACOES.md) | Importações em Lote | SECR-IMPORTACOES | F5.16 | P2 | [Passo 1](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-3182) |
| [US-F5-010](./US-F5-010-EXPORTACOES.md) | Exportações Assíncronas | SECR-EXPORTACOES | F5.17 | P2 | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=542-3693) |
| [US-F5-011](./US-F5-011-ESTATISTICAS.md) | Estatísticas Secretaria | SECR-ESTATISTICAS | F5.18 | P2 | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=542-4046) |
| [US-F5-012](./US-F5-012-TAREFAS.md) | Tarefas Internas | SECR-TAREFAS | F5.19 | P3 | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=542-4213) |

---

## Mapa de Frames Figma (F5)

| # | Frame Figma | node-id | Link |
|---|-------------|---------|------|
| 1 | F5.1 — Dashboard Secretaria / Default / Desktop | `539:449` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-449) |
| 2 | F5.1 — Dashboard Secretaria / Skeleton / Desktop | `585:15348` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=585-15348) |
| 3 | F5.1 — Dashboard Secretaria / Empty / Desktop | `585:15361` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=585-15361) |
| 4 | F5.2 — Fila solicitações / Loaded / Desktop | `539:764` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-764) |
| 5 | F5.2 — Fila solicitações / Skeleton / Desktop | `585:15485` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=585-15485) |
| 6 | F5.2 — Fila solicitações / Empty / Desktop | `585:15571` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=585-15571) |
| 7 | F5.3 — Nova solicitação interna / Passo 1 / Desktop | `539:886` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-886) |
| 8 | F5.4 — Deliberar solicitação / Ações / Desktop | `539:1010` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-1010) |
| 9 | F5.5 — Atrasados / Loaded / Desktop | `539:1124` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-1124) |
| 10 | F5.6 — Alunos / Loaded / Desktop | `540:1598` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1598) |
| 11 | F5.6 — Alunos / Drawer aberto / Desktop | `581:4554` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=581-4554) |
| 12 | F5.7 — Cursos / Loaded / Desktop | `540:1718` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1718) |
| 13 | F5.8 — Disciplinas / Loaded / Desktop | `540:1838` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1838) |
| 14 | F5.9 — Calendários / Loaded / Desktop | `541:2603` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2603) |
| 15 | F5.10 — Egressos / Loaded / Desktop | `540:1958` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1958) |
| 16 | F5.11 — Diplomas / Passo 1 / Desktop | `541:2723` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2723) |
| 17 | F5.12 — Autorizações imagem / Loaded / Desktop | `540:2078` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-2078) |
| 18 | F5.13 — Atendimentos / Novo / Desktop | `541:2847` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2847) |
| 19 | F5.14 — Eventos / Loaded / Desktop | `541:2960` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2960) |
| 20 | F5.15 — Evento operação / QR_SINGLE / Desktop | `541:3073` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-3073) |
| 21 | F5.16 — Importações / Passo 1 / Desktop | `541:3182` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-3182) |
| 22 | F5.17 — Exportações / Loaded / Desktop | `542:3693` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=542-3693) |
| 23 | F5.18 — Estatísticas / Loaded / Desktop | `542:4046` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=542-4046) |
| 24 | F5.19 — Tarefas internas / Loaded / Desktop | `542:4213` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=542-4213) |

---

## Relação F5 → Outros Fluxos (Reuso de Telas)

| Tela F5 | Tela Reutilizada | Contexto |
|---------|-----------------|---------|
| F5.3 — Nova solicitação interna | F1.8 (wizard) + campo extra `onBehalfOf` | Secretaria abre em nome do aluno |
| F5.4 — Deliberar (secretaria) | F3.4 (deliberar professor) | Mesmo frame, sem deep-link por e-mail |
| F5.15 — Operação evento | F3.2c (operação professor) | Paridade funcional, contexto secretaria |

---

## Capabilities

| Capability | Concedida a | Telas |
|-----------|-------------|-------|
| `dashboard.view_secretary` | Secretaria, Coordenação, Admin | F5.1 |
| `request.view_curso` | Secretaria | F5.2, F5.5 |
| `request.internal_open` | Secretaria | F5.3 |
| `request.deliberate` | Secretaria, Professores (por tipo) | F5.4 |
| `user.manage_students` | Secretaria, Admin | F5.6 |
| `course.manage` | Secretaria, Coordenação, Admin | F5.7 |
| `subject.manage` | Secretaria, Admin | F5.8 |
| `calendar.manage` | Secretaria, Coordenação, Admin | F5.9 |
| `alumni.list` | Secretaria, Coordenação | F5.10 |
| `diploma.register` | Secretaria | F5.11 |
| `image_authorization.review` | Secretaria | F5.12 |
| `service_record.create` | Secretaria | F5.13 |
| `event.manage` | Secretaria, Professores, Admin | F5.14 |
| `event.host` | Secretaria, Professores | F5.15 |
| `import.run` | Secretaria, Admin | F5.16 |
| `export.run` | Secretaria, Coordenação, Admin | F5.17 |
| `report.view_secretary` | Secretaria, Coordenação, Admin | F5.18 |
| `task.manage` | Secretaria | F5.19 |

---

## Referências Globais

- Análise arquitetural: `foundationDocs/analysis/analise_arquitetural_secretariaonline2.md`
- Fluxos por perfil (F5): `foundationDocs/analysis/fluxos_por_perfil.md` §6
- Endpoints canônicos (eventos/presença): `foundationDocs/analysis/endpoints_canonicos_presenca_eventos_v4.md`
- Telas inventário: `foundationDocs/analysis/telas.md`
- Figma página F5: [Telas / F5 — Secretaria](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-447)
