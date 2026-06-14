# US-F5-008 — Gestão de Eventos Institucionais

| Campo | Valor |
|-------|-------|
| **ID** | US-F5-008 |
| **Épico** | SECR-EVENTOS |
| **Telas** | F5.14 (Lista de Eventos), F5.15 (Operação ao Vivo) |
| **Rotas** | `/secretaria/eventos` · `/secretaria/eventos/:id/operacao` |
| **Prioridade** | P2 |
| **Capabilities** | `event.manage` · `event.host` |
| **APIs** | `GET/POST /events` · `PATCH /events/:id` · `POST /events/:id/open-window` · `POST /events/:id/close` |
| **Frames Figma** | [Lista](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2960) · [Operação QR_SINGLE](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-3073) |

---

## História de Usuário

> **Como** secretária acadêmica,  
> **quero** criar e gerenciar eventos formativos institucionais e operar o painel ao vivo (QR code ou PIN) no dia do evento,  
> **para que** as presenças dos alunos sejam registradas de forma controlada e os certificados sejam emitidos automaticamente ao encerramento.

---

## Regras de Negócio

### Lista de Eventos (F5.14)

| ID | Regra |
|----|-------|
| RN-F5-008-01 | Somente usuários com `event.manage` podem criar, editar e excluir eventos. |
| RN-F5-008-02 | A lista exibe eventos dos cursos vinculados à secretária. Filtros: `onlyMine`, curso, estado (`AGENDADO`, `EM_ANDAMENTO`, `CONCLUÍDO`). |
| RN-F5-008-03 | Colunas da tabela: Título, Período (data/hora início–fim), Modo (`QR_SINGLE`, `QR_DUAL`, `SECRET_SINGLE`, `SECRET_DUAL`), Estado, Organizador. |
| RN-F5-008-04 | A secretaria reutiliza os mesmos componentes de criação/edição de F3.2a (Professor). A diferença é que o escopo engloba todos os cursos vinculados, não apenas os do professor. |
| RN-F5-008-05 | Eventos no estado `CONCLUÍDO` são somente leitura; as ações de editar e excluir ficam ocultas (sem `_links`). |
| RN-F5-008-06 | Excluir um evento só é permitido se ele estiver em `AGENDADO` e não tiver registros de presença. |

### Operação ao Vivo (F5.15)

| ID | Regra |
|----|-------|
| RN-F5-008-07 | Somente usuários com `event.host` podem acessar o painel de operação ao vivo. |
| RN-F5-008-08 | O painel de operação é idêntico ao de F3.2c (Professor) — reusa o mesmo frame Figma com anotação de contexto. |
| RN-F5-008-09 | Os 4 modos configuráveis (`QR_SINGLE`, `QR_DUAL`, `SECRET_SINGLE`, `SECRET_DUAL`) funcionam conforme definido na v4.1: janelas de validação configuráveis, device binding opcional. |
| RN-F5-008-10 | Ao encerrar o evento (`POST /events/:id/close`), o backend processa automaticamente: (a) contabiliza presenças, (b) gera `formative_entry` para os alunos presentes, (c) cria `certificado` para quem atingiu o limiar de presença. |
| RN-F5-008-11 | A emissão do certificado é atômica e auditada: hash SHA-256 do PDF + assinatura ED25519 registrados. |
| RN-F5-008-12 | O scheduler encerra automaticamente eventos passados das 23:59 caso o operador não os feche manualmente. |

---

## Critérios de Aceitação

### CA-F5-008-01 — Listar e filtrar eventos

```gherkin
Dado que a secretária acessa /secretaria/eventos
Quando a página carrega
Então a tabela exibe os eventos dos cursos vinculados com Título, Período, Modo, Estado e Organizador
E os filtros de estado e curso estão disponíveis
E eventos CONCLUÍDOS não têm botões de Editar ou Excluir
```

### CA-F5-008-02 — Criar novo evento

```gherkin
Dado que a secretária clica em "Novo evento"
Quando ela preenche Título, Datas, Modo QR_SINGLE, Cursos vinculados
E define uma janela de validação de 09:00 às 10:00
E salva
Então a API recebe POST /events
E o evento aparece na lista com estado AGENDADO
```

### CA-F5-008-03 — Abrir painel de operação (QR_SINGLE)

```gherkin
Dado que existe um evento com modo QR_SINGLE no estado EM_ANDAMENTO
Quando a secretária acessa /secretaria/eventos/:id/operacao
Então o painel exibe o QR Code da sessão em tela cheia
E um contador de presenças confirmadas é atualizado em tempo real via polling
E o botão "Encerrar evento" está disponível
```

### CA-F5-008-04 — Encerrar evento e gerar certificados

```gherkin
Dado que o evento foi operado com 30 alunos confirmados
Quando a secretária clica em "Encerrar evento"
Então a API recebe POST /events/:id/close
E o backend gera formative_entry para os 30 alunos
E certificados são emitidos com hash SHA-256 e assinatura ED25519
E o evento passa para estado CONCLUÍDO
```

### CA-F5-008-05 — Excluir evento com presença já registrada

```gherkin
Dado que um evento em AGENDADO já tem 1 registro de presença (inconsistência)
Quando a secretária tenta excluí-lo
Então a API retorna HTTP 422 "Evento possui registros de presença"
E a linha permanece na tabela
```

---

## Componentes de UI

- `DS/DataTable` (lista de eventos)
- `DS/Button` ("Novo evento", "Encerrar")
- `DS/Badge` (estado do evento)
- `DS/QRDisplay` (operação ao vivo — QR_SINGLE/QR_DUAL)
- `DS/PINDisplay` (operação ao vivo — SECRET_SINGLE/SECRET_DUAL)
- `DS/WindowBuilder` (janelas de validação)
- `DS/Countdown` (contador de tempo da janela ativa)
- `DS/EmptyState`, `DS/Skeleton`

---

## Contrato de API

```
# Lista
GET /events?cursoId=...&estado=AGENDADO&page=0

# Criar
POST /events
Body: { "titulo", "inicio", "fim", "modo", "cursoIds", "janelas": [...] }

# Abrir janela
POST /events/:id/open-window
Body: { "fase": "ENTRADA|SAIDA" }

# Encerrar
POST /events/:id/close

# HATEOAS response inclui:
{
  "_links": {
    "edit": ..., "delete": ..., "host": ..., "close": ...
  }
}
```

---

## Diferença em relação ao Professor (F3.2)

| Aspecto | Professor (F3.2) | Secretaria (F5.14/15) |
|---------|-----------------|----------------------|
| Escopo de cursos | Apenas cursos onde leciona | Todos os cursos vinculados |
| Rota lista | `/professor/eventos` | `/secretaria/eventos` |
| Frame Figma | `F3.2b` (lista) + `F3.2c` (operação) | `F5.14` + `F5.15` (instância de F3.2c) |
| Criação para outros | Não (apenas eventos próprios) | Sim (eventos institucionais) |

---

## Fora de Escopo

- Geofence e BLE (não previstos em v4.1)
- Assiduidade de aulas regulares (competência do SIGA)
- Configuração de QR dinâmico rotativo (ver ADR futura)

---

## Definition of Done

- [ ] CRUD de eventos com filtros e HATEOAS
- [ ] Painel de operação ao vivo (QR/PIN) reutilizando frame F3.2c
- [ ] Encerramento com geração de formative_entry e certificados
- [ ] Certificados com hash SHA-256 e assinatura ED25519
- [ ] Scheduler encerra eventos abertos automaticamente
- [ ] Testes: encerramento com presença, excluir evento com presença

---

## Referências

- Frame Lista: [F5.14](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2960)
- Frame Operação: [F5.15 QR_SINGLE](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-3073)
- Fluxo F5.8 Organização de evento: `foundationDocs/analysis/fluxos_por_perfil.md` §6.8
- Endpoints canônicos presença v4.1: `foundationDocs/analysis/endpoints_canonicos_presenca_eventos_v4.md`
- Análogo professor: US-F3-002
