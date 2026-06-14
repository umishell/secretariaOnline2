# Inventário completo — Design System SecretariaOnline2

**Versão:** 2.0  
**Escopo:** 100% dos elementos visuais do sistema web + mobile (48 rotas, fluxos F0–F8)  
**Fontes:** `agents/ux-ui-specialist.md`, `agents/mobile-engineer.md`, `foundationDocs/prompts/PROMPT_figma_make_dashboard_aluno_estrutura.md`, `foundationDocs/analysis/telas.md`, MVPs v1/v2  
**Objetivo:** Spec única para criar **Variables semânticas no Figma**, biblioteca `DS/*`, **Page Patterns** e exportar para `tokens.css` → Tailwind → Cursor.

> **Regra imutável:** `DashboardA.tsx` (Versão A) é o blueprint visual e estrutural de todas as telas autenticadas. Zero hex/px hardcoded nos componentes `DS/*`.

---

## Índice

1. [Estrutura do arquivo Figma](#1-estrutura-do-arquivo-figma)
2. [Foundations — Tokens (Variables)](#2-foundations--tokens-variables)
3. [Brand & assets visuais](#3-brand--assets-visuais)
4. [Shells & layouts](#4-shells--layouts)
5. [Page patterns (F0–F8)](#5-page-patterns-f0f8)
6. [Catálogo de componentes `DS/*`](#6-catálogo-de-componentes-ds)
7. [Módulo presença em eventos (v4.1)](#7-módulo-presença-em-eventos-v41)
8. [Editores & admin (F7)](#8-editores--admin-f7)
9. [Mobile nativo (Expo)](#9-mobile-nativo-expo)
10. [Estados, feedback & interação](#10-estados-feedback--interação)
11. [Acessibilidade & i18n](#11-acessibilidade--i18n)
12. [Pipeline Figma → Cursor](#12-pipeline-figma--cursor)
13. [Registro mestre de componentes](#13-registro-mestre-de-componentes)
14. [Ordem de construção & priorização](#14-ordem-de-construção--priorização)

**Legenda de prioridade:** `[P0]` MVP v1 · `[P1]` MVP v2 · `[P2]` produto completo · `[P3]` opcional/futuro

---

## 1. Estrutura do arquivo Figma

| Página | Conteúdo |
|--------|----------|
| `00 — Foundations` | Primitivos, tokens semânticos, tipografia, grid, motion |
| `01 — Brand` | Logo, favicon, ilustrações EmptyState, marca institucional |
| `02 — Shells` | PublicLayout, AuthLayout, AppLayout, AdminLayout, MobileShell |
| `03 — Page Patterns` | Templates reutilizáveis por fluxo (F0–F8) |
| `04 — Componentes DS/*` | Biblioteca atômica e molecular completa |
| `05 — Domínio acadêmico` | Presença, solicitações, certificados, SLA, workflow |
| `06 — Admin & editores` | JSON Schema, state machine, Markdown, import wizard |
| `07 — Telas referência` | Dashboard aluno (A), login, wizard, operação evento |
| `08 — Estados globais` | Skeleton, empty, error, loading parcial por pattern |
| `09 — Icons` | Grid Lucide + tamanhos + mapeamento semântico |
| `10 — Mobile` | Tab bar, drawer, pull-to-refresh, safe areas |

Layers naming: `Shell/*`, `Main/*`, `DS/*`, `Pattern/*`.

---

## 2. Foundations — Tokens (Variables)

### 2.1 Cores — Primitivas

- Paleta **brand**: primary, accent, hover, pressed, subtle (bg-tint)
- Escala **neutral**: `0–900` ou `50–950` (alinhada Tailwind)
- **success** / **warning** / **danger** / **info**: cada uma com escala `50–900` ou mínimo `default`, `foreground`, `subtle`, `border`
- **opacity**: `0`, `5`, `10`, `20`, `40`, `60`, `80`, `100` — overlays, disabled, scrim

### 2.2 Cores — Semânticas

#### Brand & ação

| Token | Uso |
|-------|-----|
| `color/brand/primary` | Botão primary, links de marca |
| `color/brand/accent` | Destaques secundários |
| `color/brand/primary-hover` | Hover botão primary |
| `color/brand/primary-pressed` | Active/pressed |
| `color/brand/subtle` | Fundo tint brand (selected leve) |
| `color/action/link` | Links inline |
| `color/action/link-hover` | Hover link |
| `color/action/destructive` | Excluir, indeferir |

#### Superfícies

| Token | Uso |
|-------|-----|
| `color/surface/default` | Fundo página (`Main`) |
| `color/surface/elevated` | Cards, sidebar |
| `color/surface/overlay` | Scrim modal/drawer |
| `color/surface/subtle` | Zebra table, hover row, fundo muted |
| `color/surface/inverse` | Topbar escura (se aplicável) |
| `color/surface/auth` | Fundo telas públicas/login |
| `color/surface/code` | Blocos hash, diff audit |

#### Texto

| Token | Uso |
|-------|-----|
| `color/text/primary` | Texto principal |
| `color/text/secondary` | Texto secundário |
| `color/text/muted` | Caption, metadados |
| `color/text/disabled` | Campos desabilitados |
| `color/text/inverse` | Texto sobre superfície escura |
| `color/text/link` | Links |
| `color/text/on-brand` | Texto sobre botão primary |
| `color/text/success` / `warning` / `danger` / `info` | Mensagens inline |

#### Bordas & divisores

| Token | Uso |
|-------|-----|
| `color/border/default` | Bordas padrão |
| `color/border/strong` | Ênfase, selected |
| `color/border/subtle` | Divisores internos |
| `color/border/focus` | Focus ring |
| `color/border/error` | Campo inválido |

#### Status (cada: `bg`, `border`, `text`, `icon`)

- `color/status/success/*`
- `color/status/warning/*`
- `color/status/danger/*`
- `color/status/info/*`
- `color/status/neutral/*`

#### Interação

- `color/interactive/hover`
- `color/interactive/pressed`
- `color/interactive/selected` — NavItem active, row selected
- `color/interactive/disabled-bg`
- `color/interactive/disabled-text`

#### Domínio acadêmico

| Grupo | Tokens |
|-------|--------|
| SLA | `color/sla/on-time`, `at-risk`, `overdue` |
| Presença | `color/presence/pending`, `partial`, `complete`, `ineligible` |
| Evento | `color/event/scheduled`, `in-progress`, `completed` |
| Solicitação | `color/request-state/draft`, `submitted`, `in-review`, `adjustments`, `approved`, `rejected`, `forwarded`, `closed` |
| Outbox | `color/outbox/pending`, `sent`, `failed`, `dead` |
| Certificado | `color/verification/valid`, `invalid`, `unknown` |
| Comunicação | `color/comm/unread`, `read`, `urgent`, `archived` |
| Atendimento | `color/service/pending-ack`, `acknowledged` |

### 2.3 Tipografia

#### Famílias

- `font/family/sans` — UI principal
- `font/family/mono` — protocolos, hashes, IDs, diff audit

#### Escala (size / weight / line-height / letter-spacing)

| Token | Spec ref. | Uso |
|-------|-----------|-----|
| `Heading/H1` | 32/700 | Saudação dashboard |
| `Heading/H2` | 24/600 | Valores KPI |
| `Heading/H3` | 20/600 | Títulos de card |
| `Heading/H4` | 18/600 | Subtítulos de seção |
| `Body/Large` | 18/400 | Destaques, verificação pública |
| `Body/Default` | 16/400 | Listas, tabela |
| `Body/Semibold` | 16/600 | Títulos de item |
| `Body/Small` | 14/400 | Texto secundário em cards |
| `Caption/Default` | 12/400 | Metas KPI, subtítulos |
| `Caption/Muted` | 12/400 muted | Timestamps |
| `Label/Default` | 14/500 | Labels formulário |
| `Label/Small` | 12/500 | Labels compactos |
| `Overline` | 11/600 uppercase | Tags de seção |
| `Code/Inline` | mono 14 | `AAAA-NNNN`, hashes |
| `Code/Block` | mono 13 | Diff audit, JSON preview |

#### Regras tipográficas

- Truncate: título lista 1 linha; parecer 2 linhas; descrição evento 3 linhas
- `text-decoration`: underline (link), line-through (opcional)

### 2.4 Espaçamentos

#### Escala base (grid 8px)

| Token | px |
|-------|---:|
| `space/xs` | 4 |
| `space/sm` | 8 |
| `space/md` | 16 |
| `space/lg` | 24 |
| `space/xl` | 32 |
| `space/2xl` | 40 |
| `space/3xl` | 48 |
| `space/4xl` | 64 |

#### Layout semântico

| Token | px | Uso |
|-------|---:|-----|
| `layout/sidebar-width` | 256 | Sidebar desktop |
| `layout/sidebar-collapsed` | 72 | Breakpoint médio |
| `layout/topbar-height` | 64 | Topbar |
| `layout/page-padding-desktop` | 32 | Main desktop |
| `layout/page-padding-mobile` | 16 | Main mobile |
| `layout/card-padding` | 24 | Interior card |
| `layout/card-gap` | 24 | Entre cards irmãos |
| `layout/section-gap` | 40 | Entre seções página |
| `layout/form-gap` | 16 | Entre campos |
| `layout/list-item-gap` | 16 | Itens de lista |
| `layout/touch-target-min` | 44 | Alvo mínimo mobile |
| `layout/content-max-width` | 480 | Formulários auth centrados |
| `layout/content-max-width-wide` | 720 | Wizard, editores |
| `layout/content-max-width-full` | 1280 | Tabelas admin |

#### Grid

- Colunas: 12 (desktop), 4 (mobile)
- Gutter: 24 desktop / 16 mobile
- `KpiRow`: 4 col iguais gap 24; mobile 2×2 ou carrossel gap 12
- `MainGrid`: ratio 2:1 gap 24

### 2.5 Raios, bordas, sombras

**Radius:** `none` 0 · `sm` 4 · `md` 8 · `lg` 12 · `xl` 16 · `full` 9999

**Border width:** `default` 1px · `strong` 2px · `focus` 2px

**Shadow:** `none` · `sm` (cards) · `md` (dropdown) · `lg` (modal) · `focus` (ring)

### 2.6 Z-index

`base` · `sticky` (topbar) · `dropdown` · `sidebar-overlay` · `modal` · `toast` · `tooltip`

### 2.7 Breakpoints

| Token | px | Comportamento |
|-------|---:|---------------|
| `min-mobile` | 375 | Largura mínima |
| `sm` | 640 | Sidebar → overlay |
| `md` | 768 | Tablet landscape |
| `lg` | 1024 | Sidebar fixa |
| `xl` | 1280 | KPI 4 colunas |
| `2xl` | 1536 | Wide admin tables |

### 2.8 Motion & animação

| Token | Valor | Uso |
|-------|-------|-----|
| `duration/fast` | 150ms | Hover/active |
| `duration/normal` | 200ms | Page fade-in |
| `duration/slow` | 300ms | Drawer |
| `duration/pulse` | 1500ms | Botão "Estou ciente" |
| `easing/default` | ease-in-out | Padrão |
| `easing/enter` | ease-out | Modais |
| `easing/exit` | ease-in | Fechar overlay |

Animações nomeadas: `fade-in`, `slide-in-right` (drawer), `shimmer` (skeleton), `pulse-attention` (CTA pendente). Sempre respeitar `prefers-reduced-motion`.

### 2.9 Ícones

- Biblioteca: **Lucide React** (web) / Lucide compat (mobile)
- Tamanhos: `xs` 16 · `sm` 20 · `md` 24 · `lg` 32 · `xl` 48
- `icon/stroke-width`: 2 (default)
- Grid semântico: status, navegação, ações, domínio (documento, evento, certificado, presença)

### 2.10 Modos de cor

- **Light** — MVP primeiro; todos os tokens semânticos definidos
- **Dark** — mesma árvore de nomes, collection/mode separado no Figma
- **High contrast** — `[P3]` preparação futura a11y

---

## 3. Brand & assets visuais

| Asset | Variantes | Uso |
|-------|-----------|-----|
| `Brand/Logo` | full, mark-only, inverse | Sidebar, login, favicon source |
| `Brand/Favicon` | 16, 32, 180, 512 | Browser, PWA |
| `Brand/Wordmark` | pt-BR | Header público |
| `Illustration/Empty/*` | generic, search, inbox, requests, events, certificates | EmptyState por contexto |
| `Illustration/Error/*` | 401, 403, 404, 500, offline | Telas erro |
| `Illustration/Success/*` | submitted, verified | Confirmação wizard, verificação |
| `Pattern/AuthBackground` | subtle gradient ou institucional | Login, recuperar senha |

---

## 4. Shells & layouts

### 4.1 `Shell/PublicLayout` `[P0]`

Sem sidebar. Centro ou split para auth e páginas públicas.

```
PublicLayout
├── Header/Public          logo + links (Contato, Verificar)
├── Main/Centered          max-width 480–720
└── Footer/Public          links institucionais, copyright
```

**Rotas:** F0.1–F0.7, redirect pós-login.

### 4.2 `Shell/AuthLayout` `[P0]`

Variante de PublicLayout focada em formulário único.

- Card elevado centralizado
- Logo top
- Slot: form + links secundários
- Mensagens genéricas (anti-enumeração)

**Rotas:** `/login`, `/recuperar-senha`, `/nova-senha`, `/primeiro-acesso`.

### 4.3 `Shell/AppLayout` `[P0]`

Layout autenticado principal (Versão A).

```
AppLayout
├── Shell/Sidebar          w256 | drawer mobile
│   ├── Brand              logo 32 + label
│   ├── Nav/Primary        NavItem[]
│   └── Nav/Secondary      NavItem[] + UserMenu compact
├── Shell/Topbar           h64 sticky
│   ├── PageTitle / Breadcrumb
│   ├── GlobalSearch       max-w 480
│   ├── NotificationBell
│   └── UserMenu
└── Main/ScrollArea        p32 desktop | p16 mobile
```

**Rotas:** F1–F6 autenticados, F8.

### 4.4 `Shell/AdminLayout` `[P2]`

Extensão AppLayout com nav secundária admin ou sub-sidebar.

- Breadcrumb obrigatório
- Alert strip para operações destrutivas
- Content max-width full para tabelas/editores

**Rotas:** F7.*

### 4.5 `Shell/OperationLayout` `[P2]`

Layout full-width para painel operacional de evento (sala/projetor).

- Sidebar colapsada ou oculta
- Tipografia ampliada para QR/PIN
- Contadores em destaque

**Rotas:** `*/eventos/:id/operacao`.

### 4.6 `Shell/MobileShell` `[P1]`

```
MobileShell
├── Header/Mobile          título + ações
├── Main/Scroll            pull-to-refresh
└── TabBar/Bottom          4–5 tabs (Início, Solicitações, Comunicação, Buscar, Mais)
```

- Safe area top/bottom tokens
- Drawer off-canvas para nav completa

### 4.7 Regiões reutilizáveis (`Main/*`)

| Região | Descrição |
|--------|-----------|
| `Main/PageHeader` | Título + descrição + ações primárias |
| `Main/AlertStrip` | Max 2 AlertBanners (`aria-live`) |
| `Main/KpiRow` | 4× KpiCard desktop; 2×2 mobile |
| `Main/MainGrid` | Ratio 2:1 |
| `Main/FilterBar` | Sticky abaixo topbar em listas |
| `Main/Toolbar` | Ações bulk + export |
| `Main/TwoColumn` | Form + preview (editores) |
| `Main/SplitView` | Master-detail `[P2]` |

---

## 5. Page patterns (F0–F8)

Cada pattern documenta: layout shell, blocos, componentes `DS/*`, estados loading/empty/error.

### F0 — Público / não autenticado

| Pattern | Rotas | Componentes principais |
|---------|-------|------------------------|
| `Pattern/AuthForm` | F0.1, F0.2, F0.3, F1.2 | Input, Button, FormField, Link, AlertBanner, Checkbox (LGPD) |
| `Pattern/PublicInfo` | F0.4 | Card, Body, map embed, contact list |
| `Pattern/ErrorPage` | F0.5 | EmptyState/Error illustration, incident ID (mono), Button |
| `Pattern/VerificationPortal` | F0.6, F0.7 | VerificationResult, FileDropZone, HashDisplay, QR preview, Badge status |

### F1 — Aluno

| Pattern | Rotas | Componentes principais |
|---------|-------|------------------------|
| `Pattern/DashboardBFF` | F1.1 | KpiRow, MainGrid, PendenciaItem, EventoRow, DataTable/Compact, QuickTile, HighlightCard, AlertBanner |
| `Pattern/ProfileSettings` | F1.3, F1.4, F1.5 | Tabs, AvatarUpload, Input, Switch, SessionList, TimeRangePicker, NotificationChannelRow |
| `Pattern/CommunicationHub` | F1.6 | FilterBar, Tabs (Feed/Inbox), NotificationItem, InboxItem, MarkdownViewer, Badge unread |
| `Pattern/RequestList` | F1.7 | FilterBar, DataTable/Full, SlaIndicator, RequestStatusBadge, Pagination |
| `Pattern/RequestWizard` | F1.8 | WizardStepper, RadioGroup, DynamicForm, AttachmentUpload, ReviewSummary |
| `Pattern/RequestDetail` | F1.9 | Timeline, AttachmentList, ProtocolBadge, ActionBar (HATEOAS), DeliberationPanel |
| `Pattern/FormativeList` | F1.10 | KpiCard (horas), DataTable, Badge |
| `Pattern/FormativeForm` | F1.11 | Select, Input, FileUpload, AlertBanner (pré-preenchido evento) |
| `Pattern/FormativeDetail` | F1.12 | Timeline, AttachmentList, ParecerCard |
| `Pattern/InternshipList` | F1.13 | ListItem com pendências, Badge situação |
| `Pattern/InternshipDetail` | F1.14 | DocumentChecklist, FileUpload por tipo, ParecerList |
| `Pattern/TccOverview` | F1.15 | TeamCard, DateKeyList, Badge situação |
| `Pattern/TccDetail` | F1.16 | FileUpload final, DefenseScheduler, CommentThread `[P3]` |
| `Pattern/EventCatalog` | F1.17 | DataTable/Full, EventStatusBadge, PresenceBadge, Dialog detalhe + PresenceValidator |
| `Pattern/PresencePage` | F1.18 | PresenceValidator full-page, CountdownTimer, AuthGateBanner |
| `Pattern/CertificateList` | F1.19 | Card grid, download PDF, QR thumb |
| `Pattern/ServiceRecordList` | F1.20 | ListItem, Button pulse "Estou ciente", AcknowledgmentBadge |

### F2 — Egresso

| Pattern | Rotas | Componentes principais |
|---------|-------|------------------------|
| `Pattern/AlumniDashboard` | F2.1 | DashboardBFF read-only, CertificateList, reissue CTA |

### F3 — Professor

| Pattern | Rotas | Componentes principais |
|---------|-------|------------------------|
| `Pattern/ProfessorDashboard` | F3.1 | DashboardBFF variant, filas deliberar/formativas/TCC/eventos |
| `Pattern/EventCRUD` | F3.2 | Form multi-step, DateRangePicker, AttendanceModeSelector, ValidationWindowEditor |
| `Pattern/EventOperation` | F3.2 operacao | OperationLayout, QRDisplay, PinDisplay, LiveCounter, AttendeeStream |
| `Pattern/DeliberationQueue` | F3.3 | DataTable bulk, FilterBar |
| `Pattern/DeliberationScreen` | F3.4 | RequestDetail + DeliberationPanel + AttachmentPreview |
| `Pattern/FormativeReviewQueue` | F3.5 | BulkReviewTable, BatchActionBar |
| `Pattern/InternshipReview` | F3.6 | DocumentReviewList, ParecerForm |
| `Pattern/TccReview` | F3.7 | GradeForm, ParecerForm |
| `Pattern/ComposeAnnouncement` | F3.8 | MarkdownEditor, AudienceSelector, PreviewPane |

### F4 — Comissões

| Pattern | Rotas | Componentes principais |
|---------|-------|------------------------|
| `Pattern/CommissionDashboard` | F4.1, F4.2 | KpiRow comissão, AssignmentBoard, BulkReviewTable |

### F5 — Secretaria

| Pattern | Rotas | Componentes principais |
|---------|-------|------------------------|
| `Pattern/SecretaryDashboard` | F5.1 | DashboardBFF + SLA alerts + agenda dia |
| `Pattern/RequestQueueAdmin` | F5.2, F5.5, F5.12 | DataTable/Full, FilterBar persistente, BulkActionBar, ExportButton |
| `Pattern/InternalRequestWizard` | F5.3 | RequestWizard + Combobox "Em nome de" |
| `Pattern/StudentCRUD` | F5.6 | DataTable, SearchInput GRR, RowActions |
| `Pattern/CourseCRUD` | F5.7 | Form CRUD + SecretaryAllocation subform |
| `Pattern/SubjectCRUD` | F5.8 | SortableList (drag reorder) |
| `Pattern/CalendarCRUD` | F5.9 | CalendarView + Form eventos acadêmicos |
| `Pattern/AlumniList` | F5.10 | DataTable + Export |
| `Pattern/GraduationRegister` | F5.11 | Multi-select alunos, DiplomaDeliveryForm |
| `Pattern/ServiceRecordCreate` | F5.13 | Form atendimento + AttachmentUpload |
| `Pattern/ImportWizard` | F5.16 | Wizard 4 passos: template → upload → preview → report |
| `Pattern/ExportCatalog` | F5.17 | Tile grid export kinds + async job status |
| `Pattern/AnalyticsDashboard` | F5.18 | Chart/*, StatCard, FilterBar date range |
| `Pattern/TaskBoard` | F5.19 `[P3]` | Kanban simples ou list todo |

### F6 — Coordenação

| Pattern | Rotas | Componentes principais |
|---------|-------|------------------------|
| `Pattern/CourseConfig` | F6.1 | FormSection tabs, numeric inputs, regimento upload |
| `Pattern/CoordinatorReports` | F6.2 | AnalyticsDashboard variant |

### F7 — Admin

Ver seção [8. Editores & admin](#8-editores--admin-f7).

### F8 — Cross-cutting

| Pattern | Rotas | Componentes principais |
|---------|-------|------------------------|
| `Pattern/GlobalSearch` | F8.1 | CommandPalette, SearchResultGroup, SearchResultItem typed |
| `Pattern/SupportFAQ` | F8.2 | Accordion FAQ, TicketForm, Link contato |

---

## 6. Catálogo de componentes `DS/*`

Organizado por categoria. Cada componente: variantes, tamanhos, estados (default/hover/focus/disabled/loading/error).

### 6.1 Ações

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/Button` | primary, secondary, ghost, link, danger; sm h32 / default h40; icon leading/trailing/only | P0 |
| `DS/IconButton` | ghost, outline; aria-label obrigatório | P0 |
| `DS/ButtonGroup` | segmented actions | P2 |
| `DS/ToggleGroup` | filtros exclusivos | P2 |
| `DS/Link` | inline, standalone | P0 |

### 6.2 Superfícies & containers

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/Card` | default, interactive; Header/Title/Description/Content/Footer | P0 |
| `DS/KpiCard` | with-progress, number-only; min-h 120 | P0 |
| `DS/HighlightCard` | parecer/destaque; p 20 gap 12 | P0 |
| `DS/StatCard` | label + delta + sparkline slot | P2 |
| `DS/Panel` | seção sem sombra, border only | P1 |
| `DS/Separator` | horizontal/vertical | P0 |
| `DS/ScrollArea` | Main scroll customizado | P1 |

### 6.3 Status, badges & indicadores

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/Badge` | neutral, success, warning, danger, info; h 24 px 8 | P0 |
| `DS/ProtocolBadge` | formato `AAAA-NNNN`, mono | P1 |
| `DS/RequestStatusBadge` | estados workflow | P1 |
| `DS/EventStatusBadge` | Agendado, Em andamento, Concluído | P1 |
| `DS/PresenceBadge` | pending, partial, complete, ineligible | P1 |
| `DS/SlaIndicator` | textual + cor on-time/at-risk/overdue | P1 |
| `DS/OutboxStatusBadge` | PENDING, SENT, FAILED, DEAD | P2 |
| `DS/AcknowledgmentBadge` | pendente ciência / ciente | P1 |
| `DS/NotificationDot` | unread count on bell | P1 |
| `DS/PulseIndicator` | animação CTA pendente | P1 |

### 6.4 Feedback & estados

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/AlertBanner` | info, warning, success, error; dismissible | P0 |
| `DS/Toast` / `DS/Sonner` | success, error, info | P1 |
| `DS/Skeleton` | line, block, circle | P0 |
| `DS/EmptyState` | illustration + message + CTA | P0 |
| `DS/Spinner` | sm, md; só ações do usuário | P0 |
| `DS/Progress` | linear, circular; upload/wizard | P1 |
| `DS/InlineAlert` | dentro de FormField | P0 |

### 6.5 Identidade & mídia

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/Avatar` | sm 32, md 36, lg 48; foto + initials | P0 |
| `DS/AvatarGroup` | stack + overflow count | P2 |
| `DS/AvatarUpload` | crop + preview; perfil F1.3 | P1 |
| `DS/Logo` | full, mark, sizes | P0 |

### 6.6 Formulários — base

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/Input` | text, password, email, number; label + error + helper | P0 |
| `DS/Input/Search` | ícone, h 40, clear button | P0 |
| `DS/Textarea` | auto-resize opcional | P1 |
| `DS/Label` | required asterisk | P0 |
| `DS/FormField` | wrapper RHF+Zod | P0 |
| `DS/FormSection` | título + descrição + campos | P1 |
| `DS/FormActions` | cancel + submit sticky footer mobile | P1 |

### 6.7 Formulários — seleção & data

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/Select` | single | P1 |
| `DS/Combobox` | autocomplete, "Em nome de" | P1 |
| `DS/Checkbox` | single + indeterminate | P1 |
| `DS/RadioGroup` | wizard passo 1 | P1 |
| `DS/Switch` | DND, preferências | P1 |
| `DS/DatePicker` | single date | P1 |
| `DS/DateRangePicker` | filtros, agenda evento | P1 |
| `DS/TimePicker` | janelas validação | P2 |
| `DS/TimeRangePicker` | DND F1.5 | P1 |
| `DS/Slider` | `[P3]` | P3 |

### 6.8 Formulários — arquivos

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/FileUpload` | single/multi, drag-drop, progress | P1 |
| `DS/AttachmentUpload` | SHA-256 pré-calc, duplicate hint | P1 |
| `DS/FileDropZone` | verificação pública F0.6 | P2 |
| `DS/AttachmentList` | download, preview, remove | P1 |
| `DS/AttachmentPreview` | PDF/image inline | P1 |

### 6.9 Formulários — dinâmicos

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/DynamicForm` | JSON Schema → campos + Zod | P1 |
| `DS/ReviewSummary` | wizard passo 3 read-only | P1 |
| `DS/FieldArray` | listas repetíveis no schema | P2 |

### 6.10 Navegação

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/NavItem` | default, active; h 44 px 12 | P0 |
| `DS/Breadcrumb` | truncating middle | P1 |
| `DS/Tabs` | default, underline, pills | P1 |
| `DS/Pagination` | prev/next + pages | P1 |
| `DS/WizardStepper` | 3 passos horizontal/vertical mobile | P1 |
| `DS/StepIndicator` | import wizard 4 passos | P2 |
| `DS/CommandPalette` | Ctrl+K global search | P2 |
| `DS/BackLink` | mobile header | P1 |

### 6.11 Overlays

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/Dialog` | detalhe evento, confirmações | P1 |
| `DS/AlertDialog` | ações destrutivas | P1 |
| `DS/Sheet` | filtros mobile, painel lateral | P1 |
| `DS/Drawer` | sidebar mobile | P0 |
| `DS/Popover` | SLA info, previews | P1 |
| `DS/Tooltip` | icon-only help | P1 |
| `DS/DropdownMenu` | UserMenu, row actions | P1 |
| `DS/ContextMenu` | tabela admin | P2 |

### 6.12 Dados — tabelas & listas

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/DataTable/Compact` | dashboard; row h 48 | P0 |
| `DS/DataTable/Full` | sort, select, virtual scroll >200 | P1 |
| `DS/DataTable/Toolbar` | filtros + export CSV | P1 |
| `DS/FilterBar` | chips + selects + date range persistente | P1 |
| `DS/BulkActionBar` | aparece com seleção | P2 |
| `DS/SortableList` | reorder disciplinas F5.8 | P2 |
| `DS/ListItem` | genérico título + meta + action | P0 |
| `DS/VirtualList` | wrapper >200 linhas | P2 |

### 6.13 Dados — domínio dashboard

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/PendenciaItem` | título + status + CTA HATEOAS; min-h 72 | P0 |
| `DS/EventoRow` | with-cta, without-cta | P0 |
| `DS/TimelineItem` | request_event history | P0 |
| `DS/QuickTile` | min 88×88; grid 2×3 | P0 |
| `DS/DeadlineRow` | prazo calendário | P1 |
| `DS/ParecerCard` | parecer CAAF/COE | P1 |

### 6.14 Dados — gráficos

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/Chart/Line` | Recharts wrapper tokenizado | P2 |
| `DS/Chart/Bar` | volume solicitações | P2 |
| `DS/Chart/Pie` | distribuição estado | P2 |
| `DS/Chart/Legend` | tokens cor | P2 |

### 6.15 Comunicação & conteúdo

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/MarkdownViewer` | comunicados renderizados | P1 |
| `DS/MarkdownEditor` | publicar F3.8, templates F7.5 | P2 |
| `DS/NotificationItem` | hub feed | P1 |
| `DS/InboxItem` | atendimento + ação aluno | P1 |
| `DS/NotificationChannelRow` | email/push/in-app toggles | P1 |
| `DS/CommentThread` | TCC futuro | P3 |
| `DS/Accordion` | FAQ suporte | P2 |
| `DS/Collapsible` | filtros avançados | P2 |

### 6.16 Busca

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/SearchResultItem` | typed: aluno, protocolo, evento | P2 |
| `DS/SearchResultGroup` | agrupamento por tipo | P2 |
| `DS/SearchEmpty` | sem resultados | P2 |

### 6.17 Deliberação & workflow

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/ActionBar` | botões derivados de `_links` HATEOAS | P1 |
| `DS/DeliberationPanel` | deferir/indeferir/ajustes/encaminhar | P1 |
| `DS/Timeline` | lista TimelineItem + conectores | P1 |
| `DS/TransitionConfirmDialog` | confirma transição workflow | P1 |

### 6.18 Verificação pública & certificados

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/VerificationResult` | valid/invalid/unknown; F0.6 F0.7 | P2 |
| `DS/HashDisplay` | SHA-256, copy button, mono | P2 |
| `DS/QRCodeDisplay` | protocolo, certificado, operação evento | P2 |
| `DS/CertificateCard` | download PDF + meta | P1 |

### 6.19 Segurança & sessão

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/SessionList` | dispositivo, IP, encerrar | P1 |
| `DS/PasswordStrengthMeter` | nova senha, primeiro acesso | P1 |
| `DS/AuthGateBanner` | "Entrar" quando não autenticado em evento | P1 |

### 6.20 CRUD & admin genérico

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/CRUDPageHeader` | título + create button | P2 |
| `DS/ConfirmDeleteDialog` | padrão admin | P2 |
| `DS/RoleAuthorityMatrix` | toggle grid F7.2 F7.3 | P2 |
| `DS/AuditDiffViewer` | before/after JSON F7.7 | P2 |
| `DS/JobStatusCard` | scheduled jobs F7.6 | P2 |
| `DS/ImportPreviewTable` | erros por linha F5.16 | P2 |
| `DS/ExportJobTile` | async export status | P2 |

### 6.21 Misc

| Componente | Variantes / notas | Prioridade |
|------------|-------------------|------------|
| `DS/ExpandableCard` | dashboard mobile cards expansíveis | P1 |
| `DS/CalendarView` | calendário acadêmico F5.9 | P2 |
| `DS/MapEmbed` | contato F0.4 | P2 |
| `DS/CountdownTimer` | janela presença ativa | P2 |
| `DS/CopyButton` | protocolo, hash, PIN host | P1 |
| `DS/ExternalLink` | abre browser no mobile | P1 |

---

## 7. Módulo presença em eventos (v4.1)

Componentes compostos específicos do submódulo (F1.17–F1.18, F3.2, F5.14–F5.15).

### 7.1 Seletores de configuração (CRUD evento)

| Componente | Descrição |
|------------|-----------|
| `DS/AttendanceModeSelector` | QR único, QR duplo, PIN único, PIN duplo |
| `DS/ValidationWindowEditor` | 1 ou 2 janelas; intervalo ou sub-janelas início/fim |
| `DS/AudienceSelector` | curso, turma, público |
| `DS/FormativeLinkSelect` | vínculo opcional `formative_activity` |

### 7.2 Validação (aluno)

| Componente | Descrição |
|------------|-----------|
| `DS/PresenceValidator` | container HATEOAS-driven por `attendanceMode` |
| `DS/PinEntryForm` | 1 ou 2 fases; clear on 403 |
| `DS/QrInstructions` | redirect web / deep link |
| `DS/PhaseIndicator` | fase 1/2 em modos duplos |
| `DS/IneligibilityMessage` | mensagem genérica pós-403 |

### 7.3 Operação ao vivo (host/secretaria)

| Componente | Descrição |
|------------|-----------|
| `DS/EventOperationPanel` | layout OperationLayout |
| `DS/WindowControlBar` | abrir/fechar janela conforme modo |
| `DS/LiveAttendeeCounter` | presentes / total / inelegíveis |
| `DS/AttendeeStream` | lista ao vivo check-ins |
| `DS/HostPinDisplay` | PIN grande para projetor |
| `DS/HostQrDisplay` | QR regenerável full-screen |

### 7.4 Tokens de domínio presença

Já listados em §2.2 (`color/presence/*`, `color/event/*`). Incluir ícones: check, clock, x-circle, qr-code, key.

---

## 8. Editores & admin (F7)

| Componente | Rota | Descrição |
|------------|------|-----------|
| `DS/JsonSchemaEditor` | F7.4 | Editor JSON + syntax highlight |
| `DS/FormSchemaPreview` | F7.4 | Preview ao vivo do DynamicForm |
| `DS/WorkflowStateMachineEditor` | F7.4 | Drag-and-drop estados/transições + validação |
| `DS/RequestTypeForm` | F7.4 | capabilities, prazo_dias, metadata |
| `DS/TemplateEditor` | F7.5 | Markdown + placeholders + canal |
| `DS/TemplatePreview` | F7.5 | substituição variáveis |
| `DS/TemplateVersionHistory` | F7.5 | lista revisões |
| `DS/OutboxEventTable` | F7.6 | filtros status + retry action |
| `DS/ScheduledJobCard` | F7.6 | frequência, último/próximo run |
| `DS/UserAdminTable` | F7.1 | CRUD + role assignment |
| `DS/HealthMetricsPanel` | F7.9 `[P3]` | Actuator summary + link Grafana |

Layout padrão admin: `AdminLayout` + `TwoColumn` (editor | preview).

---

## 9. Mobile nativo (Expo)

Espelha tokens web (NativeWind). Componentes nativos adicionais:

| Componente / pattern | Descrição |
|----------------------|-----------|
| `DS/MobileTabBar` | 4–5 tabs, badge comunicação |
| `DS/MobileHeader` | título + back + actions |
| `DS/PullToRefresh` | dashboard, listas |
| `DS/SafeAreaView` | wrapper shell |
| `DS/BottomSheet` | ações contextuais nativas |
| `DS/QrScanner` | CameraView + debounce (modos QR mobile) |
| `DS/WebViewBridge` | fallback QR → browser |
| `DS/DraftBanner` | rascunho wizard retomável |
| `DS/OfflineBanner` | sem conexão |
| `DS/HapticButton` | feedback tátil ações críticas `[P3]` |

Rotas "ambas" em `telas.md` devem ter frame Figma mobile + variante responsiva web.

---

## 10. Estados, feedback & interação

### 10.1 Tríade obrigatória (listas/cards)

| Estado | Implementação |
|--------|---------------|
| Loading | `DS/Skeleton` nas posições reais do layout |
| Empty | `DS/EmptyState` contextual por módulo |
| Error | `DS/AlertBanner`; parcial (resto intacto) ou full page |

### 10.2 Estados de interação (todos os interativos)

Default · Hover · Focus-visible · Active/Pressed · Disabled · Loading

### 10.3 Estados de seleção

Selected row · NavItem active · Checkbox indeterminate · Bulk selection bar

### 10.4 Estados de formulário

Pristine · Dirty · Valid · Invalid (+ `aria-live="polite"`) · Submitting

### 10.5 Frames Figma de referência

- Dashboard skeleton (KPI + pendências + tabela)
- Empty pendências
- Erro parcial (banner topo)
- Wizard step validation error
- Presence 403 generic
- Import preview com linhas inválidas

### 10.6 Regras HATEOAS (visual)

- `DS/ActionBar` renderiza **somente** ações presentes em `_links`
- Nunca esconder por `user.role` — apenas por link ausente
- Botões destrutivos sempre `AlertDialog` confirmação

---

## 11. Acessibilidade & i18n

### 11.1 Acessibilidade (WCAG 2.1 AA)

- Contraste ≥ 4.5:1 texto normal; ≥ 3:1 texto large
- Focus ring: `ring-2 ring-brand-primary` em todo interativo
- Touch target ≥ 44×44 (nav, tiles, botões mobile)
- Cor nunca único diferenciador — sempre ícone ou texto
- `aria-label` em icon-only; `aria-live="polite"` em erros dinâmicos
- Modal: `role="dialog"`, focus trap (Radix)
- Tabelas: `<th scope>`; sort anunciado
- Virtual scroll: preservar focus management

### 11.2 i18n

- Idioma padrão: **pt-BR**
- Estrutura de chaves preparada para en-US
- Tokens tipográficos suportam expansão ~30% (alemão futuro)
- Formato data/hora: locale-aware nos DatePickers
- `ProtocolBadge`, números e hashes: LTR sempre

---

## 12. Pipeline Figma → Cursor

```
Figma Variables (source of truth)
  ↓ figma-mcp
frontend-web/src/shared/tokens/tokens.css
  ↓
tailwind.config.ts
  ↓
shadcn theme → tokens
  ↓
frontend-web/src/shared/ui/*  (DS/*)
  ↓
Code Connect (*.figma.ts) por componente
  ↓
mobile: tailwind.config.js (mesmos tokens NativeWind)
```

**Regra:** zero hex/px hardcoded em `DS/*`. `className` só para layout (flex, grid), nunca cor/spacing ad hoc.

**Prioridade implementação componente:**
1. Existe em `DS/*` Figma → reuse
2. Existe base shadcn → extend com tokens
3. Build from Figma spec + tokens

---

## 13. Registro mestre de componentes

Contagem: **~120 componentes/patterns** documentados.

### MVP v1 `[P0]` — construir primeiro

| # | ID | Dimensões / variantes |
|---|-----|------------------------|
| 1 | `DS/Button` | h40/h32; primary, secondary, ghost, link, danger |
| 2 | `DS/Card` | p24; default, interactive |
| 3 | `DS/Badge` | h24 px8; 5 semânticas |
| 4 | `DS/KpiCard` | min-h120 |
| 5 | `DS/NavItem` | h44 |
| 6 | `DS/AlertBanner` | 4 severidades, dismissible |
| 7 | `DS/PendenciaItem` | min-h72 |
| 8 | `DS/EventoRow` | with/without CTA |
| 9 | `DS/DataTable/Compact` | row h48 |
| 10 | `DS/TimelineItem` | — |
| 11 | `DS/QuickTile` | min 88×88 |
| 12 | `DS/Avatar` | 32/36/48 |
| 13 | `DS/Input` + `DS/Input/Search` | h40 |
| 14 | `DS/Skeleton` | line, block, circle |
| 15 | `DS/EmptyState` | + ilustração |
| 16 | `Shell/AppLayout` | sidebar 256 + topbar 64 |
| 17 | `Shell/PublicLayout` + `Shell/AuthLayout` | login flow |
| 18 | `Shell/Drawer` | mobile sidebar |

### MVP v2 `[P1]` — solicitações & formulários

DynamicForm, WizardStepper, Select, Checkbox, RadioGroup, FileUpload, AttachmentUpload, Dialog, Toast, Tabs, FilterBar, DataTable/Full, ActionBar, DeliberationPanel, ExpandableCard, SessionList, PasswordStrengthMeter, PresenceValidator (base).

### Produto completo `[P2]`

Presença operação completa, editores admin F7, charts, import wizard, verification portal, commission dashboards, SortableList, CommandPalette.

### Opcional `[P3]`

TaskBoard, HealthMetricsPanel, CommentThread, MFA slot, HapticButton, high contrast mode.

---

## 14. Ordem de construção & priorização

### Fase 1 — Foundations + Brand (página `00`, `01`)

1. Cores primitivas + todas semânticas (incl. domínio)
2. Tipografia completa (14 papéis)
3. Spacing, layout, grid 12 col
4. Radius, border, shadow, z-index, motion
5. Ícones grid + Logo + ilustrações Empty/Error base

### Fase 2 — Shells (página `02`)

6. PublicLayout, AuthLayout, AppLayout, Drawer
7. Regiões Main/* (PageHeader, KpiRow, MainGrid, AlertStrip)

### Fase 3 — Core DS (página `04`)

8. P0: Button → EmptyState (18 itens registro §13)
9. Estados interação em cada componente

### Fase 4 — Page Patterns (página `03`)

10. Pattern/AuthForm, DashboardBFF, ErrorPage
11. Pattern/RequestList, RequestWizard, RequestDetail (wireframes)

### Fase 5 — Domínio & extensões (páginas `05`, `06`)

12. Presença v4.1 completo
13. Admin editores F7
14. Charts, import/export, verification

### Fase 6 — Mobile + estados (páginas `08`, `10`)

15. MobileShell, TabBar, PullToRefresh
16. Frames skeleton/empty/error por pattern principal

### Fase 7 — Code Connect

17. Mapear cada `DS/*` → `shared/ui/ComponentName.tsx`

---

## Referências cruzadas

| Documento | Conteúdo |
|-----------|----------|
| `agents/ux-ui-specialist.md` | Tokens, DS/* base, AppLayout, a11y, DashboardA |
| `agents/mobile-engineer.md` | NativeWind, QR scanner, offline drafts |
| `foundationDocs/prompts/PROMPT_figma_make_dashboard_aluno_estrutura.md` | Medidas dashboard, DS/* dimensões |
| `foundationDocs/analysis/telas.md` | 48 rotas, F0–F8, componentes por tela |
| `foundationDocs/analysis/mvp_v1_walking_skeleton_aluno.md` | Escopo P0 |
| `foundationDocs/analysis/mvp_v2_solicitacoes_workflow_engine.md` | Wizard, DynamicForm P1 |
| `foundationDocs/endpoints_canonicos_presenca_eventos_v4.md` | Modos presença v4.1 |

---

*Documento v2.0 — cobertura completa de elements visuais web + mobile alinhada a `telas.md`. Valores concretos de cor/tipografia (hex, fonte institucional) devem ser extraídos do blueprint DashboardA / referência visual e aplicados sobre esta árvore de tokens semânticos.*
