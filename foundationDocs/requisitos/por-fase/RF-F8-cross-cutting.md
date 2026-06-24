# Requisitos Funcionais — Fase F8 (Cross-cutting)

**Projeto:** SecretariaOnline2 — UFPR SEPT  
**Versão:** 1.0  
**Data:** 2026-06-23  
**Gerado a partir de:** US-F8-001, US-F8-002; `fluxos_por_perfil.md` §9; `telas.md` §10; `legenda_siglas_casos_de_uso_por_ator.md`; `HUs/F8 — Cross-cutting/00-INDICE.md`  
**Total RF neste arquivo:** 2 (2 HUs → 2 capacidades coesas)

> **Princípio arquitetural:** Funcionalidades transversais disponíveis a **qualquer usuário autenticado**, independente do perfil ativo. A busca filtra resultados por **capabilities do JWT** (FGAC), não por perfil hardcoded.

---

## Resumo da fase

| RF | Nome | HU | UC | Tela | Prioridade |
|----|------|----|----|------|:----------:|
| RF-F8-001 | Busca global (Command Palette) | US-F8-001 | UC-ADM-10 | F8.1 `/buscar?q=` (modal overlay) | P2 |
| RF-F8-002 | Suporte e FAQ com abertura de ticket | US-F8-002 | UC-ADM-11 | F8.2 `/suporte` | P2 |

---

### RF-F8-001 — Busca global (Command Palette)

| Campo | Valor |
|-------|-------|
| **ID** | RF-F8-001 |
| **Nome** | Busca global (Command Palette) |
| **Prioridade** | P2 |
| **Ator(es)** | Todos autenticados (A2–A9) |
| **Módulo** | F8 — Cross-cutting |
| **Rastreio HU** | US-F8-001 |
| **Rastreio UC** | UC-ADM-10 |
| **Tela** | F8.1 `/buscar?q=` — modal (desktop) ou tela cheia (mobile); não navega de rota |
| **API** | `GET /search?q=` |
| **Legado** | — (nova — lacuna L15 corrigida) |

**Descrição:** O sistema deve permitir que qualquer usuário autenticado abra uma paleta de busca (`Ctrl+K` / `⌘K` ou clique na topbar), digite um termo e encontre alunos, solicitações, eventos ou usuários com resultados filtrados pelas capabilities do token JWT, navegando diretamente ao item selecionado.

**Pré-condições:** Sessão JWT válida.

**Pós-condições:** Item selecionado aberto na rota de detalhe correspondente; ou paleta fechada sem navegação (Esc).

**Critérios de aceitação:**

*Ativação e layout*
1. Atalho `Ctrl+K` / `⌘K` ou clique em `DS/Input/Search` (topbar) abre paleta em qualquer tela autenticada (RN-F8-001-01).
2. Desktop: modal overlay 640px com scrim; input com foco automático (RN-F8-001-07).
3. Mobile (375px): tela cheia com input expandido e botão "Cancelar" — não modal (RN-F8-001-08, CA-F8-001-07).

*Consulta e resultados*
4. Debounce 200 ms; mínimo 2 caracteres para disparar API (RN-F8-001-03).
5. `GET /search?q=` com fan-out paralelo: `students`, `requests`, `events`, `users` — máx. 5 por tipo (total 20) (RN-F8-001-04).
6. Resultados agrupados por tipo com ícone, título e subtítulo (GRR, protocolo, etc.) (RN-F8-001-05).
7. Escopo por capability do JWT — não hardcode de perfil; aluno sem `user.manage_all` não vê índice `users` (RN-F8-001-02, CA-F8-001-04).
8. Queries SQL com índices trigram (`pg_trgm`); sem expor dados inacessíveis nas telas respectivas (RN-F8-001-11).

*Estados e interação*
9. Empty: sem query ou &lt; 2 chars — "Busque protocolos, GRR, alunos e eventos." (RN-F8-001-09).
10. Loading: skeleton rows; timeout 5 s → mensagem de erro (RN-F8-001-10).
11. Sem resultados: Empty com "Nenhum resultado encontrado para '{termo}'" (CA-F8-001-08).
12. Teclado: `↑`/`↓` seleciona; `Enter` abre item e fecha paleta; `Esc` fecha sem navegar; focus trap com retorno de foco (RN-F8-001-06, CA-F8-001-05, CA-F8-001-06).
13. Dicas de atalhos no rodapé (`Main/KeyboardHints`) (RN-F8-001-06).

**Regras de negócio relacionadas:** RN-F8-001-01 a RN-F8-001-11

**Dependências:** RF-TR-005, RNF-DES-02, RNF-UX-02, RNF-UX-04

---

### RF-F8-002 — Suporte e FAQ com abertura de ticket

| Campo | Valor |
|-------|-------|
| **ID** | RF-F8-002 |
| **Nome** | Suporte e FAQ com abertura de ticket |
| **Prioridade** | P2 |
| **Ator(es)** | Todos autenticados (A2–A9) |
| **Módulo** | F8 — Cross-cutting |
| **Rastreio HU** | US-F8-002 |
| **Rastreio UC** | UC-ADM-11 |
| **Tela** | F8.2 `/suporte` |
| **API** | `GET /support/faq`; `POST /support/tickets` |
| **Legado** | — |

**Descrição:** O sistema deve permitir que qualquer usuário autenticado consulte FAQ dinâmico em Accordion acessível e, se não encontrar resposta, abra ticket de suporte com protocolo gerado — preferencialmente via `RequestType=SUPORTE_TECNICO` (workflow engine DRY).

**Pré-condições:** Sessão ativa (capability implícita `logado`).

**Pós-condições:** Ticket registrado com número de protocolo; banner de sucesso exibido; formulário limpo.

**Critérios de aceitação:**

*FAQ*
1. Rota `/suporte` acessível a qualquer logado (RN-F8-002-01).
2. `GET /support/faq?perfil=ALUNO` (ou perfil do token) retorna perguntas ordenadas por relevância (RN-F8-002-04, RN-F8-002-12).
3. `DS/Accordion` com ARIA: `aria-expanded`, `role="region"`, `aria-labelledby`; Tab + Enter/Space (RN-F8-002-05, CA-F8-002-02).
4. Desktop: split FAQ (556px) + formulário (556px); Mobile: coluna única FAQ → formulário (RN-F8-002-02, RN-F8-002-03, CA-F8-002-06).

*Formulário de ticket*
5. Campos obrigatórios: Assunto (máx. 200 chars), Mensagem (máx. 2000 chars); validação inline (RN-F8-002-06, CA-F8-002-04).
6. `POST /support/tickets` → 201 com `numero` (ex.: `SUP-2025-042`); estado Submit com `DS/AlertBanner` success; formulário limpo, sem navegação (RN-F8-002-09, RN-F8-002-10, CA-F8-002-03).
7. Implementação MVP: `RequestType=SUPORTE_TECNICO` via workflow engine; fallback `support_thread` simples se tipo não configurado (RN-F8-002-08).
8. Link fallback `mailto:secretaria@ufpr.br` abaixo do botão Enviar (RN-F8-002-07, CA-F8-002-07).

*Rate limiting*
9. Máx. 3 tickets/usuário/hora (Bucket4j); HTTP 429 com mensagem "Tente em X min." (RN-F8-002-11, CA-F8-002-05).

**Regras de negócio relacionadas:** RN-F8-002-01 a RN-F8-002-12

**Dependências:** RF-TR-001, RF-TR-002, RF-F5-007, RNF-SEC-04, RNF-UX-02

---

## Fora de escopo (fase F8)

- Busca em conteúdo de anexos/documentos
- Busca fora do contexto autenticado
- Histórico de buscas recentes
- Histórico de tickets do usuário
- Chat ao vivo com secretaria
- Categorização de tickets pelo usuário
- FAQ editável pela UI F8 (gerenciado via admin — fora desta fase)
