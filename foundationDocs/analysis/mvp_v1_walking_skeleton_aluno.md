# MVP v1 — Walking Skeleton do Aluno (implementação real, ~15 dias)

**Projeto:** SecretariaOnline2 (TCC — UFPR SEPT)
**Versão deste guia:** v1.0
**Documentos-base:** `mvp_walking_skeleton_aluno.md`, `analise_arquitetural_secretariaonline2.md`, `telas.md`, `fluxos_por_perfil.md`, `jpaInterfaces_PostgresEntities.md`, `endpoints_canonicos_presenca_eventos_v4.md`
**Para quem:** este arquivo é **guia de implementação** para o desenvolvedor **e** para os agentes (`.cursorrules` + `agents/*`). Toda decisão aqui é **definitiva** — implementações reais, sem protótipo descartável.

> **Sequência de entrega**: implementar **toda a v1**, testar e validar (Definition of Done §12), e **só então** partir para `mvp_v2_solicitacoes_workflow_engine.md`. A v2 **reusa** 100% da fundação da v1 sem refatoração.

---

## 1. Objetivo da v1

Entregar uma **fatia vertical fina e funcional** que atravessa **todas as camadas reais** do produto usando a **arquitetura definitiva**:

```
Figma (Design System) → tokens → React → API REST (Spring) → PostgreSQL
                                        ↑
                              JWT + Argon2id + FGAC + HATEOAS
```

A jornada entregue:

> `/login` → (`/primeiro-acesso` quando `mustChangePassword=true`) → `/inicio` (Dashboard do Aluno com **dados reais** de `GET /bff/dashboard/aluno`).

**Princípio diretor:** *"estreito em escopo, profundo em arquitetura e infraestrutura"*. A largura (solicitações, eventos, etc.) vem na v2+; a profundidade (segurança, contratos, deploy containerizado com HTTPS) **não pode ser retrofitada**.

---

## 2. Escopo (IN / OUT)

### 2.1 IN — Dentro da v1

**Telas (3 rotas)**
- `/login` (F0.1)
- `/primeiro-acesso` (F1.2) — troca de senha forçada + aceite LGPD
- `/inicio` (F1.1) — Dashboard do aluno (blueprint **DashboardA**, regra crítica do `.cursorrules`)

**Backend (módulos definitivos)**
- `iam`: `POST /auth/login`, `POST /auth/refresh`, `POST /auth/first-access`, `GET /me`
- `academico`: entidade `curso` (leitura) para compor o dashboard
- `bff`: `GET /bff/dashboard/aluno` (agrega KPIs, pendências, eventos, últimas solicitações, prazos, último parecer, atalhos) + `_links` HATEOAS
- Segurança: Argon2id + JWT access (15 min) + refresh rotativo (7 dias, reuse detection) + FGAC por `authorities`
- PostgreSQL 16 + Flyway (schema final parcial)
- Seed determinístico (1 aluno demo + curso + dados de dashboard)
- Swagger/OpenAPI publicado
- Erros RFC 7807 (Problem Details)

**Frontend Web**
- React 18 + Vite + TypeScript + Tailwind + shadcn/ui
- Pipeline Design System Figma → tokens (`tokens.css` + `tailwind.config.ts`)
- Componentes `DS/*` (Button, Card, Badge, KpiCard, NavItem, AlertBanner, Skeleton, EmptyState…)
- `AppLayout` (Sidebar 256 + Topbar 64)
- TanStack Query consumindo o BFF; React Hook Form + Zod no login
- Estados loading (skeleton) / empty / erro parcial
- Helper `useActions(_links)` (semente HATEOAS)

**Infraestrutura (real, containerizada, com HTTPS) — ver §8**
- `docker-compose` para dev (Postgres + backend + Mailpit opcional)
- Backend containerizado (imagem Docker multi-stage)
- Deploy cloud: frontend na **Vercel**; backend + Postgres em containers em provedor cloud (Railway/Render/Fly.io) com **HTTPS** (TLS gerenciado)
- CI (GitHub Actions): lint + build + test (backend e frontend) + build de imagem Docker

### 2.2 OUT — Explicitamente adiado (entra na v2+)
- Workflow Engine + wizard de solicitação + anexos/MinIO (→ **v2**)
- Formativas, Estágio, TCC, Presença/Eventos, Certificados
- Mobile (React Native/Expo) — estrutura prevista, não implementada
- Hub de comunicação real, Outbox dispatcher, push/email
- ETL do legado, observabilidade completa (Prometheus/Grafana/OTEL), RabbitMQ, API Gateway
- Telas de Secretaria/Coordenação/Admin

> Na v1, os cards de Solicitações/Eventos/Formativas no dashboard são **read-only**, alimentados pelo seed via BFF, **sem navegação funcional**. Isso é honesto e suficiente para validar a arquitetura.

---

## 3. Agentes responsáveis (delegação)

Conforme `.cursorrules` (Call Table). Ao implementar cada parte, **ler o agente correspondente** em `agents/`:

| Bloco da v1 | Agente(s) a ler |
|-------------|-----------------|
| Tokens, DS/*, layout, DashboardA, a11y | `ux-ui-specialist` |
| Telas React, TanStack Query, RHF+Zod, `useActions` | `frontend-engineer` |
| Módulos `iam`/`academico`/`bff`, use cases, controllers, HATEOAS | `backend-architect` |
| Schema, migrations Flyway, entidades JPA, índices | `database-engineer` |
| Argon2id, JWT, refresh rotation, FGAC, headers, rate limit | `security-engineer` |
| Docker, compose, HTTPS, Vercel, cloud, CI/CD | `devops-engineer` |

Ordem de orquestração (multi-domínio): **security → database → backend → ux-ui → frontend → devops**.

---

## 4. Arquitetura e estrutura de pastas (definitiva — "zero refatoração")

```
secretariaonline2/
  backend/
    app/                         ← Spring Boot entrypoint + composição de módulos
    shared/                      ← kernel: Result, Page, IDs (UUIDv7), erros RFC7807, ValueObjects (Email, GRR, CPF)
    modules/
      iam/
        api/                     ← AuthController, MeController, DTOs, assemblers HATEOAS
        application/             ← LoginUseCase, RefreshTokenUseCase, FirstAccessUseCase, ports/out
        domain/                  ← Usuario, Role, Authority, PasswordHash (puro Kotlin)
        infrastructure/          ← *Entity JPA, *JpaRepository, Argon2/JWT adapters, Flyway
      academico/
        api/ application/ domain/ infrastructure/   ← Curso (leitura no MVP)
      bff/
        api/                     ← DashboardAlunoController (agrega iam + academico)
        application/             ← DashboardAlunoQuery
    build.gradle.kts
    settings.gradle.kts
    Dockerfile
  frontend-web/
    src/
      app/                       ← rotas (router), providers (QueryClient, Auth)
      shared/
        ui/                      ← componentes DS/* (Button, Card, Badge, KpiCard, NavItem...)
        tokens/                  ← tokens.css / tailwind theme gerados do Figma
        api/                     ← client http, tipos OpenAPI, useActions(HATEOAS)
        auth/                    ← guard de rota, store de tokens
      features/
        auth/                    ← /login, /primeiro-acesso
        dashboard/               ← /inicio (consome /bff/dashboard/aluno)
    index.html  vite.config.ts  tailwind.config.ts
    vercel.json
  ops/
    docker-compose.yml
    docker-compose.prod.yml
    nginx/                       ← reverse proxy + TLS (cloud)
    postgres/init/               ← extensões (uuid-ossp, pgcrypto, citext, pg_trgm)
  .github/workflows/ci.yml
  README.md
```

**Invariantes arquiteturais (já valendo na v1, idealmente validadas com ArchUnit):**
- `domain/` sem import de Spring/JPA/HTTP
- `infrastructure/` de um módulo nunca importado por outro módulo
- Comunicação entre módulos só por interface pública da `application` ou eventos de domínio
- Front: `features/*` consome `shared/*`; nunca o contrário

---

## 5. Modelo de dados da v1 (subconjunto do schema final)

> As tabelas da v1 são **idênticas** ao desenho final (seção 5.3 de `analise_arquitetural_secretariaonline2.md`). Nada será reescrito — a v2 só **adiciona** migrations.

### 5.1 Migrations Flyway

**`V000__extensions.sql`**
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "citext";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- UUIDv7 (time-sortable) — ver agents/database-engineer.md para a função completa
CREATE OR REPLACE FUNCTION uuid_generate_v7() RETURNS uuid AS $$
  SELECT encode(
    set_bit(set_bit(
      overlay(uuid_send(gen_random_uuid()) placing
        substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
        from 1 for 6),
      52, 1), 53, 1), 'hex')::uuid;
$$ LANGUAGE sql VOLATILE;
```

**`V001__iam_academico_baseline.sql`** — tabelas:
- `curso` (id, nome, sigla, horas_formativas_req, tipo_calendario, ativo, created_at)
- `usuario` (id UUIDv7, nome, cpf, email CITEXT unique, email_ufpr, grr unique, senha_hash Argon2id, senha_alterada, telefone, id_curso FK, metadata JSONB, ativo, created_at, updated_at, deleted_at)
- `role` (id, code unique, description)
- `authority` (id, code unique, description)
- `role_authority` (id_role, id_authority) PK composta
- `usuario_role` (id_usuario, id_role, escopo JSONB) PK composta
- `refresh_token` (id, id_usuario FK, token_hash, expira_em, usado_em, created_at) — suporte a rotação + reuse detection
- *(opcional)* `audit_log` (registrar login/first-access desde o dia 1)

Índices obrigatórios: `idx_usuario_email` (unique), `idx_usuario_grr` (unique), `idx_usuario_curso`, `idx_usuario_nome_trgm` (GIN), `idx_refresh_token_usuario`.

**`V002__seed_demo.sql`** — dados determinísticos:
- 1 curso (TADS, `horas_formativas_req=120`)
- `authority`: `dashboard.view_own`, `auth.first_access`, `user.update_own_profile`, `request.view_own` (semente p/ v2)
- `role` `ALUNO` + vínculo `role_authority`
- 1 usuário aluno demo (`senha_alterada=false` para exercitar o primeiro acesso; hash Argon2id de senha conhecida)
- `usuario_role` ligando o aluno ao role `ALUNO`

> Os números do dashboard (KPIs/pendências/eventos) na v1 são **compostos no BFF** a partir do seed mínimo. Quando os módulos reais chegarem (v2+), o BFF passa a lê-los das tabelas reais **sem mudar o contrato**.

### 5.2 Entidades JPA (nomenclatura final)
`UsuarioEntity`, `RoleEntity`, `AuthorityEntity`, `RoleAuthorityEntity` (`@EmbeddedId`), `UsuarioRoleEntity` (`@EmbeddedId`), `CursoEntity`, `RefreshTokenEntity`. Repositórios: `UsuarioJpaRepository`, `CursoJpaRepository`, etc. (ver `jpaInterfaces_PostgresEntities.md`).

---

## 6. Contratos de API da v1 (OpenAPI-first)

> **Escreva o OpenAPI ANTES do código.** O frontend trabalha contra mock (MSW) com o mesmo shape; o backend implementa o contrato. Quando ambos estiverem prontos, troca-se o mock pelo client tipado.

### 6.1 Endpoints

| Método | Caminho | Auth | Resposta |
|--------|---------|------|----------|
| `POST` | `/auth/login` | pública | `{ accessToken, refreshToken, mustChangePassword }` |
| `POST` | `/auth/refresh` | cookie/refresh | rotação de refresh + novo access |
| `POST` | `/auth/first-access` | access (flag) | `{ novaSenha, aceiteLgpd }` → marca `senha_alterada=true` |
| `GET`  | `/me` | access | dados do usuário + `authorities` + `_links` |
| `GET`  | `/bff/dashboard/aluno` | access (`dashboard.view_own`) | payload da tela `/inicio` |
| `GET`  | `/actuator/health` | pública | liveness/readiness |

### 6.2 Payload de `GET /bff/dashboard/aluno`
```jsonc
{
  "saudacao": { "nome": "Ana Silva", "curso": "TADS", "periodoLetivo": "2026/1" },
  "kpis": {
    "horasFormativas": { "atual": 72, "requerido": 120 },
    "solicitacoesEmAndamento": 3,
    "eventosHoje": 2,
    "certificados": 1
  },
  "alertas": [ { "tipo": "warning", "titulo": "Solicitação 2026-0042 aguarda seu ajuste", "_links": { "acao": "/solicitacoes/..." } } ],
  "pendencias": [ /* até 3 */ ],
  "eventos": [ /* até 3 */ ],
  "ultimasSolicitacoes": [ /* até 5: numero, tipo, estado, prazo, sla */ ],
  "prazos": [ /* até 3 */ ],
  "ultimoParecer": { "estado": "Aprovada", "titulo": "...", "excerpt": "..." },
  "_links": { "self": "/bff/dashboard/aluno", "novaSolicitacao": "/solicitacoes/nova" }
}
```

A UI renderiza ações **somente** quando o `_link` correspondente existe (HATEOAS, "cega a perfil"). O `_links.novaSolicitacao` já fica presente para preparar a v2 — mas a rota destino só existe na v2.

---

## 7. Processo Frontend → Backend (Figma + figma-mcp)

Ordem: **Design System no Figma → import via figma-mcp → telas no Cursor com tokens → backend → ligação**.

1. **Foundations no Figma**: Variables (Color, Spacing 8px, Radius, Typography, Shadow) — ver `agents/ux-ui-specialist.md`.
2. **Biblioteca `DS/*`** vinculada às Variables (sem valores hardcoded).
3. **figma-mcp**: ler Variables → gerar `frontend-web/src/shared/tokens/tokens.css` + mapear em `tailwind.config.ts`. Tema shadcn apontando para tokens.
4. **Telas no Cursor**: `AppLayout` + `/login` + `/inicio` consumindo **mock** (MSW) do contrato.
5. **Backend**: implementar `iam` + `academico` + `bff`; Flyway sobe schema; seed popula aluno demo.
6. **Ligação**: trocar mock pelo client real (tipos gerados do OpenAPI).

> **Regra de ouro:** zero hex/medida hardcoded no front. Tudo vem de token.

---

## 8. Infraestrutura — containers, HTTPS e deploy cloud

> Responsável: `agents/devops-engineer.md`. Esta seção fundamenta a operação real do TCC e prepara as incrementações da v2.

### 8.1 Topologia alvo (produção/demo)

```
                         Internet (HTTPS)
                              │
            ┌─────────────────┴──────────────────┐
            │                                     │
   ┌────────▼─────────┐                 ┌─────────▼──────────┐
   │  Vercel (CDN)    │   HTTPS/JSON    │  Backend container │
   │  frontend-web    │ ───────────────▶│  Spring Boot (TLS) │
   │  (React/Vite)    │                 │  porta 8080        │
   └──────────────────┘                 └─────────┬──────────┘
                                                   │ JDBC (rede privada)
                                         ┌─────────▼──────────┐
                                         │ PostgreSQL 16      │
                                         │ (container/managed)│
                                         └────────────────────┘
```

- **Frontend**: **Vercel** (build automático do `frontend-web`, HTTPS gerenciado, env `VITE_API_BASE_URL` apontando para o backend).
- **Backend + Postgres**: containers em provedor cloud com TLS gerenciado. Opções recomendadas para TCC (free/low-cost, suportam Docker + Postgres + HTTPS):
  - **Railway** (deploy de container + Postgres gerenciado, HTTPS automático) — mais simples.
  - **Render** (Web Service Docker + Postgres gerenciado, HTTPS automático).
  - **Fly.io** (Docker + Postgres + TLS) — mais controle.
- **HTTPS**: garantido pelo provedor (TLS termina no edge da Vercel/Railway/Render). Se usar VM própria, **nginx + Let's Encrypt/ACME** (ver `ops/nginx/`).

### 8.2 Docker Compose — desenvolvimento (`ops/docker-compose.yml`)
Serviços: `postgres:16-alpine` (healthcheck `pg_isready`, volume persistente, init de extensões), `mailpit` (opcional), `backend` (build do Dockerfile, `SPRING_PROFILES_ACTIVE=dev`, depends_on postgres healthy). Variáveis sensíveis via `.env` (nunca hardcoded). Detalhes completos em `agents/devops-engineer.md`.

### 8.3 Dockerfile do backend (multi-stage)
- Stage builder: `eclipse-temurin:21-jdk-alpine` → `./gradlew bootJar -x test`
- Stage runtime: `eclipse-temurin:21-jre-alpine`, usuário não-root, `ENTRYPOINT java -jar app.jar`

### 8.4 Configuração HTTPS / CORS / cookies (produção)
- CORS: `allowedOrigins` = domínio Vercel (via env, nunca `*`), `allowCredentials=true`.
- Refresh token em cookie `HttpOnly; Secure; SameSite=Lax`.
- Headers de segurança (HSTS, X-Content-Type-Options, X-Frame-Options) — ver `agents/security-engineer.md`.
- Access token em memória no front (não em localStorage).

### 8.5 Variáveis de ambiente (`.env.example` versionado; `.env` gitignored)
```bash
POSTGRES_PASSWORD=
SECURITY_JWT_PRIVATE_KEY=      # RSA-2048 PEM (base64)
SECURITY_JWT_PUBLIC_KEY=       # RSA-2048 PEM (base64)
CORS_ALLOWED_ORIGINS=          # https://<app>.vercel.app
# Frontend (Vercel):
VITE_API_BASE_URL=             # https://<backend-host>
```

### 8.6 CI/CD (`.github/workflows/ci.yml`)
- Job **backend**: serviço Postgres → `ktlintCheck` + `detekt` + `test` (Testcontainers) + `bootJar` + `gitleaks`.
- Job **frontend-web**: `npm ci` + `lint` + `type-check` + `test` + `build`.
- Job **deploy** (em `main`): build da imagem Docker do backend e push; deploy do front na Vercel (integração nativa Vercel↔GitHub) e do backend no provedor escolhido.

---

## 9. Segurança (definitiva no dia 1)

Responsável: `agents/security-engineer.md`. Não negociável:
- **Senha**: Argon2id (`Argon2PasswordEncoder`, memory ≥ 46MB).
- **Login**: rate-limit (Bucket4j) por IP+identificador; mensagens **genéricas** (anti-enumeração).
- **JWT**: access RS256 (15 min) com `authorities`; refresh opaco rotativo (7 dias) com **reuse detection** (reuso → invalida todas as sessões).
- **First access**: bloqueia toda navegação até `senha_alterada=true` + aceite LGPD (`metadata.aceite_lgpd_em`).
- **Auditoria**: `login_success`, `login_failed`, `first_access_completed` (se `audit_log` na v1).
- **FGAC**: `@PreAuthorize("hasAuthority('dashboard.view_own')")` — nunca `hasRole`.

---

## 10. Cronograma sugerido (15 dias, 1–2 pessoas)

Front e Backend correm em paralelo graças ao **contrato como mock**.

| Dia | Frente | Entrega |
|-----|--------|---------|
| 1 | Fundações/DevOps | Monorepo, `docker-compose` (Postgres), esqueleto Gradle multi-módulo, README, `.env.example` |
| 2 | Figma | Variables (cores/spacing/tipografia/radius) + base `DS/*` |
| 3 | Figma+Front | figma-mcp: tokens → `tokens.css` + `tailwind.config`; tema shadcn |
| 4 | Front | `DS/*` (Button, Card, Badge, KpiCard, NavItem, AlertBanner, Skeleton, EmptyState) |
| 5 | Front | `AppLayout` (Sidebar+Topbar) + `/login` (RHF+Zod) com mock |
| 6 | Front | `/inicio` com mock do BFF (KpiRow, MainGrid 2:1, todos os cards — DashboardA) |
| 7 | Front | Estados skeleton/empty/erro parcial + responsivo básico |
| 8 | Backend/DB | `V000`/`V001`/`V002` (extensões, schema, seed) + entidades JPA |
| 9 | Backend/Sec | `iam`: Argon2id + `POST /auth/login` + JWT access/refresh |
| 10 | Backend | `/auth/first-access`, `/auth/refresh`, `GET /me`, Problem Details, Swagger |
| 11 | Backend | `bff`: `GET /bff/dashboard/aluno` com `_links` + dados seed |
| 12 | Integração | Trocar mock pelo client real; login → token → dashboard real |
| 13 | Integração/Sec | Guard de rota, refresh automático, `/primeiro-acesso` ponta a ponta |
| 14 | Qualidade/DevOps | CI verde; 1 teste de domínio (Argon2/JWT) + 1 e2e do login; **deploy cloud (Vercel + backend/DB container com HTTPS)** |
| 15 | Demo | Polimento, dados de demo, roteiro, gravação de fallback |

Folga proposital nos dias 13–14 para imprevistos (ex.: pipeline figma-mcp, config TLS).

---

## 11. Riscos e mitigação

| Risco | Mitigação |
|-------|-----------|
| Pipeline figma-mcp → tokens demorar | Exportar JSON de tokens manual primeiro; automatizar depois; mock destrava o front |
| Backend atrasar e travar o front | Contrato como mock (MSW) permite front pronto sem backend |
| Escopo "vazar" para wizard/eventos | Congelar IN/OUT da §2; extra vira v2 |
| Argon2/JWT consumir tempo | Spring Security 6 + `spring-security-crypto` + `jjwt` (ADR-004/005) |
| Config HTTPS/CORS na cloud | Usar provedor com TLS gerenciado (Vercel/Railway/Render); CORS por env |
| Demo falhar ao vivo | Seed determinístico + gravação de fallback no dia 15 |

---

## 12. Definition of Done (critérios de aceitação da v1)

- [ ] `docker-compose up` sobe Postgres + backend; `npm run dev` sobe o front.
- [ ] Login com aluno demo retorna JWT; senha verificada com **Argon2id** (não MD5).
- [ ] Primeiro acesso força troca de senha + aceite LGPD e destrava `/inicio`.
- [ ] `/inicio` exibe **dados reais** de `GET /bff/dashboard/aluno` (não hardcoded).
- [ ] Todos os blocos do dashboard presentes: KpiRow(4), Pendências(3), Eventos(3, 1 CTA), Solicitações(tabela 5×3), Prazos(3), Último parecer, Atalhos(2×3).
- [ ] Estados **skeleton**, **empty** e **erro parcial** funcionam.
- [ ] **Zero** cor/medida hardcoded no front — tudo via tokens do Figma.
- [ ] Botões/ações aparecem conforme `_links` (HATEOAS).
- [ ] Swagger acessível; erros em formato RFC 7807.
- [ ] CI verde (lint + build + test) no PR.
- [ ] **Deploy funcional**: frontend na Vercel (HTTPS) consumindo backend containerizado (HTTPS) + Postgres; login → dashboard funcionando na URL pública.

**Roteiro de demo (5 min):** Figma (Variables + DS) → tokens no código → login → primeiro acesso → dashboard com dados reais → Swagger → derrubar 1 endpoint e mostrar "erro parcial" → mostrar estrutura de módulos explicando como o próximo módulo (v2) encaixa.

---

## 13. O que a v1 garante para a v2 ("zero refatoração")

1. **Fronteiras certas**: módulos + Clean Architecture; novo contexto (`solicitacoes/`) = **criar pasta**, não reorganizar.
2. **Contratos estáveis**: OpenAPI + `_links`; o front não muda quando o BFF passa a ler tabelas reais.
3. **Segurança definitiva**: Argon2id + JWT + FGAC já prontos; v2 só adiciona authorities (`request.open`, etc.).
4. **Schema final, parcial**: tabelas da v1 são as finais; v2 só **adiciona** migrations (`request_type`, `request`, …).
5. **Design System tokenizado**: novas telas da v2 reusam `DS/*` e tokens.
6. **IDs e datas corretos**: UUIDv7 + TIMESTAMPTZ desde a V1.
7. **Infra pronta**: pipeline de containers + HTTPS + Vercel + CI já operando; v2 só adiciona serviços (ex.: MinIO) ao mesmo compose/deploy.

---

## 14. Próximo passo

Concluída e testada a v1 (DoD §12), seguir para **`mvp_v2_solicitacoes_workflow_engine.md`** — a fatia que prova o **DRY** (Workflow Engine + tipos de solicitação configuráveis), reusando toda esta fundação.
