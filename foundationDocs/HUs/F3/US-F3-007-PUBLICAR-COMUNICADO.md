# US-F3-007 — Publicar Comunicado para Turma ou Curso

| Campo | Valor |
|-------|-------|
| **ID** | US-F3-007 |
| **Épico** | PROF-COMUNICACAO |
| **Tela** | F3.8 — `/comunicacao/publicar` |
| **Prioridade** | P2 |
| **Plataforma** | Web |
| **Capability** | `communication.publish_class` |
| **API primária** | `POST /communications` |
| **Frames Figma** | [Draft/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=226-2203) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=257-22100) · [Draft/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=253-23180) |
| **Spec de tela** | `telasFigma/telas3/F3.8-comunicacao-publicar.md` |

---

## 1. História de Usuário

> **Como** professor autenticado,  
> **Quero** escrever e publicar um comunicado em Markdown para minha turma, curso ou todos os alunos, definindo prioridade e data de expiração,  
> **Para** informar os alunos de forma organizada via hub de comunicação, sem depender de e-mail externo ou grupos de WhatsApp.

---

## 2. Regras de Negócio

| ID | Regra |
|----|-------|
| **RN-F3.8-01** | O campo **audiência** aceita: turma específica (código de disciplina/semestre), curso inteiro, ou todos os alunos do professor. Um professor não pode publicar para alunos de outros cursos/turmas que não os seus. |
| **RN-F3.8-02** | O campo **prioridade** define o comportamento de entrega: CRITICAL (push imediato, ignora DND), HIGH (push + e-mail), MEDIUM (push se fora do DND), LOW (somente in-app). |
| **RN-F3.8-03** | O campo **expiração** define até quando o comunicado aparece na lista de não lidos dos destinatários. Após expirar, ainda aparece no histórico mas perde o status "não lido". |
| **RN-F3.8-04** | O corpo do comunicado é escrito em **Markdown** e renderizado no preview em tempo real com a mesma tipografia `Body` do sistema. |
| **RN-F3.8-05** | Ao publicar, o backend cria `Communication` → Outbox `comunicacao.published` → dispatcher cria `communication_delivery` por destinatário (fan-out assíncrono). |
| **RN-F3.8-06** | O professor vê confirmação e pode acessar o comunicado publicado no hub `/comunicacao`. |

---

## 3. Critérios de Aceitação

### CA-01 — Formulário de publicação

```gherkin
Dado que o professor está em /comunicacao/publicar
Quando a página carrega
Então exibe: campo título, editor Markdown, preview em tempo real, select audiência, select prioridade, campo expiração
  E o preview usa a mesma tipografia Body do sistema
  E o botão "Publicar" fica habilitado somente quando título e corpo estão preenchidos
```

### CA-02 — Publicação bem-sucedida

```gherkin
Dado que o professor preencheu todos os campos
Quando clica em "Publicar"
Então o sistema realiza POST /communications { titulo, corpo, audiencia, prioridade, expiraEm }
  E ao receber 201 Created exibe DS/AlertBanner success: "Comunicado publicado com sucesso."
  E o comunicado aparece em /comunicacao para os destinatários
  E o Outbox dispara as entregas por canal conforme a prioridade
```

### CA-03 — Preview em tempo real

```gherkin
Dado que o professor está digitando no editor Markdown
Quando escreve "## Título" e "**negrito**"
Então o painel de preview atualiza em tempo real com H2 e texto em negrito
  E o preview é somente leitura (não editável)
```

### CA-04 — Restrição de audiência

```gherkin
Dado que o professor tenta selecionar audiência "Todos os alunos da universidade"
Então essa opção NÃO está disponível (sem capability system.broadcast)
  E o select mostra apenas: suas turmas, seus cursos
```

### CA-05 — Responsividade mobile

```gherkin
Dado que o professor acessa /comunicacao/publicar em dispositivo mobile
Quando a viewport é < 768px
Então editor e preview ficam em tabs separadas (Editor | Preview)
  E ambas são acessíveis via tabs com aria-selected
```

---

## 4. Componentes de UI (Design System)

| Componente | Uso |
|------------|-----|
| `DS/Textarea` / Editor Markdown | Editor com syntax highlight básico |
| `MarkdownPreview` | Renderização em tempo real |
| `DS/Select` | Audiência, Prioridade |
| `DS/Input` | Título, Data expiração |
| `DS/Button` | `variant=primary` — Publicar |
| `DS/AlertBanner` | Confirmação de sucesso |

---

## 5. Fora de escopo

- Edição ou exclusão de comunicado após publicação — não previsto no MVP
- Comunicados com anexos de arquivo — somente texto Markdown
- Resposta dos alunos ao comunicado — unidirecional no MVP

---

## 6. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas3/F3.8-comunicacao-publicar.md` |
| Fluxo F3.8 | `foundationDocs/analysis/fluxos_por_perfil.md` §4 F3.8 |
| Recebimento aluno | [US-F1-004](../F1/US-F1-004-COMUNICACAO.md) |
| Página Figma F3 | [Telas / F3 — Professor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=209-339) |
| Frame principal | [F3.8 — Publicar comunicado / Draft / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=226-2203) |
