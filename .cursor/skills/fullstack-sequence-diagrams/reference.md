# Sequence Diagram Reference — Fullstack 2026

## Text wrap (obrigatório — evita clipping e overlap)

**Preview Cursor:** não use `%%{init}%%` (Syntax Error) nem `<br/>` em mensagens (overlap com setas e actors).

| Prioridade | Técnica | Exemplo |
|:----------:|---------|---------|
| 1 | Labels **completos** (wrap no live editor) | `repassa (secretariaId, cursoIds[], dashboard.view_secretary ✓)` |
| 2 | Abreviar só JSON volumoso | `200 {…}` + detalhe em Notas |
| 3 | Self-call espaçador | `WebApp->>WebApp: monta contexto da tela` |
| 4 | Notas markdown | SQL completo, RFC 7807 |

Nunca `\n`. Nunca `<br/>` em labels. Nunca `%%{init}%%` inline. **Nunca** truncar com `…` no meio da palavra (ex.: `secre…`).

## Diagramas SO2 (`sequenceDiagrams/`)

Config global: [`mermaid-live-config.json`](../mermaid-live-config.json) → aba **Config** do [mermaid.live](https://mermaid.live). Cada diagrama = **um** bloco abaixo (sem `%%{init}%%` inline).

```mermaid
sequenceDiagram
    autonumber
    box #e8f4fc Cliente
        participant WebApp
    end
    box #fff8ee Servidor
        participant API
    end
    WebApp->>API: GET /path (Bearer)
```

| Regra | Valor |
|-------|--------|
| Box Cliente | `box #e8f4fc Cliente` |
| Box Servidor | `box #fff8ee Servidor` |
| Labels | completos nas setas; sem padding invisível nos `.md` |
| Export PNG | `mermaid-live-config.json` + `mermaid-export.css`; padding lateral simétrico só no `.mmd` de export (`\u00a0`×6) |

## Mermaid skeleton (referência)

```mermaid
sequenceDiagram
    autonumber
    title F2.1 — Login (happy path)

    participant Aluno
    participant WebApp
    participant API as AuthController
    participant UC as LoginUseCase
    participant DB as Postgres

    Aluno->>WebApp: Submit credenciais
    WebApp->>API: POST /api/v1/auth/login
    activate API
    API->>UC: execute(LoginCommand)
    activate UC
    UC->>DB: SELECT usuario BY email
    DB-->>UC: UsuarioEntity
    UC->>UC: Argon2id.verify(password)
    UC->>DB: INSERT refresh_token
    UC-->>API: TokenPair + authorities
    deactivate UC
    API-->>WebApp: 200 {accessToken, refreshToken, _links}
    deactivate API
    WebApp-->>Aluno: Redirect /dashboard
```

## FigJam limits (`generate_diagram`)

**Supported well:** `participant`, `->>`, `-->>`, `title`

**Silently dropped:** `Note`, `loop`, `alt`, `par`, `activate`, `autonumber`, `box`, `rect`

**Hybrid workflow:** scaffold with `generate_diagram` → add stickies, phase rects, step numbers via `use_figma`.

## Layout & anti-overlap

Mermaid sequence diagrams have **no manual positioning**. Overlap and clipping are prevented by **init wrap + what you write**, not by tweaking coordinates.

### Causes → fixes (quick reference)

| Cause | Fix |
|-------|-----|
| **Label clipado nas bordas do SVG** | Abreviar single-line — **não** `<br/>` |
| **`<br/>` em mensagem** | Remover — overlap seta/actors no Cursor |
| **`actor` com 1ª seta saindo do humano** | Trocar por **`participant Nome`** — label fica no box acima da lifeline |
| `Note over X` before/after arrow involving `X` | Delete `Note`; use **Notas** markdown below diagram |
| `\n` in label | Auto-wrap; ou `<br/>` semântico (nunca `\n`) |
| Auto-wrap quebra no meio de path/status | `<br/>` manual em fronteira semântica (≤1 por label) |
| JWT/FGAC as separate note | Prefix on request: `GET /path (JWT ok, capability ✓)` |
| Two `SF->>SF` in a row | `SF->>SF: verify JWT + check authority → denied` |
| Full RFC 7807 in arrow | `403 Problem Details (access_denied)` |
| `activate` + long label + `Note` | Drop `activate`/`Note` in doc diagrams |
| Dense `box` groups | Omit `box` or reduce to ≤5 participants |

### Human actors — `participant` vs `actor`

Mermaid renders `actor` labels **below** the stick figure, on the **same row** as the first outgoing arrow → nome sobrepõe o texto da seta (ex.: "Egresso" sobre "Navega para...").

| Declaração | Posição do nome | 1ª seta `Humano->>WebApp` | Uso |
|------------|-----------------|---------------------------|-----|
| `participant Egresso` | Box **acima** da lifeline | Label da seta **abaixo** do box | **Padrão SO2** (docs, sequenceDiagrams) |
| `actor Egresso` | Abaixo do ícone, na altura da seta | **Sobreposição** | Evitar |

```mermaid
sequenceDiagram
    autonumber
    participant Egresso
    participant WebApp
    participant API
    Egresso->>WebApp: Navega para /egresso/inicio
    WebApp->>API: GET /alumni/me (Bearer)
```

**Fallback** (só se `actor` for obrigatório no renderer): prepend mensagem no cliente **antes** da 1ª mensagem humana:

```mermaid
sequenceDiagram
    actor Egresso
    participant WebApp
    WebApp->>WebApp: mount /egresso/inicio
    Egresso->>WebApp: Visualiza dashboard
```

### Before / after (F2.1 pattern)

**Ruim — `actor` + 1ª seta do humano (nome sobrepõe label):**

```mermaid
sequenceDiagram
    actor Egresso
    participant WebApp
    Egresso->>WebApp: Navega para /egresso/inicio
    WebApp->>WebApp: GET /alumni/me
```

**Ruim — `Note` + `\n` na mesma região:**

```mermaid
%%{init: { "sequence": { "wrap": true, "wrapPadding": 10, "useMaxWidth": true } } }%%
sequenceDiagram
    participant WebApp
    participant API
    WebApp->>API: GET /alumni/me\nAuthorization: Bearer
    Note over API: JwtFilter verifica JWT
    API-->>WebApp: 200 {nome, diploma, ...}
```

**Bom — legível (wrap + label inline):**

```mermaid
sequenceDiagram
    autonumber
    participant Egresso
    participant WebApp
    participant API
    participant UC as GetAlumniMeUC
    participant DB as Postgres
    Egresso->>WebApp: Navega para /egresso/inicio
    WebApp->>API: GET /alumni/me (Bearer, alumni.view_own ✓)
    API->>UC: execute(userId)
    UC->>DB: SELECT usuario, certificate BY userId
    DB-->>UC: rows
    UC-->>API: AlumniMeDto + _links
    API-->>WebApp: 200 {nome, diploma, certificados, _links}
```

Detail de `JwtFilter`, HATEOAS e queries separadas → seção **Notas** fora do bloco Mermaid.

### Label length budget

Com `<br/>` em labels longos, o limite é por **linha visual**, não pelo total do label.

| Part | Max chars **por linha** (guideline) | Example |
|------|-------------------------------------|---------|
| HTTP request | ~50 | `POST /certificates/{id}/reissue (Bearer)` |
| HTTP response | ~45 | `200 {downloadUrl, verifyUrl, expiresAt}` |
| SQL | ~50 | `SELECT certificate BY id AND userId` |
| Self-call | ~45 | `verify JWT + check request.open → denied` |
| UI action | ~40 | `Renderiza dashboard read-only` |

Se uma linha ainda clipar: outro `<br/>` **não** — abrevie ou mova para **Notas**.

### When to use `Note` (rare)

| Context | Use `Note`? |
|---------|-------------|
| `foundationDocs/sequenceDiagrams/` | **No** — always **Notas** markdown |
| Chat / PR quick draft | Sparingly, never adjacent to arrow on same lifeline |
| FigJam `generate_diagram` | **Dropped anyway** — use stickies via `use_figma` |

## Layer `box` colors (suggested)

| Box | Participants | Mermaid tint |
|-----|--------------|--------------|
| Client | WebApp, MobileApp | `rgba(230,245,255,0.3)` |
| API | Controllers, BFF | `rgba(255,245,230,0.3)` |
| Domain | Use Cases | `rgba(240,255,240,0.3)` |
| Infra | Postgres, MinIO, Redis | `rgba(245,240,255,0.3)` |
| External | FCM, Mailgun, SIGA | `rgba(255,240,240,0.3)` |

## Pattern templates

### P1 — Login + JWT + refresh

Split in two diagrams if both paths needed:
1. `Login happy path` (above skeleton)
2. `Refresh token rotation`

```mermaid
sequenceDiagram
    participant WebApp
    participant API
    participant UC as RefreshTokenUseCase
    participant DB as Postgres

    WebApp->>API: POST /api/v1/auth/refresh {refreshToken}
    API->>UC: execute(refreshToken)
    UC->>DB: SELECT refresh_token FOR UPDATE
    alt token válido e não reutilizado
        UC->>DB: ROTATE refresh_token
        UC-->>API: new TokenPair
        API-->>WebApp: 200
    else reuse detectado
        UC->>DB: REVOKE all sessions(userId)
        UC-->>API: 401 reuse_detected
        API-->>WebApp: 401 Problem Details
    end
```

### P2 — TanStack Query (read)

```mermaid
sequenceDiagram
    participant UI as DashboardPage
    participant RQ as TanStack Query
    participant API
    participant DB as Postgres

    UI->>RQ: useQuery(['requests','me'])
    alt cache hit (staleTime ok)
        RQ-->>UI: cached data
    else cache miss / stale
        RQ->>API: GET /api/v1/requests/me
        API->>DB: SELECT ...
        DB-->>API: rows + _links
        API-->>RQ: 200 Page<Request>
        RQ-->>UI: data + invalidate rules
    end
```

### P3 — HATEOAS / useActions

```mermaid
sequenceDiagram
    participant UI
    participant API
    participant UC

    UI->>API: GET /api/v1/requests/{id}
    API->>UC: load + assemble links(capabilities)
    UC-->>API: Request + _links[deliberate?]
    API-->>UI: 200 HAL
    Note over UI: useActions hides deliberate<br/>se capability ausente
    UI->>API: POST /api/v1/requests/{id}/deliberate
    API-->>UI: 200 updated resource
```

### P4 — Command + Outbox (canonical SO2)

Match `fluxos_por_perfil.md` §10.1:

```mermaid
sequenceDiagram
    autonumber
    participant UC as UseCase
    participant DB as Postgres
    participant DISP as OutboxDispatcher
    participant PUSH as FCMAdapter
    participant MAIL as MailAdapter

    UC->>DB: BEGIN TX
    UC->>DB: UPDATE estado
    UC->>DB: INSERT outbox_event
    UC->>DB: COMMIT

    loop every 5s
        DISP->>DB: SELECT SKIP LOCKED PENDING
        par push
            DISP->>PUSH: send(notification)
        and email
            DISP->>MAIL: send(email)
        end
        DISP->>DB: UPDATE status=SENT
    end
```

### P5 — Presigned upload (MinIO)

```mermaid
sequenceDiagram
    participant WebApp
    participant API
    participant STO as MinIO

    WebApp->>API: POST /api/v1/files/presign
    API-->>WebApp: 200 {uploadUrl, fileKey}
    WebApp->>STO: PUT uploadUrl (binary)
    STO-->>WebApp: 200
    WebApp->>API: POST /api/v1/requests {attachment: fileKey}
    API-->>WebApp: 201
```

### P6 — Presença QR confirm (v4.1)

```mermaid
sequenceDiagram
    participant Aluno
    participant Mobile
    participant API
    participant UC as ConfirmAttendanceUC
    participant DB as Postgres

    Aluno->>Mobile: Scan QR (window OPEN)
    Mobile->>API: POST /api/v1/eventos/{id}/presenca/confirmar
    API->>UC: execute(token, deviceUuid)
    UC->>DB: validate window + mode + UNIQUE(event,device)
    alt válido
        UC->>DB: INSERT presenca
        UC-->>API: 200 confirmed
    else fora da janela
        UC-->>API: 403 window_closed
    end
    API-->>Mobile: response
```

### P7 — BFF aggregation

```mermaid
sequenceDiagram
    participant WebApp
    participant BFF
    participant ReqAPI
    participant AcadAPI
    participant DB1 as Postgres
    participant DB2 as Postgres

    WebApp->>BFF: GET /bff/dashboard-aluno
    par requests
        BFF->>ReqAPI: GET /requests/me?limit=5
        ReqAPI->>DB1: query
        DB1-->>ReqAPI: data
        ReqAPI-->>BFF: 200
    and academic
        BFF->>AcadAPI: GET /academico/resumo
        AcadAPI->>DB2: query
        DB2-->>AcadAPI: data
        AcadAPI-->>BFF: 200
    end
    BFF-->>WebApp: 200 aggregated DTO
```

## Splitting guide

| Complexity signal | Split strategy |
|-------------------|----------------|
| Auth + business mutation | Diagram A: auth; Diagram B: command |
| Happy + 3 error types | Diagram A: 200; B: 401; C: 403; D: 409 |
| Sync write + async notify | Diagram A: TX; Diagram B: outbox dispatch |
| Mobile + Web same API | One API diagram; optional thin client wrappers |

## Message label cheat sheet

| Type | Format |
|------|--------|
| REST | `METHOD /path` → `STATUS {key fields}` |
| Query | `SELECT entity BY field` → `row \| null` |
| Command | `UPDATE table SET ...` |
| Event | `INSERT outbox_event(type='domain.event')` |
| Cache | `GET key` → `HIT \| MISS` |
| Security | `verify JWT` → `claims \| 401` |
