# Prompt — Fluxograma da Arquitetura Completa do Banco de Dados (TCC — SecretariaOnline2)

**Objetivo:** gerar **uma imagem** (fluxograma horizontal, estilo acadêmico/TCC) que explique como funcionam, em conjunto, o banco transacional, o armazenamento de arquivos, o processamento assíncrono, a auditoria e as consultas analíticas do **SecretariaOnline2**.

**Idioma do diagrama:** português do Brasil  
**Formato de saída desejado:** PNG ou SVG em alta resolução, orientação **paisagem (landscape)**, proporção aproximada **16:9** ou **A4 horizontal**  
**Público-alvo da figura:** banca de TCC e leitores técnicos não especialistas em banco de dados

---

## Como usar este prompt

1. Copie **integralmente** a seção **§ PROMPT PARA COLAR NA IA** (final deste arquivo) para a ferramenta de geração de imagem/diagrama escolhida.
2. Se a ferramenta aceitar **imagem de referência**, anexe o exemplo de fluxograma OLTP→ETL→OLAP (estilo acadêmico com cilindros de banco, caixas explicativas e setas rotuladas).
3. Se a saída ficar ilegível, peça uma **segunda iteração** pedindo: *"aumentar fonte das caixas explicativas, reduzir texto nas setas, manter todos os rótulos em português"*.
4. Salve o resultado em `foundationDocs/DB/figuras/` com nome sugerido: `FIGURA-1-arquitetura-completa-banco-dados.png`.

**Ferramentas sugeridas:** DALL·E, Midjourney, Ideogram, Gemini (imagem), Napkin AI, Lucidchart (com prompt), ou Figma Make com modo diagrama.

---

## Contexto do sistema (não inventar além disso)

**SecretariaOnline2** é a modernização do sistema acadêmico *Secretaria Online* (UFPR SEPT). Arquitetura: **monólito modular** (Kotlin + Spring Boot 3) com **PostgreSQL 16** como banco transacional único no MVP, **MinIO** para blobs, **padrão Outbox** para notificações assíncronas (sem RabbitMQ no MVP), clientes **React Web** e **React Native (Expo)**.

> **Importante:** o sistema **não** possui data warehouse OLAP separado no MVP. Estatísticas consultam o OLTP com cache de 5 minutos. A evolução futura (réplica read-only) deve aparecer apenas como caixa tracejada opcional — **não** como fluxo principal.

---

## Referência visual (imitar o estilo, não o domínio)

Reproduzir o **layout e a linguagem visual** do exemplo anexo (fluxograma "Arquitetura completa do Banco de Dados do Sistema"):

| Elemento do exemplo | Adaptação para SecretariaOnline2 |
|---------------------|----------------------------------|
| Fundo bege/amarelo claro | Manter |
| Título grande amarelo/laranja no canto superior esquerdo | **"Arquitetura completa do Banco de Dados — SecretariaOnline2"** |
| Fluxo principal da esquerda para a direita | Manter |
| Cilindro vermelho = OLTP | **PostgreSQL 16 (OLTP)** |
| Caixa azul escura = processamento batch | **Processamento Assíncrono (Outbox + Jobs)** |
| Cilindro azul claro = camada analítica | **Consultas Analíticas (MVP)** — *não* chamar de OLAP |
| Ícone verde = visualização | **Dashboards Recharts** (secretaria/coordenação) |
| Balões/caixas arredondadas com lista numerada | Manter para cada componente |
| Setas com rótulos de ação | Manter (Persiste, Enfileira, Consulta, Envia, etc.) |
| Figura de usuário no final | **Usuários do sistema acadêmico** |
| Loop de retorno do usuário | **Filtros de período/curso** nas estatísticas; **download** de exportações |

---

## Mapa do fluxo (conteúdo obrigatório)

### Bloco 1 — Entrada de dados (extrema esquerda)

**Ícones:** computador (portal web) + smartphone (app mobile)

**Rótulo principal:** `Usuários do Sistema Acadêmico`

**Sub-rótulos (pequenos):** Aluno · Professor · Secretaria · Coordenador · Admin · Público (verificação de certificado)

**Seta saindo para a direita:** `Requisições REST + JWT (HATEOAS)`

**Caixa explicativa (bege):**
1. Web: React 18 + Vite + TanStack Query  
2. Mobile: React Native + Expo  
3. API stateless; autorização por capabilities (FGAC)  
4. Upload/download de arquivos via URL pré-assinada (não passa pelo banco relacional)

---

### Bloco 2 — Camada de aplicação (opcional, entre usuários e banco)

**Retângulo azul médio:** `Backend Spring Boot 3 (Monólito Modular)`

**Caixa explicativa (azul escuro):**
1. 9 bounded contexts: iam, academico, solicitacoes, formativas, estagio, tcc, presenca, comunicacao, auditoria/arquivos  
2. Clean Architecture: domain → application → infrastructure → api  
3. Flyway aplica migrations SQL versionadas (`V###__*.sql`)  
4. Toda mutação de estado relevante grava `audit_log`

**Seta para a direita:** `Persiste / Consulta`

---

### Bloco 3 — Núcleo transacional (centro-esquerda) — **destaque visual**

**Cilindro vermelho grande:** `Banco OLTP (PostgreSQL 16)`

**Caixa explicativa (vermelho claro/rosa):**
1. Registro operacional de todo o domínio acadêmico (solicitações, presença, formativas, estágio, TCC, comunicações)  
2. **31 tabelas** em estrutura **normalizada (3NF)**  
3. Chaves **UUIDv7**; datas **TIMESTAMPTZ**; schemas variáveis em **JSONB** (`request_type.form_schema`, `request_type.workflow_json`, `request.dados`)  
4. Extensões: `pgcrypto`, `uuid-ossp`, `citext`  
5. Versionamento de schema via **Flyway** (migrations imutáveis, forward-only)

**Lista compacta dos módulos (dentro ou ao lado do cilindro):**

| Módulo | Tabelas principais |
|--------|-------------------|
| M1 IAM | `usuario`, `role`, `authority`, `role_authority`, `usuario_role`, `refresh_token`, `jti_blacklist` |
| M2 Acadêmico | `curso`, `disciplina`, `periodo_letivo`, `calendario_academico` |
| M3 Solicitações | `request_type`, `request`, `request_event`, `request_line_item`, `request_attachment` |
| M4 Formativas | `formative_activity`, `formative_entry` |
| M5 Estágio | `internship`, `internship_document` |
| M6 TCC | `tcc`, `tcc_member`, `tcc_examiner` |
| M7 Comunicação | `communication`, `communication_delivery`, `notification_preference`, `outbox_event` |
| M8 Presença v4.1 | `event_attendance`, `attendance_session` |
| M9 Certificados/Auditoria | `certificate`, `audit_log` |

**Setas saindo do cilindro OLTP (múltiplas, para baixo e para a direita):**

| Seta | Destino | Rótulo |
|------|---------|--------|
| 1 | Processamento Assíncrono | `Enfileira eventos` |
| 2 | MinIO | `Metadados de arquivo` |
| 3 | Trilha de Auditoria | `Registra imutável` |
| 4 | Consultas Analíticas | `Agrega (SELECT)` |
| 5 | Jobs Export/Import | `Dispara job` |

---

### Bloco 4 — Processamento assíncrono (centro) — equivalente visual ao "ETL" do exemplo

**Retângulo azul escuro horizontal:** `Processamento Assíncrono (Outbox + Scheduled Jobs)`

**Caixa explicativa (azul escuro):**
1. **Padrão Outbox:** `INSERT outbox_event` na mesma transação da mutação de negócio (consistência ACID)  
2. **OutboxDispatcher:** `@Scheduled(fixedDelay=5000)` — lê até 50 eventos `PENDING` com `FOR UPDATE SKIP LOCKED`  
3. Tipos de evento: `solicitacoes.deliberated`, `exports.ready`, `imports.completed`, `estagios.document_reviewed`, etc.  
4. **Export Jobs:** gera CSV volumoso em background → grava no MinIO → notifica por e-mail  
5. **Import Jobs:** valida CSV em lotes de 1.000 linhas → persiste no OLTP  
6. **Certificados:** ao concluir evento/aprovar formativa, gera PDF + hash SHA-256 + assinatura ED25519

**Setas saindo:**
- `Envia` → Canais de Notificação (e-mail Mailgun/SMTP + push FCM)  
- `Grava arquivo` → MinIO  
- `Atualiza status` → OLTP (retorno pontilhado)

> **Não** rotular este bloco como "ETL Python" — o MVP usa **Kotlin + Spring @Scheduled**, não pipeline Python/Pandas.

---

### Bloco 5 — Armazenamento de objetos (centro-direita, paralelo ao OLTP)

**Cilindro roxo ou teal:** `Object Storage (MinIO / S3-compatible)`

**Caixa explicativa (roxo/teal claro):**
1. Blobs **fora** do PostgreSQL: PDFs, imagens, CSVs de exportação  
2. Tabelas relacionais guardam apenas `storage_key`, `sha256`, `mime_type`, `tamanho_bytes`  
3. Upload: backend emite URL pré-assinada → cliente faz PUT direto no MinIO  
4. Download: URL pré-assinada temporária (15 min download; exportações expiram em 7 dias)  
5. Buckets: anexos de solicitação, documentos de estágio, fotos de perfil, certificados PDF, exports CSV

**Seta de retorno para usuário:** `Download via link assinado`

---

### Bloco 6 — Trilha de auditoria (faixa inferior, paralela ao fluxo principal)

**Retângulo cinza com ícone de escudo ou livro:** `Auditoria Imutável (audit_log)`

**Caixa explicativa (cinza):**
1. Todo comando que altera estado emite registro append-only  
2. Campos: `ator`, `acao`, `alvo_tipo`, `alvo_id`, `dados_antes/depois` (JSONB), `resultado`, `ip`, `timestamp`  
3. Consultável por admin em `/admin/audit-log`  
4. Importações e exportações registram checksum SHA-256 para rastreabilidade

**Sem seta de escrita de volta ao OLTP** (somente leitura para conformidade)

---

### Bloco 7 — Consultas analíticas (centro-direita)

**Cilindro azul claro:** `Camada Analítica (MVP — consulta OLTP)`

**Caixa explicativa (azul claro):**
1. Dashboards de estatísticas operacionais (`/secretaria/estatisticas`)  
2. API: `GET /reports/secretary` com filtros período + curso  
3. Gráficos Recharts: solicitações por tipo, evolução temporal, distribuição por estado, horas formativas  
4. Cache de **5 minutos** no backend; drill-down tabular paginado  
5. **Não há** schema estrela nem banco OLAP separado no MVP

**Caixa tracejada (evolução futura, menor, canto inferior):**  
`Evolução (6–12 meses): réplica PostgreSQL read-only para relatórios pesados`

**Seta para visualização:** `Envia dados agregados`

---

### Bloco 8 — Visualização e notificação (extrema direita)

**Ícone verde (gráfico de barras/linhas):** `Visualização (Secretaria / Coordenação)`

**Ícone azul (envelope + sino):** `Notificações Multicanal`

**Caixa explicativa do robô/IA do exemplo → substituir por Notificações:**
1. E-mail HTML renderizado por TemplateEngine  
2. Push via Firebase Cloud Messaging (app mobile)  
3. Hub de avisos in-app (`communication` + `communication_delivery`)  
4. Preferências por usuário em `notification_preference`

**Figura de usuário:** `Usuário`

**Setas finais:**
- `Visualização` → Usuário (dashboards, tabelas, gráficos)  
- `Notificação` → Usuário (e-mail, push, hub)  
- `Seleciona filtros` ← Usuário → Consultas Analíticas (loop de retorno, como no exemplo)  
- `Baixa exportação` ← Usuário → MinIO (loop opcional)

---

### Bloco 9 — Verificação pública (canto inferior direito, opcional)

**Ícone de QR code + cadeado:** `Verificador Público de Certificados`

**Rota:** `/publico/verificar-certificado/:hash`  
**Sem autenticação** — consulta hash SHA-256 e chave pública em `/.well-known/jwks.json`  
**Seta tracejada** desde `certificate` (OLTP) e PDF (MinIO)

---

## Paleta de cores sugerida

| Componente | Cor principal | Cor da caixa explicativa |
|------------|---------------|--------------------------|
| Fundo | `#F5F0E1` bege claro | — |
| Título | `#E8A317` amarelo-laranja | — |
| PostgreSQL OLTP | `#C0392B` vermelho | `#FADBD8` rosa claro |
| Spring Boot / API | `#2C3E50` azul escuro | `#D6EAF8` azul muito claro |
| Outbox + Jobs | `#1A5276` azul petróleo | `#AED6F1` |
| MinIO | `#6C3483` roxo | `#E8DAEF` |
| Analítico (MVP) | `#2980B9` azul | `#D4E6F1` |
| Visualização | `#27AE60` verde | `#D5F5E3` |
| Auditoria | `#7F8C8D` cinza | `#EAECEE` |
| Setas | `#2C3E50` ou preto | — |

---

## Regras de qualidade da figura

1. **Legibilidade:** texto das caixas explicativas em fonte sans-serif (Arial, Helvetica ou similar), tamanho mínimo equivalente a 9–10 pt impresso.  
2. **Hierarquia:** o cilindro PostgreSQL OLTP deve ser o **maior** elemento visual (núcleo do diagrama).  
3. **Fidelidade técnica:** não mostrar MongoDB, RabbitMQ, Redis ou data warehouse como componentes do MVP.  
4. **Coerência:** todas as setas com sentido lógico (esquerda→direita no fluxo principal; retornos pontilhados para downloads e filtros).  
5. **Legenda da figura (rodapé):**  
   *Figura X – Arquitetura completa do banco de dados do SecretariaOnline2: camada transacional PostgreSQL 16, armazenamento de objetos MinIO, processamento assíncrono via Outbox, trilha de auditoria imutável e consultas analíticas com cache sobre o OLTP (MVP).*  
6. **Fonte (canto inferior):** *Fonte: Os autores (2026), com base em `foundationDocs/DB/` e `analise_arquitetural_secretariaonline2.md`.*

---

## O que NÃO incluir (erros comuns a evitar)

- ❌ Pipeline ETL Python / Pandas / SQLAlchemy (é do exemplo de referência, não do SO2)  
- ❌ Banco OLAP / Data Warehouse / Star Schema como componente principal do MVP  
- ❌ Camada de IA / Machine Learning analisando dados  
- ❌ RabbitMQ, Kafka ou Redis como fila no MVP  
- ❌ MD5, sessões server-side, filesystem local `C:\Users\...` (legado)  
- ❌ Entidades removidas do modelo: `DELIBERATION`, `FORM_SCHEMA`, `WORKFLOW_DEFINITION` como tabelas separadas  
- ❌ `ATTENDANCE_CHECKIN` — o nome correto é `attendance_session`  
- ❌ Geofence, BLE ou trust score no módulo de presença v4.1

---

## Variações opcionais (pedir em iteração separada se necessário)

| Variação | Quando usar |
|----------|-------------|
| **Simplificada** | Slide de apresentação oral — omitir tabela de 31 tabelas; manter só 5 blocos principais |
| **Detalhada** | Apêndice do TCC — incluir mini-ER com hub `USUARIO` e os 4 módulos de maior volume |
| **Com migração legado** | Adicionar caixa tracejada à esquerda: "Sistema Legado (Java EE + MD5)" → seta "ETL de migração (Big Bang)" → OLTP |

---

## PROMPT PARA COLAR NA IA

Copie o bloco abaixo **na íntegra**:

---

```
Crie um fluxograma horizontal em estilo acadêmico/TCC, com fundo bege claro (#F5F0E1), título grande amarelo-laranja no canto superior esquerdo: "Arquitetura completa do Banco de Dados — SecretariaOnline2".

Imite o layout visual de um fluxograma de arquitetura de dados com cilindros de banco de dados, retângulos de processamento, ícones de usuário e caixas explicativas numeradas com cantos arredondados — fluxo principal da ESQUERDA para a DIREITA, com setas rotuladas.

DOMÍNIO: sistema acadêmico universitário (secretaria online) — NÃO é um sistema de ciências biológicas.

=== BLOCO 1 (esquerda) — ENTRADA ===
Ícones: computador + smartphone.
Rótulo: "Usuários do Sistema Acadêmico" (Aluno, Professor, Secretaria, Coordenador, Admin, Público).
Caixa explicativa bege:
1. Web React + Mobile Expo
2. API REST com JWT e HATEOAS (FGAC)
3. Upload via URL pré-assinada (arquivos não vão para o banco relacional)
Seta para direita: "Requisições REST + JWT"

=== BLOCO 2 — BACKEND ===
Retângulo azul escuro: "Backend Spring Boot 3 (Monólito Modular)".
Caixa explicativa:
1. 9 módulos: iam, academico, solicitacoes, formativas, estagio, tcc, presenca, comunicacao, auditoria
2. Flyway versiona o schema SQL
3. Toda mutação grava audit_log
Seta: "Persiste / Consulta"

=== BLOCO 3 (DESTAQUE, cilindro vermelho grande) — OLTP ===
Cilindro vermelho: "Banco OLTP (PostgreSQL 16)".
Caixa explicativa vermelho claro:
1. Registro operacional do domínio acadêmico
2. 31 tabelas normalizadas (3NF) em 9 módulos
3. UUIDv7, TIMESTAMPTZ, JSONB para formulários dinâmicos
4. Extensões pgcrypto, citext; migrations Flyway
Lista compacta dos módulos: IAM, Acadêmico, Solicitações (engine genérica 19 tipos), Formativas, Estágio, TCC, Comunicação/Outbox, Presença v4.1, Certificados/Auditoria.

Cinco setas saindo do cilindro:
- "Enfileira eventos" → Bloco 4
- "Metadados de arquivo" → Bloco 5 (MinIO)
- "Registra imutável" → faixa inferior Auditoria
- "Agrega (SELECT)" → Bloco 7
- "Dispara job" → Bloco 4

=== BLOCO 4 (centro) — PROCESSAMENTO ASSÍNCRONO ===
Retângulo azul petróleo: "Processamento Assíncrono (Outbox + Scheduled Jobs)".
NÃO rotular como ETL Python.
Caixa explicativa azul escuro:
1. Padrão Outbox: outbox_event na mesma TX ACID
2. Dispatcher @Scheduled a cada 5s (até 50 eventos)
3. Export Jobs: CSV → MinIO → e-mail
4. Import Jobs: validação em lote → OLTP
5. Geração de certificados PDF (SHA-256 + ED25519)
Setas: "Envia" → Notificações; "Grava arquivo" → MinIO; retorno pontilhado → OLTP

=== BLOCO 5 — MINIO ===
Cilindro roxo/teal: "Object Storage (MinIO / S3)".
Caixa explicativa:
1. PDFs, imagens, CSVs fora do Postgres
2. Tabelas guardam storage_key + sha256
3. Upload/download por URL pré-assinada
4. Exportações expiram em 7 dias

=== FAIXA INFERIOR — AUDITORIA ===
Retângulo cinza: "Auditoria Imutável (audit_log)".
Caixa: append-only, ator+ação+alvo+JSON antes/depois, consulta admin.

=== BLOCO 7 — ANALÍTICO MVP ===
Cilindro azul claro: "Consultas Analíticas (MVP — sobre OLTP)".
NÃO mostrar OLAP/Data Warehouse como fluxo principal.
Caixa explicativa:
1. Dashboard /secretaria/estatisticas
2. Gráficos Recharts (solicitações, formativas, estados)
3. Cache 5 min; drill-down tabular
Caixa TRACEJADA menor: "Evolução: réplica read-only PostgreSQL"
Seta: "Envia dados agregados" → Visualização

=== BLOCO 8 (direita) — SAÍDA ===
Ícone verde (gráficos): "Visualização Secretaria/Coordenação".
Ícone azul (envelope+sino): "Notificações (E-mail + Push FCM + Hub)".
Figura: "Usuário".
Setas: "Visualização" e "Notificação" → Usuário.
Loop de retorno: Usuário "Seleciona filtros" → Consultas Analíticas; Usuário "Baixa exportação" → MinIO.

=== OPCIONAL canto inferior direito ===
Ícone QR: "Verificador Público de Certificados" (/publico/verificar-certificado/:hash), sem login.

RODAPÉ: "Figura X – Arquitetura completa do banco de dados do SecretariaOnline2". Fonte: Os autores (2026).

ESTILO: limpo, profissional, cores distintas por camada (vermelho=OLTP, azul escuro=processamento, roxo=MinIO, azul claro=analítico, verde=visualização, cinza=auditoria). Texto legível em português. Alta resolução, paisagem 16:9.
```

---

## Checklist pós-geração

- [ ] Título e rodapé em português  
- [ ] PostgreSQL OLTP é o elemento central e maior  
- [ ] MinIO aparece como armazenamento separado do relacional  
- [ ] Outbox aparece (não RabbitMQ)  
- [ ] Sem OLAP/ETL Python/IA como componentes principais  
- [ ] Loop de filtros do usuário nas estatísticas  
- [ ] Legenda de figura no rodapé  
- [ ] Texto legível em zoom 100% em A4 horizontal

---

**Arquivo:** `foundationDocs/prompts/PROMPT_gerar_fluxograma_arquitetura_banco_dados.md`  
**Versão:** 1.0 — 2026-06-23  
**Referências:** `foundationDocs/DB/modelo-conceitual.md`, `foundationDocs/DB/00-inventario-e-decisoes.md`, `foundationDocs/analysis/analise_arquitetural_secretariaonline2.md` §3–5 e §13.3, `foundationDocs/sequenceDiagrams/transversal/10.1-outbox-notificacao.md`, RF-F5-010 e RF-F5-011
