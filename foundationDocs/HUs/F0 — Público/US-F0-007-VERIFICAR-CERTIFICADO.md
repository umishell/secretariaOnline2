# US-F0-007 — Verificar Autenticidade de Certificado Digital

| Campo | Valor |
|-------|-------|
| **ID** | US-F0-007 |
| **Épico** | PUB-VERIFY |
| **Tela** | F0.7 — `/publico/verificar-certificado/:hash` |
| **Prioridade** | P2 |
| **Plataforma** | Web |
| **API primária** | `GET /publico/certificados/{hash}/verificacao` |
| **Frames Figma** | [Certificado Válido](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=30-548) · [Certificado Inválido](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=30-574) |
| **Spec de tela** | `telasFigma/telas0/F0.7-verificar-certificado.md` |
| **Substitui (legado)** | Novo — sem equivalente no legado |
| **Contexto** | Anti-fraude por nascimento (seção 11 da análise arquitetural) |

---

## 1. História de Usuário

> **Como** um terceiro (empregador, banca, institution) que recebeu um certificado de participação ou atividade emitido pelo sistema,  
> **Quero** verificar a autenticidade do certificado informando o hash SHA-256 (impresso no QR Code do PDF),  
> **Para** confirmar que ele foi emitido pelo sistema oficial da UFPR SEPT, que os dados não foram alterados e que a assinatura digital é criptograficamente válida.

---

## 2. Regras de Negócio

### Emissão e estrutura do certificado

| ID | Regra |
|----|-------|
| **RN-F0.7-01** | Certificados são **exclusivamente gerados pelo sistema** após a conclusão de um evento formativo ou aprovação de atividade. Nunca são aceitos como PDFs externos enviados pelo usuário. |
| **RN-F0.7-02** | Cada certificado possui: hash SHA-256 do PDF canônico, assinatura digital **ED25519** do servidor sobre o hash, e um ID de emissão UUID v7. O QR Code incorporado no PDF codifica a URL `/publico/verificar-certificado/{hash}`. |
| **RN-F0.7-03** | A chave pública ED25519 do servidor é publicada em `/.well-known/jwks.json` (formato JWK), permitindo verificação offline por qualquer ferramenta compatível. |

### Verificação criptográfica

| ID | Regra |
|----|-------|
| **RN-F0.7-04** | O endpoint retorna: metadados sanitizados do certificado + hash SHA-256 esperado + assinatura ED25519 (em base64url) + URL para a chave pública JWKS. |
| **RN-F0.7-05** | A validação da assinatura ED25519 é realizada **no browser** (Web Crypto API `verify` com algoritmo `Ed25519`), sem enviar dados ao servidor além da consulta inicial. |
| **RN-F0.7-06** | O frontend busca a chave pública em `/.well-known/jwks.json` e verifica: `sign(hash) = assinatura` usando a chave ED25519 do servidor. |
| **RN-F0.7-07** | O resultado é classificado em: **Válido** (hash e assinatura conferem), **Inválido** (assinatura falha ou hash diverge), **Expirado** (certificado foi emitido mas a atividade foi posteriormente cancelada/revogada pelo sistema). |

### Privacidade e dados exibidos

| ID | Regra |
|----|-------|
| **RN-F0.7-08** | O nome do beneficiário pode ser exibido de forma completa ou parcial conforme configuração do tipo de certificado (alguns podem exigir nome completo para validade acadêmica; outros mascaram por LGPD). |
| **RN-F0.7-09** | Os dados mínimos exibidos para um certificado válido são: nome do evento/atividade, carga horária, data de emissão, e status da assinatura. |

### Segurança

| ID | Regra |
|----|-------|
| **RN-F0.7-10** | O endpoint é protegido por rate limit: **10 requisições por minuto** por IP. |
| **RN-F0.7-11** | O endpoint não expõe dados além dos necessários para verificação — em especial, não expõe o GRR completo nem o e-mail do beneficiário. |

---

## 3. Critérios de Aceitação

### CA-01 — Certificado válido (fluxo principal)

```gherkin
Dado que um verificador acessa /publico/verificar-certificado/<hash_válido>
Quando o backend retorna 200 OK com metadados + assinatura ED25519
  E o browser busca a chave pública em /.well-known/jwks.json
  E a verificação criptográfica da assinatura ED25519 é bem-sucedida
Então exibe DS/VerificationSeal (64px, variante "success", ícone ShieldCheck)
  E exibe DS/Badge grande variante "success": "Certificado válido"
  E exibe card com:
    - Nome do beneficiário (completo ou parcial, conforme configuração)
    - Evento / atividade
    - Carga horária
    - Data de emissão
  E exibe bloco "Assinatura digital":
    - Ícone Shield
    - Texto: "Assinado digitalmente pelo servidor da UFPR SEPT"
    - Link "Ver chave pública" → /.well-known/jwks.json
```

### CA-02 — Certificado inválido (hash não encontrado ou assinatura falha)

```gherkin
Dado que um verificador acessa a URL com hash inexistente no sistema
  OU com hash válido mas a assinatura ED25519 não confere com a chave pública
Quando o browser tenta verificar
Então exibe DS/VerificationSeal variante "danger" (ícone ShieldX ou ShieldAlert)
  E exibe DS/Badge grande variante "danger": "Certificado inválido"
  E exibe mensagem:
    "Este certificado não pôde ser verificado. Ele pode ser falso ou ter sido adulterado."
  E NÃO exibe dados do beneficiário
```

### CA-03 — Certificado revogado / expirado

```gherkin
Dado que o certificado foi emitido mas posteriormente revogado pelo sistema
  (ex.: atividade cancelada administrativamente após emissão)
Quando o verificador acessa a URL do certificado
Então o backend retorna status "REVOGADO" nos metadados
  E exibe DS/Badge variante "warning": "Certificado revogado"
  E exibe mensagem explicativa sobre a revogação
  E AINDA exibe os dados básicos para identificação histórica
```

### CA-04 — Verificação de integridade por upload do PDF (opcional)

```gherkin
Dado que o certificado foi encontrado e validado (CA-01)
Quando o verificador faz upload do PDF recebido na zona drag-and-drop
Então o browser calcula SHA-256 do arquivo localmente
  E compara com o hash do certificado retornado pelo backend
  E se coincidir: exibe DS/AlertBanner success "O arquivo confere com o certificado registrado."
  E se divergir: exibe DS/AlertBanner danger "O arquivo NÃO confere com o certificado original."
```

### CA-05 — Link para chave pública JWKS

```gherkin
Dado que o certificado foi verificado com sucesso
Quando o verificador clica em "Ver chave pública"
Então é aberta a URL /.well-known/jwks.json em nova aba
  E o JSON retornado contém a chave pública ED25519 no formato JWK
```

### CA-06 — Loading e estados intermediários

```gherkin
Dado que o verificador acessa a URL e aguarda resposta
Quando a API e a busca do JWKS estão em processamento
Então exibe DS/Skeleton cobrindo a área do card de resultado
  E o selo de verificação exibe estado "carregando" (spinner ou shimmer)
```

### CA-07 — Rate limit atingido

```gherkin
Dado que o mesmo IP realizou mais de 10 requisições em 1 minuto
Quando o limite é excedido
Então o backend retorna 429
  E a tela exibe DS/AlertBanner warning: "Muitas verificações realizadas. Aguarde antes de tentar novamente."
```

### CA-08 — Acessibilidade

```gherkin
Dado que o verificador usa leitor de tela
Então o status do certificado (válido/inválido/revogado) é anunciado via aria-live="assertive"
  E o selo de verificação possui alt text descritivo
  E todos os elementos interativos são atingíveis via Tab
```

---

## 4. Componentes de UI (Design System)

| Componente | Variante | Uso |
|------------|---------|-----|
| `Shell/PublicLayout` | `state=default` | Shell da tela |
| `DS/VerificationSeal` | `valid` / `invalid` / `revoked` | Selo central de validação (64px) |
| `DS/Badge` | `success` / `danger` / `warning` (tamanho lg) | Status do certificado |
| `DS/Card` | `default` | Metadados do certificado |
| `DS/FileDropzone` | `idle` / `success` / `error` | Upload opcional do PDF |
| `DS/AlertBanner` | `success` / `danger` / `warning` | Resultado da verificação de arquivo |
| `DS/Skeleton` | bloco card | Estado de loading |

> **Nota de implementação:** `DS/VerificationSeal` foi identificado como gap no DS existente durante a fase Figma. Deve ser criado como novo componente com variantes `valid`, `invalid` e `revoked`.

---

## 5. Contrato de API

**Request:**
```http
GET /publico/certificados/{hash}/verificacao
```

**Response (200 OK):**
```json
{
  "id": "01942b3c-...",
  "hashSha256": "a1b2c3d4...<64 chars>",
  "assinaturaEd25519": "base64url...",
  "jwksUrl": "https://api.secretaria.ufpr.br/.well-known/jwks.json",
  "status": "VALIDO",
  "beneficiarioNome": "Ana S****",
  "atividade": "Workshop de Metodologias Ativas — SEPT",
  "cargaHoraria": 4,
  "emitidoEm": "2026-03-20T10:00:00Z"
}
```

**Response (404 — hash não encontrado):**
```json
{
  "type": "https://api.secretaria.ufpr.br/errors/not-found",
  "title": "Certificado não encontrado",
  "status": 404
}
```

**Endpoint JWKS:**
```http
GET /.well-known/jwks.json
```
```json
{
  "keys": [
    {
      "kty": "OKP",
      "crv": "Ed25519",
      "use": "sig",
      "kid": "cert-signing-2026-01",
      "x": "base64url_public_key"
    }
  ]
}
```

---

## 6. Fora de escopo desta história

- Emissão do certificado — coberto em módulos `presenca` (evento) e `formativas` (atividade)
- Download do PDF original pelo verificador externo — privacidade; apenas verificação do hash
- Certificados de formatura ou diploma — fora do escopo deste sistema
- Notificação ao beneficiário quando o certificado é consultado — não previsto

---

## 7. Definição de Pronto (DoD)

- [ ] Frames Figma aprovados: Válido, Inválido, Revogado
- [ ] Endpoint `GET /publico/certificados/{hash}/verificacao` documentado em OpenAPI
- [ ] `/.well-known/jwks.json` publicado com chave pública ED25519 do servidor
- [ ] Verificação de assinatura ED25519 implementada no browser (Web Crypto API)
- [ ] Componente `DS/VerificationSeal` criado no Design System com variantes válido/inválido/revogado
- [ ] Rate limit de 10 req/min por IP implementado no backend
- [ ] Status do certificado anunciado via `aria-live` (acessibilidade)
- [ ] Nenhum dado sensível (GRR, e-mail completo) exposto na resposta da API

---

## 8. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas0/F0.7-verificar-certificado.md` |
| Fluxo de verificação pública | `foundationDocs/analysis/fluxos_por_perfil.md` §1 F0.3 |
| Anti-fraude certificados | `foundationDocs/analysis/analise_arquitetural_secretariaonline2.md` §11 |
| Mapa de rotas | `foundationDocs/analysis/telas.md` §2 F0.7 |
| História relacionada | [US-F0-006](./US-F0-006-VERIFICAR-PROTOCOLO.md) — Verificar protocolo |
| Página Figma F0 | [Telas / F0 — Público](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=18-152) |
| ED25519 (RFC 8037) | https://datatracker.ietf.org/doc/html/rfc8037 |
| JWKS (RFC 7517) | https://datatracker.ietf.org/doc/html/rfc7517 |
