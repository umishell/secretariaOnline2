# US-F3-002 — Criar, Editar e Operar Eventos Formativos (v4.1)

| Campo | Valor |
|-------|-------|
| **ID** | US-F3-002 |
| **Épico** | PROF-EVENTOS |
| **Telas** | F3.2a `/professor/eventos` · F3.2b `/professor/eventos/:id` · F3.2c `/professor/eventos/:id/operacao` |
| **Prioridade** | P2 |
| **Plataforma** | Web (F3.2c preferencial para projeção) + Mobile (F3.2a/b) |
| **Capability** | `event.manage` (CRUD) · `event.host` (operação ao vivo) |
| **API primária** | `GET/POST /events`, `GET/PATCH /events/{id}`, endpoints presença v4.1 |
| **Frames Figma** | **F3.2a:** [Loaded/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=217-575) · [Empty/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=218-691) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-17478) · [Loaded/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-17600) · [Empty/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-17725) · **F3.2b:** [Editável/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=223-1935) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=253-21624) · [Editável/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=275-20962) · **F3.2c:** [QR_SINGLE/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-7850) · [QR_DUAL entrada/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-8160) · [QR_DUAL saída/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-8473) · [SECRET_SINGLE/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-8786) · [SECRET_DUAL entrada/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-9082) · [SECRET_DUAL saída/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-9381) · [QR_SINGLE/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-9680) · [QR_DUAL entrada/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-9896) · [QR_DUAL saída/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=370-6918) · [SECRET_SINGLE/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=370-7200) · [SECRET_DUAL entrada/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=370-7465) · [SECRET_DUAL saída/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=370-7733) |
| **Specs de tela** | `telasFigma/telas3/F3.2-professor-eventos-lista.md` · `F3.2-professor-eventos-detalhe.md` · `F3.2-professor-eventos-operacao.md` |
| **Ref. canônica** | `foundationDocs/analysis/endpoints_canonicos_presenca_eventos_v4.md` |

---

## Histórias

### HU-A — Gerenciar eventos (CRUD) — F3.2a + F3.2b

> **Como** professor com capability `event.manage`,  
> **Quero** criar, editar e excluir eventos formativos configurando modo de presença, janelas de validação, carga horária e público,  
> **Para** oferecer eventos com controle de presença adequado ao contexto, sem depender da secretaria para configurações.

### HU-B — Operar evento ao vivo — F3.2c

> **Como** professor organizador no dia do evento,  
> **Quero** controlar o painel de operação ao vivo — abrir janelas de validação, exibir QR/PIN aos alunos e acompanhar contagens em tempo real,  
> **Para** conduzir a confirmação de presença de forma segura e verificável.

---

## 2. Regras de Negócio

### CRUD de eventos (F3.2a + F3.2b)

| ID | Regra |
|----|-------|
| **RN-F3.2-01** | A lista `/professor/eventos` exibe **somente os eventos do professor logado** (filtro `onlyMine=true` por padrão). Professor com `event.manage` no escopo do curso pode ver eventos de outros membros do mesmo curso se o filtro for removido. |
| **RN-F3.2-02** | Ao criar um evento, os campos obrigatórios são: título, descrição, curso/público-alvo, `inicioEm`, `fimEm`, `chCreditadas` e `attendanceMode`. |
| **RN-F3.2-03** | O campo `attendanceMode` aceita: `QR_SINGLE`, `QR_DUAL`, `SECRET_SINGLE`, `SECRET_DUAL`. A seleção determina os campos de configuração exibidos no formulário. |
| **RN-F3.2-04** | **Janelas de validação (`windows`):** o professor pode configurar a janela como "dia inteiro" (entrada = `inicioEm`, saída = `fimEm`) ou duas sub-janelas independentes (ex.: 19h00–19h15 para entrada, 21h45–22h00 para saída). Para modos DUAL, janelas de entrada e saída são obrigatórias. |
| **RN-F3.2-05** | Um evento com estado `AGENDADO` pode ser editado livremente. Um evento `EM_ANDAMENTO` pode ter apenas campos operacionais alterados (ex.: ampliar janela). Um evento `CONCLUIDO` é imutável (somente leitura). |
| **RN-F3.2-06** | Excluir um evento só é possível via `_links.excluir` e somente se estado = `AGENDADO`. Eventos em andamento ou concluídos não podem ser excluídos (preservação de auditoria). |
| **RN-F3.2-07** | Ao salvar um evento, o backend valida: `fimEm > inicioEm`, janelas dentro do intervalo do evento, `chCreditadas > 0`. |

### Operação ao vivo (F3.2c)

| ID | Regra |
|----|-------|
| **RN-F3.2-08** | A tela de operação exige capability `event.host`. O professor com `event.manage` também tem `event.host` para seus próprios eventos. |
| **RN-F3.2-09** | **Modos QR (`QR_SINGLE`, `QR_DUAL`):** o backend gera tokens QR por janela (`GET /events/{id}/qr/entry`, `.../qr/exit`). O QR é exibido em `DS/QRDisplay` (280×280px). O token tem vida curta (ex.: 5 min) e é renovado automaticamente via polling. |
| **RN-F3.2-10** | **Modos PIN/SECRET (`SECRET_SINGLE`, `SECRET_DUAL`):** o PIN é definido pelo professor no formulário do evento ou gerado pelo sistema. É exibido em `DS/PINDisplay` (fonte mono 32px). |
| **RN-F3.2-11** | **Abertura de janelas:** para janelas manuais, o professor clica em "Abrir janela entrada" → `POST /events/{id}/attendance/windows/entry`. O sistema valida que o evento está `EM_ANDAMENTO` e a janela não foi aberta anteriormente. |
| **RN-F3.2-12** | O painel exibe em tempo real (polling 5s): número de presenças confirmadas, número de inelegíveis, lista ao vivo dos últimos confirmados. |
| **RN-F3.2-13** | **Encerrar evento:** `POST /events/{id}/close` → estado vai para `CONCLUIDO` → Outbox dispara emissão de certificados/formativas para todos os alunos com presença completa. |
| **RN-F3.2-14** | A tela de operação é otimizada para **projeção** (1280px+ com alto contraste). QR deve ser legível a distância. |

---

## 3. Critérios de Aceitação

### CA-01 — Criar novo evento

```gherkin
Dado que o professor está em /professor/eventos
  E _links.novoEvento existe na resposta
Quando clica em "Novo evento"
Então navega para o formulário de criação
  E ao preencher: título, curso, inicioEm, fimEm, chCreditadas = 4, attendanceMode = SECRET_SINGLE
  E clicar em "Salvar"
Então o sistema realiza POST /events
  E ao receber 201 Created redireciona para /professor/eventos/:id
  E o evento aparece na lista com estado "AGENDADO"
```

### CA-02 — Configuração de janelas de validação (modo DUAL)

```gherkin
Dado que o professor seleciona attendanceMode = SECRET_DUAL no formulário
Quando o formulário atualiza
Então exibe dois blocos de configuração de janela: "Janela de entrada" e "Janela de saída"
  E ambas são obrigatórias antes de salvar
  E ao configurar: entrada 19h00–19h15, saída 21h45–22h00
  E salvar
Então o evento é criado com duas sub-janelas configuradas
```

### CA-03 — Evento concluído é imutável

```gherkin
Dado que o professor acessa /professor/eventos/:id de um evento com estado CONCLUIDO
Quando a página carrega
Então todos os campos do formulário estão disabled
  E um DS/AlertBanner info exibe: "Evento concluído — somente leitura."
  E _links.excluir NÃO existe na resposta
```

### CA-04 — Painel de operação: exibir QR (QR_SINGLE)

```gherkin
Dado que o professor está em /professor/eventos/:id/operacao
  E o evento está EM_ANDAMENTO e attendanceMode = QR_SINGLE
  E _links.abrir-janela-entrada existe
Quando clica em "Abrir janela entrada"
Então o sistema realiza POST /events/:id/attendance/windows/entry
  E o DS/QRDisplay exibe o token QR gerado pelo backend (280×280px)
  E um countdown exibe o tempo restante da janela
  E o QR é renovado automaticamente a cada 5 minutos
```

### CA-05 — Painel de operação: exibir PIN (SECRET_DUAL — fase saída)

```gherkin
Dado que o professor está no painel de operação de um evento SECRET_DUAL
  E a fase de entrada já foi concluída
  E _links.abrir-janela-saida existe
Quando clica em "Abrir janela saída"
Então o sistema ativa a janela de saída
  E o DS/PINDisplay exibe o PIN de saída em fonte mono 32px
  E alunos que não completaram a entrada ficam marcados como "Inelegíveis" na lista ao vivo
```

### CA-06 — Contadores em tempo real

```gherkin
Dado que o professor está no painel de operação com janela ativa
Quando os alunos começam a confirmar presença
Então os contadores atualizam a cada 5s:
  - Presenças completas: N
  - Presenças parciais (duplos): N
  - Inelegíveis: N
  E a lista ao vivo exibe os últimos nomes confirmados no topo
```

### CA-07 — Encerrar evento e disparar certificados

```gherkin
Dado que o professor está no painel de operação
  E _links.encerrar-evento existe
Quando clica em "Encerrar evento" e confirma no modal de confirmação
Então o sistema realiza POST /events/:id/close
  E o estado muda para CONCLUIDO
  E para cada aluno com presença completa: CertificateIssuerUseCase emite certificado automaticamente
  E o professor vê DS/AlertBanner success: "Evento encerrado. Certificados sendo gerados."
```

---

## 4. Componentes de UI (Design System)

| Componente | Tela | Uso |
|------------|------|-----|
| `DS/DataTable` | F3.2a | Lista de eventos |
| `DS/RadioGroup` | F3.2b | Seleção de attendanceMode |
| `DS/DateTimePicker` | F3.2b | inicioEm, fimEm, janelas |
| `WindowBuilder` | F3.2b | Configuração das sub-janelas |
| `DS/QRDisplay` | F3.2c | QR de presença (280×280) |
| `DS/PINDisplay` | F3.2c | PIN em fonte mono 32px |
| `DS/Countdown` | F3.2c | Timer da janela ativa |
| `DS/DataTable` live | F3.2c | Lista de confirmações em tempo real |

---

## 5. Fora de escopo

- Geolocalização / geofence — explicitamente fora do escopo v4.1
- Trust score — explicitamente fora do escopo
- Aula regular / chamada diária — gerida pelo SIGA/UFPR Virtual
- Edição de evento concluído — imutável por auditoria

---

## 6. Definição de Pronto (DoD)

- [ ] Frames Figma aprovados: Lista, Formulário (4 variantes de modo), Operação (4 modo × 2 fase)
- [ ] WindowBuilder implementado (aceita 1 ou 2 sub-janelas)
- [ ] QR com renovação automática a cada 5 min (polling backend)
- [ ] Contadores ao vivo com polling 5s
- [ ] Encerramento → trigger CertificateIssuerUseCase testado em integração
- [ ] Tela de operação validada em 1280px (alta legibilidade para projeção)

---

## 7. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Specs de tela | `telasFigma/telas3/F3.2-professor-eventos-*.md` |
| Fluxo F3.2 | `foundationDocs/analysis/fluxos_por_perfil.md` §4 F3.2 |
| Endpoints canônicos v4.1 | `foundationDocs/analysis/endpoints_canonicos_presenca_eventos_v4.md` |
| Presença aluno | [US-F1-009](../F1/US-F1-009-PRESENCA.md) |
| Página Figma F3 | [Telas / F3 — Professor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=209-339) |
| Frame F3.2a principal | [F3.2a — Eventos / Loaded / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=217-575) |
| Frame F3.2b principal | [F3.2b — Evento detalhe / Editável / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=223-1935) |
| Frame F3.2c principal | [F3.2c — Operação / QR_SINGLE / single / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-7850) |
