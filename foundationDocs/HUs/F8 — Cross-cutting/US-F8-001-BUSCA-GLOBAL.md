# US-F8-001 — Busca Global (Command Palette)

| Campo | Valor |
|-------|-------|
| **ID** | US-F8-001 |
| **Épico** | CROSS-BUSCA |
| **Telas** | F8.1 — Busca Global |
| **Rota** | `/buscar?q=` (modal — não navega; abre sobre a tela atual) |
| **Prioridade** | P2 |
| **Capability** | Derivada do token JWT do usuário (sem capability fixa) |
| **API primária** | `GET /search?q=` |
| **Plataforma** | Web (Desktop + Mobile) + Mobile Nativo |
| **Frames Figma** | [Empty Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=761-496) · [Loading Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=762-599) · [Results Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=764-705) · [Empty Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=774-1060) · [Loading Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=774-1077) · [Results Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=765-814) |

---

## História de Usuário

> **Como** qualquer usuário autenticado,  
> **quero** abrir uma paleta de busca com `Ctrl+K` / `⌘K` e digitar um termo para encontrar alunos, solicitações, eventos ou usuários de forma rápida,  
> **para que** eu possa navegar diretamente ao item desejado sem precisar percorrer menus e filtros manualmente.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F8-001-01 | A busca é ativada por: (a) atalho `Ctrl+K` / `⌘K` em qualquer tela; (b) clique na `DS/Input/Search` na topbar (hotspot `Proto/SearchHotspot` presente em todos os frames da aplicação). |
| RN-F8-001-02 | **Escopo filtrado por capability — não por perfil hardcoded.** O backend executa fan-out paralelo nos índices: `students`, `requests`, `events`, `users`. Cada índice só retorna resultados que o token JWT do solicitante tem capability para visualizar. Anotação Figma: `"Resultados filtrados por capability (não hardcodar por perfil)"`. |
| RN-F8-001-03 | A consulta é disparada com debounce de 200 ms após a última tecla digitada. Mínimo de 2 caracteres para iniciar a busca. |
| RN-F8-001-04 | O backend retorna no máximo **5 resultados por tipo** (`students`: 5, `requests`: 5, `events`: 5, `users`: 5 — total máx. 20). Resultados adicionais são acessados pela rota de busca completa. |
| RN-F8-001-05 | Resultados são agrupados por tipo com ícone e rótulo de categoria: "Alunos", "Solicitações", "Eventos", "Usuários". Cada resultado exibe: título, subtítulo (ex.: GRR, número de protocolo) e ícone do tipo. |
| RN-F8-001-06 | Navegação pelos resultados: teclas `↑` / `↓`, `Enter` abre o item selecionado, `Esc` fecha a paleta sem navegar. Dica de atalhos exibida no rodapé do modal (`Main/KeyboardHints`). |
| RN-F8-001-07 | **Desktop:** modal overlay com `Overlay/scrim` (fundo semitransparente), largura máxima 640px, posicionado no centro superior da tela (y=302px conforme Figma). |
| RN-F8-001-08 | **Mobile:** a busca abre em **tela cheia** (não modal). Anotação Figma: `"Mobile: fullscreen (não modal)"`. Header fixo com botão "Cancelar" e `DS/Input/Search` expandido. Resultados em `DS/SearchResultGroup`. |
| RN-F8-001-09 | Estado **Empty** (sem query ou query < 2 chars): `DS/EmptyState` com texto "Busque protocolos, GRR, alunos e eventos." |
| RN-F8-001-10 | Estado **Loading**: skeleton rows (ícone 32×32 + bloco de texto 299×16) — visível enquanto a API responde, com timeout máximo de 5 s antes de exibir mensagem de erro. |
| RN-F8-001-11 | A busca não é indexada em tempo real — usa queries SQL otimizadas com índices trigram (`pg_trgm`) para nomes e GRR. Não expõe dados de entidades às quais o usuário não teria acesso nas respectivas telas. |

---

## Critérios de Aceitação

### CA-F8-001-01 — Abrir com atalho de teclado

```gherkin
Dado que o usuário está em qualquer tela autenticada do sistema
Quando pressiona Ctrl+K (ou ⌘K no macOS)
Então o DS/CommandPalette é exibido sobre a tela atual com scrim
E o input de busca recebe foco automaticamente
E o estado Empty é exibido
```

### CA-F8-001-02 — Busca com debounce e loading

```gherkin
Dado que o usuário digitou "joão" no input de busca
Quando passam 200 ms sem nova tecla
Então a API recebe GET /search?q=joão
E o estado Loading é exibido com skeleton rows durante a requisição
```

### CA-F8-001-03 — Exibição de resultados agrupados por tipo

```gherkin
Dado que a API retornou: 3 alunos, 2 solicitações, 1 evento para "joão"
Quando os resultados são renderizados
Então aparecem 3 seções: "Alunos" (3 itens), "Solicitações" (2 itens), "Eventos" (1 item)
E cada item exibe título, subtítulo e ícone do tipo
```

### CA-F8-001-04 — Escopo por capability

```gherkin
Dado que um aluno faz a busca "João"
Quando a API processa a requisição
Então o índice "users" não retorna outros usuários (aluno sem capability user.manage_all)
E o índice "students" retorna apenas o próprio perfil do aluno (se houver match)
E o índice "requests" retorna apenas as solicitações do próprio aluno
```

### CA-F8-001-05 — Navegação por teclado e abertura de item

```gherkin
Dado que os resultados estão exibidos
Quando o usuário pressiona ↓ duas vezes para selecionar o segundo resultado
E pressiona Enter
Então a paleta fecha
E o usuário é redirecionado para a tela de detalhe do item selecionado
```

### CA-F8-001-06 — Fechar com Esc

```gherkin
Dado que a paleta está aberta com resultados
Quando o usuário pressiona Esc
Então a paleta fecha sem navegar
E o foco retorna ao elemento que estava ativo antes da abertura
```

### CA-F8-001-07 — Mobile: tela cheia

```gherkin
Dado que o usuário está em um dispositivo móvel (375px)
Quando clica no input de busca na topbar
Então a busca abre em tela cheia (não modal) com o DS/Input/Search expandido
E o botão "Cancelar" aparece ao lado do input
Quando clica em "Cancelar"
Então retorna à tela anterior sem navegar
```

### CA-F8-001-08 — Sem resultados encontrados

```gherkin
Dado que o usuário digitou "xyzxyz123" e não há resultados
Quando a API retorna array vazio
Então o estado Empty é exibido com texto "Nenhum resultado encontrado para 'xyzxyz123'"
```

---

## Comportamento Responsivo

| Dispositivo | Comportamento | Notas Figma |
|-------------|--------------|-------------|
| Desktop (≥ 768px) | Modal overlay 640px centrado com scrim | Frames `761:496`, `762:599`, `764:705` |
| Mobile (375px) | Tela cheia com input expandido | `"Mobile: fullscreen (não modal)"` — Frames `774:1060`, `774:1077`, `765:814` |

---

## Componentes de UI

- `DS/CommandPalette` (componente principal — Desktop)
- `DS/Input/Search` (campo de busca — Mobile header)
- `DS/EmptyState` (estados sem query e sem resultados)
- `DS/Skeleton/row` (loading — ícone + bloco por linha)
- `DS/SearchResultGroup` (grupo de resultados — Mobile)
- `Overlay/scrim` (fundo semitransparente — Desktop)
- Keyboard hints (rodapé do modal)

---

## Contrato de API

```
GET /search?q=joão&limit=5
Authorization: Bearer <token>

Response 200:
{
  "alunos": [
    { "id": "...", "nome": "João Silva", "grr": "GRR20231234", "href": "/alunos/:id" }
  ],
  "solicitacoes": [
    { "id": "...", "numero": "SOL-2025-001", "tipo": "Aproveitamento", "href": "/solicitacoes/:id" }
  ],
  "eventos": [
    { "id": "...", "titulo": "Workshop João", "data": "2025-10-15", "href": "/eventos/:id" }
  ],
  "usuarios": []  // vazio para quem não tem capability user.manage_all
}
```

---

## Fora de Escopo

- Busca em conteúdo de documentos/anexos (apenas metadados)
- Busca fora do contexto autenticado
- Histórico de buscas recentes (possível iteração futura)
- Sugestões de autocompletar antes de 2 caracteres

---

## Definition of Done

- [ ] Atalho `Ctrl+K` / `⌘K` abre a paleta em qualquer tela
- [ ] Debounce de 200 ms antes de disparar a API
- [ ] Fan-out paralelo: alunos, solicitações, eventos, usuários (máx. 5 cada)
- [ ] Resultados filtrados por capabilities do token (sem hardcode de perfil)
- [ ] Navegação completa por teclado (↑/↓/Enter/Esc)
- [ ] Desktop modal + Mobile tela cheia
- [ ] Estados: Empty, Loading (skeleton), Results, Sem resultados
- [ ] Focus trap no modal com retorno de foco ao fechar
- [ ] Testes: escopo por capability (aluno não vê users), debounce, mobile fullscreen

---

## Referências

- Frame Empty Desktop: [F8.1 Empty](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=761-496)
- Frame Results Desktop: [F8.1 Results](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=764-705)
- Frame Results Mobile: [F8.1 Mobile Results](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=765-814)
- Fluxo F8.1 Busca global: `foundationDocs/analysis/fluxos_por_perfil.md` §9.1
