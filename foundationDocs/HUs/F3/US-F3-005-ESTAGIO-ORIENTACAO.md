# US-F3-005 — Emitir Pareceres de Estágio (Orientador / COE)

| Campo | Valor |
|-------|-------|
| **ID** | US-F3-005 |
| **Épico** | PROF-ESTAGIO |
| **Tela** | F3.6 — `/estagios?to=me` |
| **Prioridade** | P2 |
| **Plataforma** | Web + Mobile |
| **Capability** | `internship.review` |
| **API primária** | `GET /internships?canReview=true`, `POST /internships/{id}/documents/{docId}/review`, `POST /internships/{id}/close` |
| **Frames Figma** | [Loaded/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=220-1350) · [Empty/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18989) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19101) · [Loaded/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19227) · [Empty/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19352) |
| **Spec de tela** | `telasFigma/telas3/F3.6-estagios-revisao.md` |

---

## 1. História de Usuário

> **Como** professor orientador ou membro do COE,  
> **Quero** visualizar os estágios sob minha responsabilidade, revisar os documentos enviados pelos alunos e emitir pareceres,  
> **Para** acompanhar o andamento formal dos estágios e autorizar cada etapa sem processos em papel.

---

## 2. Regras de Negócio

| ID | Regra |
|----|-------|
| **RN-F3.6-01** | A lista `/estagios?to=me` mostra apenas estágios onde o professor é **orientador** ou **membro do COE** com `internship.review`. |
| **RN-F3.6-02** | Colunas: Aluno (nome), Empresa, Documento pendente (tipo do documento mais recente aguardando parecer). |
| **RN-F3.6-03** | Em `/estagios/:id` o professor vê: tabs Documentos e Pareceres, linha do tempo, informações da empresa. |
| **RN-F3.6-04** | O parecer por documento exige texto obrigatório e decisão: APROVADO ou REPROVADO. |
| **RN-F3.6-05** | Ao emitir o último parecer necessário (ex.: Relatório Final aprovado), o professor pode **arquivar o estágio** via `_links.arquivar` → `POST /internships/{id}/close`. |
| **RN-F3.6-06** | Cada parecer emitido gera notificação push/e-mail ao aluno. |

---

## 3. Critérios de Aceitação

### CA-01 — Listar estágios para revisão

```gherkin
Dado que o professor está em /estagios?to=me
Quando a página carrega
Então exibe tabela com: Aluno, Empresa, Documento pendente
  E se não há estágios: DS/EmptyState "Nenhum estágio aguardando sua revisão."
```

### CA-02 — Emitir parecer em documento

```gherkin
Dado que o professor está em /estagios/:id, tab Documentos
  E o aluno fez upload do Relatório Final e _links.revisar existe
Quando preenche o parecer e seleciona "Aprovado"
Então o sistema realiza POST /internships/:id/documents/:docId/review { decisao: "APROVADO", parecer: "..." }
  E o documento muda para estado "Aprovado"
  E o aluno recebe notificação
```

### CA-03 — Arquivar estágio concluído

```gherkin
Dado que todos os documentos obrigatórios foram aprovados
  E _links.arquivar existe
Quando o professor clica em "Arquivar estágio"
Então o sistema realiza POST /internships/:id/close
  E o estágio muda para estado CONCLUIDO
  E o aluno recebe notificação de conclusão
```

---

## 4. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas3/F3.6-estagios-revisao.md` |
| Fluxo F3.6 | `foundationDocs/analysis/fluxos_por_perfil.md` §4 F3.6 |
| Estágio aluno | [US-F1-007](../F1/US-F1-007-ESTAGIO.md) |
| Página Figma F3 | [Telas / F3 — Professor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=209-339) |
| Frame principal | [F3.6 — Estágios revisão / Loaded / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=220-1350) |
