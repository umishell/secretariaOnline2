# Endpoints canônicos — Presença em eventos (v4.1)

> Referência única de **nomes de caminhos**, **métodos HTTP**, **chaves de corpo JSON** e **rels HATEOAS** para o módulo de **presença em eventos com horas formativas**, com **modo de confirmação configurável** e **janelas temporais definidas pelo professor**. Mantém **device binding** onde aplicável.  
> **Objetivo**: evitar deriva entre `telas.md`, implementação Spring e futuro OpenAPI.  
> **Prefixo global**: quando existir versionamento de API, prefixar todos os caminhos abaixo com o mesmo prefixo (ex.: `/api/v1`). Este documento lista apenas o sufixo após o prefixo.

---

## 1. Recurso base


| Nome lógico        | Segmento de coleção | Segmento de item   |
| ------------------ | ------------------- | ------------------ |
| Evento de presença | `events`            | `events/{eventId}` |


- **`eventId`**: UUID do agregado `event_attendance` (path parameter).

---

## 1.1 Modo de presença (`attendanceMode`)

Valores canônicos (enum OpenAPI `AttendanceMode`):

| Valor               | Descrição resumida                                      |
| ------------------- | ------------------------------------------------------- |
| `QR_SINGLE`         | Um token/QR para validação no período permitido.       |
| `QR_DUAL`           | Dois tokens/QRs (fase início e fase fim).               |
| `SECRET_SINGLE`     | Senha ou PIN único (uma ou mais janelas configuradas). |
| `SECRET_DUAL`       | Dois segredos distintos (entrada/saída).                |

A UI e os `_links` expostos em `GET .../attendance/session` dependem de `attendanceMode` + estado do evento + janelas ativas.

---

## 2. Operação do evento (CRUD — professor / secretaria / admin)

Capacidades típicas: **`event.manage`** para criar/editar/remover; leitura de catálogo ampliada pode usar filtros. **Professores sem `event.manage` não veem** as telas de gestão (menu condicionado à capability).

Regras de negócio documentais:

- **`PATCH`** / **`DELETE`** em `events/{eventId}`: permitido apenas ao **organizador** do evento (ou política institucional explícita); caso contrário **`403`**.
- Usuário com `event.manage` pode **listar** eventos de outros professores, mas mutações seguem a regra acima (**somente visualização** de terceiros).

| Método   | Caminho canônico      | Uso                                                                 |
| -------- | --------------------- | ------------------------------------------------------------------- |
| `GET`    | `/events`             | Lista com filtros (curso, estado do evento, modo, período).         |
| `POST`   | `/events`             | Criação do evento (inclui `attendanceMode`, janelas, `chCreditadas`). |
| `GET`    | `/events/{eventId}`   | Detalhe do evento (inclui estado **SCHEDULED / IN_PROGRESS / DONE**). |
| `PATCH`  | `/events/{eventId}`   | Atualização parcial (metadados, janelas, modo — se política permitir). |
| `DELETE` | `/events/{eventId}`   | Remoção lógica ou cancelamento (política a definir).                 |

### 2.1 Queries auxiliares (listagens contextualizadas)

| Método | Caminho canônico | Query params canônicos |
| ------ | ---------------- | ---------------------- |
| `GET`  | `/events`        | `audience=me` — eventos elegíveis ao **aluno** autenticado (F1.17). |
| `GET`  | `/events`        | `host=me` — eventos em que o usuário é **organizador** / anfitrião. |
| `GET`  | `/events`        | `onlyMine=true` — restrito a eventos em que o usuário é organizador (atalho; combina com `event.manage` em UI de professor). |

> No OpenAPI, documentar se `audience`, `host` e `onlyMine` são mutuamente exclusivos ou combináveis.

---

## 3. Sessão de presença do aluno (leitura + HATEOAS)

| Método | Caminho canônico                         | Uso |
| ------ | ---------------------------------------- | --- |
| `GET`  | `/events/{eventId}/attendance/session` | Estado da sessão do **aluno autenticado** + `_links` para ações permitidas naquele instante (F1.17 / F1.18). |

**Nome alternativo legado (não usar em novo código):** `GET /events/{eventId}/attendance-session`.

---

## 4. Janelas temporais (organizador — abertura das fases)

Capacidades típicas: **`event.host`** ou **`event.manage`**.

As **durações** das janelas ativas vêm da **configuração do evento** (ex.: janela única de N horas ou duas sub-janelas com início/fim absolutos). O docente pode ainda **disparar** manualmente a abertura operacional de uma fase (quando o modo exigir ação explícita) ou o sistema abre automaticamente conforme *schedule* (política híbrida a fixar no domínio).

| Método | Caminho canônico                             | Uso |
| ------ | -------------------------------------------- | --- |
| `POST` | `/events/{eventId}/attendance/windows/entry` | Abre (ou reconfirma) a **fase de entrada** conforme `attendanceMode`; inicia intervalo de validação **conforme política do evento**. |
| `POST` | `/events/{eventId}/attendance/windows/exit`  | Abre a **fase de saída** (modos duplos); segundo segredo/token quando aplicável. |

Corpo opcional (§7.2): `durationSeconds` pode **sobrepor** temporariamente a duração padrão da política, se a instituição permitir.

**Nomes descartados para evitar drift:** apenas `open-entry-window` sem namespace — preferir `.../windows/entry` e `.../windows/exit`.

---

## 5. Confirmação pelo aluno

### 5.1 Modos PIN / senha (`SECRET_*`)

| Método | Caminho canônico                      | Uso |
| ------ | ------------------------------------- | --- |
| `POST` | `/events/{eventId}/attendance/entry`  | Confirma **entrada** (primeira fase). |
| `POST` | `/events/{eventId}/attendance/exit`   | Confirma **saída** (segunda fase, modos duplos). |

### 5.2 Modos QR (`QR_*`)

| Método | Caminho canônico                              | Uso |
| ------ | --------------------------------------------- | --- |
| `GET`  | `/events/{eventId}/attendance/qr`            | *(Organizador / host)* Obtém representação do QR atual (ex.: `image/svg+xml` ou JSON com `payloadUrl`) por query `phase=entry` \| `phase=exit`. |
| `POST` | `/events/{eventId}/attendance/qr/validate`    | *(Aluno)* Confirma presença apresentando token escaneado: corpo §7.3. |

> Alternativa DRY: em modos QR, `POST .../entry` aceitar `qrToken` em vez de `pin` (mutuamente exclusivo no schema). Escolher **uma** convenção no OpenAPI e eliminar a outra.

---

## 6. Encerramento do evento

| Método | Caminho canônico          | Uso |
| ------ | ------------------------- | --- |
| `POST` | `/events/{eventId}/close` | Encerra o evento; dispara certificado / `formative_entry` conforme §11 da análise arquitetural. |

O estado **IN_PROGRESS** ↔ **DONE** também pode ser atingido **automaticamente** por *scheduler* ao cruzar `fimEm` da agenda, além de encerramento manual.

---

## 7. Corpos JSON — chaves canônicas

### 7.1 `POST .../attendance/entry` e `POST .../attendance/exit`

| Chave        | Tipo          | Obrigatório | Observação |
| ------------ | ------------- | ----------- | ----------- |
| `pin`        | string        | condicional | Obrigatório nos modos `SECRET_*` quando não se usa `qrToken`. |
| `qrToken`    | string        | condicional | Obrigatório nos modos `QR_*` se a API não usar sub-rota dedicada. |
| `deviceUuid` | string (UUID) | sim         | Binding por evento (mitigação compartilhamento de aparelho). |

Nomes **descartados**: `device_id`, `deviceUUID`, `lat`, `lon`.

### 7.2 `POST .../attendance/windows/entry` e `.../exit`

| Chave              | Tipo    | Obrigatório | Observação |
| ------------------ | ------- | ----------- | ----------- |
| `durationSeconds`  | integer | não         | Sobreposição da duração da janela ativa, se política permitir. |

---

## 8. HATEOAS — nomes canônicos de `_links` (rel)

| Rel (string)        | Método alvo | Caminho alvo | Quando aparece |
| ------------------- | ----------- | ------------ | -------------- |
| `confirmar-entrada` | `POST`      | `.../attendance/entry` ou `.../qr/validate` | Janela / fase de entrada ativa e aluno elegível. |
| `confirmar-saida`   | `POST`      | `.../attendance/exit` ou `.../qr/validate`   | Modo duplo, entrada já OK, fase de saída ativa. |
| `obter-qr-entrada`  | `GET`       | `.../attendance/qr?phase=entry`               | Modo QR; organizador exibe material. |
| `obter-qr-saida`    | `GET`       | `.../attendance/qr?phase=exit`               | Modo QR duplo; fase saída. |
| `self`              | `GET`       | `.../attendance/session`                     | Opcional (HAL). |

| Rel                    | Método | Caminho |
| ---------------------- | ------ | ------- |
| `abrir-janela-entrada` | `POST` | `.../windows/entry` |
| `abrir-janela-saida`   | `POST` | `.../windows/exit` |
| `encerrar-evento`      | `POST` | `.../close` |

---

## 9. Respostas de erro (semântica canônica)

| HTTP  | Uso no módulo |
| ----- | ------------- |
| `403` | Fora da janela, token/PIN inválido, mutação em evento de terceiro, ou aluno inelegível. UI cega. |
| `404` | `eventId` inexistente ou sem visibilidade. |
| `409` | Conflito (ex.: segundo vínculo `deviceUuid` no mesmo evento). |

---

## 10. BFF / agregação

| Método | Caminho canônico           | Uso |
| ------ | -------------------------- | --- |
| `GET`  | `/bff/dashboard/aluno`     | Resumo de eventos; não substitui mutações de domínio. |
| `GET`  | `/bff/dashboard/professor` | Atalhos a eventos **meus** e pendências operacionais. |

---

## 11. Checklist para gerar o OpenAPI depois

- Fixar `servers` e prefixo (`/api/v1` ou vazio).
- `eventId` como `uuid` em todos os paths.
- Schemas: `EventAttendance` ( `attendanceMode`, `chCreditadas`, `scheduledStart`, `scheduledEnd`, `validationWindows[]` ), `ConfirmAttendanceBody`, `AttendanceSessionResponse`.
- Documentar `403`/`409` em todos os POST de confirmação.
- Alinhar `telas.md` “Fonte” a estes caminhos.

---

## 12. Rotas de UI (não são endpoints REST)

| Rota SPA / Expo | Descrição |
| --------------- | --------- |
| `/eventos` | F1.17 — tabela + modal + componente dinâmico. |
| `/eventos/:id/presenca` | F1.18 — validação dedicada (QR / pós-login). |
| `/professor/eventos`, `/professor/eventos/:id`, `/professor/eventos/:id/operacao` | F3.2 — CRUD + operação. |
| `/professor/eventos/:id/chamadas` | Alias legível → redireciona para `.../operacao`. |
| `/secretaria/eventos`, `/secretaria/eventos/:id/operacao` | F5.14 / F5.15. |
