# US-F0-003 — Definir Nova Senha via Token

| Campo | Valor |
|-------|-------|
| **ID** | US-F0-003 |
| **Épico** | AUTH-RESET |
| **Tela** | F0.3 — `/nova-senha?token=` |
| **Prioridade** | P1 |
| **Plataforma** | Web + Mobile |
| **API primária** | `POST /auth/reset-password` |
| **Frames Figma** | [Token válido](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=27-306) · [Token inválido](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=27-353) |
| **Spec de tela** | `telasFigma/telas0/F0.3-nova-senha.md` |
| **Depende de** | US-F0-002 (solicitação do link por e-mail) |
| **Substitui (legado)** | `web/alterarSenha.jsp` [T03, T04] |

---

## 1. História de Usuário

> **Como** um usuário que clicou no link de redefinição recebido por e-mail,  
> **Quero** definir uma nova senha que atenda aos requisitos de segurança,  
> **Para** recuperar o acesso à minha conta com uma credencial que só eu conheço.

---

## 2. Regras de Negócio

### Validação do token

| ID | Regra |
|----|-------|
| **RN-F0.3-01** | O parâmetro `?token=` deve ser um JWT válido assinado com a chave do servidor, com `audience = "password-reset"` e `JTI` presente. O backend valida: assinatura, audience, expiração e se o JTI **não está** na blacklist de tokens consumidos. |
| **RN-F0.3-02** | Se o token for **inválido, expirado ou já utilizado**, a tela exibe estado `EmptyState` com mensagem: `"Link inválido ou expirado."` e botão "Solicitar novo link" → `/recuperar-senha`. Nenhum formulário de senha é exibido. |
| **RN-F0.3-03** | O token é de **uso único**: após a conclusão bem-sucedida do reset, o JTI é imediatamente inserido na blacklist (`iam_jti_blacklist`), tornando re-usos impossíveis. |

### Requisitos da nova senha

| ID | Regra |
|----|-------|
| **RN-F0.3-04** | A nova senha deve ter **no mínimo 12 caracteres**. |
| **RN-F0.3-05** | A nova senha deve conter pelo menos um de cada: letra maiúscula, letra minúscula, dígito numérico e caractere especial (`!@#$%^&*`). |
| **RN-F0.3-06** | A nova senha **não pode ser igual a nenhuma das 3 senhas anteriores** do usuário. O backend compara os hashes Argon2id armazenados. |
| **RN-F0.3-07** | Os campos "Nova senha" e "Confirmar senha" devem ser idênticos. A validação de igualdade é feita no frontend antes do envio, com mensagem de erro inline. |

### Pós-reset

| ID | Regra |
|----|-------|
| **RN-F0.3-08** | Após o reset bem-sucedido, **todas as sessões ativas** do usuário são invalidadas (tokens de acesso e refresh existentes são revogados). O usuário deve fazer login novamente. |
| **RN-F0.3-09** | O campo `usuario.senha_alterada` é definido como `true` após o reset. |
| **RN-F0.3-10** | O evento `iam.password_reset_completed` é emitido e registrado em `audit_log` com: `actor_id`, IP, timestamp, JTI utilizado. |
| **RN-F0.3-11** | Após o reset, o usuário é redirecionado para `/login` com `DS/AlertBanner` variante `success`: `"Senha redefinida com sucesso. Faça login com a nova senha."` |

---

## 3. Critérios de Aceitação

### CA-01 — Fluxo principal (token válido, senha forte)

```gherkin
Dado que o usuário acessou /nova-senha?token=<JWT_válido_não_consumido>
  E o token não está expirado e o JTI não está na blacklist
Quando o frontend carrega a tela
Então exibe o formulário: campo "Nova senha", medidor de força e campo "Confirmar senha"
  E a lista de requisitos (mínimo 12 chars, maiúscula, minúscula, número, especial) está visível
```

### CA-02 — Medidor de força de senha em tempo real

```gherkin
Dado que o formulário de nova senha está visível
Quando o usuário digita no campo "Nova senha"
Então o componente DS/Progress (medidor de força) atualiza em tempo real:
  - 1 segmento (danger): < 8 chars ou critérios insuficientes
  - 2 segmentos (warning): critérios parciais
  - 3 segmentos (warning/success): maioria dos critérios
  - 4 segmentos (success): todos os critérios atendidos
  E cada requisito na lista exibe ícone ✓ verde quando cumprido individualmente
```

### CA-03 — Validação de confirmação de senha (frontend)

```gherkin
Dado que o usuário preencheu "Nova senha" e "Confirmar senha" com valores diferentes
Quando clica em "Salvar senha"
Então o sistema NÃO realiza chamada à API
  E exibe mensagem de erro inline sob "Confirmar senha": "As senhas não coincidem"
  E o campo "Confirmar senha" exibe borda "border/error"
```

### CA-04 — Senha igual a uma das 3 últimas (rejeição do backend)

```gherkin
Dado que o usuário informou uma nova senha igual a uma das últimas 3 senhas cadastradas
Quando clica em "Salvar senha" e o backend processa a requisição
Então o sistema retorna 422 Unprocessable Entity (RFC 7807)
  E exibe DS/AlertBanner variante "danger":
    "Esta senha já foi utilizada recentemente. Escolha uma senha diferente."
  E o campo "Nova senha" é limpo
```

### CA-05 — Conclusão bem-sucedida

```gherkin
Dado que o usuário preencheu "Nova senha" com senha que atende todos os requisitos
  E "Confirmar senha" é igual à "Nova senha"
Quando clica em "Salvar senha"
Então o sistema realiza POST /auth/reset-password { token, novaSenha }
  E ao receber 200 OK:
    - o JTI é inserido na blacklist (sem possibilidade de re-uso)
    - todas as sessões ativas do usuário são invalidadas
    - usuario.senha_alterada é definido como true
    - o evento iam.password_reset_completed é gravado em audit_log
  E o usuário é redirecionado para /login
  E /login exibe DS/AlertBanner success: "Senha redefinida com sucesso."
```

### CA-06 — Token inválido ou expirado

```gherkin
Dado que o usuário acessou /nova-senha?token=<JWT_expirado_ou_inválido>
Quando o frontend tenta validar o token com o backend
Então o formulário NÃO é exibido
  E exibe DS/EmptyState com:
    - ícone de alerta
    - título: "Link inválido ou expirado"
    - descrição: "Este link não é mais válido. Solicite um novo para redefinir sua senha."
    - botão primário: "Solicitar novo link" → /recuperar-senha
```

### CA-07 — Token já utilizado (JTI na blacklist)

```gherkin
Dado que o usuário acessou /nova-senha?token=<JWT_já_consumido>
Quando o frontend tenta validar o token com o backend
Então o comportamento é idêntico ao CA-06 (token inválido)
  E a mensagem NÃO revela se o token foi "já usado" ou apenas "inválido"
```

---

## 4. Componentes de UI (Design System)

| Componente | Variante | Uso |
|------------|---------|-----|
| `Shell/AuthLayout` | `state=default` | Shell da tela |
| `DS/Input` | `type=password, state=default/error` | Nova senha |
| `DS/Input` | `type=password, state=default/error` | Confirmar senha |
| `DS/Progress` | barra 4 níveis (danger→warning→success) | Medidor de força |
| `DS/Button` | `variant=primary` | Botão "Salvar senha" |
| `DS/AlertBanner` | `danger` | Senha reutilizada / erro de servidor |
| `DS/EmptyState` | ícone alerta | Token inválido/expirado |

---

## 5. Contrato de API

**Request:**
```http
POST /auth/reset-password
Content-Type: application/json

{
  "token": "eyJ...",
  "novaSenha": "MinhaNovaSenh@2026"
}
```

**Response (200 OK):**
```json
{
  "message": "Senha redefinida com sucesso."
}
```

**Response (422 — senha reutilizada):**
```json
{
  "type": "https://api.secretaria.ufpr.br/errors/password-reuse",
  "title": "Senha já utilizada",
  "status": 422,
  "detail": "Esta senha já foi utilizada recentemente. Escolha uma senha diferente."
}
```

**Response (401 — token inválido/expirado/consumido):**
```json
{
  "type": "https://api.secretaria.ufpr.br/errors/invalid-reset-token",
  "title": "Link inválido",
  "status": 401,
  "detail": "O link de redefinição é inválido ou expirou."
}
```

---

## 6. Fora de escopo desta história

- Verificação de força de senha em tempo real via API — feita exclusivamente no frontend
- Expiração de sessões em outros dispositivos notificada via push — notificação por e-mail é suficiente para o MVP
- Desbloqueio de conta bloqueada via reset de senha — o desbloqueio expira automaticamente (15 min) independentemente

---

## 7. Definição de Pronto (DoD)

- [ ] Frames Figma aprovados: Token válido, Token inválido/expirado
- [ ] `ResetPasswordUseCase` implementado com cobertura ≥ 85%
- [ ] JTI blacklist funcionando: token não pode ser usado duas vezes
- [ ] Invalidação de todas as sessões ativas ao concluir o reset
- [ ] Histórico de senhas: rejeição das últimas 3 testada em integração
- [ ] Requisitos de força de senha validados no backend (não apenas frontend)
- [ ] Auditoria `iam.password_reset_completed` gravada em `audit_log`

---

## 8. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas0/F0.3-nova-senha.md` |
| Fluxo de recuperação | `foundationDocs/analysis/fluxos_por_perfil.md` §1 F0.2 |
| Mapa de rotas | `foundationDocs/analysis/telas.md` §2 F0.3 |
| História de origem | [US-F0-002](./US-F0-002-RECUPERAR-SENHA.md) — Solicitar link |
| Página Figma F0 | [Telas / F0 — Público](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=18-152) |
