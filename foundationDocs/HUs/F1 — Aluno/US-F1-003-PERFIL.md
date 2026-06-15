# US-F1-003 — Gerenciar Perfil, Segurança e Notificações

| Campo | Valor |
|-------|-------|
| **ID** | US-F1-003 |
| **Épico** | ALUNO-PERFIL |
| **Telas** | F1.3 `/perfil` · F1.4 `/perfil/seguranca` · F1.5 `/perfil/notificacoes` |
| **Prioridade** | P2 |
| **Plataforma** | Web + Mobile |
| **Capability** | `user.update_own_profile` / `user.*` |
| **API primária** | `GET /me`, `PATCH /me`, `GET /me/sessions`, `DELETE /me/sessions/:id`, `PATCH /me/notifications` |
| **Frames Figma** | **F1.3:** [Edit/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=88-3003) · [Edit/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=106-7000) · **F1.4:** [Default/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=88-3138) · [Default/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=106-7324) · **F1.5:** [Default/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=88-3257) · [Default/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=106-7698) |
| **Specs de tela** | `telasFigma/telas1/F1.3-perfil.md` · `F1.4-perfil-seguranca.md` · `F1.5-perfil-notificacoes.md` |

---

## Histórias

Esta US cobre 3 sub-funcionalidades agrupadas no mesmo épico de autogestão.

---

### HU-A — Editar dados pessoais (F1.3)

> **Como** aluno autenticado,  
> **Quero** editar meus dados pessoais (nome social, telefone, e-mail de contato, foto de perfil),  
> **Para** manter minhas informações atualizadas para comunicações da secretaria.

### HU-B — Trocar senha e gerenciar sessões (F1.4)

> **Como** aluno autenticado,  
> **Quero** trocar minha senha e visualizar e encerrar sessões ativas em outros dispositivos,  
> **Para** manter minha conta segura.

### HU-C — Configurar preferências de notificação (F1.5)

> **Como** aluno autenticado,  
> **Quero** configurar quais canais (e-mail, push, in-app) recebo para cada tipo de notificação, definir horário de DND e escolher entre entrega imediata ou digest,  
> **Para** não ser inundado de notificações e receber o que é importante no canal certo.

---

## 2. Regras de Negócio

### Dados pessoais (F1.3)

| ID | Regra |
|----|-------|
| **RN-F1.3-01** | Campos editáveis: nome social (opcional), telefone, e-mail pessoal. Campos **não editáveis pelo aluno**: GRR, e-mail institucional, curso, período — exibidos somente leitura. |
| **RN-F1.3-02** | A foto de perfil deve ser processada em crop circular antes do upload. Formatos aceitos: JPEG, PNG, WebP. Tamanho máximo: 2 MB. O arquivo é enviado para MinIO via URL pré-assinada. |
| **RN-F1.3-03** | O formulário exibe "dirty state" (botão Salvar fica habilitado) ao detectar mudança em qualquer campo. Botão "Cancelar" desfaz as alterações sem chamar a API. |

### Segurança (F1.4)

| ID | Regra |
|----|-------|
| **RN-F1.4-01** | Trocar senha exige confirmação da **senha atual** antes de aceitar a nova. Sem isso, não é possível alterar a senha. |
| **RN-F1.4-02** | A nova senha segue os mesmos requisitos de complexidade de US-F0-003. |
| **RN-F1.4-03** | A lista de sessões ativas exibe para cada sessão: dispositivo (User-Agent simplificado), IP, data do último uso. |
| **RN-F1.4-04** | Encerrar uma sessão específica é possível somente se `_links.encerrar` existir para aquela sessão na resposta. A sessão atual **não pode** ser encerrada por esta tela. |
| **RN-F1.4-05** | Ao trocar a senha, **todas as outras sessões** (exceto a atual) são invalidadas automaticamente. |

### Notificações (F1.5)

| ID | Regra |
|----|-------|
| **RN-F1.5-01** | A matriz de notificações é `prioridade × canal`. Prioridades: CRITICAL, HIGH, MEDIUM, LOW. Canais: push, e-mail, in-app. |
| **RN-F1.5-02** | Notificações CRITICAL **não podem** ser desabilitadas pelo usuário (ex.: bloqueio de conta, redefinição de senha). Os switches ficam bloqueados para estas. |
| **RN-F1.5-03** | O horário DND (Do Not Disturb) bloqueia push durante o período configurado. Notificações HIGH e CRITICAL ainda chegam por e-mail mesmo no horário DND. |
| **RN-F1.5-04** | Modo "digest" agrega todas as notificações não-críticas do dia em um único e-mail ao final do período configurado. |

---

## 3. Critérios de Aceitação

### CA-01 — Editar dados pessoais

```gherkin
Dado que o aluno está em /perfil
Quando altera o campo "Telefone" para um novo valor
Então o botão "Salvar" fica habilitado (dirty state)
  E ao clicar em "Salvar" o sistema realiza PATCH /me { telefone: "..." }
  E exibe DS/Toast success: "Perfil atualizado com sucesso."
  E ao clicar em "Cancelar" antes de salvar, os valores voltam ao estado original sem chamada à API
```

### CA-02 — Upload de foto de perfil

```gherkin
Dado que o aluno está em /perfil
Quando clica em "Alterar foto" e seleciona uma imagem JPEG de 1 MB
Então abre modal de crop circular para ajustar a imagem
  E ao confirmar, a imagem é enviada para MinIO via URL pré-assinada
  E o DS/Avatar é atualizado com a nova foto
  E se a imagem exceder 2 MB, exibe erro: "A imagem deve ter no máximo 2 MB."
```

### CA-03 — Trocar senha

```gherkin
Dado que o aluno está em /perfil/seguranca
Quando preenche "Senha atual" corretamente e "Nova senha" + "Confirmar nova senha" com senha forte
  E clica em "Salvar senha"
Então o sistema realiza PATCH /me/password { senhaAtual: "...", novaSenha: "..." }
  E ao receber 200 OK: todas as outras sessões são invalidadas
  E exibe DS/AlertBanner success: "Senha alterada. Outras sessões foram encerradas."
  
Quando preenche "Senha atual" incorretamente
Então recebe 401 e exibe erro inline: "Senha atual incorreta."
```

### CA-04 — Encerrar sessão de outro dispositivo

```gherkin
Dado que o aluno está em /perfil/seguranca
  E a lista de sessões exibe uma sessão de "iPhone — Safari" com _links.encerrar
Quando clica em "Encerrar" para esta sessão
Então o sistema realiza DELETE /me/sessions/{sessionId}
  E a sessão é removida da lista
  E o dispositivo correspondente perde acesso (refresh token inválido)
  E a sessão atual NÃO aparece com botão de encerramento
```

### CA-05 — Configurar notificações

```gherkin
Dado que o aluno está em /perfil/notificacoes
Quando desabilita o switch de "push" para notificações de prioridade MEDIUM
  E clica em "Salvar preferências"
Então o sistema realiza PATCH /me/notifications com a nova configuração
  E a partir deste ponto, notificações de prioridade MEDIUM não chegam por push
  
Quando tenta desabilitar notificações CRITICAL
Então os switches para canais CRITICAL estão bloqueados (disabled) e não podem ser alterados
```

---

## 4. Componentes de UI (Design System)

| Componente | Tela | Uso |
|------------|------|-----|
| `DS/Avatar` | F1.3 | Foto de perfil com fallback de iniciais |
| `DS/Input` | F1.3, F1.4 | Campos de texto e senha |
| `DS/Select` | F1.3 | Identidade de gênero (opcional) |
| `DS/Button` | todas | Salvar, Cancelar, Encerrar sessão |
| `DS/Switch` | F1.5 | Toggles de canais por prioridade |
| `DS/DataTable` | F1.4 | Lista de sessões ativas |
| `DS/Card` | todas | Container de cada seção |
| `DS/Progress` | F1.4 | Medidor de força de senha |

---

## 5. Fora de escopo

- Exclusão de conta (LGPD right-to-erasure) — fora do MVP
- Autenticação de dois fatores (2FA) — fase posterior
- Histórico de alterações de perfil — não previsto no MVP

---

## 6. Definição de Pronto (DoD)

- [ ] Frames Figma aprovados: Perfil (edit + saving), Segurança, Notificações
- [ ] Upload de foto: crop + minIO + fallback de iniciais funcionando
- [ ] Sessões: lista + encerramento individual com HATEOAS
- [ ] Troca de senha invalida outras sessões (teste de integração)
- [ ] Matriz de notificações: CRITICAL não pode ser desabilitado
- [ ] Dirty state: "Salvar" habilitado somente após alteração

---

## 7. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Specs de tela | `telasFigma/telas1/F1.3-perfil.md`, `F1.4-perfil-seguranca.md`, `F1.5-perfil-notificacoes.md` |
| Fluxo aluno | `foundationDocs/analysis/fluxos_por_perfil.md` §2 F1.10 |
| Página Figma F1 | [Telas / F1 — Aluno](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=48-339) |
| Frame F1.3 principal | [F1.3 — Perfil / Edit / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=88-3003) |
| Frame F1.4 principal | [F1.4 — Segurança / Default / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=88-3138) |
| Frame F1.5 principal | [F1.5 — Notificações / Default / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=88-3257) |
