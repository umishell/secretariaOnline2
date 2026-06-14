# US-F5-012 — Tarefas Internas da Secretaria

| Campo | Valor |
|-------|-------|
| **ID** | US-F5-012 |
| **Épico** | SECR-TAREFAS |
| **Telas** | F5.19 — Tarefas Internas |
| **Rota** | `/secretaria/tarefas` |
| **Prioridade** | **P3 (opcional MVP)** |
| **Capability** | `task.manage` |
| **APIs** | `/tasks` CRUD |
| **Frames Figma** | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=542-4213) |

> ⚠️ **Esta história é de prioridade P3 e pode ser excluída do MVP.** Sua implementação é controlada por feature flag (`tasks.enabled`). O módulo não deve bloquear nenhum outro fluxo de F5.

---

## História de Usuário

> **Como** secretária acadêmica,  
> **quero** gerenciar uma lista de tarefas internas no estilo kanban (pendente / concluída),  
> **para que** eu possa organizar afazeres do dia a dia da secretaria sem recorrer a ferramentas externas.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F5-012-01 | O módulo de tarefas só é renderizado se a feature flag `tasks.enabled` estiver ativa. Caso contrário, a rota `/secretaria/tarefas` retorna 404. |
| RN-F5-012-02 | Somente usuários com capability `task.manage` acessam esta tela. |
| RN-F5-012-03 | Cada tarefa tem: título (obrigatório, max 200 chars), descrição (opcional), data de vencimento (opcional), responsável (usuário com `task.manage` no mesmo curso), estado (`PENDENTE` / `CONCLUIDA`). |
| RN-F5-012-04 | O layout apresenta **2 colunas**: "Pendentes" e "Concluídas". Cada coluna é uma lista de cards arrastáveis (`DS/Card`). |
| RN-F5-012-05 | Arrastar um card de "Pendentes" para "Concluídas" — ou vice-versa — atualiza o estado da tarefa via `PATCH /tasks/:id`. |
| RN-F5-012-06 | Como alternativa ao arrastar (acessibilidade), cada card tem botões "Concluir" / "Reabrir" para usuários que não usam mouse. |
| RN-F5-012-07 | Tarefas com data de vencimento ultrapassada exibem a data em `status/danger`. |
| RN-F5-012-08 | As tarefas são exclusivas do contexto da secretaria; alunos, professores e comissões não têm visibilidade sobre elas. |

---

## Critérios de Aceitação

### CA-F5-012-01 — Feature flag desativada

```gherkin
Dado que a feature flag tasks.enabled está desativada
Quando a secretária tenta acessar /secretaria/tarefas
Então o sistema retorna 404 ou redireciona para o dashboard
E o item de menu "Tarefas" não é exibido na navegação
```

### CA-F5-012-02 — Criar nova tarefa

```gherkin
Dado que tasks.enabled está ativa e a secretária acessa /secretaria/tarefas
Quando ela clica em "Nova tarefa"
E preenche título "Enviar memorando SCA" com vencimento em 2 dias
E salva
Então a API recebe POST /tasks
E o card aparece na coluna "Pendentes"
```

### CA-F5-012-03 — Mover para concluída via drag-and-drop

```gherkin
Dado que existe um card "Enviar memorando SCA" em Pendentes
Quando a secretária arrasta o card para a coluna Concluídas
Então a API recebe PATCH /tasks/:id com estado CONCLUIDA
E o card aparece na coluna Concluídas
```

### CA-F5-012-04 — Alternativa por teclado (acessibilidade)

```gherkin
Dado que um card está em Pendentes
Quando a secretária navega até o botão "Concluir" via Tab e pressiona Enter
Então o estado da tarefa é atualizado para CONCLUIDA
E o card move para a coluna Concluídas
```

### CA-F5-012-05 — Vencimento ultrapassado

```gherkin
Dado que uma tarefa tem data de vencimento ontem
Quando o kanban é exibido
Então a data de vencimento aparece em vermelho (status/danger) no card
```

---

## Componentes de UI

- `DS/Card` (cards arrastáveis no kanban)
- `DS/Modal` (nova tarefa / editar)
- `DS/Badge` (estado da tarefa)
- `DS/Button` ("Nova tarefa", "Concluir", "Reabrir")
- Kanban 2 colunas (Pendentes | Concluídas)

---

## Contrato de API

```
GET /tasks?estado=PENDENTE|CONCLUIDA
POST /tasks
Body: { "titulo", "descricao", "vencimento", "responsavelId" }

PATCH /tasks/:id
Body: { "estado": "PENDENTE|CONCLUIDA" }

DELETE /tasks/:id  // somente tarefas PENDENTE
```

---

## Fora de Escopo

- Tarefas compartilhadas com professores ou coordenadores
- Notificações de vencimento (Outbox não implementado para tarefas no MVP)
- Subtarefas ou checklists internos

---

## Definition of Done

- [ ] Feature flag `tasks.enabled` controla a visibilidade da rota e item de menu
- [ ] CRUD de tarefas com kanban 2 colunas
- [ ] Drag-and-drop funcional entre colunas
- [ ] Alternativa por teclado (botões Concluir/Reabrir)
- [ ] Vencimento ultrapassado destacado em `status/danger`
- [ ] Testes: flag desativada, criar/mover tarefa, teclado

---

## Referências

- Frame principal: [F5.19 Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=542-4213)
- Spec da tela: `telasFigma/telas5/F5.19-secretaria-tarefas.md`
