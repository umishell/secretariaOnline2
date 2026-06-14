# US-F1-008 — Acompanhar TCC e Enviar Versão Final

| Campo | Valor |
|-------|-------|
| **ID** | US-F1-008 |
| **Épico** | ALUNO-TCC |
| **Telas** | F1.15 `/tccs` · F1.16 `/tccs/:id` |
| **Prioridade** | P2 |
| **Plataforma** | Web + Mobile |
| **Capability** | `tcc.view_own` |
| **API primária** | `GET /tccs?aluno=me`, `GET /tccs/{id}`, `POST /tccs/{id}/upload` |
| **Frames Figma** | [Telas / F1 — Aluno](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=48-339) |
| **Specs de tela** | `telasFigma/telas1/F1.15-tccs-lista.md` · `F1.16-tccs-detalhe.md` |

---

## 1. História de Usuário

> **Como** aluno em fase de conclusão de curso,  
> **Quero** acompanhar o status do meu TCC, ver a composição da banca e as datas-chave, e fazer o upload da versão final,  
> **Para** formalizar minha entrega e acompanhar o resultado da avaliação.

---

## 2. Regras de Negócio

| ID | Regra |
|----|-------|
| **RN-F1.15-01** | A lista exibe TCC com colunas: Título, Orientador, Situação (DS/Badge), Data prevista de defesa. |
| **RN-F1.15-02** | Um aluno pode ter no máximo 1 TCC ativo por vez. A lista pode ter TCCs de períodos anteriores com estado `CONCLUIDO`. |
| **RN-F1.16-01** | O detalhe exibe: equipe (aluno + orientador + co-orientador), banca (membros), datas-chave (entrega, defesa) e arquivo atual. |
| **RN-F1.16-02** | O upload do arquivo final é habilitado via `_links.upload-final` HATEOAS, disponível apenas quando o estado permite. |
| **RN-F1.16-03** | Após o upload, o Outbox emite `tcc.submitted` → notifica a banca para avaliação. |
| **RN-F1.16-04** | O resultado da avaliação (aprovado, reprovado, com correções) é exibido como evento na timeline da tela de detalhe. |

---

## 3. Critérios de Aceitação

### CA-01 — Listar TCCs

```gherkin
Dado que o aluno está em /tccs
Quando a página carrega
Então exibe tabela com: Título, Orientador, Situação (DS/Badge), Data defesa
  E se não há TCC cadastrado: DS/EmptyState "Nenhum TCC registrado. Consulte a secretaria."
```

### CA-02 — Fazer upload da versão final

```gherkin
Dado que o aluno está em /tccs/:id
  E _links.upload-final existe na resposta (estado permite upload)
Quando faz upload do arquivo PDF do TCC
Então o arquivo é enviado para MinIO via URL pré-assinada
  E o estado muda para "SUBMETIDO"
  E a banca recebe notificação via Outbox (tcc.submitted)
  E o botão de upload desaparece (estado não permite novo upload)
```

### CA-03 — Visualizar banca e datas

```gherkin
Dado que o aluno está em /tccs/:id
Quando a página carrega
Então exibe composição da banca com nome e papel de cada membro
  E exibe data prevista de defesa com destaque visual
  E exibe data limite de entrega com badge danger se prazo próximo
```

---

## 4. Fora de escopo

- Criação de TCC pelo aluno — feita pela secretaria/coordenação
- Comunicação com a banca pelo sistema — usa hub de comunicação (F1.6)

---

## 5. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Specs de tela | `telasFigma/telas1/F1.15-tccs-lista.md`, `F1.16-tccs-detalhe.md` |
| Fluxo banca | `foundationDocs/analysis/fluxos_por_perfil.md` §4 F3.7 |
| Página Figma F1 | [Telas / F1 — Aluno](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=48-339) |
