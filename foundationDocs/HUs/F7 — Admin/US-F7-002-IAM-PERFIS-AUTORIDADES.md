# US-F7-002 — Perfis (Roles) e Matriz de Autoridades

| Campo | Valor |
|-------|-------|
| **ID** | US-F7-002 |
| **Épico** | ADMIN-IAM |
| **Telas** | F7.2 — Perfis, F7.3 — Autoridades |
| **Rotas** | `/admin/perfis` · `/admin/autoridades` · `/admin/usuarios/:id/roles` |
| **Prioridade** | P2 |
| **Capabilities** | `iam.manage_roles` · `iam.manage_authorities` |
| **APIs** | `/admin/perfis` CRUD · `/admin/autoridades` CRUD · `PUT /users/:id/roles` |
| **Frames Figma** | [Perfis](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-5396) · [Autoridades](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-5612) |

---

## História de Usuário

> **Como** administrador da plataforma,  
> **quero** criar e gerenciar perfis (roles) como agregadores de capabilities, definir capabilities granulares (authorities) e atribuí-las a usuários via matriz,  
> **para que** o sistema de controle de acesso (FGAC) reflita exatamente as responsabilidades de cada pessoa sem necessidade de mudanças de código.

---

## Regras de Negócio

### Perfis / Roles (F7.2)

| ID | Regra |
|----|-------|
| RN-F7-002-01 | Somente usuários com `iam.manage_roles` acessam `/admin/perfis`. |
| RN-F7-002-02 | Um **perfil (role)** é um agregador de authorities (capabilities). Campos: Nome (único, snake_case), Descrição, lista de authorities vinculadas. |
| RN-F7-002-03 | Perfis pré-definidos do sistema (`ALUNO`, `PROFESSOR`, `SECRETARIA`, `COORDENADOR`, `EGRESSO`, `ADMIN`) não podem ser excluídos; apenas editados para adicionar/remover authorities. |
| RN-F7-002-04 | Perfis customizados podem ser criados (ex.: `PROFESSOR_TCC`, `MEMBRO_CAAF`) e atribuídos a usuários específicos via `/admin/usuarios/:id/roles`. |
| RN-F7-002-05 | A tela F7.2 usa a mesma tela F7.3 (Autoridades) como referência ao exibir o painel de atribuição de authorities ao perfil. |
| RN-F7-002-06 | Excluir um perfil customizado só é possível se nenhum usuário ativo tiver esse perfil. A API retorna HTTP 422 com a lista de usuários bloqueantes. |

### Autoridades / Capabilities (F7.3)

| ID | Regra |
|----|-------|
| RN-F7-002-07 | Somente usuários com `iam.manage_authorities` acessam `/admin/autoridades`. |
| RN-F7-002-08 | Uma **authority (capability)** é uma string de permissão granular (ex.: `request.deliberate`, `event.host`, `tcc.supervise`). Campos: Nome (único, dot-notation), Descrição, Módulo (enum: IAM, SOLICITACOES, EVENTOS, etc.). |
| RN-F7-002-09 | A tela F7.3 exibe, além da tabela CRUD, o componente `DS/RoleAuthorityMatrix` — uma grade role × authority com checkboxes para atribuição em massa. Essa grade substitui a atribuição individual quando há múltiplos perfis para configurar. |
| RN-F7-002-10 | Authorities do sistema (definidas no código) são somente leitura na UI; apenas a descrição pode ser editada. |
| RN-F7-002-11 | **Atribuir role a usuário** (`/admin/usuarios/:id/roles`): modal acessado a partir da linha do usuário em F7.1 via `_link manage-roles`. Exibe uma matriz checkbox dos perfis disponíveis. |
| RN-F7-002-12 | Toda alteração na matriz (atribuição/remoção de authority a perfil, atribuição de perfil a usuário) invalida o cache de capabilities do usuário afetado (Redis/local cache). |
| RN-F7-002-13 | Todas as mutações IAM são registradas no `audit_log`. |

---

## Critérios de Aceitação

### CA-F7-002-01 — Listar perfis

```gherkin
Dado que o admin acessa /admin/perfis
Quando a tabela carrega
Então são exibidos os perfis com Nome, Descrição, Número de authorities vinculadas, Número de usuários
E os perfis pré-definidos têm badge "Sistema" e botão "Excluir" oculto
```

### CA-F7-002-02 — Criar perfil customizado

```gherkin
Dado que o admin clica em "Novo perfil"
Quando preenche Nome "membro_caaf" e seleciona as authorities: formative.review, formative.assign
E salva
Então a API recebe POST /admin/perfis com as authorities
E o perfil aparece na tabela com badge "Customizado"
```

### CA-F7-002-03 — Excluir perfil com usuários ativos

```gherkin
Dado que o perfil "membro_caaf" está atribuído a 3 usuários ativos
Quando o admin tenta excluí-lo
Então a API retorna HTTP 422
E a UI exibe AlertBanner: "Perfil em uso por 3 usuários — remova antes de excluir"
```

### CA-F7-002-04 — Listar e editar autoridades com matriz

```gherkin
Dado que o admin acessa /admin/autoridades
Quando a tela carrega
Então a tabela exibe as authorities com Nome, Módulo, Descrição
E abaixo da tabela o DS/RoleAuthorityMatrix exibe a grade role × authority com checkboxes
Quando o admin marca "PROFESSOR" × "event.host"
E salva
Então a API atualiza o perfil PROFESSOR adicionando a authority event.host
E o cache de capabilities de todos os usuários com perfil PROFESSOR é invalidado
```

### CA-F7-002-05 — Atribuir role a usuário (modal)

```gherkin
Dado que o admin clica em "Gerenciar roles" na linha do usuário "Maria"
Quando o modal de matriz de roles abre
Então os checkboxes mostram os perfis atuais de Maria marcados
Quando o admin adiciona o perfil "membro_caaf" e remove "SECRETARIA"
E confirma
Então a API recebe PUT /users/maria/roles com a nova lista de perfis
E o cache de capabilities de Maria é invalidado
E o audit_log registra a alteração
```

### CA-F7-002-06 — Authority somente leitura

```gherkin
Dado que a authority "request.deliberate" foi definida no código
Quando o admin tenta renomeá-la
Então o campo Nome está desabilitado
E apenas o campo Descrição é editável
```

---

## Componentes de UI

- `Shell/AdminLayout`
- `DS/DataTable/Full` (listas de perfis e authorities)
- `DS/FilterBar` (busca)
- `DS/Button` ("Novo", ações de linha)
- `DS/Pagination`
- `DS/Badge` (Sistema / Customizado)
- `DS/RoleAuthorityMatrix` (grade checkbox role × authority — F7.3)
- Modal de matriz de roles (atribuição de perfis a usuário)
- `DS/AlertBanner` (erros de exclusão)

---

## Contrato de API

```
# Perfis
GET /admin/perfis?q=...&page=0
POST /admin/perfis  Body: { nome, descricao, authorityIds: [...] }
PATCH /admin/perfis/:id  Body: { authorityIds: [...] }
DELETE /admin/perfis/:id

# Autoridades
GET /admin/autoridades?modulo=EVENTOS&page=0
POST /admin/autoridades  Body: { nome, descricao, modulo }
PATCH /admin/autoridades/:id  Body: { descricao }  // apenas descrição

# Atribuir role a usuário
PUT /users/:id/roles  Body: { roleIds: [...] }

# Matriz role × authority
PATCH /admin/perfis/:roleId/authorities
Body: { add: ["event.host"], remove: ["event.manage"] }
```

---

## Fora de Escopo

- Hierarquia de perfis (herança de permissions — não implementada no MVP)
- Criar authorities compostas (conjunção de múltiplas)

---

## Definition of Done

- [ ] CRUD de perfis com proteção dos pré-definidos
- [ ] CRUD de authorities com campo Nome somente leitura para as do sistema
- [ ] `DS/RoleAuthorityMatrix` operacional na F7.3
- [ ] Modal de atribuição de perfis a usuário funcional
- [ ] Invalidação de cache de capabilities após mudança
- [ ] `audit_log` para todas as mutações IAM
- [ ] Testes: excluir perfil com usuários ativos, authority somente leitura

---

## Referências

- Frame Perfis: [F7.2](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-5396)
- Frame Autoridades: [F7.3](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=727-5612)
- Fluxo F7.1 IAM: `foundationDocs/analysis/fluxos_por_perfil.md` §8.1
- Coordenador gere comissões via F7.2: US-F6-002 §F6.3
