# US-F1-009 — Consultar Eventos e Confirmar Presença

| Campo | Valor |
|-------|-------|
| **ID** | US-F1-009 |
| **Épico** | ALUNO-PRESENCA |
| **Telas** | F1.17 `/eventos` · F1.18 `/eventos/:id/presenca` |
| **Prioridade** | P2 |
| **Plataforma** | Web (preferencial) + Mobile |
| **Capability** | `attendance.view_open`, `attendance.check_in` |
| **API primária** | `GET /events?audience=me`, `GET /events/{id}/attendance/session`, `POST /events/{id}/attendance/confirm` |
| **Frames Figma** | **F1.17:** [Loaded/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=89-4137) · [Modal detalhe/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=90-5489) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=109-12060) · [Empty/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=142-18634) · [Error/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=109-12659) · [Loaded/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=112-14003) · [Empty/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=149-25743) · **F1.18:** [QR_DUAL Entrada/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=101-6301) · [QR_DUAL Saída/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=101-6445) · [QR_SINGLE/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=92-5716) · [SECRET_SINGLE/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=90-5627) · [SECRET_DUAL Entrada/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=101-6015) · [SECRET_DUAL Saída/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=101-6158) · [Inelegível/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=144-13445) · [Sucesso/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=144-15293) · [QR_DUAL Entrada/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=112-29846) · [QR_DUAL Saída/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=112-31492) · [QR_SINGLE/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=112-25286) · [SECRET_SINGLE/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=112-23894) · [SECRET_DUAL Entrada/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=112-26745) · [SECRET_DUAL Saída/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=112-28264) · [Inelegível/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=149-35509) · [Sucesso/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=144-15444) |
| **Specs de tela** | `telasFigma/telas1/F1.17-eventos-lista.md` · `F1.18-eventos-presenca.md` |
| **Ref. canônica** | `foundationDocs/analysis/endpoints_canonicos_presenca_eventos_v4.md` |

---

## 1. História de Usuário

> **Como** aluno autenticado,  
> **Quero** ver os eventos formativos disponíveis para mim e confirmar minha presença quando a janela de validação estiver aberta,  
> **Para** registrar minha participação e acumular horas formativas de forma segura e verificável.

---

## 2. Regras de Negócio

### Lista de eventos (F1.17)

| ID | Regra |
|----|-------|
| **RN-F1.17-01** | A lista exibe eventos com colunas: Título, Período, Estado do evento (DS/Badge: Agendado/Em andamento/Concluído), Organizador, Carga horária, Situação de presença (Pendente/Parcial/Completa). |
| **RN-F1.17-02** | O modal de detalhe exibe `AttendanceWidget` **somente** se `_links.confirmar-presenca` existir na resposta — ou seja, quando uma janela de validação está ativa. Fora da janela, a UI não mostra opção de confirmar. |
| **RN-F1.17-03** | O `AttendanceWidget` renderiza variantes diferentes conforme `attendanceMode` do evento: `SECRET_SINGLE`, `SECRET_DUAL`, `QR_SINGLE`, `QR_DUAL`. |

### Confirmação de presença (F1.18 — modos configuráveis v4.1)

| ID | Regra |
|----|-------|
| **RN-F1.18-01** | **Modo SECRET_SINGLE**: o aluno informa um PIN/senha definido pelo professor. O sistema valida e registra presença única. |
| **RN-F1.18-02** | **Modo SECRET_DUAL**: exige dois PINs em duas fases (entrada e saída). A segunda fase só está disponível após completar a primeira dentro da janela correta. Não completar a primeira fase torna o aluno inelegível para a segunda. |
| **RN-F1.18-03** | **Modo QR_SINGLE**: o aluno valida via token QR (escaneado ou digitado). O sistema verifica o token e registra presença única. |
| **RN-F1.18-04** | **Modo QR_DUAL**: dois QRs em duas fases (entrada e saída), com as mesmas regras de inelegibilidade do SECRET_DUAL. |
| **RN-F1.18-05** | Fora da janela de validação configurada pelo professor: o backend retorna 403 e a tela exibe `DS/EmptyState` com mensagem genérica sem revelar detalhes da política. |
| **RN-F1.18-06** | O `deviceUuid` é enviado em cada confirmação. Quando a política de device binding está ativa no evento, um mesmo dispositivo não pode confirmar presença por dois alunos diferentes (`UNIQUE (id_evento, device_uuid)`). |
| **RN-F1.18-07** | A tela `/eventos/:id/presenca` exibe countdown da janela ativa em fonte mono grande. Quando o countdown chega a zero, a interface bloqueia novas confirmações automaticamente. |
| **RN-F1.18-08** | Ao completar todos os requisitos do modo, a `attendance_session` atinge estado **Presença completa efetivada**. O Outbox emite `presenca.confirmed` → dispara emissão de certificado/formativa (US-F1-006). |
| **RN-F1.18-09** | Usuário não logado que acessa link direto de evento recebe notificação + redirecionamento para login com retorno à mesma URL após autenticação. |

---

## 3. Critérios de Aceitação

### CA-01 — Listar eventos disponíveis para o aluno

```gherkin
Dado que o aluno está em /eventos
Quando a página carrega
Então exibe tabela com: Título, Período, Estado (badge Agendado/Em andamento/Concluído), Organizador, CH, Situação presença
  E eventos com janela ativa exibem badge "Janela aberta" (success) na coluna de presença
```

### CA-02 — Modal de detalhe com AttendanceWidget (janela aberta)

```gherkin
Dado que o aluno clica em um evento com estado "Em andamento"
  E _links.confirmar-presenca existe na resposta
Quando o modal de detalhe abre
Então exibe descrição do evento
  E exibe AttendanceWidget com variante correspondente ao attendanceMode do evento
  E exibe countdown da janela ativa
```

### CA-03 — Modal de detalhe sem widget (janela fechada)

```gherkin
Dado que o aluno clica em um evento fora da janela de validação
  E _links.confirmar-presenca NÃO existe na resposta
Quando o modal de detalhe abre
Então exibe apenas descrição e dados do evento
  E NÃO exibe AttendanceWidget nem botão de confirmação
  E NÃO há indicação de quando a janela abrirá (UI cega)
```

### CA-04 — Confirmação de presença (SECRET_SINGLE)

```gherkin
Dado que o aluno está em /eventos/:id/presenca
  E o modo é SECRET_SINGLE com janela ativa
Quando informa o PIN correto no AttendanceWidget e clica em "Confirmar"
Então o sistema realiza POST /events/:id/attendance/confirm { pin: "...", deviceUuid: "...", fase: "ENTRADA" }
  E ao receber 200 OK exibe DS/AlertBanner success: "Presença registrada com sucesso!"
  E o ícone de presença na lista de eventos muda para "Completa"
```

### CA-05 — Confirmação de presença (SECRET_DUAL — fase entrada)

```gherkin
Dado que o aluno está em /eventos/:id/presenca
  E o modo é SECRET_DUAL e a janela de ENTRADA está ativa
Quando informa o PIN de entrada e confirma
Então o sistema registra a fase de entrada
  E exibe mensagem: "Entrada registrada. Confirme a saída quando solicitado."
  E a situação de presença muda para "Parcial"
```

### CA-06 — Janela expirada (countdown zerado)

```gherkin
Dado que o aluno está em /eventos/:id/presenca com countdown visível
Quando o countdown chega a 00:00
Então o AttendanceWidget é bloqueado automaticamente sem necessidade de reload
  E exibe DS/EmptyState: "A janela de validação encerrou."
  E qualquer tentativa de confirmação retorna 403 do backend
```

### CA-07 — Aluno não logado tentando confirmar presença

```gherkin
Dado que um aluno não autenticado acessa /eventos/:id/presenca
Quando a página tenta carregar
Então o sistema redireciona para /login
  E após login bem-sucedido retorna para /eventos/:id/presenca automaticamente
```

---

## 4. Componentes de UI (Design System)

| Componente | Tela | Uso |
|------------|------|-----|
| `DS/DataTable` | F1.17 | Lista de eventos |
| `DS/Modal` | F1.17 | Detalhe com AttendanceWidget |
| `DS/AttendanceWidget` | F1.17, F1.18 | Confirmação por modo (SECRET/QR × SINGLE/DUAL) |
| `DS/Badge` | F1.17 | Estado do evento e situação de presença |
| `DS/Input` | F1.18 | Campo de PIN (autocomplete=off) |
| `DS/Countdown` | F1.18 | Timer da janela ativa |
| `DS/AlertBanner` | F1.18 | Feedback de sucesso/erro/fora-da-janela |
| `DS/EmptyState` | F1.18 | Janela fechada ou inelegível |

---

## 5. Fora de escopo

- Geolocalização / geofence — explicitamente fora do escopo (v4.1)
- Trust score — explicitamente fora do escopo
- Chamada de aula regular — gerido pelo SIGA/UFPR Virtual
- BLE (Bluetooth Low Energy) — fora do escopo

---

## 6. Definição de Pronto (DoD)

- [ ] Frames Figma: variantes por attendanceMode × fase (8 variantes)
- [ ] AttendanceWidget implementado com 4 variantes (SECRET/QR × SINGLE/DUAL)
- [ ] Countdown sincronizado com servidor (anti-drift)
- [ ] Device binding: UNIQUE (id_evento, device_uuid) validado
- [ ] Fora da janela: 403 sem revelar política ao cliente
- [ ] Redirecionamento pós-login para URL original do evento

---

## 7. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Specs de tela | `telasFigma/telas1/F1.17-eventos-lista.md`, `F1.18-eventos-presenca.md` |
| Fluxo de presença v4.1 | `foundationDocs/analysis/fluxos_por_perfil.md` §2 F1.7 |
| Endpoints canônicos | `foundationDocs/analysis/endpoints_canonicos_presenca_eventos_v4.md` |
| Página Figma F1 | [Telas / F1 — Aluno](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=48-339) |
| Frame F1.17 principal | [F1.17 — Eventos / Loaded / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=89-4137) |
| Frame F1.18 principal | [F1.18 — Presença / QR_SINGLE / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=92-5716) |
