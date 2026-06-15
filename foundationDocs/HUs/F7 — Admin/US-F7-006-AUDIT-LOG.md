# US-F7-006 — Trilha de Auditoria

| Campo | Valor |
|-------|-------|
| **ID** | US-F7-006 |
| **Épico** | ADMIN-AUDIT |
| **Telas** | F7.7 — Audit Log |
| **Rota** | `/admin/audit-log` |
| **Prioridade** | P2 |
| **Capability** | `audit.read` |
| **APIs** | `GET /audit-log` |
| **Frames Figma** | [Diff Drawer](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6615) |

---

## História de Usuário

> **Como** administrador da plataforma,  
> **quero** pesquisar a trilha de auditoria por ator, entidade e intervalo de tempo, e visualizar o diff JSON antes/depois de qualquer alteração em um Drawer lateral,  
> **para que** seja possível investigar incidentes, rastrear mudanças não autorizadas e comprovar a conformidade com políticas de segurança.

---

## Regras de Negócio

| ID | Regra |
|----|-------|
| RN-F7-006-01 | Somente usuários com capability `audit.read` acessam `/admin/audit-log`. |
| RN-F7-006-02 | O `audit_log` é **imutável**: nenhum registro pode ser editado ou excluído pela interface, nem mesmo pelo admin. Inserções são feitas exclusivamente pelo sistema. |
| RN-F7-006-03 | Colunas da tabela: ID, Ator (nome + tipo), Ação (ex.: `USER_DEACTIVATED`, `REQUEST_DELIBERATED`), Entidade Alvo (tipo + ID), Timestamp, IP de origem. |
| RN-F7-006-04 | **Filtros da `DS/FilterBar`:** Ator (busca por nome/e-mail), Tipo de ação (enum), Entidade alvo (tipo), Intervalo de datas (de–até). Filtros combinados com `AND`. |
| RN-F7-006-05 | Ao clicar em uma linha, o **Drawer lateral** (`DS/Drawer` + `DS/AuditDiffViewer`) é aberto à direita com: detalhes do evento, diff JSON side-by-side (payload antes vs. depois). |
| RN-F7-006-06 | O diff JSON é renderizado em `surface/code` com fonte monoespaçada. Campos adicionados aparecem em verde (`status/success`); campos removidos em vermelho (`status/danger`); campos alterados em amarelo (`status/warning`). |
| RN-F7-006-07 | O Drawer ocupa 420px de largura (conforme Figma `837:2493`) e tem foco capturado (focus trap) enquanto aberto. Fechamento via botão X ou tecla Esc. |
| RN-F7-006-08 | A tabela é somente leitura: nenhum botão de ação aparece no header (o `DS/Button` está como `hidden=true` no Figma `731:6620`). |
| RN-F7-006-09 | Entradas são retidas por **5 anos** (requisito de conformidade institucional). A busca padrão limita ao último ano; o admin pode estender o intervalo explicitamente. |
| RN-F7-006-10 | Paginação: 50 registros por página. Ordenação padrão por `timestamp DESC`. |

---

## Critérios de Aceitação

### CA-F7-006-01 — Listar eventos de auditoria

```gherkin
Dado que o admin acessa /admin/audit-log
Quando a tabela carrega (sem filtros aplicados)
Então são exibidos os eventos do último ano ordenados por timestamp DESC
E cada linha mostra: Ator, Ação, Entidade Alvo, Timestamp, IP
E nenhum botão de ação aparece no header da página
```

### CA-F7-006-02 — Filtrar por ator e ação

```gherkin
Dado que o admin preenche o filtro Ator com "João" e seleciona Ação "USER_DEACTIVATED"
Quando aplica os filtros
Então a tabela exibe apenas eventos em que João realizou a ação USER_DEACTIVATED
```

### CA-F7-006-03 — Abrir Drawer com diff

```gherkin
Dado que existe um evento "REQUEST_DELIBERATED" na tabela
Quando o admin clica na linha
Então o DS/Drawer abre à direita com 420px de largura
E o DS/AuditDiffViewer exibe o diff JSON side-by-side
E campos adicionados aparecem em verde, removidos em vermelho, alterados em amarelo
E o Drawer captura o foco (focus trap)
```

### CA-F7-006-04 — Fechar Drawer

```gherkin
Dado que o Drawer está aberto
Quando o admin pressiona Esc
Então o Drawer fecha e o foco retorna à linha da tabela
```

### CA-F7-006-05 — Imutabilidade

```gherkin
Dado que qualquer evento de auditoria existe na tabela
Então não há botão "Excluir" ou "Editar" em nenhuma linha
E a API não expõe endpoints DELETE ou PATCH para /audit-log
```

### CA-F7-006-06 — Busca por intervalo estendido

```gherkin
Dado que o admin define o intervalo "De: 2021-01-01 Até: hoje"
Quando aplica os filtros
Então a tabela exibe eventos dos últimos 5 anos
E o sistema retorna até 50 registros por página dentro desse intervalo
```

---

## Componentes de UI

- `Shell/AdminLayout`
- `DS/FilterBar` (ator, ação, entidade, datas)
- `DS/DataTable/Full` (somente leitura — sem botões no header)
- `DS/Pagination`
- `DS/Drawer` (lateral — 420px, `837:2493`)
- `DS/AuditDiffViewer` (diff JSON side-by-side com cores semânticas)
- `Overlay/scrim` (sobreposição quando Drawer aberto)

---

## Contrato de API

```
GET /audit-log
  ?ator=João
  &acao=USER_DEACTIVATED
  &entidade=REQUEST
  &de=2025-01-01
  &ate=2025-12-31
  &page=0&size=50

Response 200: {
  content: [
    {
      "id": "...", "ator": { "id", "nome", "tipo" }, "acao": "REQUEST_DELIBERATED",
      "entidadeTipo": "REQUEST", "entidadeId": "...",
      "timestamp": "...", "ip": "...",
      "payloadAntes": { ... },
      "payloadDepois": { ... }
    }
  ],
  totalElements: N
}
```

---

## Fora de Escopo

- Exportação do audit_log como CSV (requer `export.run` capability — ver US-F5-010)
- Alertas automáticos por padrão de comportamento suspeito
- Purga/arquivamento de registros antigos pela UI

---

## Definition of Done

- [ ] Tabela somente leitura com filtros avançados
- [ ] Drawer com AuditDiffViewer renderizando diff JSON com cores semânticas
- [ ] Focus trap no Drawer com fechamento via Esc
- [ ] Busca de intervalo estendido (até 5 anos)
- [ ] Paginação 50 registros/página ordenada por timestamp DESC
- [ ] Imutabilidade: sem endpoints DELETE/PATCH, sem botões de ação na UI
- [ ] Testes: filtros combinados, diff JSON, focus trap

---

## Referências

- Frame principal: [F7.7 Diff Drawer](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=731-6615)
- Fluxo F7.5 Audit log: `foundationDocs/analysis/fluxos_por_perfil.md` §8.5
- Inserção no audit_log: todas as mutações do sistema (US-F5-003 RN-03-07, US-F7-001 RN-09, etc.)
