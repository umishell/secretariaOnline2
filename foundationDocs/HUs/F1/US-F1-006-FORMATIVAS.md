# US-F1-006 — Submeter e Acompanhar Atividades Formativas

| Campo | Valor |
|-------|-------|
| **ID** | US-F1-006 |
| **Épico** | ALUNO-FORMATIVAS |
| **Telas** | F1.10 `/formativas` · F1.11 `/formativas/nova` · F1.12 `/formativas/:id` |
| **Prioridade** | P2 |
| **Plataforma** | Web + Mobile |
| **Capability** | `formative.view_own`, `formative.submit` |
| **API primária** | `GET /formative-entries?aluno=me`, `POST /formative-entries`, `GET /formative-entries/{id}` |
| **Frames Figma** | **F1.10:** [Loaded/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=89-3495) · [Empty/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=89-4770) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=109-8442) · [Error/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=109-9050) · [Loaded/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=112-11657) · [Empty/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=112-16910) · **F1.11:** [Default/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=90-4972) · [Default/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=112-18967) · **F1.12:** [Default/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=90-5105) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=148-14167) · [404/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=148-16090) · [Default/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=112-20108) |
| **Specs de tela** | `telasFigma/telas1/F1.10-formativas-lista.md` · `F1.11-formativas-nova.md` · `F1.12-formativas-detalhe.md` |

---

## 1. História de Usuário

> **Como** aluno autenticado,  
> **Quero** submeter comprovantes de atividades formativas complementares e acompanhar o parecer da CAAF,  
> **Para** registrar minhas horas e obter o certificado correspondente quando aprovadas.

---

## 2. Regras de Negócio

### Lista de formativas (F1.10)

| ID | Regra |
|----|-------|
| **RN-F1.10-01** | A lista exibe todas as entradas formativas do aluno com colunas: Atividade, Horas declaradas, Estado (DS/Badge), Data. |
| **RN-F1.10-02** | O KpiCard de horas no Dashboard é calculado a partir das entradas no estado `APROVADA` (não inclui submetidas ou em análise). |

### Submissão de nova formativa (F1.11)

| ID | Regra |
|----|-------|
| **RN-F1.11-01** | O aluno seleciona o tipo de `formative_activity` válido para seu curso. A lista é filtrada pelo backend. |
| **RN-F1.11-02** | O aluno declara a carga horária e anexa comprovante (PDF ou imagem). O upload segue o padrão MinIO com URL pré-assinada. |
| **RN-F1.11-03** | Ao submeter, o estado da entrada é `SUBMETIDA`. O Outbox enfileira `formativas.submitted` → notifica a CAAF do curso. |
| **RN-F1.11-04** | **Caminho pré-validado (evento interno):** se a atividade formativa veio de um evento interno com presença já validada pelo sistema, o formulário é pré-preenchido (campos readonly) e o aluno apenas **confirma** com 1 clique, sem necessidade de upload de comprovante. |

### Detalhe e parecer CAAF (F1.12)

| ID | Regra |
|----|-------|
| **RN-F1.12-01** | O detalhe exibe: atividade, horas declaradas, horas validadas (após parecer), estado, parecer da CAAF e comprovante (pré-visualização). |
| **RN-F1.12-02** | Estado `APROVADA`: o link `baixar-certificado` aparece em `_links` → download do PDF assinado (US-F1-010). |
| **RN-F1.12-03** | Estado `REJEITADA`: o link `resubmeter` pode aparecer em `_links` (se o tipo de atividade permite contestação), permitindo que o aluno envie novo comprovante. |

---

## 3. Critérios de Aceitação

### CA-01 — Listar formativas

```gherkin
Dado que o aluno está em /formativas
Quando a página carrega
Então exibe tabela com atividades, horas, estado (DS/Badge) e data
  E filtrável por estado e tipo
  E button "Nova atividade" visível se _links.nova existir
```

### CA-02 — Submeter nova formativa manualmente

```gherkin
Dado que o aluno está em /formativas/nova
Quando seleciona tipo de atividade, informa carga horária e faz upload de comprovante PDF
  E clica em "Enviar"
Então o sistema realiza POST /formative-entries
  E a entrada aparece na lista com estado "SUBMETIDA"
  E a CAAF do curso recebe notificação via Outbox
```

### CA-03 — Confirmar formativa pré-validada (evento interno)

```gherkin
Dado que o aluno participou de um evento interno com presença validada
  E o sistema criou automaticamente uma formative_entry PENDENTE_CONFIRMACAO
Quando o aluno acessa /formativas/nova (ou link direto)
Então o formulário está pré-preenchido com os dados do evento (campos readonly)
  E exibe DS/AlertBanner info: "Participação registrada pelo sistema. Confirme para finalizar."
  E ao clicar em "Confirmar" transiciona para SUBMETIDA sem necessidade de upload
```

### CA-04 — Detalhe com link para certificado

```gherkin
Dado que a formativa do aluno tem estado APROVADA
  E _links.baixar-certificado existe na resposta
Quando o aluno acessa /formativas/:id
Então exibe badge "APROVADA" em success
  E exibe botão "Baixar certificado" na ActionBar
  E ao clicar realiza o download do PDF do certificado emitido
```

---

## 4. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Specs de tela | `telasFigma/telas1/F1.10-formativas-lista.md`, `F1.11-formativas-nova.md`, `F1.12-formativas-detalhe.md` |
| Fluxo F1.4, F1.5 | `foundationDocs/analysis/fluxos_por_perfil.md` §2 F1.4, F1.5 |
| Emissão certificado | [US-F1-010](./US-F1-010-CERTIFICADOS.md) |
| Página Figma F1 | [Telas / F1 — Aluno](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=48-339) |
| Frame F1.10 principal | [F1.10 — Formativas / Loaded / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=89-3495) |
| Frame F1.11 principal | [F1.11 — Formativas nova / Default / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=90-4972) |
| Frame F1.12 principal | [F1.12 — Formativas detalhe / Default / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=90-5105) |
