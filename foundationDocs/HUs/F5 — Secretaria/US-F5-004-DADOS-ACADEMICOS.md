# US-F5-004 — Dados Acadêmicos: Cursos, Disciplinas e Calendários

| Campo | Valor |
|-------|-------|
| **ID** | US-F5-004 |
| **Épico** | SECR-ACADEMICO |
| **Telas** | F5.7 (Cursos), F5.8 (Disciplinas), F5.9 (Calendários) |
| **Rotas** | `/secretaria/cursos` · `/secretaria/disciplinas` · `/secretaria/calendarios` |
| **Prioridade** | P2 |
| **Capabilities** | `course.manage` · `subject.manage` · `calendar.manage` |
| **APIs** | `/secretaria/cursos` CRUD · `/secretaria/disciplinas` CRUD · `/calendars` CRUD |
| **Frames Figma** | [Cursos](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1718) · [Disciplinas](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1838) · [Calendários](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2603) |

---

## História de Usuário

> **Como** secretária acadêmica,  
> **quero** manter o cadastro de cursos, disciplinas e calendário acadêmico,  
> **para que** o sistema disponha de dados de referência corretos para regras de elegibilidade, carga horária, prazos e exibição nos demais módulos.

---

## Regras de Negócio

### Cursos (F5.7)

| ID | Regra |
|----|-------|
| RN-F5-004-01 | Somente usuários com `course.manage` acessam e modificam o cadastro de cursos. |
| RN-F5-004-02 | Campos obrigatórios de curso: Nome, Sigla (único), Coordenador (usuário com papel COORDENADOR), Horas formativas mínimas, Duração padrão (semestres). |
| RN-F5-004-03 | Secretários vinculados ao curso são listados no campo "Secretários" (multi-select de usuários). Esse vínculo controla o escopo de capability `request.view_curso`. |
| RN-F5-004-04 | Desativar um curso não exclui dados históricos; solicitações e alunos existentes mantêm o vínculo. |

### Disciplinas (F5.8)

| ID | Regra |
|----|-------|
| RN-F5-004-05 | Somente usuários com `subject.manage` acessam e modificam o cadastro de disciplinas. |
| RN-F5-004-06 | Campos obrigatórios: Nome, Código (único por curso), Curso, Período sugerido, Carga horária, Ativa (boolean). |
| RN-F5-004-07 | Uma disciplina pode ser marcada como inativa; alunos já matriculados não são desmatriculados automaticamente (requer ação manual). |
| RN-F5-004-08 | Exportação CSV disponível via botão na barra de ações. |

### Calendários (F5.9)

| ID | Regra |
|----|-------|
| RN-F5-004-09 | Somente usuários com `calendar.manage` criam e editam períodos e eventos do calendário. |
| RN-F5-004-10 | O calendário possui duas abas: **Períodos letivos** (semestres com data início/fim) e **Eventos** (datas especiais: feriados, colações, prazo matrícula). |
| RN-F5-004-11 | Cada evento tem um tipo com cor semântica: `FERIADO` (cinza), `COLACAO` (roxo), `PRAZO` (laranja), `INSTITUCIONAL` (azul). |
| RN-F5-004-12 | Não é permitido criar dois períodos letivos com datas sobrepostas para o mesmo curso; a API retorna HTTP 422. |
| RN-F5-004-13 | Todos os prazos do sistema (SLA de solicitações, janelas de eventos) referenciam o período letivo vigente. Sem período ativo configurado, o sistema emite alerta no dashboard. |

---

## Critérios de Aceitação

### CA-F5-004-01 — CRUD de Curso

```gherkin
Dado que a secretária acessa /secretaria/cursos
Quando ela clica em "Novo"
E preenche Nome, Sigla, Coordenador, Horas formativas e Secretários
E salva
Então a API recebe POST /secretaria/cursos
E o novo curso aparece na tabela
E o vínculo de secretários é salvo, refletindo em request.view_curso
```

### CA-F5-004-02 — Sigla de curso duplicada

```gherkin
Dado que já existe um curso com sigla "TADS"
Quando a secretária tenta criar outro curso com sigla "TADS"
Então a API retorna HTTP 409
E o formulário exibe erro inline no campo Sigla
```

### CA-F5-004-03 — CRUD de Disciplina

```gherkin
Dado que a secretária acessa /secretaria/disciplinas
Quando ela cria uma disciplina com Nome "Banco de Dados", Código "BDD01", Curso "TADS", Carga 60h
Então a API recebe POST /secretaria/disciplinas
E a disciplina aparece na tabela com situação Ativa
```

### CA-F5-004-04 — Desativar disciplina

```gherkin
Dado que existe uma disciplina ativa
Quando a secretária a desativa via toggle
Então o campo Ativa é atualizado para false via PATCH
E alunos já matriculados permanecem vinculados
E a disciplina aparece com badge "Inativa" na tabela
```

### CA-F5-004-05 — Criar período letivo

```gherkin
Dado que a secretária acessa /secretaria/calendarios na aba Períodos
Quando ela cria um período "2025/2" com início 01/08/2025 e fim 30/11/2025
Então a API recebe POST /calendars/periods
E o período aparece na visualização mensal
```

### CA-F5-004-06 — Sobreposição de período letivo

```gherkin
Dado que já existe um período de 01/08/2025 a 30/11/2025 para o curso TADS
Quando a secretária tenta criar período de 01/10/2025 a 28/02/2026 para o mesmo curso
Então a API retorna HTTP 422 com mensagem "Período sobrepõe 2025/2"
```

### CA-F5-004-07 — Criar evento de calendário

```gherkin
Dado que a secretária acessa a aba Eventos
Quando ela cria um evento tipo COLACAO em 15/11/2025 com título "Colação de Grau TADS"
Então o evento aparece no dia 15/11 com a cor semântica roxa
```

---

## Componentes de UI

- `DS/DataTable` (cursos e disciplinas)
- `DS/Button` ("Novo", "Exportar")
- `DS/Badge` (situação: Ativo/Inativo)
- `DS/Input` (busca, filtros)
- `DS/EmptyState`
- `DS/Skeleton`
- `DS/Calendar` (visualização mensal + lista)
- `DS/Modal` (formulário de período/evento)
- Tabs (Períodos | Eventos)

---

## Fora de Escopo

- Configuração de regras curriculares por curso (ver F6 — Coordenação)
- Importação em lote de disciplinas (ver US-F5-009)
- Grade horária semestral

---

## Definition of Done

- [ ] CRUD completo para Cursos, Disciplinas e Calendários
- [ ] Validação de sigla/código único e sobreposição de períodos
- [ ] Vínculo secretário ↔ curso refletido em `request.view_curso`
- [ ] `audit_log` para todas as mutações
- [ ] Exportação CSV de disciplinas
- [ ] Visualização de calendário mensal com tipos de evento com cores semânticas
- [ ] Testes: sobreposição de período, código duplicado, desativação de disciplina

---

## Referências

- Frame Cursos: [F5.7](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1718)
- Frame Disciplinas: [F5.8](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1838)
- Frame Calendários: [F5.9](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2603)
- Fluxo F5.4 CRUD: `foundationDocs/analysis/fluxos_por_perfil.md` §6.4
