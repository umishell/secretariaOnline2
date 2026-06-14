# US-F5-010 — Exportações Assíncronas

| Campo | Valor |
|-------|-------|
| **ID** | US-F5-010 |
| **Épico** | SECR-EXPORTACOES |
| **Telas** | F5.17 — Exportações |
| **Rota** | `/secretaria/exportacoes` |
| **Prioridade** | P2 |
| **Capability** | `export.run` |
| **APIs** | `POST /exports/:kind` · `GET /exports` · `GET /exports/:jobId/download` |
| **Frames Figma** | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=542-3693) |

---

## História de Usuário

> **Como** secretária acadêmica,  
> **quero** solicitar exportações de dados em diferentes formatos (alunos, solicitações, presenças, certificados) e baixar os arquivos gerados de forma assíncrona,  
> **para que** eu possa obter relatórios volumosos sem travar o navegador enquanto eles são processados.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F5-010-01 | Somente usuários com capability `export.run` acessam esta tela. |
| RN-F5-010-02 | Tipos de exportação disponíveis (`kind`): `alunos`, `solicitacoes`, `presencas`, `certificados`, `egressos`, `formativas`. Cada tipo é representado por um card na grade. |
| RN-F5-010-03 | Ao clicar em um card, a secretária pode informar filtros opcionais (período letivo, curso) e confirmar a solicitação de exportação. |
| RN-F5-010-04 | O backend cria um `export_job` assíncrono e retorna `202 Accepted` com o `jobId`. O frontend não bloqueia a UI durante o processamento. |
| RN-F5-010-05 | O histórico de downloads exibe os jobs do usuário com status: `PROCESSANDO` (ícone de loading), `PRONTO` (botão de download), `EXPIRADO` (cinza, sem ação). |
| RN-F5-010-06 | O link de download expira em **7 dias**; após esse prazo, o status é `EXPIRADO` e o arquivo é removido do MinIO. |
| RN-F5-010-07 | A atualização do status é feita via polling (`GET /exports?status=PROCESSANDO`) a cada 10 s enquanto há jobs em processamento. O status usa `aria-live="polite"` para acessibilidade. |
| RN-F5-010-08 | Outbox emite `exports.ready` com link para download quando o job muda para `PRONTO`; o e-mail é enviado para a secretária. |
| RN-F5-010-09 | Um export_job expirado permanece visível no histórico por 30 dias para fins de auditoria, mas sem possibilidade de download. |

---

## Critérios de Aceitação

### CA-F5-010-01 — Solicitar exportação

```gherkin
Dado que a secretária acessa /secretaria/exportacoes
Quando ela clica no card "Alunos"
E seleciona o filtro "Curso: TADS" e "Período: 2025/2"
E confirma
Então a API recebe POST /exports/alunos com os filtros
E um job aparece no histórico com status PROCESSANDO
E um toast confirma "Exportação solicitada"
```

### CA-F5-010-02 — Polling e download

```gherkin
Dado que o export_job muda para status PRONTO
Quando o polling detecta a mudança
Então o card no histórico exibe o botão "Baixar"
E ao clicar, o arquivo CSV é baixado via URL pré-assinada do MinIO
E a secretária recebe e-mail de notificação com o link de download
```

### CA-F5-010-03 — Link expirado

```gherkin
Dado que um export_job tem mais de 7 dias
Quando a secretária acessa o histórico
Então o status desse job aparece como EXPIRADO
E o botão de download não está disponível
E o job ainda aparece por 30 dias para fins de auditoria
```

### CA-F5-010-04 — Acessibilidade do status assíncrono

```gherkin
Dado que um job muda de PROCESSANDO para PRONTO
Quando o polling atualiza a UI
Então a região de status tem aria-live="polite"
E o leitor de tela anuncia "Exportação de Alunos pronta para download"
```

---

## Componentes de UI

- `DS/Card` (grid de tipos de exportação — 3 colunas)
- `DS/Badge` (status: PROCESSANDO / PRONTO / EXPIRADO)
- `DS/Button` ("Baixar")
- Histórico de downloads (lista com status e datas)
- Dialog de filtros (por card)
- `aria-live` region para status assíncrono

---

## Contrato de API

```
# Solicitar exportação
POST /exports/:kind
Body: { "filtros": { "cursoId": "...", "periodoId": "..." } }
Response 202: { "jobId": "...", "status": "PROCESSANDO" }

# Listar jobs do usuário
GET /exports?status=PROCESSANDO|PRONTO|EXPIRADO&page=0

# Download
GET /exports/:jobId/download
Response: redirect para URL pré-assinada MinIO (válida 15 min)
```

---

## Fora de Escopo

- Exportação em formato XLSX (apenas CSV por ora)
- Agendamento automático de exportações recorrentes
- Exportações de logs de auditoria (restrito ao Admin)

---

## Definition of Done

- [ ] Grid de cards por kind com filtros opcionais
- [ ] Job assíncrono com polling a cada 10 s
- [ ] Status EXPIRADO após 7 dias, arquivo removido do MinIO
- [ ] Outbox `exports.ready` disparado
- [ ] `aria-live` para atualizações de status
- [ ] Testes: download, link expirado, polling parece após conclusão

---

## Referências

- Frame principal: [F5.17 Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=542-3693)
- Fluxo F5.9 Exportações: `foundationDocs/analysis/fluxos_por_perfil.md` §6.9
