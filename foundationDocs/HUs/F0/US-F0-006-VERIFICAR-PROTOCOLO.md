# US-F0-006 — Verificar Autenticidade de Protocolo PDF

| Campo | Valor |
|-------|-------|
| **ID** | US-F0-006 |
| **Épico** | PUB-VERIFY |
| **Tela** | F0.6 — `/publico/verificar-protocolo/:id` |
| **Prioridade** | P2 |
| **Plataforma** | Web |
| **API primária** | `GET /publico/protocolos/{id}/verificacao` |
| **Frames Figma** | [Resultado OK](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=30-456) · [Upload confere](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=30-489) · [Protocolo não encontrado](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=30-522) |
| **Spec de tela** | `telasFigma/telas0/F0.6-verificar-protocolo.md` |
| **Substitui (legado)** | `web/protocolo.jsp` [T144, T145, T146, T147] |

---

## 1. História de Usuário

> **Como** um terceiro (empregador, instituição, banca avaliadora) que recebeu um protocolo de solicitação em PDF,  
> **Quero** verificar a autenticidade desse protocolo informando seu número ou escaneando o QR Code do documento,  
> **Para** confirmar que o documento foi emitido pelo sistema da UFPR SEPT e que seu conteúdo não foi adulterado.

---

## 2. Regras de Negócio

### Acesso e exibição de dados

| ID | Regra |
|----|-------|
| **RN-F0.6-01** | O endpoint `GET /publico/protocolos/{id}/verificacao` é público e **não requer autenticação**. Retorna apenas metadados sanitizados: número do protocolo, tipo de solicitação, status, datas de criação e conclusão, e hash SHA-256 do PDF gerado pelo sistema. |
| **RN-F0.6-02** | Dados pessoais do solicitante **não são exibidos na íntegra**. O nome pode ser parcialmente mascarado (ex.: `A** S****`) para proteger privacidade (LGPD), respeitando que verificadores externos precisam de dados mínimos para confirmar a autoria. |
| **RN-F0.6-03** | O hash SHA-256 exibido na tela deve ser truncado visualmente (ex.: primeiros 16 chars + `...`) mas disponível completo via tooltip ou área expandível com fonte mono. |

### Verificação de integridade por upload

| ID | Regra |
|----|-------|
| **RN-F0.6-04** | A zona de drag-and-drop aceita **apenas arquivos PDF**. O upload não envia o arquivo ao servidor — o cálculo do SHA-256 é feito **no browser** (via Web Crypto API) para preservar privacidade e reduzir tráfego. |
| **RN-F0.6-05** | Após o cálculo, o hash computado pelo cliente é comparado com o hash `esperado` retornado pelo endpoint. Se coincidirem: exibir `DS/AlertBanner success` + ícone Check. Se divergirem: exibir `DS/AlertBanner danger` + mensagem de alerta de adulteração. |
| **RN-F0.6-06** | O arquivo enviado **não é armazenado** no servidor. A verificação é inteiramente local no browser após receber o hash do backend. |

### Segurança

| ID | Regra |
|----|-------|
| **RN-F0.6-07** | O endpoint é protegido por rate limit: máximo de **10 requisições por minuto** por IP. Tentativas que excedam o limite devem retornar `429 Too Many Requests` e o frontend exibe `DS/AlertBanner warning`. |
| **RN-F0.6-08** | Tentativas de bruteforce para enumerar IDs de protocolo devem gerar alerta no Grafana (threshold configurável). |
| **RN-F0.6-09** | O endpoint não expõe se o protocolo pertence a um usuário específico — apenas confirma a existência e os metadados do documento. |

---

## 3. Critérios de Aceitação

### CA-01 — Protocolo encontrado (resultado OK, sem upload)

```gherkin
Dado que um verificador acessa /publico/verificar-protocolo/PROT-2026-00123
Quando a página carrega e o backend retorna 200 OK
Então exibe DS/Card com:
  - Número do protocolo: PROT-2026-00123
  - Tipo de solicitação (ex.: "Aproveitamento de Disciplina")
  - Status com DS/ProtocolBadge (ex.: "CONCLUÍDA", variante success)
  - Data de criação e data de conclusão
  - Hash SHA-256 truncado em fonte mono (expandível)
  E abaixo do card exibe zona de drag-and-drop com instrução de upload opcional
  E exibe caption explicativa sobre o propósito da verificação anti-fraude
```

### CA-02 — Verificação de integridade por upload (hash confere)

```gherkin
Dado que o protocolo foi carregado com sucesso (CA-01)
Quando o verificador arrasta o PDF original para a zona de upload
  OU clica na zona e seleciona o arquivo via dialog
Então o browser calcula SHA-256 do arquivo localmente (sem enviar ao servidor)
  E compara com o hash retornado pelo backend
  E ao coincidir exibe DS/AlertBanner variante "success":
    "Hash confere. O documento é autêntico e não foi modificado."
  E exibe ícone CheckCircle ao lado da zona de upload
```

### CA-03 — Verificação de integridade por upload (hash não confere)

```gherkin
Dado que o protocolo foi carregado com sucesso
Quando o verificador faz upload de um PDF com conteúdo diferente do original
  OU um PDF adulterado
Então o browser detecta divergência de hash
  E exibe DS/AlertBanner variante "danger":
    "Atenção: o hash deste arquivo NÃO confere com o protocolo registrado. O documento pode ter sido adulterado."
  E NENHUMA informação adicional é enviada ao servidor
```

### CA-04 — Protocolo não encontrado

```gherkin
Dado que um verificador acessa /publico/verificar-protocolo/PROT-INEXISTENTE
Quando o backend retorna 404 Not Found
Então exibe DS/EmptyState com:
  - ícone de documento com ponto de interrogação
  - título: "Protocolo não encontrado"
  - descrição: "O número informado não corresponde a nenhum protocolo registrado."
  E NÃO há zona de upload (nada a verificar)
```

### CA-05 — Loading skeleton

```gherkin
Dado que o verificador acessa a página e a API está em processamento
Quando a resposta ainda não chegou
Então exibe DS/Skeleton cobrindo a área do card de resultado
  E a zona de upload não está visível durante o loading
```

### CA-06 — Rate limit atingido

```gherkin
Dado que o mesmo IP realizou mais de 10 requisições em 1 minuto para este endpoint
Quando o limite é excedido
Então o backend retorna 429 Too Many Requests
  E a tela exibe DS/AlertBanner warning:
    "Muitas verificações realizadas. Aguarde antes de tentar novamente."
```

### CA-07 — Acessibilidade da zona de upload

```gherkin
Dado que o verificador usa apenas teclado ou leitor de tela
Então a zona de drag-and-drop possui botão alternativo "Selecionar arquivo" ativável via Tab
  E o resultado da verificação (confere / não confere) é anunciado via aria-live="assertive"
```

---

## 4. Componentes de UI (Design System)

| Componente | Variante | Uso |
|------------|---------|-----|
| `Shell/PublicLayout` | `state=default` | Shell da tela |
| `DS/Card` | `default` | Metadados do protocolo |
| `DS/ProtocolBadge` | por status | Badge de status |
| `DS/FileDropzone` | `idle` / `success` / `error` | Zona de upload do PDF |
| `DS/AlertBanner` | `success` / `danger` / `warning` | Resultados de verificação |
| `DS/EmptyState` | ícone documento | Protocolo não encontrado |
| `DS/Skeleton` | bloco card | Estado de loading |

---

## 5. Contrato de API

**Request:**
```http
GET /publico/protocolos/{id}/verificacao
```

**Response (200 OK):**
```json
{
  "numero": "PROT-2026-00123",
  "tipo": "Aproveitamento de Disciplina",
  "status": "CONCLUIDA",
  "criadoEm": "2026-01-15T10:30:00Z",
  "concluidoEm": "2026-02-10T14:00:00Z",
  "hashSha256": "a1b2c3d4e5f6...<64 chars>",
  "solicitanteNomeParcial": "A** S****"
}
```

**Response (404):**
```json
{
  "type": "https://api.secretaria.ufpr.br/errors/not-found",
  "title": "Protocolo não encontrado",
  "status": 404,
  "detail": "Nenhum protocolo registrado com este identificador."
}
```

---

## 6. Fora de escopo desta história

- Upload do PDF para o servidor — a verificação é puramente local no browser
- Exibição completa do nome/GRR do solicitante — restrição LGPD
- Verificação de protocolo via app mobile — apenas web nesta versão
- Histórico de verificações — sem persistência de consultas públicas

---

## 7. Definição de Pronto (DoD)

- [ ] Frames Figma aprovados: Resultado OK, Upload confere, Upload não confere, Não encontrado
- [ ] Endpoint `GET /publico/protocolos/{id}/verificacao` documentado em OpenAPI
- [ ] Cálculo de SHA-256 no browser (Web Crypto API) implementado e testado
- [ ] Nenhum dado do arquivo é enviado ao servidor durante a verificação
- [ ] Rate limit de 10 req/min por IP implementado no backend
- [ ] Dados pessoais mascarados (LGPD) na resposta da API
- [ ] Acessibilidade: dropzone com botão alternativo, aria-live no resultado

---

## 8. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas0/F0.6-verificar-protocolo.md` |
| Fluxo de verificação pública | `foundationDocs/analysis/fluxos_por_perfil.md` §1 F0.3 |
| Mapa de rotas | `foundationDocs/analysis/telas.md` §2 F0.6 |
| História relacionada | [US-F0-007](./US-F0-007-VERIFICAR-CERTIFICADO.md) — Verificar certificado |
| Página Figma F0 | [Telas / F0 — Público](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=18-152) |
