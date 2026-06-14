# US-F5-005 — Egressos e Colação de Grau

| Campo | Valor |
|-------|-------|
| **ID** | US-F5-005 |
| **Épico** | SECR-EGRESSOS |
| **Telas** | F5.10 (Egressos), F5.11 (Diplomas / Colação) |
| **Rotas** | `/secretaria/egressos` · `/secretaria/diplomas` |
| **Prioridade** | P2 |
| **Capabilities** | `alumni.list` · `diploma.register` |
| **APIs** | `GET /secretaria/egressos` · `POST /graduations` · `PATCH /graduations/:id/confirm-delivery` |
| **Frames Figma** | [Egressos](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1958) · [Diplomas Passo 1](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2723) |

---

## História de Usuário

> **Como** secretária acadêmica,  
> **quero** gerenciar o cadastro de egressos e registrar o processo de colação de grau e entrega de diploma,  
> **para que** a transição do aluno para o perfil EGRESSO seja documentada, o diploma seja entregue formalmente e o egresso receba acesso ao portal.

---

## Regras de Negócio

### Egressos (F5.10)

| ID | Regra |
|----|-------|
| RN-F5-005-01 | Somente usuários com `alumni.list` visualizam e editam a lista de egressos. |
| RN-F5-005-02 | A lista exibe: Nome, Curso, Ano de Colação, Situação do diploma (PENDENTE / ENTREGUE / RETIRADO). |
| RN-F5-005-03 | Filtros disponíveis: curso, ano de colação, situação do diploma. |
| RN-F5-005-04 | Um egresso pode ser criado manualmente (casos excepcionais) ou transicionado automaticamente via fluxo de colação (F5.11). |
| RN-F5-005-05 | Exportação CSV da lista disponível via `export.run`. |

### Colação de Grau e Diploma (F5.11)

| ID | Regra |
|----|-------|
| RN-F5-005-06 | Somente usuários com `diploma.register` executam o processo de colação. |
| RN-F5-005-07 | **Elegibilidade:** um aluno é elegível para colação quando: (a) TCC aprovado, (b) todas as disciplinas do currículo concluídas, (c) horas formativas ≥ mínimo do curso, (d) sem pendências financeiras (se integração ativa) e (e) sem solicitações abertas bloqueantes. |
| RN-F5-005-08 | O wizard possui 2 passos: (1) Selecionar elegíveis — lista com checkbox; (2) Confirmar colação — data da cerimônia, livro, folha e ata. |
| RN-F5-005-09 | Ao confirmar, o backend executa em transação: cria `graduation_record`, altera `usuario.role` para `EGRESSO`, registra `audit_log`. |
| RN-F5-005-10 | Outbox emite evento `egressos.graduated` para cada egresso gerado → e-mail de boas-vindas ao portal do egresso com instruções de acesso. |
| RN-F5-005-11 | **Entrega física do diploma:** após a colação, a secretária registra a entrega via `PATCH /graduations/:id/confirm-delivery` com data e método (retirada presencial / por procuração / por correio). |
| RN-F5-005-12 | Se um aluno não atende aos critérios de elegibilidade, ele aparece na lista com um indicador de bloqueio e tooltip com a razão (ex.: "Horas formativas insuficientes: 60/120 h"). |

---

## Critérios de Aceitação

### CA-F5-005-01 — Listar egressos

```gherkin
Dado que a secretária acessa /secretaria/egressos
Quando a página carrega
Então a tabela exibe os egressos com Nome, Curso, Ano de Colação e Situação do diploma
E filtros de curso, ano e situação estão disponíveis
```

### CA-F5-005-02 — Iniciar processo de colação

```gherkin
Dado que a secretária acessa /secretaria/diplomas
Quando ela escolhe o curso "TADS" e o período "2025/2"
Então o Passo 1 exibe a lista de elegíveis com checkboxes
E alunos inelegíveis aparecem desabilitados com tooltip explicativo
```

### CA-F5-005-03 — Confirmar colação

```gherkin
Dado que a secretária selecionou 5 alunos elegíveis no Passo 1
Quando ela avança para o Passo 2 e preenche data da cerimônia, livro e folha
E clica em "Confirmar colação"
Então a API recebe POST /graduations com os dados
E os 5 alunos têm role atualizado para EGRESSO
E cada um recebe e-mail de boas-vindas via Outbox
E um graduation_record é criado para cada aluno
```

### CA-F5-005-04 — Aluno inelegível

```gherkin
Dado que um aluno tem apenas 60 horas formativas e o mínimo é 120
Quando a secretária abre o wizard de colação para o curso do aluno
Então o aluno aparece na lista mas com checkbox desabilitado
E o tooltip exibe "Horas formativas insuficientes: 60/120 h"
```

### CA-F5-005-05 — Confirmar entrega de diploma

```gherkin
Dado que um egresso tem graduation_record com diploma PENDENTE
Quando a secretária clica em "Confirmar entrega" e seleciona "Retirada presencial" com a data atual
Então a API recebe PATCH /graduations/:id/confirm-delivery
E a situação do diploma muda para ENTREGUE na lista de egressos
```

---

## Componentes de UI

- `DS/DataTable` (egressos)
- `DS/WizardStepper` (colação — 2 passos)
- `DS/Badge` (situação do diploma)
- `DS/Input` (busca, filtros)
- `DS/EmptyState`
- `DS/Skeleton`
- Checkbox multiselect (lista de elegíveis)
- Dialog de confirmação (colação)

---

## Contrato de API

```
# Egressos
GET /secretaria/egressos?curso=TADS&anoCola=2025&situacaoDiploma=PENDENTE&page=0

# Elegíveis para colação
GET /students?eligibleForGraduation=true&cursoId=...&periodoId=...

# Confirmar colação em lote
POST /graduations
Body: {
  "cursoId": "...",
  "periodoId": "...",
  "dataCerimonia": "2025-11-15",
  "livro": "12", "folha": "34", "ata": "2025/TADS/001",
  "alunoIds": ["id1", "id2"]
}

# Confirmar entrega
PATCH /graduations/:id/confirm-delivery
Body: { "metodo": "PRESENCIAL", "dataEntrega": "2025-11-20" }
```

---

## Fora de Escopo

- Emissão do PDF do diploma (processo externo ao sistema)
- Registro de colação para pós-graduação
- Reemissão de diploma por perda (ver módulo de solicitações)

---

## Definition of Done

- [ ] Lista de egressos com filtros e exportação CSV
- [ ] Wizard de colação com verificação de elegibilidade
- [ ] Transição `usuario.role → EGRESSO` em transação atômica
- [ ] Outbox `egressos.graduated` disparado por egresso
- [ ] Registro de entrega física do diploma
- [ ] `audit_log` para colação e entrega
- [ ] Testes: aluno inelegível bloqueado, transação atômica multi-aluno

---

## Referências

- Frame Egressos: [F5.10](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=540-1958)
- Frame Diplomas: [F5.11 Passo 1](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2723)
- Fluxo F5.7 Diploma e colação: `foundationDocs/analysis/fluxos_por_perfil.md` §6.7
- Dashboard Egresso: US-F2-001
