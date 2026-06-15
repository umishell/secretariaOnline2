# US-F0-002 — Solicitar Link de Recuperação de Senha

| Campo | Valor |
|-------|-------|
| **ID** | US-F0-002 |
| **Épico** | AUTH-RESET |
| **Tela** | F0.2 — `/recuperar-senha` |
| **Prioridade** | P1 |
| **Plataforma** | Web + Mobile |
| **API primária** | `POST /auth/forgot-password` |
| **Frames Figma** | [Default](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=27-225) · [Success](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=27-253) |
| **Spec de tela** | `telasFigma/telas0/F0.2-recuperar-senha.md` |
| **Depende de** | US-F0-003 (redefinição de senha via token) |
| **Substitui (legado)** | `web/enviarEmailSenha.jsp` [T02] |

---

## 1. História de Usuário

> **Como** um usuário cadastrado no sistema que não lembra sua senha,  
> **Quero** informar meu e-mail e receber um link de redefinição,  
> **Para** recuperar o acesso à minha conta sem precisar contatar a secretaria.

---

## 2. Regras de Negócio

| ID | Regra |
|----|-------|
| **RN-F0.2-01** | O endpoint `POST /auth/forgot-password` **sempre** retorna `202 Accepted` com corpo neutro, independentemente de o e-mail informado existir ou não na base de dados. Isso impede ataques de enumeração de contas. |
| **RN-F0.2-02** | Se o e-mail informado corresponder a um usuário ativo, o backend deve gerar um **JWT de uso único** com as propriedades: `JTI` único (UUID v7), `audience = "password-reset"`, `sub = usuario.id`, expiração de **24 horas**. |
| **RN-F0.2-03** | O token gerado é colocado em `outbox_event` com tipo `iam.password_reset_requested`, garantindo que o e-mail seja enviado via template `PASSWORD_RESET` pelo dispatcher assíncrono. |
| **RN-F0.2-04** | A mensagem exibida ao usuário após o submit é sempre: `"Se este e-mail estiver cadastrado, você receberá um link válido por 24 horas."` — sem variação para e-mails existentes ou inexistentes. |
| **RN-F0.2-05** | O campo de e-mail deve ser validado no frontend para formato básico (regex RFC 5322 simplificada) **antes** de realizar a chamada à API. |
| **RN-F0.2-06** | Após exibir a mensagem de sucesso, o formulário é substituído pela mensagem neutra (estado `Success`) e o usuário não pode reenviar pela mesma tela sem navegar de volta. |
| **RN-F0.2-07** | Cada solicitação de recuperação (bem-sucedida internamente) é registrada em `audit_log` com: `actor_id` (se identificado), e-mail informado, IP de origem, timestamp. |
| **RN-F0.2-08** | O endpoint é protegido por rate limit: máximo de **3 solicitações por hora** por e-mail + IP, para mitigar spam de e-mails. |

---

## 3. Critérios de Aceitação

### CA-01 — Fluxo principal (e-mail cadastrado)

```gherkin
Dado que o usuário está em /recuperar-senha
Quando preenche o campo "E-mail" com um e-mail válido e cadastrado no sistema
  E clica em "Enviar link"
Então o sistema realiza POST /auth/forgot-password
  E recebe 202 Accepted
  E o formulário é ocultado
  E exibe DS/AlertBanner variante "info" com ícone Mail e mensagem:
    "Se este e-mail estiver cadastrado, você receberá um link válido por 24 horas."
  E internamente um JWT de uso único é gerado e enfileirado para envio por e-mail
  E o evento iam.password_reset_requested é registrado em audit_log
```

### CA-02 — E-mail não cadastrado (resposta idêntica)

```gherkin
Dado que o usuário está em /recuperar-senha
Quando preenche o campo "E-mail" com um e-mail que NÃO existe na base de dados
  E clica em "Enviar link"
Então o sistema realiza POST /auth/forgot-password e recebe 202 Accepted
  E exibe exatamente a mesma mensagem do CA-01 (anti-enumeração)
  E NENHUM e-mail é enviado internamente
  E a resposta visual é IDÊNTICA à de um e-mail cadastrado
```

### CA-03 — Validação de formato de e-mail (frontend)

```gherkin
Dado que o usuário está em /recuperar-senha
Quando preenche o campo "E-mail" com valor inválido (ex: "abc", "sem@domínio")
  E clica em "Enviar link"
Então o sistema NÃO realiza chamada à API
  E exibe mensagem de validação inline: "Informe um e-mail válido"
  E o campo exibe borda "border/error"
```

### CA-04 — Estado de loading durante submit

```gherkin
Dado que o usuário preencheu o formulário e clicou em "Enviar link"
Quando a chamada à API está em andamento
Então o botão "Enviar link" exibe estado "loading" (spinner + label "Enviando...")
  E o campo de e-mail fica desabilitado durante o processamento
```

### CA-05 — Erro de rede

```gherkin
Dado que o usuário está em /recuperar-senha
Quando tenta enviar o formulário e ocorre falha de conexão ou timeout
Então o sistema exibe DS/AlertBanner variante "danger":
  "Erro ao processar a solicitação. Verifique sua conexão e tente novamente."
  E o formulário permanece acessível para nova tentativa
```

### CA-06 — Navegação para o login

```gherkin
Dado que o usuário está em /recuperar-senha
Quando clica no botão/ícone "Voltar" (variante ghost + ícone ArrowLeft)
Então é redirecionado para /login (F0.1)
```

---

## 4. Componentes de UI (Design System)

| Componente | Variante | Uso |
|------------|---------|-----|
| `Shell/AuthLayout` | `state=default` | Shell da tela |
| `DS/Input` | `state=default` / `state=error` | Campo de e-mail |
| `DS/Button` | `variant=primary` | Botão "Enviar link" |
| `DS/Button` | `variant=ghost, icon=ArrowLeft` | Botão voltar |
| `DS/AlertBanner` | `info` (ícone Mail) | Mensagem de sucesso neutral |
| `DS/AlertBanner` | `danger` | Erro de rede |

---

## 5. Contrato de API

**Request:**
```http
POST /auth/forgot-password
Content-Type: application/json

{
  "email": "ana.silva@ufpr.br"
}
```

**Response (202 — sempre, independente do e-mail existir):**
```json
{
  "message": "Se este e-mail estiver cadastrado, você receberá um link válido por 24 horas."
}
```

---

## 6. Fora de escopo desta história

- Envio de SMS como canal alternativo — não previsto no MVP
- Opção de recuperação via GRR — o campo aceita apenas e-mail nesta tela
- Reenvio automático de link expirado — coberto por nova requisição manual
- Cancelamento de tokens de reset ainda válidos — cobre US-F0-003 (token em blacklist após uso)

---

## 7. Definição de Pronto (DoD)

- [ ] Frames Figma aprovados: Default, Success, Error de rede
- [ ] `ForgotPasswordUseCase` implementado com cobertura ≥ 80%
- [ ] Outbox pattern: evento `iam.password_reset_requested` enfileirado na mesma transação
- [ ] Template de e-mail `PASSWORD_RESET` criado e testado
- [ ] Resposta 202 idêntica para e-mail existente/inexistente (teste de enumeração)
- [ ] Rate limit de 3 req/hora por e-mail+IP implementado e testado
- [ ] Auditoria registrada mesmo quando o e-mail não existe

---

## 8. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas0/F0.2-recuperar-senha.md` |
| Fluxo de recuperação | `foundationDocs/analysis/fluxos_por_perfil.md` §1 F0.2 |
| Mapa de rotas | `foundationDocs/analysis/telas.md` §2 F0.2 |
| História relacionada | [US-F0-003](./US-F0-003-NOVA-SENHA.md) — Definir nova senha via token |
| Página Figma F0 | [Telas / F0 — Público](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=18-152) |
