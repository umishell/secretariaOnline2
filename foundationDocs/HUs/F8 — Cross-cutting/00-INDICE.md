# F8 — Cross-cutting: Índice de Histórias de Usuário

> **Perfil-alvo:** Todos os usuários autenticados (Aluno, Egresso, Professor, Secretaria, Coordenação, Admin)  
> **Característica:** Funcionalidades transversais disponíveis em qualquer contexto do sistema, independente do perfil ativo.  
> **Fase Figma:** `Telas / F8 — Cross-cutting` · [node 758:339](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=758-339)  
> **Sprint-alvo MVP:** Sprint 2 (F8.1) + Sprint 5 (F8.2)  
> **Telas cobertas:** F8.1 – F8.2 (2 telas, 10 frames)  
> **Plataforma:** Web (Desktop + Mobile) + Mobile Nativo

---

## Épicos

| ID Épico | Nome | Escopo |
|----------|------|--------|
| CROSS-BUSCA | Busca Global | Command palette Ctrl+K, fan-out por entidade, escopo por capability |
| CROSS-SUPORTE | Suporte & FAQ | Base de conhecimento com Accordion, abertura de tickets |

---

## Histórias de Usuário

| ID | Título | Épico | Telas | Prioridade | Frames Figma |
|----|--------|-------|-------|------------|--------------|
| [US-F8-001](./US-F8-001-BUSCA-GLOBAL.md) | Busca Global (Command Palette) | CROSS-BUSCA | F8.1 | P2 | [Empty Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=761-496) · [Loading Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=762-599) · [Results Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=764-705) · [Empty Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=774-1060) · [Loading Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=774-1077) · [Results Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=765-814) |
| [US-F8-002](./US-F8-002-SUPORTE-FAQ.md) | Suporte e FAQ | CROSS-SUPORTE | F8.2 | P2 | [Default Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=768-824) · [Submit Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=769-931) · [Default Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=775-1074) · [Submit Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=775-1290) |

---

## Mapa de Frames Figma (F8)

| # | Frame Figma | node-id | Link |
|---|-------------|---------|------|
| 1 | F8.1 — Busca global / Empty / Desktop | `761:496` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=761-496) |
| 2 | F8.1 — Busca global / Loading / Desktop | `762:599` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=762-599) |
| 3 | F8.1 — Busca global / Results / Desktop | `764:705` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=764-705) |
| 4 | F8.1 — Busca global / Empty / Mobile | `774:1060` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=774-1060) |
| 5 | F8.1 — Busca global / Loading / Mobile | `774:1077` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=774-1077) |
| 6 | F8.1 — Busca global / Results / Mobile | `765:814` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=765-814) |
| 7 | F8.2 — Suporte / Default / Desktop | `768:824` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=768-824) |
| 8 | F8.2 — Suporte / Submit / Desktop | `769:931` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=769-931) |
| 9 | F8.2 — Suporte / Default / Mobile | `775:1074` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=775-1074) |
| 10 | F8.2 — Suporte / Submit / Mobile | `775:1290` | [↗](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=775-1290) |

---

## Nota Arquitetural — Escopo da Busca por Capability

A busca global **não é hardcoded por perfil**. A anotação Figma confirma:  
> `"GET /search?q= · Resultados filtrados por capability (não hardcodar por perfil)"`

O backend faz fan-out paralelo e filtra cada resultado de acordo com as capabilities do token JWT do usuário — o mesmo resultado aparece ou não conforme o escopo do solicitante.

---

## Referências Globais

- Fluxos transversais: `foundationDocs/analysis/fluxos_por_perfil.md` §9
- Telas inventário: `foundationDocs/analysis/telas.md`
- Figma página F8: [Telas / F8 — Cross-cutting](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=758-339)
