# US-F5-006 — Revisão de Autorizações de Uso de Imagem

| Campo | Valor |
|-------|-------|
| **ID** | US-F5-006 |
| **Épico** | SECR-AUTORIZACOES |
| **Telas** | F5.12 — Autorizações de Imagem |
| **Rota** | `/secretaria/autorizacoes-imagem` |
| **Prioridade** | P2 |
| **Capability** | `image_authorization.review` |
| **APIs** | `GET /requests?type=AUTORIZACAO_IMAGEM` · `PATCH /requests/bulk-deliberate` |
| **Frames Figma** | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-2078) |

---

## História de Usuário

> **Como** secretária acadêmica,  
> **quero** revisar e aprovar ou rejeitar em lote as solicitações de autorização de uso de imagem dos alunos,  
> **para que** eu possa processar esse volume alto de pedidos com eficiência sem precisar abrir cada solicitação individualmente.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F5-006-01 | Somente usuários com capability `image_authorization.review` acessam esta tela. |
| RN-F5-006-02 | A tela é uma variante compacta de F5.2, filtrada exclusivamente por `type=AUTORIZACAO_IMAGEM`. Outros tipos de solicitação não aparecem aqui. |
| RN-F5-006-03 | Cada linha exibe: thumbnail da foto do aluno (48 × 48 px), Nome, GRR, Curso, Data envio, Status atual. |
| RN-F5-006-04 | A foto do thumbnail é carregada do MinIO via URL pré-assinada com validade de 15 min; se a URL expirar, exibe placeholder com ícone de usuário. |
| RN-F5-006-05 | **Aprovação em lote:** a secretária seleciona múltiplas linhas e aplica "Aprovar lote" ou "Rejeitar lote". A ação só está disponível via `_link bulk_deliberate` na resposta da API. |
| RN-F5-006-06 | Ao deliberar em lote, todas as solicitações selecionadas transitam para `DEFERIDA` ou `INDEFERIDA` em uma única transação. Se qualquer item falhar, a transação é revertida e a UI exibe quais IDs falharam. |
| RN-F5-006-07 | Após deliberação, o sistema emite Outbox `autorizacoes.deliberated` para cada aluno notificar o resultado. |
| RN-F5-006-08 | Solicitações com estado diferente de `ABERTA` aparecem em modo somente leitura (sem checkbox de seleção). |

---

## Critérios de Aceitação

### CA-F5-006-01 — Exibição compacta com thumbnails

```gherkin
Dado que existem 30 solicitações AUTORIZACAO_IMAGEM com estado ABERTA
Quando a secretária acessa /secretaria/autorizacoes-imagem
Então a tabela densa exibe as 30 solicitações com thumbnail de 48px, Nome, GRR, Curso, Data e Status
E o thumbnail exibe a foto enviada pelo aluno (URL pré-assinada MinIO)
```

### CA-F5-006-02 — Aprovação em lote

```gherkin
Dado que existem 10 solicitações abertas de autorização de imagem
Quando a secretária seleciona 8 delas e clica em "Aprovar lote"
Então um dialog de confirmação é exibido com o número de itens selecionados
Quando ela confirma
Então a API recebe PATCH /requests/bulk-deliberate com os 8 IDs e decisão DEFERIDA
E as 8 linhas exibem status "Deferida"
E o Outbox emite notificação para cada aluno
```

### CA-F5-006-03 — Falha parcial em lote

```gherkin
Dado que a secretária aprova 5 solicitações em lote
E uma delas tem estado diferente de ABERTA (inconsistência de concorrência)
Quando a API processa a ação
Então a transação é revertida
E a UI exibe um AlertBanner listando o ID que causou a falha
E nenhuma das 5 solicitações é alterada
```

### CA-F5-006-04 — Thumbnail expirado

```gherkin
Dado que a URL pré-assinada de uma foto expirou
Quando a tabela renderiza
Então o placeholder de ícone de usuário é exibido no lugar do thumbnail
E o alt text é o nome do aluno para acessibilidade
```

### CA-F5-006-05 — Rejeitar com justificativa

```gherkin
Dado que a secretária seleciona 3 solicitações e clica em "Rejeitar lote"
Quando o dialog pede uma justificativa opcional
E ela preenche "Foto ilegível" e confirma
Então a API recebe PATCH /requests/bulk-deliberate com decisão INDEFERIDA e justificativa
E os 3 alunos recebem e-mail com a justificativa
```

---

## Componentes de UI

- `DS/DataTable` compact (com thumbnails e `DS/BulkActionBar`)
- `DS/Badge` (status da solicitação)
- `DS/Checkbox` (seleção de linhas)
- `DS/AlertBanner` (erros de lote)
- Dialog de confirmação de lote (com campo justificativa opcional)

---

## Contrato de API

```
GET /requests?type=AUTORIZACAO_IMAGEM&estado=ABERTA&page=0&size=50

PATCH /requests/bulk-deliberate
Body: {
  "ids": ["id1", "id2", ...],
  "decisao": "DEFERIDA | INDEFERIDA",
  "justificativa": "Foto ilegível"  // opcional
}

Response inclui:
{
  "_links": {
    "bulk_deliberate": { "href": "/requests/bulk-deliberate" }
  }
}
```

---

## Fora de Escopo

- Visualização da imagem em tamanho completo (thumbnail apenas)
- Edição da foto enviada pelo aluno
- Criação de AUTORIZACAO_IMAGEM pela secretaria (aluno abre via F1)

---

## Definition of Done

- [ ] Tabela compacta com thumbnails de 48 px
- [ ] Seleção múltipla com `DS/BulkActionBar`
- [ ] Aprovação e rejeição em lote com transação atômica
- [ ] Outbox `autorizacoes.deliberated` disparado por deliberação
- [ ] Fallback de thumbnail expirado com alt text
- [ ] Testes: lote com falha parcial revertido, HATEOAS bulk_deliberate

---

## Referências

- Frame principal: [F5.12 Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-2078)
- Análogo: aprovação em lote CAAF — US-F4-001 (RN-F4-001-06)
