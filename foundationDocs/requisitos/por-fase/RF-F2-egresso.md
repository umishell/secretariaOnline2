# Requisitos Funcionais — Fase F2 (Egresso)

**Projeto:** SecretariaOnline2 — UFPR SEPT  
**Versão:** 1.0  
**Data:** 2026-06-23  
**Gerado a partir de:** US-F2-001; `fluxos_por_perfil.md` §3; `telas.md` §4; `legenda_siglas_casos_de_uso_por_ator.md`; `analise_arquitetural_secretariaonline2.md` §11; `HUs/F2 — Egresso/F2-INDICE.md`  
**Total RF neste arquivo:** 1 (1 HU → 1 capacidade coesa)

---

## Resumo da fase

| RF | Nome | HU | UC | Tela | Prioridade |
|----|------|----|----|------|:----------:|
| RF-F2-001 | Visualizar dashboard read-only e reemitir documentos | US-F2-001 | UC-EGR-01 | F2.1 `/egresso/inicio` | P2 |

> **Telas reaproveitadas (sem RF próprio em F2):** `/perfil`, `/perfil/seguranca`, `/perfil/notificacoes` (RF-F1-003-a/b/c), `/certificados` (RF-F1-010), verificadores públicos (RF-F0-006, RF-F0-007). O egresso mantém as capabilities correspondentes após a transição ALUNO → EGRESSO (RN-F2.1-03).

---

### RF-F2-001 — Visualizar dashboard read-only e reemitir documentos

| Campo | Valor |
|-------|-------|
| **ID** | RF-F2-001 |
| **Nome** | Visualizar dashboard read-only e reemitir documentos |
| **Prioridade** | P2 |
| **Ator(es)** | A3 Egresso |
| **Módulo** | F2 — Egresso |
| **Rastreio HU** | US-F2-001 |
| **Rastreio UC** | UC-EGR-01 |
| **Tela** | F2.1 `/egresso/inicio` |
| **API** | `GET /alumni/me`; `GET /alumni/me/diploma/download`; `POST /certificates/{id}/reissue` |
| **Legado** | — (nova — preenche vácuo da Árvore 5 do legado) |

**Descrição:** O sistema deve oferecer ao egresso autenticado um painel estritamente read-only com histórico acadêmico resumido, diploma, certificados emitidos durante o curso e dados de colação, permitindo download do diploma e reemissão de certificados (regeneração do PDF original, sem nova chave de assinatura), com bloqueio de rotas exclusivas de aluno e redirecionamento pós-login adequado ao perfil EGRESSO.

**Pré-condições:**
- A secretaria registrou o diploma do ex-aluno (US-F5-005 / F5.11) e o sistema transicionou `usuario.role` de `ALUNO` para `EGRESSO`, revogando capabilities de aluno e concedendo `alumni.view_own` (RN-F2.1-01).
- Egresso autenticado com `mustChangePassword = false` (RF-F0-001, RF-F1-002).

**Pós-condições:**
- Dashboard renderizado com dados read-only ou estados vazios/skeleton conforme resposta da API.
- Download de diploma ou reemissão de certificado gera URL pré-assinada MinIO (TTL 15 min) sem criar novos registros na base.
- Tentativa de acesso a rotas exclusivas de aluno resulta em HTTP 403 e redirecionamento para `/erro/403`.

**Critérios de aceitação:**

*Transição e acesso*
1. Após F5.11: capabilities de aluno (`dashboard.view_own`, `request.open`, `formative.submit`, etc.) revogadas; `alumni.view_own` concedida (RN-F2.1-01).
2. Login com role `EGRESSO`: redirecionamento para `/egresso/inicio` (não `/inicio` do aluno) (CA-01).
3. Egresso mantém acesso a `/perfil`, `/perfil/seguranca`, `/perfil/notificacoes`, `/certificados` e verificadores públicos (RN-F2.1-03, CA-05).
4. Em `/perfil/notificacoes`: opções de solicitação e formativa ausentes (capabilities revogadas); e-mail pessoal, telefone e foto editáveis via `user.update_own_profile` (CA-05).

*Dashboard read-only*
5. `GET /alumni/me` retorna apenas dados do egresso autenticado — sem listagem de turma ou histórico de terceiros (RN-F2.1-06).
6. Conteúdo exibido: curso, período de conclusão, CRA (se disponível), KPIs históricos (horas formativas validadas, número de certificados, situação do diploma), seção Diploma (número, data), seção Certificados, seção Colação (data, turma) (RN-F2.1-05, CA-02).
7. Dashboard estritamente read-only: sem formulários de criação, sem CTAs de "nova" ação; badges em variante success/neutral "Concluído" ou "Emitido" (RN-F2.1-04, CA-02).
8. Botões Download e Reemitir PDF renderizados somente quando `_links.download` ou `_links.reemitir` existirem na resposta — nunca hardcoded (RN-F2.1-09, RF-TR-005).
9. Durante carregamento: `DS/Skeleton` cobrindo blocos do dashboard (CA-06).
10. Seção Certificados vazia: `DS/EmptyState` com mensagem `"Nenhum certificado emitido durante o curso."` (CA-06).

*Download de diploma*
11. Com `_links.download` no objeto diploma: `GET /alumni/me/diploma/download` retorna URL pré-assinada MinIO (TTL 900 s) para o PDF oficial já armazenado; nenhum novo artefato criado (RN-F2.1-10, F2.1-D02).
12. Diploma é documento institucional direto via MinIO — distinto do fluxo anti-fraude de certificados (hash SHA-256 + ED25519).

*Reemissão de certificado*
13. Com `_links.reemitir`: `POST /certificates/{id}/reissue` valida ownership (`beneficiario = alumniId` do JWT) e retorna URL pré-assinada do PDF existente no MinIO (RN-F2.1-07, RN-F2.1-08, F2.1-D03).
14. Reemissão **não** cria novo registro de certificado, **não** gera nova chave de assinatura; hash SHA-256 e assinatura ED25519 permanecem idênticos ao original; documento continua verificável em `/publico/verificar-certificado/:hash` (RN-F2.1-07, CA-03, RF-F0-007).
15. Certificados listados são exclusivamente emitidos pelo sistema — nunca upload externo (RF-TR-003, RF-F1-010).

*Bloqueio de rotas de aluno*
16. Acesso a `/solicitacoes/nova`, `/formativas`, `/estagios` e demais rotas exclusivas de aluno: HTTP 403 RFC 7807; frontend redireciona para `/erro/403` com mensagem `"Você não tem permissão para acessar este recurso."` (RN-F2.1-02, CA-04).
17. Botão "Ir ao início" na tela `/erro/403` para egresso leva a `/egresso/inicio` (não `/inicio`) (CA-04).
18. RouteGuard do frontend verifica `authorities[]` do JWT antes de navegar; rotas bloqueadas não disparam chamadas desnecessárias ao backend (F2.1-D04).

*Rota `/certificados` reaproveitada*
19. Em `/certificados`: lista completa dos certificados do curso com download via `_links.download` (CA-05, RF-F1-010).

*Acessibilidade e responsividade*
20. Campos read-only com `aria-readonly="true"` ou renderizados como texto estático; headings: H1 `"Olá, {nome}"` → H2 por seção (Diploma, Certificados, Colação) (CA-07).
21. Botões de download com `aria-label` descritivo: `"Baixar certificado de [atividade]"` (CA-07).
22. Responsivo desde 375 px; contraste ≥ 4,5:1 (RNF-UX-01, RNF-UX-02).

**Regras de negócio relacionadas:** RN-F2.1-01 a RN-F2.1-10

**Dependências:** RF-F0-001 (login + redirect por role), RF-F0-007, RF-F1-003-a/b/c, RF-F1-010, RF-TR-003, RF-TR-005, US-F5-005 (trigger transição ALUNO → EGRESSO), RNF-UX-01, RNF-UX-02, RNF-UX-04, RNF-LGL-02, RNF-POR-03

---

## Fora de escopo (registrado na HU)

- Histórico acadêmico detalhado (disciplinas, notas) — permanece no SIGA/UFPR Virtual
- Segunda via formal de diploma — processo presencial na secretaria
- Reativação do perfil de aluno — processo administrativo manual
- Comunicação com ex-professores/colegas pelo sistema
