# Histórias de Usuário — Fase F3 (Professor)

**Projeto:** SecretariaOnline2 — UFPR SEPT  
**Versão:** 1.0  
**Data:** 2026-06-14  
**Autor:** TCC — gerado a partir de `telasFigma/telas3/`, `foundationDocs/analysis/telas.md` §5 e `fluxos_por_perfil.md` §4

---

## Visão geral da fase

O fluxo F3 cobre as **funcionalidades do perfil Professor** — docentes que atuam como deliberantes de solicitações, organizadores e operadores de eventos formativos, orientadores de estágio e TCC, revisores da CAAF, e publicadores de comunicados. Um mesmo professor pode acumular **múltiplas capabilities** (ex.: `event.manage` + `formative.review` + `request.deliberate`); a UI decide o que mostrar exclusivamente via `_links` HATEOAS.

**Nota:** O professor usa a mesma rota `/inicio` que o aluno, mas servida pelo BFF `/bff/dashboard/professor`, que agrega os blocos relevantes para o perfil docente.

---

## Épicos

| Épico | Escopo | Telas |
|-------|--------|-------|
| `PROF-DASH` | Dashboard unificado do professor | F3.1 |
| `PROF-EVENTOS` | CRUD de eventos + operação ao vivo (v4.1) | F3.2a, F3.2b, F3.2c |
| `PROF-SOLICITACOES` | Fila de deliberação + tela de deliberar | F3.3, F3.4 |
| `PROF-FORMATIVAS` | Revisão de atividades formativas (CAAF) | F3.5 |
| `PROF-ESTAGIO` | Orientação e pareceres de estágio (COE) | F3.6 |
| `PROF-TCC` | Orientação, banca e avaliação de TCC | F3.7 |
| `PROF-COMUNICACAO` | Publicar comunicados para turmas/cursos | F3.8 |

---

## Histórias desta fase

| ID | Épico | Telas | Título curto | Prioridade | Frames Figma | Arquivo |
|----|-------|-------|-------------|------------|--------------|---------|
| US-F3-001 | PROF-DASH | F3.1 | Dashboard do professor | P2 | [Default/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=243-16994) · [Skeleton](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=243-17311) · [Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=243-17324) · [Empty](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=243-17629) | [US-F3-001-DASHBOARD.md](./US-F3-001-DASHBOARD.md) |
| US-F3-002 | PROF-EVENTOS | F3.2a, F3.2b, F3.2c | Criar, editar e operar eventos formativos (v4.1) | P2 | [F3.2a Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=217-575) · [F3.2b Editável](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=223-1935) · [F3.2c QR_SINGLE](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-7850) | [US-F3-002-EVENTOS.md](./US-F3-002-EVENTOS.md) |
| US-F3-003 | PROF-SOLICITACOES | F3.3, F3.4 | Deliberar solicitações (fila + deep-link email) | P2 | [F3.3 Loaded](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=219-817) · [F3.4 Ações](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=225-2090) | [US-F3-003-DELIBERAR-SOLICITACOES.md](./US-F3-003-DELIBERAR-SOLICITACOES.md) |
| US-F3-004 | PROF-FORMATIVAS | F3.5 | Revisar atividades formativas (CAAF) | P2 | [Loaded/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=220-1142) · [Empty](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18408) · [Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18646) | [US-F3-004-REVISAR-FORMATIVAS.md](./US-F3-004-REVISAR-FORMATIVAS.md) |
| US-F3-005 | PROF-ESTAGIO | F3.6 | Emitir pareceres de estágio (orientador / COE) | P2 | [Loaded/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=220-1350) · [Empty](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18989) · [Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19227) | [US-F3-005-ESTAGIO-ORIENTACAO.md](./US-F3-005-ESTAGIO-ORIENTACAO.md) |
| US-F3-006 | PROF-TCC | F3.7 | Avaliar TCC (orientador / banca) | P2 | [Loaded/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=220-1558) · [Empty](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19570) · [Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19808) | [US-F3-006-TCC-ORIENTACAO.md](./US-F3-006-TCC-ORIENTACAO.md) |
| US-F3-007 | PROF-COMUNICACAO | F3.8 | Publicar comunicado para turma ou curso | P2 | [Draft/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=226-2203) · [Skeleton](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=257-22100) · [Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=253-23180) | [US-F3-007-PUBLICAR-COMUNICADO.md](./US-F3-007-PUBLICAR-COMUNICADO.md) |

---

## Capabilities do perfil Professor

| Capability | Concedida a | Aciona fluxo |
|-----------|-------------|-------------|
| `dashboard.view_self_professor` | Todo professor | F3.1 |
| `event.manage` | Professor organizador | F3.2a, F3.2b |
| `event.host` | Professor organizador | F3.2c |
| `request.deliberate` | Professor deliberante (workflow-driven) | F3.3, F3.4 |
| `formative.review` | Membro CAAF do curso | F3.5 |
| `internship.review` | Orientador / membro COE | F3.6 |
| `tcc.supervise` | Orientador / membro de banca | F3.7 |
| `communication.publish_class` | Todo professor | F3.8 |

> A UI **nunca** conhece o perfil diretamente — exibe blocos e botões apenas quando `_links` existem na resposta do BFF ou dos endpoints de recurso.

---

## Mapa de frames Figma (F3)

Página: [Telas / F3 — Professor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=209-339)

| Tela | Frame | Variante | Plataforma | Node |
|------|-------|----------|------------|------|
| F3.1 | Dashboard Professor | Default | Desktop | [243-16994](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=243-16994) |
| F3.1 | Dashboard Professor | Skeleton | Desktop | [243-17311](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=243-17311) |
| F3.1 | Dashboard Professor | Default | Mobile | [243-17324](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=243-17324) |
| F3.1 | Dashboard Professor | Empty | Desktop | [243-17629](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=243-17629) |
| F3.2a | Eventos | Loaded | Desktop | [217-575](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=217-575) |
| F3.2a | Eventos | Empty | Desktop | [218-691](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=218-691) |
| F3.2a | Eventos | Skeleton | Desktop | [244-17478](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-17478) |
| F3.2a | Eventos | Loaded | Mobile | [244-17600](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-17600) |
| F3.2a | Eventos | Empty | Mobile | [244-17725](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-17725) |
| F3.2b | Evento detalhe | Editável | Desktop | [223-1935](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=223-1935) |
| F3.2b | Evento detalhe | Skeleton | Desktop | [253-21624](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=253-21624) |
| F3.2b | Evento detalhe | Editável | Mobile | [275-20962](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=275-20962) |
| F3.2c | Operação | QR_SINGLE / single | Desktop | [261-7850](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-7850) |
| F3.2c | Operação | QR_DUAL / entrada | Desktop | [261-8160](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-8160) |
| F3.2c | Operação | QR_DUAL / saída | Desktop | [261-8473](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-8473) |
| F3.2c | Operação | SECRET_SINGLE / single | Desktop | [261-8786](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-8786) |
| F3.2c | Operação | SECRET_DUAL / entrada | Desktop | [261-9082](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-9082) |
| F3.2c | Operação | SECRET_DUAL / saída | Desktop | [261-9381](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-9381) |
| F3.2c | Operação | QR_SINGLE / single | Mobile | [261-9680](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-9680) |
| F3.2c | Operação | QR_DUAL / entrada | Mobile | [261-9896](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=261-9896) |
| F3.2c | Operação | QR_DUAL / saída | Mobile | [370-6918](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=370-6918) |
| F3.2c | Operação | SECRET_SINGLE / single | Mobile | [370-7200](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=370-7200) |
| F3.2c | Operação | SECRET_DUAL / entrada | Mobile | [370-7465](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=370-7465) |
| F3.2c | Operação | SECRET_DUAL / saída | Mobile | [370-7733](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=370-7733) |
| F3.3 | Deliberar fila | Loaded | Desktop | [219-817](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=219-817) |
| F3.3 | Deliberar fila | Empty | Desktop | [219-1025](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=219-1025) |
| F3.3 | Deliberar fila | Skeleton | Desktop | [244-17943](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-17943) |
| F3.3 | Deliberar fila | Loaded | Mobile | [244-18065](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18065) |
| F3.3 | Deliberar fila | Empty | Mobile | [244-18190](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18190) |
| F3.4 | Deliberar solicitação | Ações | Desktop | [225-2090](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=225-2090) |
| F3.4 | Deliberar solicitação | Skeleton | Desktop | [257-21325](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=257-21325) |
| F3.4 | Deliberar solicitação | Ações | Mobile | [275-20969](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=275-20969) |
| F3.5 | Formativas revisão | Loaded | Desktop | [220-1142](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=220-1142) |
| F3.5 | Formativas revisão | Empty | Desktop | [244-18408](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18408) |
| F3.5 | Formativas revisão | Skeleton | Desktop | [244-18520](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18520) |
| F3.5 | Formativas revisão | Loaded | Mobile | [244-18646](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18646) |
| F3.5 | Formativas revisão | Empty | Mobile | [244-18771](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18771) |
| F3.6 | Estágios revisão | Loaded | Desktop | [220-1350](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=220-1350) |
| F3.6 | Estágios revisão | Empty | Desktop | [244-18989](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-18989) |
| F3.6 | Estágios revisão | Skeleton | Desktop | [244-19101](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19101) |
| F3.6 | Estágios revisão | Loaded | Mobile | [244-19227](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19227) |
| F3.6 | Estágios revisão | Empty | Mobile | [244-19352](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19352) |
| F3.7 | TCCs revisão | Loaded | Desktop | [220-1558](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=220-1558) |
| F3.7 | TCCs revisão | Empty | Desktop | [244-19570](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19570) |
| F3.7 | TCCs revisão | Skeleton | Desktop | [244-19682](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19682) |
| F3.7 | TCCs revisão | Loaded | Mobile | [244-19808](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19808) |
| F3.7 | TCCs revisão | Empty | Mobile | [244-19933](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=244-19933) |
| F3.8 | Publicar comunicado | Draft | Desktop | [226-2203](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=226-2203) |
| F3.8 | Publicar comunicado | Skeleton | Desktop | [257-22100](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=257-22100) |
| F3.8 | Publicar comunicado | Draft | Mobile | [253-23180](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=253-23180) |

---

## Referências globais

| Recurso | Localização |
|---------|------------|
| Specs de tela (F3) | `telasFigma/telas3/F3.x-*.md` |
| Fluxos do professor | `foundationDocs/analysis/fluxos_por_perfil.md` §4 |
| Mapa de rotas | `foundationDocs/analysis/telas.md` §5 |
| Endpoints presença v4.1 | `foundationDocs/analysis/endpoints_canonicos_presenca_eventos_v4.md` |
| Página Figma F3 | [Telas / F3 — Professor](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=209-339) |
