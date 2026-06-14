# US-F0-005 — Exibir Página de Erro Amigável

| Campo | Valor |
|-------|-------|
| **ID** | US-F0-005 |
| **Épico** | PUB-STATIC |
| **Tela** | F0.5 — `/erro/:codigo` |
| **Prioridade** | P1 |
| **Plataforma** | Web + Mobile |
| **API primária** | Nenhuma (renderização baseada no código HTTP capturado) |
| **Frames Figma** | [401](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=30-332) · [403](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=30-363) · [404](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=30-394) · [500](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=30-425) |
| **Spec de tela** | `telasFigma/telas0/F0.5-erro.md` |
| **Substitui (legado)** | `menuErrado.jsp` [T11] + `exibirErro.jsp` [T155] |

---

## 1. História de Usuário

> **Como** qualquer usuário do sistema (autenticado ou não),  
> **Quero** ver uma mensagem de erro clara e amigável quando ocorrer uma falha (acesso negado, recurso não encontrado ou erro interno),  
> **Para** entender o que aconteceu, obter um ID de incidente para suporte e saber como prosseguir sem ficar preso em uma tela genérica.

---

## 2. Regras de Negócio

### Mapeamento de códigos de erro

| ID | Regra |
|----|-------|
| **RN-F0.5-01** | A tela `/erro/:codigo` deve cobrir no mínimo os 4 códigos canônicos: `401` (não autenticado), `403` (sem permissão), `404` (não encontrado), `500` (erro interno). Cada código possui ilustração, mensagem e paleta distintas. |
| **RN-F0.5-02** | Mapeamento de mensagens amigáveis por código: **401** → `"Você precisa fazer login para acessar esta página."` / **403** → `"Você não tem permissão para acessar este recurso."` / **404** → `"Página não encontrada. O link pode estar desatualizado."` / **500** → `"Erro inesperado no servidor. Nossa equipe foi notificada."` |
| **RN-F0.5-03** | Mapeamento de paleta semântica: **401** → neutro / **403** → `danger subtle` / **404** → neutro / **500** → `warning`. |
| **RN-F0.5-04** | Mapeamento de ilustrações `DS/EmptyState`: **401/403** → ícone cadeado / **404** → ícone arquivo riscado / **500** → ícone raio/trovão. |
| **RN-F0.5-05** | A tela deve exibir um **ID de incidente** gerado pelo backend no formato `INC-YYYY-XXXX` (para erros 5xx) ou derivado do contexto (para 4xx) que permita ao usuário acionar o suporte. |

### Botões de ação contextual

| ID | Regra |
|----|-------|
| **RN-F0.5-06** | Se o usuário **não estiver autenticado** (`401`): exibir botões `"Fazer login"` (primary → `/login`) e `"Ir ao início"` (secondary → `/`). |
| **RN-F0.5-07** | Se o usuário **estiver autenticado** (`403`, `404`, `500`): exibir botões `"Ir ao início"` (primary → `/inicio`) e `"Ir ao suporte"` (secondary → `/suporte`). |
| **RN-F0.5-08** | O roteador do frontend deve capturar erros de navegação (ex.: rota inexistente) e redirecionar para `/erro/404` automaticamente, sem expor stack traces. |
| **RN-F0.5-09** | Erros de API com código 5xx devem ser capturados pelo interceptor TanStack Query e redirecionar para `/erro/500`, passando o `incidentId` quando disponível no corpo RFC 7807 (`instance` field). |

---

## 3. Critérios de Aceitação

### CA-01 — Erro 401 (não autenticado)

```gherkin
Dado que um usuário não autenticado tenta acessar uma rota protegida
Quando o middleware detecta ausência de JWT válido
Então o sistema redireciona para /erro/401
  E a tela exibe: ícone cadeado, código "401" em destaque, mensagem amigável de sessão expirada
  E exibe botões: "Fazer login" (primary → /login) e "Ir ao início" (secondary → /)
  E a paleta de fundo é neutra (surface/default)
```

### CA-02 — Erro 403 (sem permissão)

```gherkin
Dado que um usuário autenticado tenta acessar recurso além de sua autorização
Quando o backend retorna 403 Forbidden
Então o sistema exibe /erro/403
  E a tela exibe: ícone cadeado, código "403", mensagem amigável de permissão negada
  E exibe botões: "Ir ao início" (primary → /inicio) e "Ir ao suporte" (secondary)
  E a paleta de fundo é "danger subtle" (surface/danger/subtle)
```

### CA-03 — Erro 404 (recurso não encontrado)

```gherkin
Dado que o usuário navega para uma URL inexistente no frontend
  OU o backend retorna 404 Not Found para uma chamada de API
Quando o roteador captura a rota desconhecida ou o interceptor captura a resposta 404
Então o sistema redireciona para /erro/404
  E a tela exibe: ícone arquivo riscado, código "404", mensagem amigável
  E exibe botões: "Ir ao início" e "Ir ao suporte"
  E a paleta é neutra
```

### CA-04 — Erro 500 (erro interno)

```gherkin
Dado que o backend retorna 5xx em qualquer chamada de API
Quando o interceptor do TanStack Query captura o erro
Então o sistema redireciona para /erro/500
  E a tela exibe: ícone raio, código "500", mensagem amigável de erro interno
  E exibe o ID de incidente: "ID do incidente: INC-2026-XXXX"
  E exibe botões: "Ir ao início" e "Ir ao suporte"
  E a paleta é "warning" (surface/warning/subtle)
```

### CA-05 — Exibição do ID de incidente

```gherkin
Dado que o backend retorna erro 5xx com campo "instance" no corpo RFC 7807
Quando a tela de erro 500 é exibida
Então o ID de incidente no campo "instance" é exibido abaixo da mensagem principal
  E o ID pode ser copiado pelo usuário para acionar o suporte
```

### CA-06 — Ausência de stack trace / dados técnicos

```gherkin
Dado que qualquer erro ocorre no sistema
Quando a tela de erro é exibida ao usuário
Então NENHUM stack trace, nome de classe, query SQL ou detalhe técnico interno é visível
  E a mensagem é sempre em linguagem natural e amigável
```

### CA-07 — Acessibilidade

```gherkin
Dado que um usuário utiliza leitor de tela
Então a ilustração da tela de erro possui alt text descritivo (ex: "Ícone de cadeado indicando acesso negado")
  E o código de erro e a mensagem são anunciados em sequência lógica de leitura
```

---

## 4. Componentes de UI (Design System)

| Componente | Variante | Uso |
|------------|---------|-----|
| `DS/EmptyState` | Variante por ícone (lock, file-x, zap) | Ilustração central |
| `DS/Button` | `variant=primary` | Ação principal (login / início) |
| `DS/Button` | `variant=secondary` | Ação secundária (suporte / início) |

---

## 5. Fora de escopo

- Logging automático de erros de frontend para o servidor — Sentry/OpenTelemetry é tarefa de DevOps
- Página de manutenção (503) — implementação futura quando houver janelas de manutenção planejadas
- Localização de mensagens de erro — apenas português neste MVP

---

## 6. Definição de Pronto (DoD)

- [ ] Frames Figma aprovados: variantes 401, 403, 404, 500
- [ ] Interceptor TanStack Query implementado para 4xx/5xx → `/erro/:codigo`
- [ ] Error boundary React captura erros de renderização → `/erro/500`
- [ ] Nenhum stack trace exposto em produção
- [ ] ID de incidente exibido para erros 500 quando disponível no RFC 7807
- [ ] Acessibilidade: alt text em ilustrações, sequência de leitura correta

---

## 7. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas0/F0.5-erro.md` |
| Mapa de rotas | `foundationDocs/analysis/telas.md` §2 F0.5 |
| RFC 7807 (Problem Details) | https://datatracker.ietf.org/doc/html/rfc7807 |
| Página Figma F0 | [Telas / F0 — Público](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=18-152) |
