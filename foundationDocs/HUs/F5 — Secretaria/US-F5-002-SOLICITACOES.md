# US-F5-002 — Fila de Solicitações, Nova Interna, Deliberar e Atrasados

| Campo | Valor |
|-------|-------|
| **ID** | US-F5-002 |
| **Épico** | SECR-SOLICITACOES |
| **Telas** | F5.2 (Fila), F5.3 (Nova interna), F5.4 (Deliberar), F5.5 (Atrasados) |
| **Rotas** | `/solicitacoes` · `/solicitacoes/nova` · `/solicitacoes/:id/deliberar` · `/secretaria/atrasados` |
| **Prioridade** | P2 |
| **Capabilities** | `request.view_curso` · `request.internal_open` · `request.deliberate` |
| **APIs** | `GET /requests` · `POST /requests {onBehalfOf}` · `PATCH /requests/:id/deliberate` |
| **Frames Figma** | [Fila Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-764) · [Fila Skeleton](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=585-15485) · [Fila Empty](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=585-15571) · [Nova Passo 1](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-886) · [Deliberar](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-1010) · [Atrasados](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-1124) |

---

## História de Usuário

> **Como** secretária acadêmica,  
> **quero** gerenciar a fila central de solicitações — consultando, filtrando, abrindo em nome de alunos, deliberando e monitorando atrasos —  
> **para que** eu possa operar o fluxo de trabalho de ponta a ponta sem sair do módulo de solicitações.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F5-002-01 | A fila (`/solicitacoes`) exibe somente solicitações dos cursos vinculados à secretária (escopo por capability `request.view_curso`). |
| RN-F5-002-02 | Filtros padrão ao abrir a página: `estado=ABERTA`, ordenação por `prazo_em ASC`. Os filtros selecionados persistem em `localStorage` durante a sessão. |
| RN-F5-002-03 | Colunas obrigatórias da tabela: Número, Aluno, Tipo, Estado, Deliberador, SLA. A coluna SLA exibe `status/danger` se breach, `status/warning` se < 24 h. |
| RN-F5-002-04 | Ações por linha são controladas via `_links` da API (HATEOAS): `deliberate`, `assign`, `encaminhar` — o botão só aparece se o `rel` estiver presente. |
| RN-F5-002-05 | **Nova interna (F5.3):** a tela reutiliza o wizard de F1.8 acrescido de um campo `Combobox` de busca de aluno (por GRR ou nome, trigrama). O campo `onBehalfOf` é enviado no corpo da requisição. |
| RN-F5-002-06 | A secretária somente pode abrir solicitações internas para alunos dos cursos de sua competência; a API valida e retorna HTTP 403 caso contrário. |
| RN-F5-002-07 | **Deliberar (F5.4):** mesma tela de F3.4; a distinção é que a secretária não recebe deep-link JWT — acessa diretamente pela fila. Alguns `RequestType` exigem capability adicional `senior_secretary` para deliberação. |
| RN-F5-002-08 | Ação em massa: a secretária pode selecionar múltiplas solicitações (`DS/BulkActionBar`) e aplicar: atribuir deliberador, encaminhar (mudar responsável). Somente itens cujo `_link` `bulk_assign` existe participam da seleção. |
| RN-F5-002-09 | **Atrasados (F5.5):** é uma variante de F5.2 com filtro persistente `slaBreached=true`; os controles de filtro livre não são exibidos; o botão "Exportar" gera CSV síncrono da página atual. |
| RN-F5-002-10 | A exportação CSV da fila inclui os campos: Número, Tipo, Aluno, GRR, Curso, Estado, Deliberador, Data Abertura, Prazo, Dias de Atraso. |

---

## Critérios de Aceitação

### CA-F5-002-01 — Fila com filtros

```gherkin
Dado que a secretária acessa /solicitacoes
Quando a página carrega
Então a tabela exibe as solicitações abertas dos cursos vinculados ordenadas por prazo_em ASC
E os filtros de estado, tipo, curso e atraso estão disponíveis
E solicitações com SLA vencido têm a célula SLA em status/danger
```

### CA-F5-002-02 — Nova solicitação interna em nome de aluno

```gherkin
Dado que a secretária possui capability request.internal_open
Quando ela clica em "Nova interna" e busca um aluno por GRR "20231234"
Então o aluno aparece no Combobox
Quando ela seleciona o aluno e preenche o wizard normalmente
E confirma a abertura
Então a API recebe POST /requests com o campo onBehalfOf preenchido com o ID do aluno
E a solicitação aparece na fila com o aluno como titular
```

### CA-F5-002-03 — Deliberar sem deep-link

```gherkin
Dado que a secretária possui capability request.deliberate
E uma solicitação na fila tem _link "deliberate"
Quando ela clica na linha e acessa /solicitacoes/:id/deliberar
Então a tela de deliberação é exibida (frame F5.4/F3.4)
E ela pode deferir, indeferir ou solicitar complementação
E ao confirmar, o estado da solicitação é atualizado na fila
```

### CA-F5-002-04 — Ação em massa (atribuir deliberador)

```gherkin
Dado que três solicitações na fila têm _link bulk_assign
Quando a secretária seleciona as três usando os checkboxes
E escolhe "Atribuir" na DS/BulkActionBar
E seleciona um professor deliberador
Então a API recebe PATCH /requests/bulk com os três IDs e o deliberador selecionado
E a coluna Deliberador das três linhas é atualizada
```

### CA-F5-002-05 — Tela Atrasados

```gherkin
Dado que existem solicitações com slaBreached=true
Quando a secretária acessa /secretaria/atrasados
Então a tabela exibe somente essas solicitações
E o botão "Exportar" está visível
Quando ela clica em "Exportar"
Então um CSV é baixado com as colunas documentadas
```

### CA-F5-002-06 — Estado Empty da fila

```gherkin
Dado que não há solicitações abertas para os cursos vinculados
Quando a secretária acessa /solicitacoes
Então o componente EmptyState é exibido com mensagem "Nenhuma solicitação aberta"
```

---

## Componentes de UI

- `DS/DataTable` (com BulkActionBar)
- `DS/Button` ("Nova interna", "Exportar")
- `DS/Badge` (status da solicitação)
- `DS/Input` (busca)
- `DS/EmptyState`
- `DS/Skeleton`
- `DS/AlertBanner` (erros)
- `DS/Combobox` (busca de aluno em F5.3)
- `DS/WizardStepper` (herdado de F1.8)
- `DS/BulkActionBar` (ações em massa)

---

## Contrato de API

```
# Listar fila
GET /requests?estado=ABERTA&slaBreached=false&page=0&size=20
Authorization: Bearer <token>

# Nova interna
POST /requests
Body: { "tipo": "...", "dados": {...}, "onBehalfOf": "<alunoId>" }

# Deliberar
PATCH /requests/:id/deliberate
Body: { "decisao": "DEFERIDA|INDEFERIDA|COMPLEMENTACAO", "justificativa": "..." }

# Ação em massa
PATCH /requests/bulk
Body: { "ids": ["id1","id2"], "action": "assign", "deliberadorId": "..." }

# Exportar CSV atrasados
GET /requests?slaBreached=true&format=csv
```

---

## Fora de Escopo

- Aprovação em lote de solicitações (apenas atribuição/encaminhamento em massa aqui)
- Edição do formulário de uma solicitação já aberta
- Histórico de deliberações anteriores (ver timeline na tela de detalhe F3.4)

---

## Definition of Done

- [ ] Fila filtra por cursos vinculados à secretária
- [ ] SLA breach destacado visualmente nas colunas
- [ ] Wizard F5.3 inclui campo `onBehalfOf` com busca por GRR/nome
- [ ] Tela de deliberação reutiliza frame F3.4 sem duplicação de design
- [ ] BulkActionBar operacional com HATEOAS
- [ ] Exportação CSV de atrasados funcional
- [ ] Estados Skeleton, Loaded, Empty e Error implementados
- [ ] Testes de integração: filtro por curso, abertura interna, deliberação

---

## Referências

- Frame principal: [F5.2 Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=539-764)
- Fluxo F5.1 Triagem e F5.2 Deliberar: `foundationDocs/analysis/fluxos_por_perfil.md` §6.1–6.2
- Análogo no professor: US-F3-003 (Deliberar solicitações)
