# Histórias de Usuário — Fase F4 (Comissões: CAAF e COE)

**Projeto:** SecretariaOnline2 — UFPR SEPT  
**Versão:** 1.0  
**Data:** 2026-06-14  
**Autor:** TCC — gerado a partir de `telasFigma/telas4/`, `foundationDocs/analysis/fluxos_por_perfil.md` §5

---

## Visão geral da fase

O fluxo F4 cobre os **dashboards de comissão** — painéis usados por subgrupos de professores com capabilities especializadas para gerir filas coletivas de atividades formativas (CAAF) e estágios (COE). A fase F4 é **deliberadamente compacta**: a lógica de revisão individual já está em F3 (US-F3-004 para CAAF, US-F3-005 para COE); o F4 adiciona apenas a **camada de pool coletivo** — atribuição de itens a membros e aprovação em lote.

> Uma comissão é um subset de professores com capabilities específicas e escopo restrito a um curso/centro. O professor-membro acessa `/comissoes/caaf` (ou `/coe`) em vez de `/formativas?to=me`, pois sua função é gerir o pool antes de revisar individualmente.

---

## Épicos

| Épico | Escopo | Telas |
|-------|--------|-------|
| `CAAF-POOL` | Dashboard e gestão do pool CAAF (atividades formativas) | F4.1 |
| `COE-POOL` | Dashboard e gestão do pool COE (estágios) | F4.2 |

---

## Histórias desta fase

| ID | Épico | Telas | Título curto | Prioridade | Frames Figma | Arquivo |
|----|-------|-------|-------------|------------|--------------|---------|
| US-F4-001 | CAAF-POOL | F4.1 | Pool CAAF — atribuir e aprovar formativas em lote | P2 | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=473-6859) · [Skeleton](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=476-723) · [Empty](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=479-828) · [Seleção](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=480-936) · [Atribuir](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=524-1988) | [US-F4-001-COMISSAO-CAAF.md](./US-F4-001-COMISSAO-CAAF.md) |
| US-F4-002 | COE-POOL | F4.2 | Pool COE — atribuir e acompanhar estágios em lote | P2 | [Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=481-1093) · [Skeleton](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=481-1311) · [Empty](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=481-1436) · [Seleção](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=481-1560) · [Atribuir](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=524-2254) | [US-F4-002-COMISSAO-COE.md](./US-F4-002-COMISSAO-COE.md) |

---

## Mapa de frames Figma (F4)

Página: [Telas / F4 — Comissões](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=473-447)

| Tela | Frame | Variante | Node |
|------|-------|----------|------|
| F4.1 | Comissão CAAF | Loaded / Desktop | [473-6859](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=473-6859) |
| F4.1 | Comissão CAAF | Skeleton / Desktop | [476-723](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=476-723) |
| F4.1 | Comissão CAAF | Empty / Desktop | [479-828](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=479-828) |
| F4.1 | Comissão CAAF | Seleção / Desktop | [480-936](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=480-936) |
| F4.1 | Comissão CAAF | Atribuir / Desktop | [524-1988](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=524-1988) |
| F4.2 | Comissão COE | Loaded / Desktop | [481-1093](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=481-1093) |
| F4.2 | Comissão COE | Skeleton / Desktop | [481-1311](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=481-1311) |
| F4.2 | Comissão COE | Empty / Desktop | [481-1436](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=481-1436) |
| F4.2 | Comissão COE | Seleção / Desktop | [481-1560](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=481-1560) |
| F4.2 | Comissão COE | Atribuir / Desktop | [524-2254](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=524-2254) |

---

## Relação F4 → F3

| Ação em F4 | Continua em F3 |
|-----------|----------------|
| CAAF atribui formativa a membro → membro abre `/formativas/:id` | [US-F3-004](../F3/US-F3-004-REVISAR-FORMATIVAS.md) |
| COE atribui estágio a orientador → orientador abre `/estagios/:id` | [US-F3-005](../F3/US-F3-005-ESTAGIO-ORIENTACAO.md) |
| Aprovação em lote (lote-friendly) encerra no F4 diretamente | — evento `formativas.assigned` / `estagios.assigned` Outbox |

---

## Capabilities do fluxo F4

| Capability | Comissão | Função |
|-----------|----------|--------|
| `formative.review` + escopo CAAF | CAAF | Acessa `/comissoes/caaf`, atribui e aprova formativas |
| `internship.review` + escopo COE | COE | Acessa `/comissoes/coe`, atribui e acompanha estágios |

---

## Referências globais

| Recurso | Localização |
|---------|------------|
| Specs de tela (F4) | `telasFigma/telas4/F4.x-*.md` |
| Fluxo F4 | `foundationDocs/analysis/fluxos_por_perfil.md` §5 |
| Página Figma F4 | [Telas / F4 — Comissões](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=473-447) |
