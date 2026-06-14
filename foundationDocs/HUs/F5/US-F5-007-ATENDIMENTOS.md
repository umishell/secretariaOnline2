# US-F5-007 — Registro de Atendimento Presencial

| Campo | Valor |
|-------|-------|
| **ID** | US-F5-007 |
| **Épico** | SECR-ATENDIMENTOS |
| **Telas** | F5.13 — Registrar Atendimento |
| **Rota** | `/secretaria/atendimentos` |
| **Prioridade** | P2 |
| **Capability** | `service_record.create` |
| **APIs** | `POST /service-records` · `GET /service-records` |
| **Frames Figma** | [Novo](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2847) |

---

## História de Usuário

> **Como** secretária acadêmica,  
> **quero** registrar atendimentos presenciais no guichê (aluno, assunto, resposta e anexo opcional),  
> **para que** o histórico de atendimentos fique documentado no sistema, o aluno seja notificado e a secretaria possa consultar o histórico posteriormente.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F5-007-01 | Somente usuários com capability `service_record.create` podem registrar atendimentos. |
| RN-F5-007-02 | Campos obrigatórios: Aluno (busca por GRR/nome via Combobox), Assunto (seleção de categoria + campo livre), Resposta (textarea). |
| RN-F5-007-03 | Categorias de assunto são configuráveis pelo admin e carregadas via `GET /service-record-categories`; exibidas como lista dropdown. |
| RN-F5-007-04 | O campo Anexo é opcional; aceita PDF, JPEG e PNG com limite de 10 MB. O arquivo é enviado para o MinIO e a URL é incluída no `service_record`. |
| RN-F5-007-05 | Antes de submeter, a secretária visualiza um **preview de notificação** mostrando o resumo que o aluno receberá por e-mail: assunto, resposta e link para histórico (F1.11). |
| RN-F5-007-06 | Ao confirmar, o sistema cria o `service_record` e envia Outbox `atendimento.registrado` com o resumo para o e-mail do aluno. |
| RN-F5-007-07 | O aluno pode acessar o histórico de atendimentos em US-F1-011 (Atendimentos); o `service_record_id` aparece nessa tela. |
| RN-F5-007-08 | Não é possível editar ou excluir um atendimento após o registro; erros devem ser corrigidos com um novo atendimento complementar. |

---

## Critérios de Aceitação

### CA-F5-007-01 — Buscar aluno e preencher formulário

```gherkin
Dado que a secretária acessa /secretaria/atendimentos
Quando ela digita "20231234" no Combobox
Então o aluno "João Silva - GRR20231234" aparece na lista de sugestões
Quando ela seleciona o aluno e preenche Assunto e Resposta
Então o preview de notificação é atualizado em tempo real com as informações preenchidas
```

### CA-F5-007-02 — Registrar atendimento com anexo

```gherkin
Dado que a secretária preencheu o formulário e adicionou um PDF de 2 MB
Quando ela clica em "Registrar"
Então o arquivo é enviado ao MinIO
E a API recebe POST /service-records com o campo anexoUrl preenchido
E o aluno recebe e-mail com o resumo do atendimento e link para o histórico
```

### CA-F5-007-03 — Registrar atendimento sem anexo

```gherkin
Dado que a secretária preencheu apenas Aluno, Assunto e Resposta
Quando ela clica em "Registrar"
Então a API recebe POST /service-records sem o campo anexoUrl
E o registro é criado com sucesso
E um toast de confirmação "Atendimento registrado" é exibido
```

### CA-F5-007-04 — Arquivo acima do limite

```gherkin
Dado que a secretária tenta anexar um PDF de 15 MB
Quando ela arrasta o arquivo para o DS/FileDropzone
Então o upload é bloqueado no frontend
E uma mensagem de erro "Arquivo excede 10 MB" é exibida
```

### CA-F5-007-05 — Preview de notificação

```gherkin
Dado que a secretária preencheu todos os campos
Quando ela visualiza o preview de notificação
Então o preview mostra o nome do aluno, o assunto selecionado e o texto da resposta
E um aviso indica "Este e-mail será enviado ao aluno ao confirmar"
```

---

## Componentes de UI

- `DS/Combobox` (busca de aluno)
- `DS/Select` (categoria de assunto)
- `DS/Textarea` (resposta)
- `DS/FileDropzone` (anexo opcional)
- Preview de notificação (card estático)
- `DS/Button` ("Registrar", "Cancelar")

---

## Contrato de API

```
GET /service-record-categories

POST /service-records
Body: {
  "alunoId": "...",
  "categoriaId": "...",
  "assunto": "...",
  "resposta": "...",
  "anexoUrl": "..."  // opcional
}

Response 201:
{
  "id": "...",
  "numero": "AT-2025-001",
  "_links": { "self": { "href": "/service-records/:id" } }
}
```

---

## Fora de Escopo

- Listagem do histórico de atendimentos pela secretaria (consultar via fila de solicitações F5.2)
- Edição ou exclusão de atendimentos
- Chat em tempo real com aluno

---

## Definition of Done

- [ ] Combobox de busca de aluno por GRR/nome
- [ ] Upload de anexo para MinIO com validação de tipo e tamanho
- [ ] Preview de notificação atualizado em tempo real
- [ ] Outbox `atendimento.registrado` disparado
- [ ] Aluno visualiza atendimento em US-F1-011
- [ ] Testes: sem anexo, com anexo, arquivo acima do limite

---

## Referências

- Frame principal: [F5.13 Novo](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=541-2847)
- Fluxo F5.6 Registrar atendimento: `foundationDocs/analysis/fluxos_por_perfil.md` §6.6
- Vista do aluno: US-F1-011
