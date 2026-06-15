# US-F7-003 — Editor de Tipos de Solicitação (Workflow Engine)

| Campo | Valor |
|-------|-------|
| **ID** | US-F7-003 |
| **Épico** | ADMIN-WORKFLOW |
| **Telas** | F7.4 — Tipos de Solicitação |
| **Rota** | `/admin/tipos-solicitacao` |
| **Prioridade** | P2 |
| **Capability** | `request_type.manage` |
| **APIs** | `/request-types` CRUD · `POST /request-types/:id/publish` |
| **Frames Figma** | [Editor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=730-1228) |

> ⚠️ **Tela crítica ADR-003 — Coração do princípio DRY.** Esta tela é a mais complexa do sistema admin. Cada tipo de solicitação adicionado aqui substitui a criação de múltiplos arquivos de código. Erros de schema ou workflow devem ser bloqueados antes da publicação.

---

## História de Usuário

> **Como** administrador da plataforma,  
> **quero** criar e editar tipos de solicitação definindo seu formulário (JSON Schema) e seu fluxo de trabalho (state machine JSON) através de um editor visual de 3 painéis com preview ao vivo,  
> **para que** novos processos acadêmicos sejam suportados pelo sistema apenas com a configuração de dados, sem necessidade de novas deployments.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F7-003-01 | Somente usuários com capability `request_type.manage` acessam esta tela. |
| RN-F7-003-02 | O editor é dividido em 3 painéis (conforme `Main/ThreePanelSplit` no Figma): (1) **Lista de tipos** — panel esquerdo 240px; (2) **Editor JSON Schema** — painel central com dois `DS/JsonSchemaEditor` (form_schema + metadados); (3) **Preview + Workflow** — painel direito com `DS/FormSchemaPreview` e `DS/WorkflowStateMachineEditor`. |
| RN-F7-003-03 | **`form_schema` (JSON Schema):** define os campos do formulário dinâmico apresentado ao aluno/professor. Deve ser JSON Schema draft-07 válido. Schema inválido exibe borda `status/danger` no editor e bloqueia a publicação. |
| RN-F7-003-04 | **`workflow_json` (State Machine DSL):** define estados (ex.: `ABERTA`, `EM_ANALISE`, `DELIBERADA`, `ARQUIVADA`), transições (evento + capability exigida), guards (ex.: `aluno.semestre >= 4`) e templates de notificação por estado. |
| RN-F7-003-05 | O preview ao vivo (`DS/FormSchemaPreview`) atualiza em tempo real conforme o JSON Schema é editado — sem necessidade de salvar. Se o schema estiver inválido, o preview exibe uma mensagem de erro descritiva. |
| RN-F7-003-06 | O `DS/WorkflowStateMachineEditor` é um grafo visual (nodes = estados, edges = transições) que reflete o `workflow_json`. Alterações no editor JSON atualizam o grafo automaticamente. |
| RN-F7-003-07 | **Versionamento atômico:** ao publicar (`POST /request-types/:id/publish`), o sistema cria uma nova versão imutável. Solicitações já abertas continuam usando a versão que estava vigente em sua criação; somente novas solicitações usam a versão corrente. |
| RN-F7-003-08 | Um `RequestType` não publicado (`status = DRAFT`) não aparece para os usuários finais. Apenas tipos com `status = PUBLISHED` são oferecidos no wizard de nova solicitação (F1.8, F5.3). |
| RN-F7-003-09 | Não é possível excluir um `RequestType` que tenha solicitações abertas ou em histórico. Apenas tipos em `DRAFT` sem histórico podem ser excluídos. |
| RN-F7-003-10 | Toda criação, edição e publicação é registrada no `audit_log` com o payload completo do `form_schema` e `workflow_json` (para rastreabilidade do versionamento). |
| RN-F7-003-11 | Exemplos de tipos de solicitação no painel esquerdo (visíveis no Figma): "Aproveitamento", "Trancamento", "Colação grau" — representando o universo de 19 tipos do projeto. |

---

## Critérios de Aceitação

### CA-F7-003-01 — Exibição dos três painéis

```gherkin
Dado que o admin acessa /admin/tipos-solicitacao
Quando a tela carrega
Então o painel esquerdo exibe a lista de RequestTypes com nome e status (DRAFT/PUBLISHED)
E o painel central exibe os editores JSON (form_schema e workflow_json) do tipo selecionado
E o painel direito exibe o preview do formulário e o grafo do workflow
```

### CA-F7-003-02 — Edição de form_schema com preview ao vivo

```gherkin
Dado que o admin seleciona o tipo "Trancamento"
Quando ele adiciona um novo campo "motivoTrancamento" ao JSON Schema
Então o DS/FormSchemaPreview atualiza imediatamente exibindo o novo campo
E o campo aparece como textarea no preview
```

### CA-F7-003-03 — Schema inválido bloqueia publicação

```gherkin
Dado que o admin edita o form_schema com JSON malformado (chave sem fechar)
Quando o editor detecta o erro de sintaxe
Então o DS/JsonSchemaEditor exibe borda status/danger
E uma mensagem de erro "JSON inválido na linha N" aparece abaixo do editor
E o botão "Publicar" está desabilitado
```

### CA-F7-003-04 — Publicar versão

```gherkin
Dado que o admin finalizou a edição do form_schema e workflow_json de "Colação grau"
E ambos estão válidos
Quando ele clica em "Publicar"
Então a API recebe POST /request-types/:id/publish
E uma nova versão imutável é criada com número de versão incrementado
E o status muda para PUBLISHED
E novas solicitações deste tipo usam a versão corrente
E solicitações já abertas mantêm a versão anterior
```

### CA-F7-003-05 — Versionamento: solicitações existentes não afetadas

```gherkin
Dado que existem 5 solicitações abertas do tipo "Aproveitamento" usando a versão 2
Quando o admin publica a versão 3 com um novo campo obrigatório
Então as 5 solicitações existentes continuam sendo processadas com o formulário da versão 2
E apenas novas solicitações de "Aproveitamento" exibem o campo novo
```

### CA-F7-003-06 — Workflow grafo atualiza com o JSON

```gherkin
Dado que o admin edita o workflow_json adicionando um novo estado "EM_RECURSO"
Quando o JSON é salvo em memória (sem publicar)
Então o DS/WorkflowStateMachineEditor exibe o novo nó "EM_RECURSO" no grafo
E as transições do estado são renderizadas como edges
```

### CA-F7-003-07 — Criar novo tipo de solicitação

```gherkin
Dado que o admin clica em "Novo"
Quando preenche o Nome "Monitoria" e define form_schema e workflow_json válidos
E clica em "Publicar"
Então o RequestType "Monitoria" aparece no wizard de nova solicitação (F1.8/F5.3)
E é adicionado ao painel esquerdo com status PUBLISHED
```

---

## Estrutura do form_schema (exemplo)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Aproveitamento de Disciplina",
  "type": "object",
  "required": ["disciplinaCursar", "disciplinaAproveitada", "historico"],
  "properties": {
    "disciplinaCursar": {
      "type": "string",
      "title": "Disciplina a cursar",
      "description": "Código da disciplina para a qual solicita aproveitamento"
    },
    "disciplinaAproveitada": {
      "type": "string",
      "title": "Disciplina aproveitada"
    },
    "historico": {
      "type": "string",
      "title": "Histórico escolar",
      "format": "uri",
      "contentMediaType": "application/pdf"
    }
  }
}
```

## Estrutura do workflow_json (exemplo)

```json
{
  "initialState": "ABERTA",
  "states": [
    { "id": "ABERTA", "label": "Aberta" },
    { "id": "EM_ANALISE", "label": "Em análise" },
    { "id": "DELIBERADA", "label": "Deliberada" },
    { "id": "ARQUIVADA", "label": "Arquivada" }
  ],
  "transitions": [
    {
      "from": "ABERTA", "to": "EM_ANALISE",
      "event": "assign",
      "capability": "request.assign",
      "guard": null
    },
    {
      "from": "EM_ANALISE", "to": "DELIBERADA",
      "event": "deliberate",
      "capability": "request.deliberate",
      "guard": "aluno.semestre >= 2"
    }
  ],
  "prazoDefaultDias": 15,
  "notificacoes": {
    "DELIBERADA": "template.aproveitamento.deferido"
  }
}
```

---

## Componentes de UI

- `Shell/AdminLayout` (largura mínima 1440px)
- `Main/ThreePanelSplit` (3 painéis)
- `DS/JsonSchemaEditor` × 2 (form_schema + workflow_json)
- `DS/FormSchemaPreview` (preview ao vivo)
- `DS/WorkflowStateMachineEditor` (grafo visual)
- `DS/Button` ("Novo", "Publicar", "Salvar rascunho")
- `DS/Badge` (DRAFT / PUBLISHED)

---

## Fora de Escopo

- Execução de testes automatizados do workflow (sandbox de simulação)
- Importação de schema via arquivo
- Editor visual de JSON Schema (WYSIWYG sem código)

---

## Definition of Done

- [ ] Editor 3 painéis funcional: lista · JSON editor · preview + grafo
- [ ] Preview ao vivo sem necessidade de salvar
- [ ] Validação de JSON Schema: borda danger + mensagem de erro
- [ ] Publicação cria versão imutável
- [ ] Versionamento: solicitações existentes usam versão anterior
- [ ] Workflow grafo reflete JSON em tempo real
- [ ] `audit_log` com payload completo do schema/workflow
- [ ] Testes: schema inválido, publicação, versionamento retroativo

---

## Referências

- Frame principal: [F7.4 Editor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=730-1228)
- ADR-003 (Workflow Engine DRY): `foundationDocs/analysis/analise_arquitetural_secretariaonline2.md` §14
- Fluxo F7.2 Catálogo de tipos: `foundationDocs/analysis/fluxos_por_perfil.md` §8.2
- DynamicForm (frontend): US-F1-008 (wizard de solicitação do aluno)
