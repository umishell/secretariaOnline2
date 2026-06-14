# US-F1-010 — Visualizar e Baixar Certificados Emitidos

| Campo | Valor |
|-------|-------|
| **ID** | US-F1-010 |
| **Épico** | ALUNO-CERTIFICADOS |
| **Tela** | F1.19 — `/certificados` |
| **Prioridade** | P2 |
| **Plataforma** | Web + Mobile |
| **Capability** | `certificate.view_own` |
| **API primária** | `GET /certificates?beneficiario=me` |
| **Frames Figma** | [Telas / F1 — Aluno](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=48-339) |
| **Spec de tela** | `telasFigma/telas1/F1.19-certificados.md` |

---

## 1. História de Usuário

> **Como** aluno autenticado,  
> **Quero** visualizar todos os meus certificados emitidos e baixar o PDF assinado digitalmente,  
> **Para** ter acesso aos documentos que comprovam minhas atividades e participações, com garantia de autenticidade verificável por terceiros.

---

## 2. Regras de Negócio

| ID | Regra |
|----|-------|
| **RN-F1.19-01** | Certificados são **emitidos automaticamente** pelo sistema quando: (a) formativa aprovada pela CAAF, ou (b) evento encerrado com presença completa validada. O aluno nunca solicita manualmente. |
| **RN-F1.19-02** | A lista exibe: Tipo de certificado, Evento/Atividade, Data de emissão e botão Download. |
| **RN-F1.19-03** | O download do PDF usa URL pré-assinada do MinIO com expiração de 15 minutos. |
| **RN-F1.19-04** | Cada certificado possui QR Code embutido apontando para `/publico/verificar-certificado/:hash` (US-F0-007). |
| **RN-F1.19-05** | O certificado é imutável: o hash SHA-256 e a assinatura ED25519 permanecem válidos para sempre após a emissão. |

---

## 3. Critérios de Aceitação

### CA-01 — Listar certificados

```gherkin
Dado que o aluno está em /certificados
Quando a página carrega
Então exibe tabela com: Tipo, Evento/Atividade, Data de emissão, botão Download
  E filtrável por tipo e ano
  E se não há certificados: DS/EmptyState "Você ainda não possui certificados emitidos."
```

### CA-02 — Download do PDF

```gherkin
Dado que o aluno clica em "Download" para um certificado
  E _links.download existe na resposta
Quando o sistema gera a URL pré-assinada do MinIO
Então o download do PDF inicia automaticamente
  E o PDF contém o QR Code de verificação
  E se a URL pré-assinada expirar (> 15 min): novo clique gera nova URL
```

### CA-03 — Badge no dashboard ao receber novo certificado

```gherkin
Dado que a CAAF aprovou uma formativa do aluno
Quando o CertificateIssuerUseCase emite o certificado (processo background)
Então o KpiCard de certificados no dashboard (US-F1-001) incrementa em 1
  E o aluno recebe notificação in-app + push: "Seu certificado de [atividade] foi emitido."
  E o certificado aparece no topo da lista em /certificados
```

---

## 4. Fora de escopo

- Solicitação de reemissão de certificado com dados corrigidos — processo manual via secretaria
- Certificados de egresso — coberto em F2.1

---

## 5. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas1/F1.19-certificados.md` |
| Fluxo de emissão | `foundationDocs/analysis/fluxos_por_perfil.md` §2 F1.6 |
| Verificação pública | [US-F0-007](../F0/US-F0-007-VERIFICAR-CERTIFICADO.md) |
| Página Figma F1 | [Telas / F1 — Aluno](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=48-339) |
