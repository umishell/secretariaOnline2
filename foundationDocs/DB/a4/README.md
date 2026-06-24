# Exportação A4 — Modelo conceitual (mermaid.live)

O arquivo completo `../modelo-conceitual.mmd` tem **~30 entidades** ligadas a `USUARIO`. O motor de layout do Mermaid (`dagre`) coloca todos os filhos do hub na **mesma faixa horizontal** — `direction TB` não corrige isso no mermaid.live (só muda a orientação da “espinha”, não o leque de arestas).

O preview vertical do Cursor usa painel estreito / versão diferente do renderizador; no mermaid.live o diagrama completo **sempre** ficará horizontal.

## Solução: 4 partes verticais (mesmo visual erDiagram)

| Arquivo | Conteúdo |
|---------|----------|
| `modelo-conceitual-parte-1-nucleo-iam.mmd` | USUARIO, CURSO, IAM, JTI_BLACKLIST |
| `modelo-conceitual-parte-2-academico-solicitacoes.mmd` | Acadêmico + Solicitações |
| `modelo-conceitual-parte-3-formativas-estagio-tcc.mmd` | Formativas + Estágio + TCC |
| `modelo-conceitual-parte-4-comunicacao-presenca-cert.mmd` | Comunicação + Presença + Certificado + Auditoria + OUTBOX |

### Passo a passo (Google Docs, 1 página A4)

1. Abra [mermaid.live](https://mermaid.live).
2. Para cada arquivo `parte-1` … `parte-4`:
   - Cole o conteúdo do `.mmd`
   - Confirme layout **vertical**
   - **Actions → PNG** (ou SVG)
3. No Google Docs, insira as **4 imagens empilhadas** (parte 1 no topo), largura ~17 cm cada.
4. Legenda única: *Figura 2 — Modelo conceitual (partes 1–4)*.

### Fonte canônica

O diagrama **completo** para o repositório continua em `../modelo-conceitual.mmd` (referência de todas as entidades e cardinalidades). As partes são apenas artefatos de **exportação visual**.
