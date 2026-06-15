# F7 — Admin / Plataforma: Índice de Histórias de Usuário

> **Perfil-alvo:** Administrador da Plataforma  
> **Shell:** `Shell/AdminLayout` (AppLayout + seção nav "Administração" + breadcrumb reforçado)  
> **Fase Figma:** `Telas / F7 — Admin` · [node 727:447](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-447)  
> **Sprint-alvo MVP:** Sprint 5–6  
> **Telas cobertas:** F7.1 – F7.9 (9 telas)  
> **Largura mínima:** 1440px (obrigatória para editores F7.4 e F7.5)

---

## Épicos

| ID Épico | Nome | Escopo |
|----------|------|--------|
| ADMIN-IAM | Gestão de Identidade e Acesso | Usuários, perfis (roles), authorities, reset de senha |
| ADMIN-WORKFLOW | Motor de Tipos de Solicitação | Editor JSON Schema + workflow state machine (ADR-003) |
| ADMIN-TEMPLATES | Templates de Comunicação | CRUD Markdown + placeholders + versionamento |
| ADMIN-JOBS | Observabilidade Outbox & Jobs | Outbox events, scheduled jobs, retry, DEAD letter |
| ADMIN-AUDIT | Trilha de Auditoria | Pesquisa audit_log, diff JSON antes/depois |
| ADMIN-OPS | Saúde do Sistema | KPIs latência, Outbox, 5xx + link Grafana (P3) |

---

## Histórias de Usuário

| ID | Título | Épico | Telas | Prioridade | Frames Figma |
|----|--------|-------|-------|------------|--------------|
| [US-F7-001](./US-F7-001-IAM-USUARIOS.md) | Gestão de Usuários e Reset de Senha | ADMIN-IAM | F7.1, F7.8 | P2 | [Usuários](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-5180) · [Reset Modal](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6862) |
| [US-F7-002](./US-F7-002-IAM-PERFIS-AUTORIDADES.md) | Perfis (Roles) e Matriz de Autoridades | ADMIN-IAM | F7.2, F7.3 | P2 | [Perfis](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-5396) · [Autoridades](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-5612) |
| [US-F7-003](./US-F7-003-WORKFLOW-ENGINE.md) | Editor de Tipos de Solicitação | ADMIN-WORKFLOW | F7.4 | P2 | [Editor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=730-1228) |
| [US-F7-004](./US-F7-004-TEMPLATES-COMUNICACAO.md) | Templates de Comunicação | ADMIN-TEMPLATES | F7.5 | P2 | [Editor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6151) |
| [US-F7-005](./US-F7-005-JOBS-OUTBOX.md) | Observabilidade Outbox e Jobs Agendados | ADMIN-JOBS | F7.6 | P2 | [FAILED tab](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6384) |
| [US-F7-006](./US-F7-006-AUDIT-LOG.md) | Trilha de Auditoria | ADMIN-AUDIT | F7.7 | P2 | [Diff Drawer](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6615) |
| [US-F7-007](./US-F7-007-SAUDE-SISTEMA.md) | Saúde do Sistema | ADMIN-OPS | F7.9 | **P3** | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-7123) |

---

## Mapa de Frames Figma (F7)

| # | Frame Figma | node-id | Link |
|---|-------------|---------|------|
| 1 | F7.1 — Usuários / Loaded / Desktop | `727:5180` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-5180) |
| 2 | F7.2 — Perfis / Loaded / Desktop | `727:5396` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-5396) |
| 3 | F7.3 — Autoridades / Loaded / Desktop | `727:5612` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-5612) |
| 4 | F7.4 — Tipos solicitação / Editor / Desktop | `730:1228` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=730-1228) |
| 5 | F7.5 — Templates comunicação / Editor / Desktop | `731:6151` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6151) |
| 6 | F7.6 — Jobs Outbox / FAILED tab / Desktop | `731:6384` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6384) |
| 7 | F7.7 — Audit log / Diff drawer / Desktop | `731:6615` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6615) |
| 8 | F7.8 — Reset senha / Confirm modal / Desktop | `731:6862` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6862) |
| 9 | F7.9 — Saúde sistema / P3 extra-MVP / Desktop | `731:7123` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-7123) |

---

## Capabilities Exclusivas do Admin

| Capability | Telas |
|-----------|-------|
| `user.manage_all` | F7.1 |
| `user.reset_password` | F7.8 |
| `iam.manage_roles` | F7.2 |
| `iam.manage_authorities` | F7.3 |
| `request_type.manage` | F7.4 |
| `communication.manage_templates` | F7.5 |
| `system.observe` | F7.6 |
| `audit.read` | F7.7 |
| `system.admin` | F7.9 |

---

## Contexto Arquitetural (ADR-003 — Workflow Engine)

F7.4 é a tela **mais crítica** do módulo admin. Ela implementa o coração da estratégia DRY do sistema:

- **`form_schema`** (JSON Schema): define dinamicamente os campos de cada tipo de solicitação
- **`workflow_json`** (DSL state machine): define estados, transições, capabilities exigidas e guards
- **Versionamento atômico**: solicitações abertas mantêm a versão original; novas usam a versão corrente
- **Impacto**: adicionar um novo tipo de solicitação = inserir 1 registro, sem criar novos arquivos de código

---

## Referências Globais

- Análise arquitetural (F7): `foundationDocs/analysis/analise_arquitetural_secretariaonline2.md` §14 (ADR-003)
- Fluxos por perfil (F7): `foundationDocs/analysis/fluxos_por_perfil.md` §8
- Telas inventário: `foundationDocs/analysis/telas.md`
- Figma página F7: [Telas / F7 — Admin](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-447)
