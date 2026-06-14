# US-F1-004 — Visualizar e Gerenciar Comunicações Recebidas

| Campo | Valor |
|-------|-------|
| **ID** | US-F1-004 |
| **Épico** | ALUNO-COMUNICACAO |
| **Tela** | F1.6 — `/comunicacao` |
| **Prioridade** | P2 |
| **Plataforma** | Web + Mobile |
| **Capability** | `communication.read` |
| **API primária** | `GET /communications`, `POST /communications/:id/read` |
| **Frames Figma** | [Telas / F1 — Aluno](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=48-339) |
| **Spec de tela** | `telasFigma/telas1/F1.6-comunicacao.md` |

---

## 1. História de Usuário

> **Como** aluno autenticado,  
> **Quero** ver todas as comunicações recebidas (avisos institucionais, mensagens da turma e inbox de ações) em um hub unificado com filtros,  
> **Para** não perder comunicados importantes e agir quando uma mensagem requer minha atenção.

---

## 2. Regras de Negócio

| ID | Regra |
|----|-------|
| **RN-F1.6-01** | As comunicações são agrupadas em tabs: **Todos**, **Institucional**, **Turma**, **Inbox** (requer ação). Cada tab exibe badge com contagem de não lidos. |
| **RN-F1.6-02** | A tab **Inbox** exibe apenas comunicações com CTA pendente (ex.: ciência, resposta obrigatória). O CTA é pulsante para chamar atenção. |
| **RN-F1.6-03** | Uma mensagem é marcada como lida ao ser clicada, desde que `_links.marcar-lido` esteja presente na resposta. A marcação é feita via `POST /communications/:id/read`. |
| **RN-F1.6-04** | O filtro "lido/não lido" combinado com tipo e curso é aplicado no backend (query params). O frontend não filtra localmente. |
| **RN-F1.6-05** | A entrega de comunicações ao aluno é assíncrona via Outbox pattern: secretaria publica → `comunicacao.published` → dispatcher cria `communication_delivery` por destinatário → push/email/in-app. |
| **RN-F1.6-06** | O badge de contagem de não lidos no topbar do `AppLayout` é atualizado via polling de 60s ou via push notification. |

---

## 3. Critérios de Aceitação

### CA-01 — Listagem de comunicações

```gherkin
Dado que o aluno está em /comunicacao
Quando a página carrega
Então exibe as tabs: Todos | Institucional | Turma | Inbox (com badge de contagem)
  E a tab "Todos" está selecionada por padrão
  E lista CommunicationRow para cada comunicação: ícone de tipo, título, data, Badge prioridade, unread dot para não lidas
```

### CA-02 — Marcar como lido

```gherkin
Dado que o aluno vê uma comunicação com unread dot
Quando clica na comunicação para expandir ou navegar ao detalhe
Então o sistema verifica se _links.marcar-lido existe
  E realiza POST /communications/:id/read
  E o unread dot desaparece
  E o badge de contagem do topbar decrementa
```

### CA-03 — Tab Inbox com CTA pulsante

```gherkin
Dado que existe uma comunicação que requer ação do aluno
Quando o aluno acessa a tab Inbox
Então vê o item com CTA visualmente destacado (pulsante/animado)
  E ao clicar no CTA é direcionado para a ação correspondente (ex.: dar ciência de atendimento)
```

### CA-04 — Filtros

```gherkin
Dado que o aluno está em /comunicacao
Quando aplica filtro "não lido" + tipo "Institucional"
Então o sistema realiza GET /communications?lido=false&tipo=INSTITUCIONAL
  E exibe apenas as comunicações que correspondem ao filtro
  E se não houver resultados exibe DS/EmptyState: "Nenhuma comunicação encontrada."
```

### CA-05 — Tabs scrolláveis no mobile

```gherkin
Dado que o aluno acessa /comunicacao em viewport 375px
Então as tabs são scrolláveis horizontalmente sem quebrar layout
  E cada tab permanece interativa com área de toque ≥ 44px
```

---

## 4. Componentes de UI (Design System)

| Componente | Uso |
|------------|-----|
| `DS/Tabs` | Agrupamento Todos / Institucional / Turma / Inbox |
| `DS/Badge` | Prioridade da comunicação + contagem não lidos |
| `CommunicationRow` | Item de lista com variante unread |
| `DS/EmptyState` | Sem comunicações ou filtro vazio |

---

## 5. Fora de escopo

- Resposta direta a comunicações pelo aluno — unidirecional no MVP
- Arquivamento de mensagens — não previsto

---

## 6. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas1/F1.6-comunicacao.md` |
| Fluxo F1.9 | `foundationDocs/analysis/fluxos_por_perfil.md` §2 F1.9 |
| Página Figma F1 | [Telas / F1 — Aluno](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=48-339) |
