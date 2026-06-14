# US-F3-004 — Revisar Atividades Formativas (CAAF)

| Campo | Valor |
|-------|-------|
| **ID** | US-F3-004 |
| **Épico** | PROF-FORMATIVAS |
| **Tela** | F3.5 — `/formativas?to=me` |
| **Prioridade** | P2 |
| **Plataforma** | Web + Mobile |
| **Capability** | `formative.review` (somente membros CAAF) |
| **API primária** | `GET /formative-entries?canReview=true`, `POST /formative-entries/{id}/approve`, `POST /formative-entries/{id}/reject` |
| **Frames Figma** | [Loaded/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=220-1142) · [Empty/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18408) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18520) · [Loaded/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18646) · [Empty/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18771) |
| **Spec de tela** | `telasFigma/telas3/F3.5-formativas-revisao.md` |

---

## 1. História de Usuário

> **Como** professor membro da CAAF (Comissão de Atividades de Formação),  
> **Quero** revisar as atividades formativas submetidas pelos alunos do meu curso, aprovar ou rejeitar com parecer,  
> **Para** validar a carga horária complementar de forma formal, gerando automaticamente o certificado quando aprovada.

---

## 2. Regras de Negócio

| ID | Regra |
|----|-------|
| **RN-F3.5-01** | Esta tela é **invisível** para professores sem `formative.review`. O BFF não retorna o bloco e a rota retorna 403. |
| **RN-F3.5-02** | A listagem é restrita ao **escopo de curso/comissão** do professor — ele não vê submissões de alunos de outros cursos. |
| **RN-F3.5-03** | **Aprovar em lote** é disponibilizado para atividades do tipo `EVENTO_INTERNO_PRESENCA_VALIDADA` (presença já validada pelo sistema). Para atividades com comprovante manual, cada item exige revisão individual. |
| **RN-F3.5-04** | Ao **aprovar**, o professor informa `horasValidadas` (pode diferir das horas declaradas pelo aluno). O backend marca `APROVADA` e dispara `CertificateIssuerUseCase`. |
| **RN-F3.5-05** | Ao **rejeitar**, o parecer é obrigatório (mínimo 20 caracteres). O aluno recebe push/e-mail para corrigir e resubmeter. |
| **RN-F3.5-06** | Cada decisão gera `formative_entry.event_log` com: tipo (APROVADA/REJEITADA), `horasValidadas`, parecer, `actor_id`, timestamp. |

---

## 3. Critérios de Aceitação

### CA-01 — Fila de formativas para revisão

```gherkin
Dado que o professor membro da CAAF acessa /formativas?to=me
Quando a página carrega
Então exibe tabela com: Aluno (nome), Atividade, Horas declaradas, Estado (DS/Badge), Data
  E filtrável por curso e estado
  E professor sem formative.review recebe 403
```

### CA-02 — Aprovar formativa individual

```gherkin
Dado que o professor clica em uma formativa com estado SUBMETIDA
  E _links.aprovar existe
Quando preenche horasValidadas = 4 e clica em "Aprovar"
Então o sistema realiza POST /formative-entries/:id/approve { horasValidadas: 4 }
  E o estado muda para APROVADA
  E CertificateIssuerUseCase emite o certificado para o aluno
  E o aluno recebe notificação: "Sua atividade formativa foi aprovada. Certificado disponível."
```

### CA-03 — Aprovar em lote (presença validada)

```gherkin
Dado que há 15 formativas do tipo EVENTO_INTERNO_PRESENCA_VALIDADA submetidas
Quando o professor seleciona todas e clica em "Revisar em lote"
Então um modal exibe: "Confirmar aprovação de 15 atividades de evento com presença validada?"
  E ao confirmar: o sistema aprova todas em uma chamada batch
  E cada item ganha seu event_log individual
```

### CA-04 — Rejeitar formativa com parecer

```gherkin
Dado que o professor clica em uma formativa
  E _links.rejeitar existe
Quando preenche o campo parecer com menos de 20 caracteres e tenta rejeitar
Então exibe erro inline: "O parecer deve ter pelo menos 20 caracteres."

Quando preenche parecer adequado e confirma
Então o estado muda para REJEITADA
  E o aluno recebe push com o parecer
```

---

## 5. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas3/F3.5-formativas-revisao.md` |
| Fluxo F3.5 | `foundationDocs/analysis/fluxos_por_perfil.md` §4 F3.5 |
| Submissão aluno | [US-F1-006](../F1/US-F1-006-FORMATIVAS.md) |
| Emissão certificado | [US-F1-010](../F1/US-F1-010-CERTIFICADOS.md) |
| Página Figma F3 | [Telas / F3 — Professor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=209-339) |
| Frame principal | [F3.5 — Formativas revisão / Loaded / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=220-1142) |
