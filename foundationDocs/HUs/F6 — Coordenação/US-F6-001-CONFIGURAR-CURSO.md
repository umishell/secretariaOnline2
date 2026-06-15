# US-F6-001 — Configurar Parâmetros do Curso

| Campo | Valor |
|-------|-------|
| **ID** | US-F6-001 |
| **Épico** | COORD-CONFIG |
| **Telas** | F6.1 — Configurar Curso |
| **Rota** | `/coordenacao/cursos/:id/configurar` |
| **Prioridade** | P2 |
| **Capability** | `course.config` |
| **API primária** | `PATCH /courses/:id/config` |
| **Frames Figma** | [Default](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=685-447) |

---

## História de Usuário

> **Como** coordenador de curso,  
> **quero** configurar os parâmetros curriculares do meu curso (horas formativas mínimas, duração do calendário letivo, regras da banca de TCC e texto do regimento),  
> **para que** o sistema aplique automaticamente as regras corretas de elegibilidade, SLA de deliberação e composição de bancas sem intervenção manual da secretaria.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F6-001-01 | Somente usuários com capability `course.config` acessam esta tela. O coordenador só pode configurar os cursos para os quais está designado como coordenador (`course.coordenador_id = usuario.id`). |
| RN-F6-001-02 | **Horas formativas mínimas:** campo numérico (inteiro, mínimo 0, máximo 1000). Valor padrão definido globalmente pela coordenação acadêmica; pode ser sobrescrito por curso. Afeta diretamente a elegibilidade para colação (US-F5-005 RN-F5-005-07). |
| RN-F6-001-03 | **Calendário letivo:** seleção entre `15 semanas` e `18 semanas`. O valor escolhido determina a duração padrão dos períodos criados via wizard de calendário (US-F5-004). |
| RN-F6-001-04 | **Regras de banca de TCC:** configuração de dois parâmetros via DS/Select: (a) Número mínimo de membros externos (1 ou 2); (b) Modalidade permitida (`PRESENCIAL`, `REMOTO`, `HÍBRIDO`). Esses valores são lidos pelo módulo de TCC ao montar a proposta de banca. |
| RN-F6-001-05 | **Regimento / subforma:** campo textarea livre (máx. 10.000 caracteres) para o texto normativo do curso que é exibido em telas informativas para alunos e professores. Suporte a Markdown básico. |
| RN-F6-001-06 | Ao salvar, o sistema registra no `audit_log` os campos alterados, os valores anteriores e os novos valores, além do `userId` do coordenador e `timestamp`. |
| RN-F6-001-07 | Mudanças em horas formativas mínimas **não retroagem**: alunos que já atingiram o limiar antigo não perdem a elegibilidade. Apenas novos cálculos usam o valor atualizado. |
| RN-F6-001-08 | A tela exibe um `DS/Breadcrumb` com o caminho: Início → Cursos → [Nome do Curso] → Configurar, permitindo navegação rápida. |
| RN-F6-001-09 | O botão "Salvar" fica habilitado somente se ao menos um campo foi alterado em relação ao valor persistido (dirty state). O botão "Cancelar" descarta as alterações sem confirmação se não houver dirty state; com dirty state, exibe dialog de confirmação. |

---

## Critérios de Aceitação

### CA-F6-001-01 — Exibição dos valores atuais

```gherkin
Dado que o coordenador acessa /coordenacao/cursos/tads/configurar
Quando a tela carrega
Então os campos exibem os valores atuais persistidos no banco:
  horas formativas, duração calendário, membros externos banca, modalidade banca, regimento
E o botão "Salvar" está desabilitado (nenhum campo alterado)
```

### CA-F6-001-02 — Alterar horas formativas mínimas

```gherkin
Dado que o valor atual de horas formativas é 120
Quando o coordenador altera para 150 e clica em "Salvar"
Então a API recebe PATCH /courses/tads/config com { "horasFormativasMinimas": 150 }
E o audit_log registra { campo: "horasFormativasMinimas", de: 120, para: 150 }
E um toast "Configuração salva" é exibido
```

### CA-F6-001-03 — Dirty state e cancelar com confirmação

```gherkin
Dado que o coordenador alterou o número de membros externos de 1 para 2
Quando ele clica em "Cancelar"
Então um dialog de confirmação pergunta "Deseja descartar as alterações?"
Quando ele confirma
Então o campo retorna ao valor anterior (1) sem chamar a API
```

### CA-F6-001-04 — Restrição ao curso próprio

```gherkin
Dado que o coordenador é responsável apenas pelo curso TADS
Quando ele tenta acessar /coordenacao/cursos/ec/configurar (Engenharia de Computação)
Então a API retorna HTTP 403
E a UI exibe AlertBanner "Você não é coordenador deste curso"
```

### CA-F6-001-05 — Não-retroatividade de horas formativas

```gherkin
Dado que o aluno "João" tem 125 horas formativas validadas com limiar anterior de 120
Quando o coordenador aumenta o limiar para 150
Então o aluno João mantém o status de elegível para colação
E apenas novos cálculos de elegibilidade usam o limiar 150
```

### CA-F6-001-06 — Validação de campos

```gherkin
Dado que o coordenador insere -10 no campo de horas formativas mínimas
Quando tenta salvar
Então o campo exibe erro inline "Valor deve ser entre 0 e 1000"
E o botão "Salvar" permanece desabilitado
```

---

## Layout (detalhado pelo Figma `685:447`)

O formulário é dividido em 4 `CardSection` empilhadas em `FormScroll`:

| Seção | Componentes | Campo |
|-------|------------|-------|
| 1 | `DS/Card` + `DS/Input` | Horas formativas mínimas (numérico) |
| 2 | `DS/Card` + `DS/Select` | Duração do calendário (15 semanas / 18 semanas) |
| 3 | `DS/Card` + `DS/Select` × 2 | Membros externos mínimos banca + Modalidade de banca |
| 4 | `DS/Card` + `DS/Input` (textarea grande) | Regimento do curso (Markdown, 10k chars) |

`FooterActions` com botões "Cancelar" (secondary) e "Salvar" (primary).

---

## Componentes de UI

- `DS/Breadcrumb`
- `DS/Card` (container de seção)
- `DS/Input` (horas formativas + regimento/textarea)
- `DS/Select` (calendário, membros banca, modalidade)
- `DS/Button` ("Cancelar", "Salvar")
- `DS/AlertBanner` (erros de acesso)
- Dialog de confirmação (cancelar com dirty state)

---

## Contrato de API

```
GET /courses/:id/config
Response: {
  "horasFormativasMinimas": 120,
  "duracaoCalendario": "15_SEMANAS",
  "bancaMembrosExternos": 1,
  "bancaModalidade": "PRESENCIAL",
  "regimento": "# Regimento do Curso TADS\n..."
}

PATCH /courses/:id/config
Body: {
  "horasFormativasMinimas": 150,     // apenas campos alterados
  "bancaMembrosExternos": 2
}
Response 200: config atualizada completa
Response 403: capability insuficiente ou curso não é do coordenador
```

---

## Fora de Escopo

- Alteração de nome, sigla ou coordenador do curso (ver US-F5-004)
- Configuração de tipos de solicitação permitidos por curso (ver Admin — F7.4)
- Upload de arquivo PDF do regimento (apenas texto no MVP)

---

## Definition of Done

- [ ] Formulário carrega valores persistidos via `GET /courses/:id/config`
- [ ] `PATCH` envia apenas os campos dirty
- [ ] Dirty state controla `enabled` do botão Salvar e dialog de cancelar
- [ ] `audit_log` registra alterações com valores anteriores e novos
- [ ] Não-retroatividade de horas formativas testada
- [ ] HTTP 403 para coordenador acessando curso de outro
- [ ] Testes: dirty state, validação de intervalo, não-retroatividade

---

## Referências

- Frame principal: [F6.1 Default](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=685-447)
- Fluxo F6.1 Configurar curso: `foundationDocs/analysis/fluxos_por_perfil.md` §7.1
- Elegibilidade colação (afeta): US-F5-005 RN-F5-005-07
- CRUD cursos (base): US-F5-004 RN-F5-004-01–04
