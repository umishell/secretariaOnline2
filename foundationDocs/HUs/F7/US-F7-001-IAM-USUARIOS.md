# US-F7-001 — Gestão de Usuários e Reset de Senha (Administrativo)

| Campo | Valor |
|-------|-------|
| **ID** | US-F7-001 |
| **Épico** | ADMIN-IAM |
| **Telas** | F7.1 — Usuários, F7.8 — Reset Senha |
| **Rotas** | `/admin/usuarios` · `/admin/usuarios/:id/reset-senha` |
| **Prioridade** | P2 |
| **Capabilities** | `user.manage_all` · `user.reset_password` |
| **APIs** | `/admin/usuarios` CRUD · `POST /users/:id/password-reset` |
| **Frames Figma** | [Usuários Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-5180) · [Reset Modal](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6862) |

---

## História de Usuário

> **Como** administrador da plataforma,  
> **quero** gerenciar todos os usuários do sistema (criar, editar, desativar, atribuir perfis) e disparar reset de senha por link de uso único,  
> **para que** o acesso ao sistema esteja sempre correto e seguro, sem que eu precise manipular senhas diretamente.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F7-001-01 | Somente usuários com capability `user.manage_all` acessam `/admin/usuarios`. A capability `user.manage_students` (da secretaria) é um subconjunto; o admin opera sobre todos os tipos de usuário. |
| RN-F7-001-02 | Colunas da tabela: Nome, E-mail, Tipo (ALUNO/PROFESSOR/SECRETARIA/COORDENADOR/EGRESSO/ADMIN), Situação (ATIVO/INATIVO), Último acesso. |
| RN-F7-001-03 | Busca na `DS/FilterBar` por nome (trigrama), e-mail (prefix) e GRR/matrícula (exato). |
| RN-F7-001-04 | Ações por linha via `_links` (HATEOAS): `edit`, `deactivate`, `reset-password`, `manage-roles`. Botões ausentes se `rel` não presente. |
| RN-F7-001-05 | Ao criar um usuário, o sistema gera automaticamente uma senha temporária (Argon2id) e envia por e-mail via Outbox. O campo `mustChangePassword = true` é definido. O operador **nunca visualiza** a senha. |
| RN-F7-001-06 | **Desativação:** altera `status = INATIVO`; invalida todos os tokens JWT ativos do usuário via JTI blacklist. Não exclui dados históricos. |
| RN-F7-001-07 | **Reset de senha (F7.8):** gera link JWT de uso único (JTI único, válido por 24 h, Argon2id na ativação). O modal de confirmação não exibe nenhum campo de senha — apenas confirma o envio. Anotação Figma: `"Operador NUNCA vê senha — apenas confirma envio de link 1-uso (24h)"`. |
| RN-F7-001-08 | Após o envio do link de reset, um `DS/AlertBanner` informativo é exibido: "Link de redefinição enviado para [email]". O link enviado ao usuário segue o padrão `/redefinir-senha?token=<JWT>` (ver F0.3). |
| RN-F7-001-09 | Todas as ações de criação, edição, desativação e reset são registradas em `audit_log` com `operadorId`, `targetUserId`, `acao`, `timestamp` e `payload` (valores alterados). |
| RN-F7-001-10 | Paginação padrão: 20 usuários por página. A tabela suporta ordenação por Nome e Último acesso. |

---

## Critérios de Aceitação

### CA-F7-001-01 — Listar e filtrar usuários

```gherkin
Dado que o admin acessa /admin/usuarios
Quando a tabela carrega
Então todos os usuários do sistema são exibidos com Nome, E-mail, Tipo, Situação, Último acesso
E a busca filtra por nome (trigrama), e-mail e GRR em tempo real (debounce 300 ms)
```

### CA-F7-001-02 — Criar usuário

```gherkin
Dado que o admin clica em "Novo"
Quando preenche Nome, E-mail, Tipo e Curso (se aplicável) e salva
Então a API cria o usuário com mustChangePassword=true
E o usuário recebe e-mail com link de acesso inicial via Outbox
E o admin nunca visualiza a senha criada
```

### CA-F7-001-03 — Desativar usuário

```gherkin
Dado que o admin clica em "Desativar" na linha de um usuário ativo
Quando confirma o dialog destrutivo
Então a API atualiza status=INATIVO via PATCH /admin/usuarios/:id
E todos os tokens JWT do usuário são invalidados via JTI blacklist
E a linha exibe badge "Inativo"
E o audit_log registra a ação
```

### CA-F7-001-04 — Reset de senha (F7.8) — operador nunca vê senha

```gherkin
Dado que o admin clica em "Reset senha" na linha de um usuário
Quando o modal DS/Dialog · Reset senha é exibido
Então o modal mostra apenas o nome do usuário e um botão "Confirmar envio"
E não há nenhum campo de senha ou exibição de credencial
Quando o admin confirma
Então a API recebe POST /users/:id/password-reset
E o usuário recebe e-mail com link JWT 1-uso válido por 24 h
E o DS/AlertBanner informativo é exibido: "Link enviado para [email]"
```

### CA-F7-001-05 — Link de reset expirado

```gherkin
Dado que um link de reset foi enviado há mais de 24 h e não foi usado
Quando o usuário tenta usá-lo
Então a API retorna HTTP 401 "Token expirado"
E a UI de redefinição (F0.3) exibe mensagem de erro com link para solicitar novo reset
```

### CA-F7-001-06 — HATEOAS: ações condicionais

```gherkin
Dado que um usuário tem status INATIVO
Quando o admin visualiza sua linha na tabela
Então o botão "Desativar" não é exibido (rel "deactivate" ausente)
E apenas os botões "Editar" e "Reset senha" estão disponíveis via _links
```

---

## Componentes de UI

- `Shell/AdminLayout`
- `DS/DataTable/Full` (tabela completa)
- `DS/FilterBar` (busca)
- `DS/Button` ("Novo", ações de linha)
- `DS/Pagination`
- `DS/Badge` (tipo e situação)
- `DS/Skeleton`, `DS/EmptyState`
- `DS/Dialog · Reset senha` (modal F7.8 — sem campo senha)
- `DS/AlertBanner · info` (confirmação após reset)

---

## Contrato de API

```
GET /admin/usuarios?q=João&tipo=ALUNO&status=ATIVO&page=0&size=20
POST /admin/usuarios  Body: { nome, email, tipo, cursoId?, mustChangePassword: true }
PATCH /admin/usuarios/:id  Body: { status: "INATIVO" }
POST /users/:id/password-reset  → gera link JWT 1-uso, envia e-mail

Resposta inclui _links:
{
  "_links": {
    "edit": ..., "deactivate": ..., "reset-password": ..., "manage-roles": ...
  }
}
```

---

## Fora de Escopo

- Exclusão permanente de usuário (apenas desativação — soft delete)
- Importação em lote de usuários via admin (ver US-F5-009)
- Visualização do histórico de senhas

---

## Definition of Done

- [ ] CRUD completo de usuários com `Shell/AdminLayout`
- [ ] Reset de senha: link JWT 1-uso, modal sem campo de senha, AlertBanner pós-envio
- [ ] Desativação invalida JTI blacklist
- [ ] HATEOAS: ações condicionais por `_links`
- [ ] `audit_log` para todas as mutações
- [ ] Testes: reset expirado, desativação invalida token, HATEOAS

---

## Referências

- Frame Usuários: [F7.1](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-5180)
- Frame Reset Senha: [F7.8](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6862)
- Fluxo F7.1 IAM e F7.6 Reset: `foundationDocs/analysis/fluxos_por_perfil.md` §8.1, §8.6
- Redefinir senha (fluxo do usuário): US-F0-003
