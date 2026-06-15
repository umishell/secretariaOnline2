# US-F7-004 — Templates de Comunicação

| Campo | Valor |
|-------|-------|
| **ID** | US-F7-004 |
| **Épico** | ADMIN-TEMPLATES |
| **Telas** | F7.5 — Templates de Comunicação |
| **Rota** | `/admin/templates-comunicacao` |
| **Prioridade** | P2 |
| **Capability** | `communication.manage_templates` |
| **APIs** | `/communication-templates` CRUD · `GET /communication-templates/:id/versions` |
| **Frames Figma** | [Editor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6151) |

---

## História de Usuário

> **Como** administrador da plataforma,  
> **quero** criar e editar templates de e-mail e notificação em Markdown com placeholders dinâmicos e visualizar o preview com variáveis substituídas,  
> **para que** as comunicações automáticas do sistema (deliberações, notificações, boas-vindas) tenham texto correto e possam ser ajustados sem alteração de código.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F7-004-01 | Somente usuários com capability `communication.manage_templates` acessam esta tela. |
| RN-F7-004-02 | Cada template possui: Nome (único, ex.: `aproveitamento.deferido`), Assunto (e-mail subject), Corpo (Markdown), Variáveis disponíveis (`{{nome}}`, `{{protocolo}}`, `{{curso}}`, etc.), Canal (EMAIL / PUSH / AMBOS). |
| RN-F7-004-03 | O editor é dividido em 2 colunas (conforme `Main/TwoColumn` no Figma): (1) **Coluna esquerda (752px):** `DS/MarkdownEditor` + `DS/TemplatePreview`; (2) **Coluna direita (320px):** histórico de versões (`DS/DataTable/Full` com versões). |
| RN-F7-004-04 | O `DS/MarkdownEditor` suporta syntax highlighting Markdown, inserção de placeholders via autocomplete (ex.: digitar `{{` sugere variáveis disponíveis). |
| RN-F7-004-05 | O `DS/TemplatePreview` renderiza o Markdown com as variáveis substituídas por valores de exemplo (ex.: `{{nome}} → "João da Silva"`, `{{protocolo}} → "SOL-2025-001"`). O preview atualiza em tempo real. |
| RN-F7-004-06 | **Versionamento imutável:** cada vez que o template é salvo, uma nova revisão é criada. A revisão corrente é marcada como `CURRENT`; as anteriores são somente leitura. Não há exclusão de revisões (auditabilidade). |
| RN-F7-004-07 | O histórico de versões (coluna direita) exibe: versão número, autor, data e status (`CURRENT` / `ARCHIVED`). Clicar em uma versão anterior carrega seu conteúdo em modo somente leitura no editor (sem poder salvar). |
| RN-F7-004-08 | Placeholders não reconhecidos pelo sistema (ex.: `{{variavel_inexistente}}`) são destacados em `status/danger` no preview com tooltip explicativo. |
| RN-F7-004-09 | Templates são referenciados por nome no `workflow_json` de cada `RequestType` (ex.: `"notificacoes": { "DELIBERADA": "template.aproveitamento.deferido" }`). Renomear um template exige atualizar os workflows que o referenciam. |
| RN-F7-004-10 | Toda criação e edição (nova revisão) é registrada em `audit_log`. |

---

## Critérios de Aceitação

### CA-F7-004-01 — Exibição do editor dividido

```gherkin
Dado que o admin acessa /admin/templates-comunicacao
E seleciona o template "aproveitamento.deferido"
Quando a tela carrega
Então o DS/MarkdownEditor exibe o conteúdo Markdown do template
E o DS/TemplatePreview renderiza o HTML com variáveis substituídas por exemplos
E a coluna direita lista o histórico de versões com status CURRENT e ARCHIVED
```

### CA-F7-004-02 — Preview ao vivo com placeholders

```gherkin
Dado que o corpo do template contém "Olá {{nome}}, sua solicitação {{protocolo}} foi deferida."
Quando o preview renderiza
Então exibe "Olá João da Silva, sua solicitação SOL-2025-001 foi deferida."
E qualquer alteração no editor atualiza o preview imediatamente
```

### CA-F7-004-03 — Placeholder inválido destacado

```gherkin
Dado que o admin digita "{{aluno_email}}" (variável não disponível)
Quando o preview renderiza
Então o placeholder aparece destacado em vermelho (status/danger)
E um tooltip exibe "Variável não reconhecida — use: nome, protocolo, curso, link"
```

### CA-F7-004-04 — Salvar cria nova versão

```gherkin
Dado que o admin editou o corpo do template
Quando clica em "Salvar"
Então a API cria uma nova revisão com número incrementado
E a revisão anterior muda para status ARCHIVED
E a nova revisão aparece no histórico com status CURRENT e timestamp atual
```

### CA-F7-004-05 — Visualizar versão anterior (somente leitura)

```gherkin
Dado que existem 3 versões do template "boas-vindas.egresso"
Quando o admin clica na versão 1 no histórico
Então o editor exibe o conteúdo da versão 1
E um banner informativo exibe "Versão 1 — somente leitura"
E o botão "Salvar" está desabilitado
```

### CA-F7-004-06 — Autocomplete de placeholders

```gherkin
Dado que o admin está editando o corpo no DS/MarkdownEditor
Quando ele digita "{{"
Então uma lista de sugestões de placeholders aparece: nome, protocolo, curso, link, data
Quando ele seleciona "protocolo"
Então "{{protocolo}}" é inserido no cursor
```

---

## Componentes de UI

- `Shell/AdminLayout`
- `DS/MarkdownEditor` (com autocomplete de placeholders)
- `DS/TemplatePreview` (renderização com variáveis exemplo)
- `DS/DataTable/Full` (histórico de versões — coluna direita)
- `DS/Button` ("Salvar", "Novo template")
- `DS/Badge` (CURRENT / ARCHIVED)
- Tooltip de placeholder inválido

---

## Contrato de API

```
GET /communication-templates?page=0
POST /communication-templates  Body: { nome, assunto, corpo, canal, variaveis }

# Salvar (cria nova revisão)
POST /communication-templates/:id/revisions
Body: { assunto, corpo }
Response: { revisao: N, status: "CURRENT", criadoEm: ... }

# Histórico
GET /communication-templates/:id/versions

# Carregar revisão específica
GET /communication-templates/:id/versions/:rev
```

---

## Fora de Escopo

- Templates de SMS (fora do canal do MVP)
- Editor WYSIWYG HTML (apenas Markdown)
- Teste de envio de e-mail a partir da tela de edição

---

## Definition of Done

- [ ] Editor dividido: MarkdownEditor + preview ao vivo + histórico de versões
- [ ] Autocomplete de placeholders ao digitar `{{`
- [ ] Placeholder inválido destacado em `status/danger`
- [ ] Versionamento imutável: cada save cria nova revisão
- [ ] Versão anterior exibida em modo somente leitura
- [ ] `audit_log` para cada nova revisão
- [ ] Testes: placeholder inválido, versão anterior somente leitura, autocomplete

---

## Referências

- Frame principal: [F7.5 Editor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6151)
- Fluxo F7.3 Templates de comunicação: `foundationDocs/analysis/fluxos_por_perfil.md` §8.3
- Referência no workflow_json: US-F7-003 RN-F7-003-04
