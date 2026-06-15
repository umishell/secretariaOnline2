# US-F3-006 — Avaliar TCC (Orientador / Banca)

| Campo | Valor |
|-------|-------|
| **ID** | US-F3-006 |
| **Épico** | PROF-TCC |
| **Tela** | F3.7 — `/tccs?to=me` |
| **Prioridade** | P2 |
| **Plataforma** | Web + Mobile |
| **Capability** | `tcc.supervise` |
| **API primária** | `GET /tccs?canReview=true`, `POST /tccs/{id}/review` |
| **Frames Figma** | [Loaded/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=220-1558) · [Empty/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19570) · [Skeleton/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19682) · [Loaded/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19808) · [Empty/Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19933) |
| **Spec de tela** | `telasFigma/telas3/F3.7-tccs-revisao.md` |

---

## 1. História de Usuário

> **Como** professor orientador ou membro de banca de TCC,  
> **Quero** visualizar os TCCs sob minha responsabilidade, baixar o arquivo enviado, registrar nota e parecer,  
> **Para** formalizar a avaliação e, quando aprovado, desencadear a emissão do certificado de conclusão do aluno.

---

## 2. Regras de Negócio

| ID | Regra |
|----|-------|
| **RN-F3.7-01** | A lista mostra TCCs onde o professor é orientador, co-orientador ou membro de banca, com `canReview=true`. |
| **RN-F3.7-02** | Colunas: Aluno, Título, Papel (Orientador / Banca), Situação. |
| **RN-F3.7-03** | O professor pode baixar o arquivo final via URL pré-assinada do MinIO. |
| **RN-F3.7-04** | Ao registrar avaliação, informa: nota (0–10, uma casa decimal) e parecer textual. A situação resultante (APROVADO/REPROVADO/COM_CORRECOES) depende da nota mínima configurada no sistema. |
| **RN-F3.7-05** | Se aprovado e elegível, o backend dispara `CertificateIssuerUseCase` para emitir o certificado de conclusão. |
| **RN-F3.7-06** | Cada avaliação é registrada em `tcc_evaluation` com `actor_id`, nota, parecer e timestamp. |

---

## 3. Critérios de Aceitação

### CA-01 — Listar TCCs para avaliação

```gherkin
Dado que o professor acessa /tccs?to=me
Quando a página carrega
Então exibe tabela com: Aluno, Título, Papel, Situação (DS/Badge)
  E se nenhum TCC pendente: DS/EmptyState "Nenhum TCC aguardando sua avaliação."
```

### CA-02 — Registrar avaliação

```gherkin
Dado que o professor acessa /tccs/:id
  E o aluno enviou o arquivo final e _links.avaliar existe
Quando preenche nota = 8.5, parecer e clica em "Registrar avaliação"
Então o sistema realiza POST /tccs/:id/review { nota: 8.5, parecer: "...", situacao: "APROVADO" }
  E o estado do TCC muda conforme a nota
  E se aprovado: CertificateIssuerUseCase é disparado
  E o aluno recebe notificação com o resultado
```

### CA-03 — Download do arquivo para avaliação

```gherkin
Dado que o aluno fez upload do TCC
Quando o professor clica em "Baixar TCC"
Então o sistema gera URL pré-assinada do MinIO (válida 15 min)
  E o download inicia automaticamente
```

---

## 4. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas3/F3.7-tccs-revisao.md` |
| Fluxo F3.7 | `foundationDocs/analysis/fluxos_por_perfil.md` §4 F3.7 |
| TCC aluno | [US-F1-008](../F1/US-F1-008-TCC.md) |
| Página Figma F3 | [Telas / F3 — Professor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=209-339) |
| Frame principal | [F3.7 — TCCs revisão / Loaded / Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=220-1558) |
