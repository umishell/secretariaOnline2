# US-F1-011 — Consultar Atendimentos e Dar Ciência

| Campo | Valor |
|-------|-------|
| **ID** | US-F1-011 |
| **Épico** | ALUNO-ATENDIMENTOS |
| **Tela** | F1.20 — `/meus-atendimentos` |
| **Prioridade** | P2 |
| **Plataforma** | Web + Mobile |
| **Capability** | `service_record.view_own` |
| **API primária** | `GET /service-records?aluno=me`, `POST /service-records/:id/acknowledge` |
| **Frames Figma** | [Telas / F1 — Aluno](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=48-339) |
| **Spec de tela** | `telasFigma/telas1/F1.20-meus-atendimentos.md` |

---

## 1. História de Usuário

> **Como** aluno autenticado,  
> **Quero** ver os atendimentos que a secretaria registrou para mim e confirmar ciência daqueles que aguardam minha resposta,  
> **Para** ter registro formal dos atendimentos presenciais e cumprir com as confirmações necessárias de forma digital.

---

## 2. Regras de Negócio

| ID | Regra |
|----|-------|
| **RN-F1.20-01** | Atendimentos são registrados pela secretaria (F5.13) e ficam com estado `PENDENTE_CIENCIA` até o aluno confirmar. |
| **RN-F1.20-02** | A lista exibe: Data, Assunto, Status (DS/Badge), Ação (botão "Estou ciente" se pendente). |
| **RN-F1.20-03** | Dar ciência realiza `POST /service-records/:id/acknowledge` e transiciona para `CIENCIA_DADA`, registrando `ciencia_em = now()` e IP. |
| **RN-F1.20-04** | Ao criar um atendimento, a secretaria dispara `atendimentos.created` via Outbox → notificação push + e-mail + in-app ao aluno com link direto para dar ciência. |
| **RN-F1.20-05** | Atendimentos com ciência pendente aparecem como pendência no Dashboard (US-F1-001). |

---

## 3. Critérios de Aceitação

### CA-01 — Listar atendimentos com pendência destacada

```gherkin
Dado que o aluno está em /meus-atendimentos
Quando a página carrega
Então exibe tabela com: Data, Assunto, Status (DS/Badge), Ação
  E atendimentos com estado PENDENTE_CIENCIA têm badge "Pendente ciência" em warning
  E exibem botão "Estou ciente" na coluna Ação
```

### CA-02 — Dar ciência

```gherkin
Dado que o aluno vê atendimento com "Estou ciente" disponível
  E _links.acknowledge existe na resposta
Quando clica em "Estou ciente"
Então o sistema realiza POST /service-records/:id/acknowledge
  E o estado muda para CIENCIA_DADA
  E o badge muda para "Ciente" (success) e o botão desaparece
  E a pendência correspondente some do Dashboard
  E o evento atendimentos.acknowledged é gravado em audit_log com data/IP
```

### CA-03 — Filtro por pendências

```gherkin
Dado que o aluno filtra por "Pendente ciência"
Então exibe apenas atendimentos com estado PENDENTE_CIENCIA
  E se não há pendências: DS/EmptyState "Nenhum atendimento pendente."
```

---

## 4. Fora de escopo

- Criação de atendimento pelo aluno — feita pela secretaria
- Contestação de atendimento — fora do MVP

---

## 5. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas1/F1.20-meus-atendimentos.md` |
| Fluxo F1.8 | `foundationDocs/analysis/fluxos_por_perfil.md` §2 F1.8 |
| Registro secretaria | Coberto em histórias da fase F5 |
| Página Figma F1 | [Telas / F1 — Aluno](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=48-339) |
