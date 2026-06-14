# Histórias de Usuário — Fase F1 (Aluno)

**Projeto:** SecretariaOnline2 — UFPR SEPT  
**Versão:** 1.0  
**Data:** 2026-06-14  
**Autor:** TCC — gerado a partir de `telasFigma/telas1/`, `foundationDocs/analysis/telas.md` e `fluxos_por_perfil.md`

---

## Visão geral da fase

O fluxo F1 cobre **todas as funcionalidades do perfil Aluno** após autenticação. Utiliza `AppLayout` (com sidebar e topbar). O backend serve dados via **BFF** (`GET /bff/dashboard/aluno`) e endpoints de cada módulo. O controle de autorização é baseado em **HATEOAS `_links`** — a UI nunca exibe ações que a API não retornou.

---

## Épicos

| Épico | Escopo | Telas |
|-------|--------|-------|
| `ALUNO-DASH` | Dashboard e visão geral | F1.1 |
| `ALUNO-ONBOARD` | Primeiro acesso obrigatório | F1.2 |
| `ALUNO-PERFIL` | Dados pessoais, segurança e notificações | F1.3, F1.4, F1.5 |
| `ALUNO-COMUNICACAO` | Hub unificado de comunicações | F1.6 |
| `ALUNO-SOLICITACOES` | CRUD de solicitações (wizard DRY) | F1.7, F1.8, F1.9 |
| `ALUNO-FORMATIVAS` | Atividades formativas e comprovantes | F1.10, F1.11, F1.12 |
| `ALUNO-ESTAGIO` | Estágios e documentos | F1.13, F1.14 |
| `ALUNO-TCC` | Trabalho de conclusão de curso | F1.15, F1.16 |
| `ALUNO-PRESENCA` | Eventos formativos e confirmação de presença | F1.17, F1.18 |
| `ALUNO-CERTIFICADOS` | Visualização e download de certificados | F1.19 |
| `ALUNO-ATENDIMENTOS` | Atendimentos da secretaria e ciência | F1.20 |

---

## Histórias desta fase

| ID | Épico | Telas | Título curto | Prioridade | Arquivo |
|----|-------|-------|-------------|------------|---------|
| US-F1-001 | ALUNO-DASH | F1.1 | Dashboard do aluno (visão unificada) | **P0 — MVP v1** | [US-F1-001-DASHBOARD.md](./US-F1-001-DASHBOARD.md) |
| US-F1-002 | ALUNO-ONBOARD | F1.2 | Primeiro acesso: senha + LGPD | **P0 — MVP v1** | [US-F1-002-PRIMEIRO-ACESSO.md](./US-F1-002-PRIMEIRO-ACESSO.md) |
| US-F1-003 | ALUNO-PERFIL | F1.3, F1.4, F1.5 | Gerenciar perfil, segurança e notificações | P2 | [US-F1-003-PERFIL.md](./US-F1-003-PERFIL.md) |
| US-F1-004 | ALUNO-COMUNICACAO | F1.6 | Visualizar e gerenciar comunicações recebidas | P2 | [US-F1-004-COMUNICACAO.md](./US-F1-004-COMUNICACAO.md) |
| US-F1-005 | ALUNO-SOLICITACOES | F1.7, F1.8, F1.9 | Abrir, acompanhar e detalhar solicitações | P1 (wizard) / P2 | [US-F1-005-SOLICITACOES.md](./US-F1-005-SOLICITACOES.md) |
| US-F1-006 | ALUNO-FORMATIVAS | F1.10, F1.11, F1.12 | Submeter e acompanhar atividades formativas | P2 | [US-F1-006-FORMATIVAS.md](./US-F1-006-FORMATIVAS.md) |
| US-F1-007 | ALUNO-ESTAGIO | F1.13, F1.14 | Acompanhar estágios e enviar documentos | P2 | [US-F1-007-ESTAGIO.md](./US-F1-007-ESTAGIO.md) |
| US-F1-008 | ALUNO-TCC | F1.15, F1.16 | Acompanhar TCC e enviar versão final | P2 | [US-F1-008-TCC.md](./US-F1-008-TCC.md) |
| US-F1-009 | ALUNO-PRESENCA | F1.17, F1.18 | Consultar eventos e confirmar presença | P2 | [US-F1-009-PRESENCA.md](./US-F1-009-PRESENCA.md) |
| US-F1-010 | ALUNO-CERTIFICADOS | F1.19 | Visualizar e baixar certificados emitidos | P2 | [US-F1-010-CERTIFICADOS.md](./US-F1-010-CERTIFICADOS.md) |
| US-F1-011 | ALUNO-ATENDIMENTOS | F1.20 | Consultar atendimentos e dar ciência | P2 | [US-F1-011-ATENDIMENTOS.md](./US-F1-011-ATENDIMENTOS.md) |

---

## Referências globais

| Recurso | Localização |
|---------|------------|
| Specs de tela (F1) | `telasFigma/telas1/F1.x-*.md` |
| Fluxos do aluno | `foundationDocs/analysis/fluxos_por_perfil.md` §2 |
| Mapa de rotas | `foundationDocs/analysis/telas.md` §3 |
| MVP Walking Skeleton | `foundationDocs/analysis/mvp_walking_skeleton_aluno.md` |
| Frames Figma | [Telas / F1 — Aluno](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=48-339) |
| Convenções de tela | `telasFigma/00-CONVENCOES.md` |

---

## Critério de "Pronto" global (DoD) para F1

- [ ] Frames Figma aprovados por épico (estados: Loading, Filled, Empty, Error)
- [ ] Capability (`authority`) definida no Spring Security para cada endpoint
- [ ] Ações renderizadas **somente** se `_links` HATEOAS correspondente existir na resposta
- [ ] Cobertura de testes: Use Cases ≥ 80%, domínio ≥ 85%
- [ ] Contrato OpenAPI publicado antes do desenvolvimento frontend
- [ ] Tokens CSS usados em 100% dos valores visuais (sem hex/px hardcoded)
- [ ] Responsividade validada em 375px (mobile) e 1440px (desktop)
- [ ] WCAG 2.1 AA: contraste, foco, aria-live em todas as telas
