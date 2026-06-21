# US-F0-004 — Visualizar Informações de Contato da Secretaria

| HU | Tela | Capability | API primária | Fonte |
|----|------|------------|--------------|-------|
| US-F0-004 | F0.4 — `/contato` | pública (sem autenticação) | **nenhuma — página estática** | `HUs/F0 — Público/US-F0-004-CONTATO.md` |

---

## Matriz de cobertura

| ID diagrama | Origem (CA / RN) | Tipo | Status |
|-------------|------------------|------|--------|
| — | CA-01 (exibição de endereço, telefones, e-mail, horário) | NAO_APLICAVEL | — |
| — | CA-02 (layout responsivo — grid 2 cols / 1 col) | NAO_APLICAVEL | — |
| — | CA-03 (link "Voltar ao login" → /login) | NAO_APLICAVEL | — |
| — | CA-04 (acessibilidade — alt text, aria-label) | NAO_APLICAVEL | — |
| — | RN-F0.4-01 (conteúdo via env, não hardcoded) | NAO_APLICAVEL | — |
| — | RN-F0.4-02 (links tel:) | NAO_APLICAVEL | — |
| — | RN-F0.4-03 (link /login no rodapé) | NAO_APLICAVEL | — |
| — | RN-F0.4-04 (alt text no mapa) | NAO_APLICAVEL | — |
| — | RN-F0.4-05 (mobile abre em browser externo) | NAO_APLICAVEL | — |

**Total de diagramas gerados: 0** — conforme previsto na fila da campanha ("0 diagrama OK").

---

## Referências DRY

Nenhuma.

---

## Fora de sequência

| Item | Motivo |
|------|--------|
| Todos os CAs e RNs | A tela `/contato` é **inteiramente estática**: o conteúdo é carregado de variáveis de ambiente / configuração em build-time e renderizado pelo React sem nenhuma chamada HTTP. Não há troca de mensagens entre Browser, API, UseCase ou Postgres para diagramar. Nenhum CA dispara um round-trip de rede; todos são requisitos de layout, acessibilidade ou configuração estática — categorias explicitamente `NAO_APLICAVEL` conforme §5.1 do prompt. |

> **Referência na fila:** `sequenceDiagrams/README.md` — linha US-F0-004, coluna Observação: "0 diagrama OK".
