# US-F5-003 — Gestão de Alunos

| Campo | Valor |
|-------|-------|
| **ID** | US-F5-003 |
| **Épico** | SECR-CADASTROS |
| **Telas** | F5.6 — Alunos |
| **Rota** | `/secretaria/alunos` |
| **Prioridade** | P2 |
| **Capability** | `user.manage_students` |
| **APIs** | `GET /students` · `POST /students` · `PATCH /students/:id` · `POST /students/:id/reset-password` · `POST /students/:id/matricula` |
| **Frames Figma** | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1598) · [Drawer aberto](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=581-4554) |

---

## História de Usuário

> **Como** secretária acadêmica,  
> **quero** buscar, cadastrar, editar e administrar contas de alunos (incluindo reset de senha e matrícula em disciplinas),  
> **para que** eu possa manter o cadastro atualizado sem precisar de acesso direto ao banco de dados.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F5-003-01 | Somente usuários com capability `user.manage_students` acessam esta tela. |
| RN-F5-003-02 | A busca suporta GRR (match exato), nome (trigrama, case-insensitive) e e-mail (prefix match). Os três campos são combinados com `OR`. |
| RN-F5-003-03 | O formulário de aluno (exibido em `DS/Drawer`) contém: nome completo, GRR, CPF (máscara), e-mail institucional, curso, período de ingresso, situação (ATIVO/INATIVO/TRANCADO). |
| RN-F5-003-04 | CPF e GRR são únicos no sistema; a API retorna HTTP 409 com campo e valor em conflito caso haja duplicidade. |
| RN-F5-003-05 | **Reset de senha:** gera nova senha temporária (12 chars, Argon2id) e envia por e-mail ao aluno. A senha deve ser trocada no próximo login (`mustChangePassword = true`). Ação registrada em `audit_log`. |
| RN-F5-003-06 | **Matrícula:** vincula o aluno a uma ou mais disciplinas no período vigente. A disciplina deve existir no catálogo e estar com vagas disponíveis; caso contrário a API retorna HTTP 422. |
| RN-F5-003-07 | Todas as mutações (criar, editar, reset, matricular) geram entrada em `audit_log` com `userId` do operador, `timestamp` e `payload` da alteração. |
| RN-F5-003-08 | A secretária só pode gerenciar alunos dos cursos para os quais possui capability; alunos de outros cursos aparecem como resultado de busca mas sem ações de edição (`_links` ausentes). |
| RN-F5-003-09 | O Drawer fecha ao confirmar a ação com sucesso e a linha da tabela é atualizada via invalidação de cache TanStack Query sem recarregar a página inteira. |

---

## Critérios de Aceitação

### CA-F5-003-01 — Busca de alunos

```gherkin
Dado que a secretária acessa /secretaria/alunos
Quando ela digita "João" na barra de busca
Então a tabela exibe os alunos cujo nome contém "João" (trigrama)
E cada linha mostra: Nome, GRR, Curso, Período, Situação
```

### CA-F5-003-02 — Cadastrar novo aluno

```gherkin
Dado que a secretária clica em "Novo aluno"
Quando o Drawer abre e ela preenche todos os campos obrigatórios
E clica em "Salvar"
Então a API recebe POST /students com os dados
E o aluno aparece na tabela
E um e-mail de boas-vindas com senha temporária é enviado via Outbox
```

### CA-F5-003-03 — Editar aluno

```gherkin
Dado que a secretária clica em "Editar" na linha de um aluno do seu curso
Quando o Drawer abre com os dados pré-preenchidos
E ela altera o período de ingresso
E salva
Então a API recebe PATCH /students/:id
E a linha na tabela reflete a alteração sem recarregar a página
```

### CA-F5-003-04 — Reset de senha

```gherkin
Dado que a secretária clica em "Reset senha" para um aluno
Quando um dialog de confirmação aparece e ela confirma
Então a API envia POST /students/:id/reset-password
E o aluno recebe e-mail com nova senha temporária
E audit_log registra a ação com o ID da secretária e timestamp
E mustChangePassword é marcado como true para o aluno
```

### CA-F5-003-05 — Conflito de GRR

```gherkin
Dado que já existe um aluno com GRR "20231234"
Quando a secretária tenta cadastrar outro aluno com o mesmo GRR
Então a API retorna HTTP 409
E o Drawer exibe uma mensagem de erro inline no campo GRR
```

### CA-F5-003-06 — Aluno de outro curso (HATEOAS)

```gherkin
Dado que a secretária busca um aluno de um curso que ela não gerencia
Quando o aluno aparece nos resultados
Então as ações "Editar", "Reset senha" e "Matricular" não são exibidas para essa linha
E uma tooltip indica "Sem permissão para este curso"
```

---

## Componentes de UI

- `DS/DataTable` (com row actions)
- `DS/Drawer` (formulário de aluno)
- `DS/Input` (busca, campos do formulário)
- `DS/Badge` (situação do aluno)
- `DS/Skeleton`
- `DS/EmptyState`
- Dialog de confirmação (reset senha)

---

## Contrato de API

```
GET /students?q=João&page=0&size=20
GET /students/:id
POST /students
PATCH /students/:id
POST /students/:id/reset-password
POST /students/:id/matricula  Body: { "disciplinaIds": ["..."] }

Resposta padrão inclui _links:
{
  "_links": {
    "edit": { "href": "/students/:id" },
    "reset-password": { "href": "/students/:id/reset-password" },
    "matricula": { "href": "/students/:id/matricula" }
  }
}
```

---

## Fora de Escopo

- Exclusão permanente de aluno (soft-delete via situação INATIVO)
- Histórico de disciplinas cursadas (ver sistema SIGA/legado)
- Geração de declarações (ver módulo de solicitações)

---

## Definition of Done

- [ ] Busca por GRR, nome e e-mail operacional
- [ ] CRUD completo com Drawer
- [ ] Reset de senha com `mustChangePassword` e Outbox e-mail
- [ ] Matrícula em disciplina com validação de vagas
- [ ] `audit_log` para todas as mutações
- [ ] HATEOAS: ações ocultas para alunos de outros cursos
- [ ] Testes: conflito CPF/GRR, reset, matrícula sem vagas

---

## Referências

- Frame principal: [F5.6 Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1598)
- Fluxo F5.4 CRUD aluno: `foundationDocs/analysis/fluxos_por_perfil.md` §6.4
- JPA interfaces: `foundationDocs/analysis/jpaInterfaces_PostgresEntities.md`
