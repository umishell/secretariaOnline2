# US-F3-003 — Deliberar Solicitações (Fila + Deep-link por E-mail)


| Campo             | Valor                                                                                                           |
| ----------------- | --------------------------------------------------------------------------------------------------------------- |
| **ID**            | US-F3-003                                                                                                       |
| **Épico**         | PROF-SOLICITACOES                                                                                               |
| **Telas**         | F3.3 `/solicitacoes?to=me` · F3.4 `/solicitacoes/:id/deliberar`                                                 |
| **Prioridade**    | P2                                                                                                              |
| **Plataforma**    | Web + Mobile                                                                                                    |
| **Capability**    | `request.deliberate`                                                                                            |
| **API primária**  | `GET /requests?canDeliberate=true`, `POST /requests/{id}/transitions`                                           |
| **Frames Figma**  | **F3.3:** [Loaded/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=219-817) · [Empty/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=219-1025) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-17943) · [Loaded/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18065) · [Empty/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18190) · **F3.4:** [Ações/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=225-2090) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=257-21325) · [Ações/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=275-20969) |
| **Specs de tela** | `telasFigma/telas3/F3.3-solicitacoes-deliberar-fila.md` · `F3.4-solicitacoes-deliberar.md`                      |


---

## Histórias

### HU-A — Fila de deliberação (F3.3)

> **Como** professor com capability `request.deliberate`,  
> **Quero** ver todas as solicitações que aguardam minha decisão em uma fila organizada com filtros e indicadores de SLA,  
> **Para** priorizar as mais urgentes e garantir que nenhuma solicitação fique sem resposta dentro do prazo.

### HU-B — Deliberar via sistema ou deep-link de e-mail (F3.4)

> **Como** professor deliberante,  
> **Quero** deferir, indeferir, solicitar ajustes ou encaminhar uma solicitação a outro professor, informando um parecer fundamentado,  
> **Para** dar andamento formal ao pedido do aluno com registro imutável de auditoria.

---

## 2. Regras de Negócio

### Fila de deliberação (F3.3)


| ID             | Regra                                                                                                                                                                                               |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **RN-F3.3-01** | A lista exibe somente solicitações com `canDeliberate=true` para aquele professor (filtrada pelo backend com base no workflow e authority). O professor não vê solicitações de outros deliberantes. |
| **RN-F3.3-02** | Colunas: Número, Aluno (nome parcial), Tipo, Prazo, SLA. O prazo em vermelho indica breach (`prazo_em < now`).                                                                                      |
| **RN-F3.3-03** | Suporte a **ações em lote** quando o `RequestType.workflow_json` configura `batchDeliberate=true` (ex.: aprovação em lote de pedidos de cópia de documento).                                        |


### Deliberação individual (F3.4)


| ID             | Regra                                                                                                                                                                                                                                                                             |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **RN-F3.4-01** | O professor pode chegar à tela de deliberação por **dois caminhos**: (a) navegação pelo sistema a partir da fila (F3.3), ou (b) **deep-link por e-mail** com JWT 1-uso (`audience=request-action`, `TTL=7d`, `JTI` único).                                                        |
| **RN-F3.4-02** | Via **deep-link**: o backend valida o JWT, extrai `requestId` e abre a tela com `viaDeepLink=true`. Se o professor não estiver logado, a tela exibe modo **preview** (leitura dos dados, sem ações) e solicita login; após autenticação, retorna à mesma URL mantendo o contexto. |
| **RN-F3.4-03** | As **ações disponíveis** (Deferir, Indeferir, Solicitar ajustes, Encaminhar) são derivadas **exclusivamente** de `_links` na resposta de `GET /requests/{id}`. A UI não assume quais ações estão disponíveis — renderiza apenas o que o backend libera.                           |
| **RN-F3.4-04** | O campo **Parecer** é obrigatório para todas as ações. Mínimo de 20 caracteres para Indeferir; sem mínimo para Deferir.                                                                                                                                                           |
| **RN-F3.4-05** | Ao aplicar uma transição, o backend valida: (a) `authority` do professor confere com `Transition.requiresAuthority`, (b) `guard` do workflow satisfeito, (c) JTI não está na blacklist. Qualquer falha retorna 422 com detalhe RFC 7807.                                          |
| **RN-F3.4-06** | **Encaminhar para outro professor**: `action='FORWARD', targetUserId=UUID`. O sistema gera novo JWT 1-uso para o destinatário e enfileira `solicitacoes.assigned_to_user` → e-mail com novo deep-link.                                                                            |
| **RN-F3.4-07** | **Solicitar ajustes ao aluno**: estado vai para `EM_AJUSTE` → aluno recebe push/e-mail para corrigir o pedido.                                                                                                                                                                    |
| **RN-F3.4-08** | Cada transição grava: `request_event` com `tipo`, `parecer`, `actor_id`; e linha em `audit_log`. É imutável após gravada.                                                                                                                                                         |
| **RN-F3.4-09** | O painel de decisão (Textarea + botões) fica **sticky** no rodapé (desktop) ou em **bottom sheet** (mobile), sempre visível durante a leitura dos dados e anexos.                                                                                                                 |


---

## 3. Critérios de Aceitação

### CA-01 — Fila carregada com SLA breach destacado

```gherkin
Dado que o professor está em /solicitacoes?to=me
Quando a página carrega
Então exibe tabela com: Número, Aluno, Tipo, Prazo (danger se vencido), SLA
  E ordenada por prazo ascendente (mais urgente no topo) por padrão
  E filtrável por tipo, curso e atraso
```

### CA-02 — Navegação da fila para deliberação

```gherkin
Dado que o professor está na fila e clica em uma solicitação
Quando abre /solicitacoes/:id/deliberar
Então exibe: dados da solicitação, anexos, timeline de eventos
  E painel sticky de decisão com: Textarea "Parecer", botões das ações disponíveis via _links
  E os botões têm variantes: Deferir (success), Indeferir (danger), Solicitar ajustes (warning), Encaminhar (secondary)
```

### CA-03 — Deferir solicitação

```gherkin
Dado que o professor está na tela de deliberação
  E _links.deferir existe
Quando preenche o Textarea com o parecer e clica em "Deferir"
Então o sistema realiza POST /requests/:id/transitions { action: "DEFER", parecer: "..." }
  E ao receber 200 OK: o estado da solicitação muda conforme o workflow
  E a timeline exibe o novo evento "DEFERIDA" com o parecer
  E o aluno recebe notificação push/e-mail
  E o professor é redirecionado para a fila com mensagem de confirmação
```

### CA-04 — Deep-link por e-mail (professor não logado)

```gherkin
Dado que o professor recebeu e-mail com URL /solicitacoes/:id/deliberar?token=JWT
  E não está logado no sistema
Quando clica no link
Então a tela exibe modo "preview": dados da solicitação visíveis (read-only)
  E um banner info: "Faça login para deliberar esta solicitação."
  E botão "Fazer login" que redireciona para /login mantendo a URL de retorno
  E após login bem-sucedido retorna para /solicitacoes/:id/deliberar?token=JWT
  E o token JWT é validado e as ações ficam disponíveis
```

### CA-05 — Deep-link com token já utilizado

```gherkin
Dado que o professor tenta acessar um deep-link cujo JTI já está na blacklist
Quando o backend valida o token
Então retorna 401 com detalhe "Token já utilizado"
  E a tela exibe DS/EmptyState: "Este link já foi utilizado. Acesse a fila de solicitações para continuar."
  E botão "Ir para a fila" → /solicitacoes?to=me
```

### CA-06 — Encaminhar para outro professor

```gherkin
Dado que _links.encaminhar existe na resposta
Quando o professor clica em "Encaminhar", seleciona outro professor no select
  E clica em "Confirmar encaminhamento"
Então o sistema realiza POST /requests/:id/transitions { action: "FORWARD", targetUserId: "..." }
  E o sistema gera novo JWT 1-uso para o professor destino
  E enfileira e-mail via Outbox para o novo deliberante
  E a timeline exibe evento "ENCAMINHADA" com nome do destinatário
```

### CA-07 — Parecer obrigatório ao indeferir

```gherkin
Dado que o professor tenta clicar em "Indeferir" sem preencher o Textarea
Então o campo Textarea exibe borda danger e mensagem: "Informe o parecer para indeferimento (mín. 20 caracteres)."
  E a chamada à API NÃO é realizada
```

---

## 4. Componentes de UI (Design System)


| Componente          | Tela       | Uso                                                                              |
| ------------------- | ---------- | -------------------------------------------------------------------------------- |
| `DS/DataTable`      | F3.3       | Fila de solicitações                                                             |
| `DS/Badge`          | F3.3, F3.4 | Estado e SLA                                                                     |
| `DS/Textarea`       | F3.4       | Campo de parecer                                                                 |
| `DS/Button`         | F3.4       | Deferir (success), Indeferir (danger), Ajustes (warning), Encaminhar (secondary) |
| `DS/TimelineItem`   | F3.4       | Histórico de eventos da solicitação                                              |
| `DS/AttachmentList` | F3.4       | Visualização de anexos                                                           |
| `DS/AlertBanner`    | F3.4       | Banner de deep-link / token expirado                                             |


---

## 5. Fora de escopo

- Criação de solicitação pelo professor — exclusividade do aluno (US-F1-005)
- Reabrir solicitação após deliberação — requer capability extra, não no MVP padrão

---

## 6. Definição de Pronto (DoD)

- [ ] Frames Figma: Fila (loaded + empty), Deliberação (Deferir, Indeferir, Ajustes, Encaminhar), Deep-link (preview + logado)
- [ ] JWT 1-uso para deep-link: TTL 7d, JTI blacklist após uso
- [ ] Modo preview (não logado) funcional sem expor dados sensíveis
- [ ] Cada transição gravada em audit_log + request_event (imutável)
- [ ] Encaminhamento: novo JWT gerado + Outbox e-mail testado

---

## 7. Referências


| Recurso              | Link / Caminho                                                                                                  |
| -------------------- | --------------------------------------------------------------------------------------------------------------- |
| Specs de tela        | `telasFigma/telas3/F3.3-solicitacoes-deliberar-fila.md`, `F3.4-solicitacoes-deliberar.md`                       |
| Fluxo F3.3, F3.4     | `foundationDocs/analysis/fluxos_por_perfil.md` §4 F3.3, F3.4                                                    |
| Detalhe aluno (F1.9) | [US-F1-005](../F1/US-F1-005-SOLICITACOES.md) HU-C                                                               |
| Workflow engine      | `agents/workflow-engine-specialist.md`                                                                          |
| Página Figma F3      | [Telas / F3 — Professor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=209-339) |
| Frame F3.3 principal | [F3.3 — Deliberar fila / Loaded / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=219-817) |
| Frame F3.4 principal | [F3.4 — Deliberar solicitação / Ações / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=225-2090) |


