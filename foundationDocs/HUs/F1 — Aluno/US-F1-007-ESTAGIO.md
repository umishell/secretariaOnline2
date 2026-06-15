# US-F1-007 — Acompanhar Estágios e Enviar Documentos

| Campo | Valor |
|-------|-------|
| **ID** | US-F1-007 |
| **Épico** | ALUNO-ESTAGIO |
| **Telas** | F1.13 `/estagios` · F1.14 `/estagios/:id` |
| **Prioridade** | P2 |
| **Plataforma** | Web + Mobile |
| **Capability** | `internship.view_own` |
| **API primária** | `GET /internships?aluno=me`, `GET /internships/{id}`, `POST /internships/{id}/documents` |
| **Frames Figma** | **F1.13:** [Loaded/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=89-3715) · [Empty/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=142-14786) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=109-9664) · [Error/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=109-10260) · [Loaded/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=112-12384) · [Empty/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=149-21266) · **F1.14:** [Default/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=90-5245) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=148-18012) · [404/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=148-19917) · [Default/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=112-21319) |
| **Specs de tela** | `telasFigma/telas1/F1.13-estagios-lista.md` · `F1.14-estagios-detalhe.md` |

---

## 1. História de Usuário

> **Como** aluno autenticado realizando estágio curricular,  
> **Quero** visualizar meus estágios registrados, acompanhar a situação de cada um e enviar os documentos exigidos (TCE, relatórios),  
> **Para** manter meu processo de estágio atualizado e receber pareceres do orientador/COE sem precisar ir presencialmente à secretaria.

---

## 2. Regras de Negócio

| ID | Regra |
|----|-------|
| **RN-F1.13-01** | A lista exibe estágios com colunas: Empresa, Supervisor, Vigência (datas), Situação (DS/Badge). |
| **RN-F1.13-02** | O aluno não abre estágio pelo sistema — o registro é feito pela secretaria (F5). O aluno apenas acompanha e envia documentos. |
| **RN-F1.14-01** | A tela de detalhe tem duas tabs: **Documentos** e **Pareceres**. |
| **RN-F1.14-02** | Cada tipo de documento exigido (TCE, Relatório Parcial, Relatório Final) aparece com status de entrega. O upload de cada documento é habilitado via `_links` HATEOAS. |
| **RN-F1.14-03** | Ao fazer upload de documento, o Outbox emite `estagios.document_uploaded` → notifica o orientador/COE para emitir parecer. |
| **RN-F1.14-04** | Pareceres do orientador/COE são exibidos na tab "Pareceres" em ordem cronológica. |

---

## 3. Critérios de Aceitação

### CA-01 — Listar estágios

```gherkin
Dado que o aluno está em /estagios
Quando a página carrega
Então exibe tabela com: Empresa, Supervisor, Vigência, Situação
  E filtrável por situação (Ativo, Concluído, Pendente)
  E se não há estágios: DS/EmptyState "Você não possui estágios registrados."
```

### CA-02 — Enviar documento de estágio

```gherkin
Dado que o aluno está em /estagios/:id, tab Documentos
  E o tipo "Relatório Final" tem _links.upload na resposta
Quando faz upload do PDF do relatório
Então o documento é enviado para MinIO via URL pré-assinada
  E o status do documento muda para "Enviado — aguardando parecer"
  E o orientador/COE recebe notificação via Outbox (estagios.document_uploaded)
```

### CA-03 — Visualizar pareceres

```gherkin
Dado que o aluno está em /estagios/:id, tab Pareceres
Quando há pareceres registrados pelo orientador/COE
Então exibe cada parecer com: data, autor, texto e ícone de status (aprovado/rejeitado)
  E os pareceres estão em ordem cronológica (mais recente no topo)
```

---

## 4. Fora de escopo

- Abertura de estágio pelo aluno — feita pela secretaria (F5)
- Comunicação direta com orientador pelo sistema — usa o hub de comunicação (F1.6)

---

## 5. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Specs de tela | `telasFigma/telas1/F1.13-estagios-lista.md`, `F1.14-estagios-detalhe.md` |
| Fluxo orientador/COE | `foundationDocs/analysis/fluxos_por_perfil.md` §4 F3.6 |
| Página Figma F1 | [Telas / F1 — Aluno](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=48-339) |
| Frame F1.13 principal | [F1.13 — Estágios / Loaded / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=89-3715) |
| Frame F1.14 principal | [F1.14 — Estágios detalhe / Default / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=90-5245) |
