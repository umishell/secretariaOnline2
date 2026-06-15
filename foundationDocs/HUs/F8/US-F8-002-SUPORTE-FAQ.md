# US-F8-002 — Suporte e FAQ

| Campo | Valor |
|-------|-------|
| **ID** | US-F8-002 |
| **Épico** | CROSS-SUPORTE |
| **Telas** | F8.2 — Suporte |
| **Rota** | `/suporte` |
| **Prioridade** | P2 |
| **Capability** | `logado` (qualquer usuário autenticado) |
| **APIs** | `GET /support/faq` · `POST /support/tickets` |
| **Plataforma** | Web (Desktop + Mobile) |
| **Frames Figma** | [Default Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=768-824) · [Submit Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=769-931) · [Default Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=775-1074) · [Submit Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=775-1290) |

---

## História de Usuário

> **Como** qualquer usuário autenticado,  
> **quero** consultar uma base de perguntas frequentes (FAQ) e, caso não encontre a resposta, abrir um ticket de suporte diretamente pela plataforma,  
> **para que** eu possa resolver dúvidas operacionais sem precisar contatar a secretaria por e-mail ou telefone.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F8-002-01 | A rota `/suporte` é acessível a qualquer usuário com sessão ativa (capability implícita: `logado`). Não há restrição por perfil. |
| RN-F8-002-02 | **Layout (Desktop):** divide-se em `Main/SupportSplit` — coluna esquerda (556px): FAQ em `DS/Accordion`; coluna direita (556px): formulário de ticket. |
| RN-F8-002-03 | **Layout (Mobile):** coluna única — FAQ primeiro, formulário de ticket em seguida, sem split lateral. |
| RN-F8-002-04 | **FAQ:** lista de perguntas e respostas em `DS/Accordion`. Itens revelados no Figma: "Como redefinir minha senha?" (expandida com resposta: "Acesse Perfil > Segurança ou Recuperar senha no login.") e "Prazo de deliberação?" (recolhida). A lista de FAQs é carregada dinamicamente via `GET /support/faq` e pode ser gerenciada pelo admin. |
| RN-F8-002-05 | O Accordion segue o padrão de acessibilidade ARIA: cada pergunta é um `<button>` com `aria-expanded`, o painel de resposta tem `role="region"` e `aria-labelledby`. Navegação completa por teclado (Tab + Enter/Space para expandir). |
| RN-F8-002-06 | **Formulário de ticket:** campos obrigatórios: Assunto (`DS/Input`, máx. 200 chars) e Mensagem (`DS/Textarea`, máx. 2000 chars). Sem campo de Categoria no MVP — todos os tickets chegam na fila geral da secretaria. |
| RN-F8-002-07 | **Contato de fallback:** o texto "Ou contate: secretaria@ufpr.br" é exibido abaixo do botão "Enviar ticket" em Desktop e é um link `mailto:`. |
| RN-F8-002-08 | **Estratégia de implementação (MVP):** o ticket é registrado como `RequestType=SUPORTE_TECNICO` reutilizando o workflow engine (DRY total), conforme indicação em `fluxos_por_perfil.md` §9.2. Na ausência desse tipo configurado no admin, pode ser registrado como `support_thread` simples. |
| RN-F8-002-09 | Após o envio bem-sucedido, o estado **Submit** é exibido: um `DS/AlertBanner · success` aparece no topo da página com a mensagem "Ticket enviado com sucesso. Você receberá uma resposta em até 2 dias úteis." O formulário é limpo mas permanece visível (não navega). |
| RN-F8-002-10 | O número do protocolo do ticket é exibido no banner de sucesso para acompanhamento. |
| RN-F8-002-11 | Rate limiting: máximo de 3 tickets por usuário por hora (Bucket4j). Se o limite for atingido, o botão "Enviar ticket" exibe erro inline "Limite de tickets atingido. Tente novamente em X min." |
| RN-F8-002-12 | O FAQ exibe as perguntas mais relevantes para o perfil do usuário primeiro (ordenação configurável pelo admin no endpoint `GET /support/faq?perfil=ALUNO`). |

---

## Critérios de Aceitação

### CA-F8-002-01 — Exibir FAQ com Accordion

```gherkin
Dado que o usuário acessa /suporte
Quando a página carrega
Então a seção FAQ exibe as perguntas como DS/Accordion recolhidos
E o item "Como redefinir minha senha?" está expandido por padrão mostrando a resposta
Quando o usuário clica em "Prazo de deliberação?"
Então o painel de resposta é expandido e o ícone de chevron gira
```

### CA-F8-002-02 — Navegação por teclado no FAQ

```gherkin
Dado que o usuário navega pelo FAQ via Tab
Quando pressiona Tab para focar na pergunta "Prazo de deliberação?"
E pressiona Enter
Então o item é expandido
E o attr aria-expanded muda para "true"
```

### CA-F8-002-03 — Enviar ticket com sucesso

```gherkin
Dado que o usuário preenche Assunto "Dúvida sobre prazo de aproveitamento" e Mensagem "..."
Quando clica em "Enviar ticket"
Então a API recebe POST /support/tickets
E o estado Submit é exibido com DS/AlertBanner success
E o banner inclui o número do protocolo gerado (ex.: "SUP-2025-042")
E o formulário é limpo mas permanece visível
```

### CA-F8-002-04 — Campos obrigatórios

```gherkin
Dado que o usuário deixou o campo Assunto em branco
Quando clica em "Enviar ticket"
Então o formulário exibe erro inline "Assunto é obrigatório"
E a API não é chamada
```

### CA-F8-002-05 — Rate limit de tickets

```gherkin
Dado que o usuário já enviou 3 tickets na última hora
Quando tenta enviar o quarto
Então a API retorna HTTP 429
E o botão "Enviar ticket" exibe mensagem de erro "Limite de 3 tickets/hora atingido. Tente em 42 min."
```

### CA-F8-002-06 — Layout Mobile (coluna única)

```gherkin
Dado que o usuário acessa /suporte em um dispositivo de 375px
Quando a página carrega
Então o FAQ e o formulário são exibidos em coluna única (FAQ primeiro, formulário abaixo)
E o layout não usa split lateral
```

### CA-F8-002-07 — Link de contato de fallback

```gherkin
Dado que o usuário visualiza o formulário de ticket em Desktop
Quando vê o texto "Ou contate: secretaria@ufpr.br"
Quando clica no e-mail
Então o cliente de e-mail padrão abre com o destinatário pré-preenchido
```

---

## Comportamento Responsivo

| Dispositivo | Layout | Frames |
|-------------|--------|--------|
| Desktop (≥ 768px) | Split: FAQ (esquerda 556px) + Formulário (direita 556px) | `768:824`, `769:931` |
| Mobile (375px) | Coluna única: FAQ → Formulário | `775:1074`, `775:1290` |

---

## Componentes de UI

- `DS/Accordion` (FAQ — expandível por teclado)
- `DS/Input` (Assunto)
- `DS/Textarea` (Mensagem)
- `DS/Button` ("Enviar ticket")
- `DS/AlertBanner · success` (estado Submit)
- Link `mailto:` (contato de fallback)
- Mensagem de erro inline (rate limit e validação)

---

## Contrato de API

```
# FAQ
GET /support/faq?perfil=ALUNO
Response: [
  { "id": "...", "pergunta": "Como redefinir minha senha?", "resposta": "..." },
  { "id": "...", "pergunta": "Prazo de deliberação?", "resposta": "..." }
]

# Criar ticket
POST /support/tickets
Body: { "assunto": "...", "mensagem": "..." }
Response 201: { "id": "...", "numero": "SUP-2025-042" }
Response 429: { "message": "Rate limit excedido", "retryAfterMinutes": 42 }
```

---

## Fora de Escopo

- Histórico de tickets abertos pelo usuário (possível iteração futura)
- Chat ao vivo com a secretaria
- Categorização de tickets pelo usuário (apenas pela secretaria ao processar)
- FAQ editável pela UI (gerenciado via admin — fora do escopo F8)

---

## Definition of Done

- [ ] FAQ carregado dinamicamente via `GET /support/faq`
- [ ] Accordion com ARIA completo (aria-expanded, role="region", teclado funcional)
- [ ] Formulário com validação de Assunto e Mensagem
- [ ] Estado Submit com AlertBanner de sucesso e número de protocolo
- [ ] Rate limiting: 3 tickets/hora com mensagem de erro clara
- [ ] Layout split Desktop + coluna única Mobile
- [ ] Link `mailto:` de fallback funcional
- [ ] Testes: campos obrigatórios, rate limit, accordion por teclado

---

## Referências

- Frame Default Desktop: [F8.2 Default](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=768-824)
- Frame Submit Desktop: [F8.2 Submit](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=769-931)
- Frame Default Mobile: [F8.2 Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=775-1074)
- Fluxo F8.2 Suporte: `foundationDocs/analysis/fluxos_por_perfil.md` §9.2
