# Examples — SecretariaOnline2

## Example A — Notificação ponta-a-ponta (from fluxos §10.1)

Already canonical in repo. When extending, keep:
- `autonumber`
- `par` for push + email
- `loop` on dispatcher
- Real table names: `outbox_event`, `communication_delivery`

## Example B — Deliberação de solicitação (suggested)

**F3.x — Deliberar solicitação (happy path)**

```mermaid
sequenceDiagram
    autonumber
    participant Secretaria
    participant WebApp
    participant API
    participant UC as DeliberateRequestUC
    participant DB as Postgres
    participant OUT as Outbox

    Secretaria->>WebApp: Clica Deferir
    WebApp->>API: POST /requests/{id}/deliberate (deliberar ✓)
    API->>UC: execute(id, DEFERIDA)
    UC->>DB: BEGIN
    UC->>DB: UPDATE request SET estado
    UC->>DB: INSERT request_event
    UC->>DB: INSERT outbox_event
    UC->>DB: COMMIT
    UC-->>API: Request + _links
    API-->>WebApp: 200 HAL
    WebApp-->>Secretaria: Toast + lista atualizada
```

**F3.x — Deliberar (403 sem capability)**

Separate diagram — only through auth check:

```mermaid
sequenceDiagram
    participant WebApp
    participant API

    WebApp->>API: POST /requests/{id}/deliberate
    API->>API: FGAC check deliberar → failed
    API-->>WebApp: 403 Problem Details (access_denied)
```

UI não exibe botão se `useActions` não encontrar rel `deliberate` (ver **Notas** na HU).

## Example C — Naming a doc section

```markdown
### F2.1 Login com JWT (happy path)

Ver também: F2.1b Refresh token | F2.1c Rate limit 429

```mermaid
...
```
```
