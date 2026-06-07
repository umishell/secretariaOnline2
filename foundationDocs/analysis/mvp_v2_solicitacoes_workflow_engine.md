# MVP v2 — Solicitações do Aluno + Workflow Engine (incremento real, ~10–15 dias)

**Projeto:** SecretariaOnline2 (TCC — UFPR SEPT)
**Versão deste guia:** v1.0
**Pré-requisito obrigatório:** `mvp_v1_walking_skeleton_aluno.md` **concluída e validada** (DoD §12 da v1).
**Documentos-base:** `mvp_v1_walking_skeleton_aluno.md`, `analise_arquitetural_secretariaonline2.md`, `telas.md` (F1.7/F1.8/F1.9), `fluxos_por_perfil.md`, `jpaInterfaces_PostgresEntities.md`, `agents/workflow-engine-specialist.md`
**Para quem:** guia de implementação para o desenvolvedor **e** para os agentes.

> **Quando começar:** apenas se a v1 estiver finalizada e testada a tempo. A v2 **reusa 100%** da fundação da v1 (IAM, JWT, Design System, BFF, infra/containers/HTTPS/Vercel) — **sem refatoração**, somente **adições**.

---

## 1. Objetivo da v2

Provar, com implementação real, a **maior melhoria arquitetural do TCC**: substituir **dezenas de telas repetitivas** do legado (`novaSol*`, `consultarSol*`) por **uma única engine + um wizard dinâmico**, dirigidos por configuração (JSON Schema + Workflow Definition).

> **Princípio diretor:** *"Uma engine, N tipos, três telas"* — `RequestType` (config) → `Request` (instância) → `RequestEvent` (histórico), renderizados por 3 rotas genéricas: `/solicitacoes`, `/solicitacoes/nova`, `/solicitacoes/:id`.

A jornada entregue (perfil **Aluno**, ponta a ponta):

> abrir nova solicitação (wizard 3 passos, formulário dinâmico) → acompanhar lista → ver detalhe com timeline + anexos → executar ações permitidas via HATEOAS (ex.: reenviar após ajuste) → ver dados reais refletidos no Dashboard.

---

## 2. Escopo (IN / OUT)

> **Tudo da v1 permanece em escopo e funcional.** A v2 apenas adiciona o que segue.

### 2.1 IN — Dentro da v2

**Novo módulo backend `solicitacoes/`** (Clean Architecture completa: api/application/domain/infrastructure)

- **Domínio**: `RequestType`, `Request`, `RequestEvent`, `RequestAttachment`, `WorkflowEngine` (state machine pura).
- **Engine de workflow**: avalia transições a partir do `workflow_json` do `RequestType`; valida `from → to`, autoridade exigida e (opcional) guards simples; **sempre** grava `RequestEvent`.
- **Validação dupla**: payload validado contra `form_schema` (JSON Schema) no backend (além do Zod no front).
- **Anexos**: upload via **URL pré-assinada** para **MinIO/S3** (`upload-url` → PUT direto → `confirm`), com SHA-256 calculado no cliente.

**Seed de tipos (`V003__seed_request_types.sql`)** — 2 a 3 `RequestType` reais com `form_schema` e `workflow_json` distintos, ex.:

- `ADIANTAMENTO_PERIODO`
- `APROVEITAMENTO_DISCIPLINA`
- `TRANCAMENTO_DISCIPLINA`

**API de solicitações (perfil aluno)**


| Método | Caminho                                 | Capability         | Função                                                |
| ------ | --------------------------------------- | ------------------ | ----------------------------------------------------- |
| `GET`  | `/request-types`                        | `request.open`     | lista tipos disponíveis ao aluno                      |
| `GET`  | `/request-types/{code}`                 | `request.open`     | `form_schema` + estado inicial do workflow            |
| `POST` | `/requests`                             | `request.open`     | abre solicitação (estado inicial + 1º `RequestEvent`) |
| `GET`  | `/requests?solicitante=me`              | `request.view_own` | lista as próprias solicitações                        |
| `GET`  | `/requests/{id}`                        | `request.view_own` | detalhe + timeline + anexos + `_links` condicionais   |
| `POST` | `/requests/{id}/transitions`            | conforme estado    | ação do aluno (ex.: `RESUBMIT`)                       |
| `POST` | `/requests/{id}/attachments/upload-url` | `request.open`     | gera URL pré-assinada                                 |
| `POST` | `/requests/{id}/attachments/confirm`    | `request.open`     | confirma upload (registra metadados)                  |


**BFF — passa a ler dados reais**

- `GET /bff/dashboard/aluno`: cards `solicitacoesEmAndamento`, `ultimasSolicitacoes`, `alertas` e `pendencias` agora vêm das tabelas reais de `solicitacoes/` (não mais do seed mockado). **Contrato inalterado** → front da v1 não muda.

**Frontend Web (3 rotas genéricas)**

- `/solicitacoes` (F1.7): lista das próprias solicitações, filtros (estado/tipo/ano), SLA destacado.
- `/solicitacoes/nova` (F1.8): **wizard genérico 3 passos** — (1) escolher tipo + escopo, (2) `DynamicForm` renderizado do `form_schema` + upload de anexos, (3) revisar + confirmar (`POST /requests`). Rascunho local.
- `/solicitacoes/:id` (F1.9): detalhe com dados estruturados, anexos, **timeline** (`RequestEvent`), e botões de ação via `useActions(_links)`.
- Novos componentes: `DynamicForm` (JSON Schema → campos), `WizardStepper`, `AttachmentUpload`, `Timeline`.

**Infra (incremento sobre a v1)**

- `MinIO` adicionado ao `docker-compose` (dev) e bucket S3/compatível na cloud (prod).
- CI: novos testes de integração do módulo `solicitacoes/` (Testcontainers + MinIO).
- Deploy mantém Vercel (front) + backend/Postgres em containers com HTTPS; adiciona serviço de object storage.

### 2.2 OUT — Adiado (pós-v2)

- Telas/fluxos de **deliberação** (Secretaria/Professor/Coordenação): `/solicitacoes?to=me`, `/solicitacoes/:id/deliberar`. *(O backend suporta transições de deliberação via Swagger para a demo, mas sem UI dedicada.)*
- Outros perfis e suas dashboards.
- Módulos Formativas/Estágio/TCC/Presença/Certificados como features completas.
- Outbox + notificações reais (push/email) das transições. *(Eventos de domínio podem ser apenas logados na v2.)*
- Mobile (Expo).
- Protocolo PDF com QR de verificação pública (pode ficar como stretch goal).
- Guards complexos / `notifyTemplate` avançado no workflow.

---

## 3. Agentes responsáveis (delegação)


| Bloco da v2                                                             | Agente(s) a ler              |
| ----------------------------------------------------------------------- | ---------------------------- |
| RequestType, engine, JSON Schema, workflow_json, DynamicForm (conceito) | `workflow-engine-specialist` |
| Módulo `solicitacoes/` (use cases, controllers, HATEOAS, BFF)           | `backend-architect`          |
| Migrations `request*`, JSONB, índices, entidades JPA                    | `database-engineer`          |
| Capabilities `request.*`, autorização por estado, anexos seguros        | `security-engineer`          |
| `/solicitacoes`, wizard, `DynamicForm`, timeline, `useActions`          | `frontend-engineer`          |
| Telas e padrões visuais (reuso DS/*), estados, a11y                     | `ux-ui-specialist`           |
| MinIO/S3, URL pré-assinada, CI/testes integração, deploy                | `devops-engineer`            |


Ordem de orquestração: **workflow-engine → security → database → backend → ux-ui → frontend → devops**.

---

## 4. Modelo de dados da v2 (apenas adições)

> Nenhuma tabela da v1 é alterada. Migrations **incrementais** (`V003`, `V004`…).

`**V003__solicitacoes.sql`**

- `**request_type**`: `id UUIDv7`, `code` unique (ex.: `ADIANTAMENTO_PERIODO`), `nome`, `descricao`, `categoria`, `form_schema JSONB` (JSON Schema do formulário), `workflow_json JSONB` (estados + transições + autoridades), `estado_inicial`, `sla_dias`, `authorities_required JSONB`, `ativo`, `created_at`.
- `**request**`: `id UUIDv7`, `numero` (gerado: `2026-0042`), `id_request_type` FK, `id_solicitante` FK→usuario, `estado` (controlado pela engine), `dados JSONB` (payload do `form_schema`), `prazo_em TIMESTAMPTZ`, `created_at`, `updated_at`, índices em `(id_solicitante, estado)` e GIN em `dados`.
- `**request_event**`: `id UUIDv7`, `id_request` FK, `tipo` (`CREATED`/`TRANSITION`/`COMMENT`), `de_estado`, `para_estado`, `id_ator` FK→usuario, `comentario`, `metadata JSONB`, `created_at`. **Histórico imutável** (append-only).
- `**request_attachment`**: `id UUIDv7`, `id_request` FK, `nome_arquivo`, `content_type`, `tamanho`, `sha256`, `storage_key`, `status` (`PENDING`/`CONFIRMED`), `created_at`.

`**V004__seed_request_types.sql**`: 2–3 `RequestType` com `form_schema` + `workflow_json` reais; adiciona authorities `request.open`/`request.view_own`/`request.deliberate` se ainda não semeadas na v1.

Entidades JPA: `RequestTypeEntity`, `RequestEntity`, `RequestEventEntity`, `RequestAttachmentEntity` + repositórios (`jpaInterfaces_PostgresEntities.md`).

---

## 5. Design do `form_schema` e `workflow_json`

> Detalhes e templates completos em `agents/workflow-engine-specialist.md`. Resumo:

`**form_schema` (JSON Schema)** — descreve campos, tipos, validações, obrigatoriedade e widgets. O `DynamicForm` (front) gera os inputs e o **Zod** é derivado dele; o backend revalida contra o mesmo schema.

`**workflow_json`** — define a state machine:

```jsonc
{
  "estadoInicial": "EM_ANALISE",
  "estados": ["EM_ANALISE", "EM_AJUSTE", "DEFERIDA", "INDEFERIDA", "CANCELADA"],
  "transicoes": [
    { "de": "EM_ANALISE", "para": "EM_AJUSTE",  "acao": "REQUEST_CHANGES", "authority": "request.deliberate" },
    { "de": "EM_AJUSTE",  "para": "EM_ANALISE", "acao": "RESUBMIT",        "authority": "request.view_own", "ownerOnly": true },
    { "de": "EM_ANALISE", "para": "DEFERIDA",   "acao": "APPROVE",         "authority": "request.deliberate" },
    { "de": "EM_ANALISE", "para": "INDEFERIDA", "acao": "REJECT",          "authority": "request.deliberate" }
  ]
}
```

**HATEOAS:** `GET /requests/{id}` calcula, a partir do estado atual + autoridades do usuário, quais `_links` de ação retornar. O front (`useActions`) renderiza só os botões presentes. Ex.: aluno em `EM_AJUSTE` recebe `_links.resubmit`; em `EM_ANALISE` não recebe ação alguma além de `self`.

---

## 6. Fluxo de anexos (URL pré-assinada)

1. Front calcula **SHA-256** do arquivo (evita duplicata) e chama `POST /requests/{id}/attachments/upload-url`.
2. Backend gera URL pré-assinada (MinIO/S3) e cria `request_attachment` `status=PENDING`.
3. Front faz **PUT** direto no storage (não passa pelo backend).
4. Front chama `POST .../attachments/confirm` → backend valida tamanho/content-type e marca `CONFIRMED`.

> Segurança (ver `agents/security-engineer.md`): validar content-type/tamanho, escopo do bucket, expiração curta da URL, e que o `id_request` pertence ao solicitante.

---

## 7. Frontend — wizard e telas genéricas

- `**/solicitacoes/nova`** (wizard `WizardStepper`):
  - Passo 1: `GET /request-types` → seleciona tipo + escopo (curso/disciplina).
  - Passo 2: `GET /request-types/{code}` → `DynamicForm` renderiza do `form_schema`; `AttachmentUpload` para anexos; rascunho local (localStorage).
  - Passo 3: revisão → `POST /requests` → redireciona para `/solicitacoes/:id`.
- `**/solicitacoes**`: TanStack Query em `GET /requests?solicitante=me`; filtros client/server; badges de estado e SLA usando `DS/Badge`.
- `**/solicitacoes/:id**`: dados + `Timeline` (de `request_event`) + anexos + ações `useActions(_links)`; ex.: botão **Reenviar** chama `POST /requests/{id}/transitions { acao: "RESUBMIT" }`.

Tudo reusa `DS/`* e tokens da v1. Estados skeleton/empty/erro idênticos ao padrão da v1.

---

## 8. Infraestrutura — incremento sobre a v1

- **Dev (`ops/docker-compose.yml`)**: adicionar serviço `minio` (console + API) + `createbuckets` (init do bucket). Backend recebe envs `S3_ENDPOINT`, `S3_BUCKET`, `S3_ACCESS_KEY`, `S3_SECRET_KEY`.
- **Prod/cloud**: usar object storage compatível S3 (MinIO containerizado no mesmo provedor, ou bucket gerenciado). Manter Vercel (front) + backend/Postgres em containers com HTTPS (igual v1).
- **CORS do storage**: liberar PUT a partir do domínio Vercel para a URL pré-assinada.
- **Envs novas** (`.env.example`): `S3_ENDPOINT`, `S3_PUBLIC_URL`, `S3_BUCKET`, `S3_ACCESS_KEY`, `S3_SECRET_KEY`.
- **CI**: job de teste de integração de `solicitacoes/` com Testcontainers (Postgres) + MinIO; manter pipeline de deploy da v1.

---

## 9. Segurança específica da v2

- Autorização **por estado + propriedade**: aluno só transiciona solicitações próprias e só ações permitidas pelo `workflow_json` (`ownerOnly`).
- Validar payload contra `form_schema` no servidor (não confiar só no front).
- Anexos: URL pré-assinada de expiração curta; validar `content-type`, tamanho máximo e ownership.
- Cada transição gera `RequestEvent` (trilha de auditoria imutável).
- `@PreAuthorize` com capabilities `request.`* (nunca roles).

---

## 10. Cronograma sugerido (10–15 dias)


| Dia | Frente        | Entrega                                                                                             |
| --- | ------------- | --------------------------------------------------------------------------------------------------- |
| 1   | Backend       | Esqueleto módulo `solicitacoes/` (domain ports, application)                                        |
| 2   | DB/Backend    | `V003`/`V004` (request_type/request/request_event/request_attachment + seed) + entidades JPA        |
| 3   | Backend       | `RequestType` + `WorkflowEngine` (state machine + validação JSON Schema)                            |
| 4   | Backend       | `GET /request-types`, `GET /request-types/{code}`, `POST /requests`, `GET /requests?solicitante=me` |
| 5   | Backend       | `GET /requests/{id}` (timeline + `_links` HATEOAS) + `POST /requests/{id}/transitions`              |
| 6   | Front         | `/solicitacoes` (lista) e `/solicitacoes/:id` (detalhe + Timeline) com mock                         |
| 7   | Front         | `DynamicForm` (JSON Schema → campos + Zod) + `WizardStepper`                                        |
| 8   | Front         | `/solicitacoes/nova` (wizard 3 passos) + `POST /requests`                                           |
| 9   | Front         | Ações HATEOAS no detalhe (`useActions`, ex.: RESUBMIT) + integração real                            |
| 10  | Back+Front    | BFF lê dados reais; dashboard mostra solicitações reais                                             |
| 11  | Qualidade     | Testes integração (backend) + e2e (abrir → acompanhar → reenviar)                                   |
| 12  | DevOps/Anexos | MinIO no compose + URL pré-assinada + `AttachmentUpload`                                            |
| 13  | Polimento     | UX/UI, mensagens, tratamento de erros, a11y                                                         |
| 14  | Demo          | Seed para demonstrar transições; roteiro; deploy cloud atualizado                                   |
| 15  | Folga         | Buffer p/ imprevistos (anexos/cloud/CORS)                                                           |


---

## 11. Definition of Done (critérios de aceitação da v2)

- Tudo da v1 continua funcional e testado.
- Aluno acessa `/solicitacoes` e vê a lista das próprias solicitações.
- Aluno abre `/solicitacoes/nova`, escolhe um dos 2–3 tipos e preenche o **formulário dinâmico** gerado do `form_schema`.
- `POST /requests` cria a solicitação no **estado inicial** + primeiro `RequestEvent`; redireciona ao detalhe.
- `request.dados` (JSONB) reflete fielmente o que foi preenchido no `DynamicForm`.
- `/solicitacoes/:id` mostra dados, anexos e **timeline** de eventos.
- Ação do aluno aparece **só** quando o estado permite (HATEOAS); ex.: `EM_AJUSTE` → botão **Reenviar** funcional.
- Transição via backend (mesmo pela Swagger para simular deliberação) gera `RequestEvent` e atualiza a timeline.
- `GET /bff/dashboard/aluno` mostra **solicitações reais** (não mais seed mockado) — contrato inalterado.
- Upload de anexo via URL pré-assinada funciona (PENDING → CONFIRMED) *(se incluído)*.
- CI verde com testes de integração de `solicitacoes/`.
- Deploy cloud atualizado (Vercel + backend/Postgres + object storage) com HTTPS.

**Roteiro de demo (5–7 min):** mostrar um `RequestType` (JSON `form_schema` + `workflow_json`) → abrir 2 tipos diferentes no **mesmo wizard** (provando "uma engine, N tipos") → acompanhar → simular "solicitar ajuste" (Swagger/deliberador) → aluno vê estado `EM_AJUSTE` e botão Reenviar (HATEOAS) → reenviar → dashboard reflete a contagem real. Fechar enfatizando: **~40 telas legadas → 3 telas + configuração**.

---

## 12. O que a v2 prova (valor de TCC)

1. **DRY na prática**: novo tipo de solicitação = **inserir um `RequestType` (JSON)**, sem nova tela nem nova classe (ADR-003).
2. **Config > código**: `form_schema` + `workflow_json` definem UI, validação e fluxo.
3. **HATEOAS validado**: UI adapta-se às ações permitidas pelo backend conforme estado + autoridade.
4. **Workflow Engine** real: state machine com histórico auditável (`RequestEvent`).
5. **Reuso total da fundação v1**: IAM, JWT, Design System, BFF, containers, HTTPS e Vercel — **sem refatoração**.

---

## 13. Próximos passos (pós-v2)

- Telas de **deliberação** (Secretaria/Professor): reusam `/solicitacoes/:id` com `_links` de deliberação.
- **Outbox + notificações** reais das transições (email/push).
- Protocolo **PDF + QR** de verificação pública.
- Próximo módulo de negócio (Presença em Eventos v4.1, Formativas, Estágio ou TCC), seguindo o mesmo padrão modular.
- **Mobile (Expo)** consumindo os mesmos contratos.

