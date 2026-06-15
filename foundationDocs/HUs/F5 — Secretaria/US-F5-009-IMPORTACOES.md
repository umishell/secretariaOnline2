# US-F5-009 — Importações em Lote

| Campo | Valor |
|-------|-------|
| **ID** | US-F5-009 |
| **Épico** | SECR-IMPORTACOES |
| **Telas** | F5.16 — Importações |
| **Rota** | `/secretaria/importacoes` |
| **Prioridade** | P2 |
| **Capability** | `import.run` |
| **APIs** | `GET /imports/templates/:kind` · `POST /imports/:kind` · `GET /imports/:jobId` · `POST /imports/:jobId/confirm` |
| **Frames Figma** | [Passo 1](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-3182) |

---

## História de Usuário

> **Como** secretária acadêmica,  
> **quero** importar dados em lote (alunos, disciplinas, usuários, alocação de professores) via planilha CSV/XLSX com preview de validação antes de confirmar,  
> **para que** eu possa atualizar o cadastro massivamente no início do semestre sem erros silenciosos.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F5-009-01 | Somente usuários com capability `import.run` acessam esta tela. |
| RN-F5-009-02 | Tipos de importação disponíveis (`kind`): `alunos`, `disciplinas`, `usuarios`, `alocacao_professor`. |
| RN-F5-009-03 | O wizard possui **4 passos**: (1) Escolher `kind` e baixar modelo; (2) Upload do arquivo; (3) Preview de validação linha a linha; (4) Confirmar ou cancelar. |
| RN-F5-009-04 | O arquivo aceito deve ser CSV (UTF-8) ou XLSX; tamanho máximo 20 MB; máximo 10.000 linhas por importação. |
| RN-F5-009-05 | Após o upload, o backend cria um `import_job` + `import_row` para cada linha e executa validação assíncrona. O frontend faz polling em `GET /imports/:jobId` até `status = VALIDATED`. |
| RN-F5-009-06 | O preview exibe linhas válidas (verde), linhas com aviso (amarelo) e linhas inválidas (vermelho com mensagem de erro na coluna). |
| RN-F5-009-07 | A confirmação só é habilitada se `errorCount = 0`. Linhas com avisos podem ser confirmadas com ciência da secretária. |
| RN-F5-009-08 | Ao confirmar, o backend processa em **transação por lote de 1.000 linhas**. Se um lote falhar, os anteriores já processados permanecem; um relatório de resultado parcial é exibido. |
| RN-F5-009-09 | O `import_job` registra: `kind`, operador, `timestamp`, checksum SHA-256 do arquivo, total de linhas, erros, status final (`SUCCESS`, `PARTIAL`, `FAILED`). Esse registro é auditável. |
| RN-F5-009-10 | Outbox emite `imports.completed` com o sumário (totais e link para o relatório) para o e-mail da secretária. |
| RN-F5-009-11 | O modelo CSV/XLSX é gerado dinamicamente pelo backend com colunas, tipos e exemplos na linha 1 como cabeçalho. |

---

## Critérios de Aceitação

### CA-F5-009-01 — Baixar modelo

```gherkin
Dado que a secretária acessa /secretaria/importacoes
Quando ela seleciona o kind "alunos"
E clica em "Baixar modelo"
Então o sistema baixa o arquivo alunos_modelo.csv com as colunas e linha de exemplo
```

### CA-F5-009-02 — Upload e validação

```gherkin
Dado que a secretária fez upload de alunos.csv com 500 linhas (480 válidas, 20 inválidas)
Quando o backend conclui a validação (status VALIDATED)
Então o preview exibe 480 linhas verdes e 20 linhas vermelhas com mensagens de erro por coluna
E o botão "Confirmar importação" está desabilitado
E uma mensagem "Corrija os 20 erros antes de confirmar" é exibida
```

### CA-F5-009-03 — Confirmar importação sem erros

```gherkin
Dado que a secretária corrigiu o arquivo e fez novo upload com 500 linhas todas válidas
Quando ela clica em "Confirmar importação"
Então o backend processa em lotes de 1.000 linhas (1 lote neste caso)
E um relatório é exibido: "500 alunos importados com sucesso"
E o Outbox envia e-mail de sumário para a secretária
```

### CA-F5-009-04 — Processamento parcial

```gherkin
Dado que uma importação de 2.500 linhas processa o primeiro lote (1.000) com sucesso
E o segundo lote falha por erro de banco de dados
Então o relatório exibe "1.000 importados, 1.500 não processados"
E o status do import_job é PARTIAL
E o e-mail de sumário descreve o erro do segundo lote
```

### CA-F5-009-05 — Arquivo acima do limite

```gherkin
Dado que a secretária tenta fazer upload de um arquivo de 25 MB
Quando arrasta o arquivo para o DS/FileDropzone
Então o upload é bloqueado no frontend com mensagem "Arquivo excede 20 MB"
```

### CA-F5-009-06 — Auditabilidade

```gherkin
Dado que a importação foi concluída com sucesso
Quando o administrador consulta o audit_log
Então existe uma entrada com: operadorId, kind, timestamp, checksum, total_linhas, status SUCCESS
```

---

## Componentes de UI

- `DS/WizardStepper` (4 passos)
- `DS/FileDropzone` (upload)
- `DS/DataTable` (preview de validação com highlight de erros)
- `DS/Badge` (status das linhas: válida/aviso/inválida)
- `DS/Button` ("Baixar modelo", "Confirmar", "Cancelar")
- `DS/Skeleton` (polling de validação)
- `DS/AlertBanner` (erros de processamento)

---

## Contrato de API

```
# Baixar modelo
GET /imports/templates/:kind → arquivo CSV/XLSX

# Upload
POST /imports/:kind   (multipart/form-data, campo "file")
Response 202: { "jobId": "...", "status": "PROCESSING" }

# Polling de validação
GET /imports/:jobId
Response: { "status": "VALIDATED|PROCESSING|FAILED", "rows": [...], "errorCount": N }

# Confirmar
POST /imports/:jobId/confirm
Response: { "status": "SUCCESS|PARTIAL|FAILED", "importados": N, "falhas": N }
```

---

## Fora de Escopo

- Importação via API externa (integração SIGA)
- Importação de turmas/horários
- Reversão (rollback) de importação confirmada

---

## Definition of Done

- [ ] Wizard 4 passos: kind → upload → preview → confirmar
- [ ] Preview com highlight de erros por linha e coluna
- [ ] Confirmação bloqueada quando `errorCount > 0`
- [ ] Processamento em lotes de 1.000 com relatório parcial
- [ ] `import_job` auditável com checksum SHA-256
- [ ] Outbox `imports.completed` disparado
- [ ] Testes: arquivo inválido, processamento parcial, limite de tamanho

---

## Referências

- Frame principal: [F5.16 Passo 1](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-3182)
- Fluxo F5.5 Importação em lote: `foundationDocs/analysis/fluxos_por_perfil.md` §6.5
