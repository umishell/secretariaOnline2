# F6 — Coordenação: Índice de Histórias de Usuário

> **Perfil-alvo:** Coordenador de Curso  
> **Princípio arquitetural:** Coordenação **é** Secretaria com capabilities adicionais — o perfil COORDENADOR herda todas as capabilities da secretaria e recebe as exclusivas listadas abaixo. Não há shell ou layout dedicado exclusivo; usa `AppLayout` com seção nav ampliada.  
> **Fase Figma:** `Telas / F6 — Coordenação` · [node 681:447](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=681-447)  
> **Sprint-alvo MVP:** Sprint 4–5  
> **Telas próprias:** F6.1 – F6.2 (2 telas exclusivas)  
> **Tela delegada:** F6.3 — Gerir Comissões usa `/admin/perfis` (ver nota abaixo)

---

## Épicos

| ID Épico | Nome | Escopo |
|----------|------|--------|
| COORD-CONFIG | Configuração de curso | Parâmetros curriculares: horas formativas, calendário, banca TCC |
| COORD-RELATORIOS | Relatórios analíticos | Séries históricas, evasão, comparativos, carga de deliberadores |
| COORD-COMISSOES | Gestão de comissões (delegado) | Adicionar/remover membros CAAF/COE via `/admin/perfis` |

---

## Histórias de Usuário

| ID | Título | Épico | Telas Cobertas | Prioridade | Frames Figma |
|----|--------|-------|----------------|------------|--------------|
| [US-F6-001](./US-F6-001-CONFIGURAR-CURSO.md) | Configurar Parâmetros do Curso | COORD-CONFIG | F6.1 | P2 | [Default](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=685-447) |
| [US-F6-002](./US-F6-002-RELATORIOS.md) | Relatórios Analíticos de Coordenação | COORD-RELATORIOS | F6.2 | P2 | [Default](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=718-5166) · [Loading](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=721-1209) |

> **F6.3 — Gerir Comissões (delegado):** O coordenador acessa a tela `/admin/perfis` com capability `commission.manage` para adicionar/remover membros das comissões CAAF e COE. Essa tela pertence ao fluxo F7 (Admin). Não há história de usuário exclusiva em F6; a rastreabilidade está em US-F7-002 (Admin Perfis).

---

## Mapa de Frames Figma (F6)

| # | Frame Figma | node-id | Link |
|---|-------------|---------|------|
| 1 | F6.1 — Configurar curso / Default / Desktop | `685:447` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=685-447) |
| 2 | F6.2 — Relatórios coordenação / Default / Desktop | `718:5166` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=718-5166) |
| 3 | F6.2 — Relatórios coordenação / Loading / Desktop | `721:1209` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=721-1209) |

---

## Capabilities Exclusivas do Coordenador

| Capability | Descrição | Telas F6 |
|-----------|-----------|----------|
| `course.config` | Editar parâmetros curriculares de um curso | F6.1 |
| `report.view_coordinator` | Visualizar relatórios analíticos de coordenação | F6.2 |
| `commission.manage` | Adicionar/remover membros CAAF e COE | F6.3 (delegado a F7) |

> Além destas, o coordenador herda: `dashboard.view_secretary`, `request.view_curso`, `request.deliberate`, `course.manage`, `subject.manage`, `calendar.manage`, `alumni.list`, `diploma.register`, `event.manage`, `event.host`, `export.run`, `report.view_secretary`.

---

## Relação F6 → Outros Fluxos

| Funcionalidade F6 | Tela Reutilizada | Contexto |
|------------------|-----------------|---------|
| Fila de solicitações | F5.2 (Fila Secretaria) | Com escopo coordenador |
| Deliberar solicitação | F5.4 / F3.4 | Mesmo frame, sem duplicação |
| Gestão de eventos | F5.14 / F5.15 | Escopo todos os cursos |
| Gerir membros comissão | F7 — `/admin/perfis` | Delegado ao Admin |
| F6.2 — Relatórios | Derivado de F5.18 | Filtros + charts adicionais |

---

## Referências Globais

- Análise arquitetural (F6): `foundationDocs/analysis/analise_arquitetural_secretariaonline2.md`
- Fluxos por perfil (F6): `foundationDocs/analysis/fluxos_por_perfil.md` §7
- Telas inventário: `foundationDocs/analysis/telas.md`
- Figma página F6: [Telas / F6 — Coordenação](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=681-447)
- Estatísticas Secretaria (base): US-F5-011
