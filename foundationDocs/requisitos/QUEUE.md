# Fila de Execução — Campanha de Requisitos SO2

**Projeto:** SecretariaOnline2 — UFPR SEPT  
**Total de etapas:** 13 (Etapa 0 a Etapa 12)  
**Prompt mestre:** `foundationDocs/prompts/PROMPT_gerar_requisitos_funcionais_e_nao_funcionais.md`

> **Como usar:** Execute uma etapa por conversa. Ao concluir, marque `✅` e anote a data. Use o prompt curto abaixo para cada etapa.

---

## Prompt de invocação por etapa

```
Execute a [Etapa N] conforme @foundationDocs/prompts/PROMPT_gerar_requisitos_funcionais_e_nao_funcionais.md
```

---

## Fila

| # | Status | Etapa | Escopo | HUs | Arquivos gerados | Data |
|--:|:------:|-------|--------|:---:|-----------------|------|
| 0 | ✅ | **Etapa 0** | Convenções + 00-indice + 00-inventario + QUEUE + estimativas | — | `00-indice-requisitos.md`, `00-inventario-e-decisoes.md`, `QUEUE.md` | 2026-06-23 |
| 1 | ✅ | **Etapa 1** | RNF transversais completos (todas as categorias ISO 25010) | — | `02-requisitos-nao-funcionais.md` | 2026-06-23 |
| 2 | ✅ | **Etapa 2** | RF F0 — Público | 7 | `por-fase/RF-F0-publico.md` | 2026-06-23 |
| 3 | ✅ | **Etapa 3** | RF F1 — Aluno | 11 → 14 RFs | `por-fase/RF-F1-aluno.md` | 2026-06-23 |
| 4 | ✅ | **Etapa 4** | RF F2 — Egresso | 1 RF | `por-fase/RF-F2-egresso.md` | 2026-06-23 |
| 5 | ✅ | **Etapa 5** | RF F3 — Professor | 7 → 9 RFs | `por-fase/RF-F3-professor.md` | 2026-06-23 |
| 6 | ✅ | **Etapa 6** | RF F4 — Comissões | 2 RFs | `por-fase/RF-F4-comissoes.md` | 2026-06-23 |
| 7 | ✅ | **Etapa 7** | RF F5 — Secretaria | 12 → 18 RFs | `por-fase/RF-F5-secretaria.md` | 2026-06-23 |
| 8 | ✅ | **Etapa 8** | RF F6 — Coordenação | 2 RFs | `por-fase/RF-F6-coordenacao.md` | 2026-06-23 |
| 9 | ✅ | **Etapa 9** | RF F7 — Admin | 7 → 8 RFs | `por-fase/RF-F7-admin.md` | 2026-06-23 |
| 10 | ✅ | **Etapa 10** | RF F8 — Cross-cutting | 2 RFs | `por-fase/RF-F8-cross-cutting.md` | 2026-06-23 |
| 11 | ⬜ | **Etapa 11** | RF transversais (RF-TR-001 a 008) + revisão narrativa | — | `por-fase/RF-TR-transversais.md` | — |
| 12 | ⬜ | **Etapa 12** | Revisão de cobertura: 51/51 HUs, métricas RNF, duplicatas, checklist qualidade §7 | — | Atualização `00-indice-requisitos.md` | — |

---

## Contexto obrigatório por etapa

### Etapas 1–12 (sempre anexar)

```
@foundationDocs/prompts/PROMPT_gerar_requisitos_funcionais_e_nao_funcionais.md
@foundationDocs/analysis/analise_arquitetural_secretariaonline2.md
@foundationDocs/analysis/fluxos_por_perfil.md
@foundationDocs/analysis/telas.md
@.cursorrules
@foundationDocs/requisitos/00-indice-requisitos.md
@foundationDocs/requisitos/00-inventario-e-decisoes.md
```

### Etapa 1 (RNF — adicionar)

```
@agents/security-engineer.md
@agents/backend-architect.md
@agents/database-engineer.md
@agents/devops-engineer.md
@agents/ux-ui-specialist.md
@agents/workflow-engine-specialist.md
@foundationDocs/useCaseDiagrams/legenda_siglas_casos_de_uso_por_ator.md
```

### Etapa 2 (F0 — adicionar)

```
@foundationDocs/HUs/F0 — Público/US-F0-001-LOGIN.md
@foundationDocs/HUs/F0 — Público/US-F0-002-RECUPERAR-SENHA.md
@foundationDocs/HUs/F0 — Público/US-F0-003-NOVA-SENHA.md
@foundationDocs/HUs/F0 — Público/US-F0-004-CONTATO.md
@foundationDocs/HUs/F0 — Público/US-F0-005-ERRO.md
@foundationDocs/HUs/F0 — Público/US-F0-006-VERIFICAR-PROTOCOLO.md
@foundationDocs/HUs/F0 — Público/US-F0-007-VERIFICAR-CERTIFICADO.md
@agents/security-engineer.md
@foundationDocs/analysis/mvp_v1_walking_skeleton_aluno.md
```

### Etapa 3 (F1 — adicionar)

```
@foundationDocs/HUs/F1 — Aluno/US-F1-001-DASHBOARD.md
@foundationDocs/HUs/F1 — Aluno/US-F1-002-PRIMEIRO-ACESSO.md
@foundationDocs/HUs/F1 — Aluno/US-F1-003-PERFIL.md
@foundationDocs/HUs/F1 — Aluno/US-F1-004-COMUNICACAO.md
@foundationDocs/HUs/F1 — Aluno/US-F1-005-SOLICITACOES.md
@foundationDocs/HUs/F1 — Aluno/US-F1-006-FORMATIVAS.md
@foundationDocs/HUs/F1 — Aluno/US-F1-007-ESTAGIO.md
@foundationDocs/HUs/F1 — Aluno/US-F1-008-TCC.md
@foundationDocs/HUs/F1 — Aluno/US-F1-009-PRESENCA.md
@foundationDocs/HUs/F1 — Aluno/US-F1-010-CERTIFICADOS.md
@foundationDocs/HUs/F1 — Aluno/US-F1-011-ATENDIMENTOS.md
@foundationDocs/analysis/mvp_v1_walking_skeleton_aluno.md
@foundationDocs/analysis/mvp_v2_solicitacoes_workflow_engine.md
@foundationDocs/analysis/endpoints_canonicos_presenca_eventos_v4.md
```

### Etapa 4 (F2 — adicionar)

```
@foundationDocs/HUs/F2 — Egresso/US-F2-001-DASHBOARD-EGRESSO.md
```

### Etapa 5 (F3 — adicionar)

```
@foundationDocs/HUs/F3 — Professor/US-F3-001-DASHBOARD.md
@foundationDocs/HUs/F3 — Professor/US-F3-002-EVENTOS.md
@foundationDocs/HUs/F3 — Professor/US-F3-003-DELIBERAR-SOLICITACOES.md
@foundationDocs/HUs/F3 — Professor/US-F3-004-REVISAR-FORMATIVAS.md
@foundationDocs/HUs/F3 — Professor/US-F3-005-ESTAGIO-ORIENTACAO.md
@foundationDocs/HUs/F3 — Professor/US-F3-006-TCC-ORIENTACAO.md
@foundationDocs/HUs/F3 — Professor/US-F3-007-PUBLICAR-COMUNICADO.md
@foundationDocs/analysis/endpoints_canonicos_presenca_eventos_v4.md
```

### Etapa 6 (F4 — adicionar)

```
@foundationDocs/HUs/F4 — Comissões/US-F4-001-COMISSAO-CAAF.md
@foundationDocs/HUs/F4 — Comissões/US-F4-002-COMISSAO-COE.md
```

### Etapa 7 (F5 — adicionar)

```
@foundationDocs/HUs/F5 — Secretaria/US-F5-001-DASHBOARD.md
@foundationDocs/HUs/F5 — Secretaria/US-F5-002-SOLICITACOES.md
@foundationDocs/HUs/F5 — Secretaria/US-F5-003-GESTAO-ALUNOS.md
@foundationDocs/HUs/F5 — Secretaria/US-F5-004-DADOS-ACADEMICOS.md
@foundationDocs/HUs/F5 — Secretaria/US-F5-005-EGRESSOS-DIPLOMAS.md
@foundationDocs/HUs/F5 — Secretaria/US-F5-006-AUTORIZACOES-IMAGEM.md
@foundationDocs/HUs/F5 — Secretaria/US-F5-007-ATENDIMENTOS.md
@foundationDocs/HUs/F5 — Secretaria/US-F5-008-EVENTOS.md
@foundationDocs/HUs/F5 — Secretaria/US-F5-009-IMPORTACOES.md
@foundationDocs/HUs/F5 — Secretaria/US-F5-010-EXPORTACOES.md
@foundationDocs/HUs/F5 — Secretaria/US-F5-011-ESTATISTICAS.md
@foundationDocs/HUs/F5 — Secretaria/US-F5-012-TAREFAS.md
@foundationDocs/analysis/endpoints_canonicos_presenca_eventos_v4.md
```

### Etapa 8 (F6 — adicionar)

```
@foundationDocs/HUs/F6 — Coordenação/US-F6-001-CONFIGURAR-CURSO.md
@foundationDocs/HUs/F6 — Coordenação/US-F6-002-RELATORIOS.md
```

### Etapa 9 (F7 — adicionar)

```
@foundationDocs/HUs/F7 — Admin/US-F7-001-IAM-USUARIOS.md
@foundationDocs/HUs/F7 — Admin/US-F7-002-IAM-PERFIS-AUTORIDADES.md
@foundationDocs/HUs/F7 — Admin/US-F7-003-WORKFLOW-ENGINE.md
@foundationDocs/HUs/F7 — Admin/US-F7-004-TEMPLATES-COMUNICACAO.md
@foundationDocs/HUs/F7 — Admin/US-F7-005-JOBS-OUTBOX.md
@foundationDocs/HUs/F7 — Admin/US-F7-006-AUDIT-LOG.md
@foundationDocs/HUs/F7 — Admin/US-F7-007-SAUDE-SISTEMA.md
@foundationDocs/analysis/mvp_v2_solicitacoes_workflow_engine.md
@agents/workflow-engine-specialist.md
@agents/devops-engineer.md
@agents/security-engineer.md
```

### Etapa 10 (F8 — adicionar)

```
@foundationDocs/HUs/F8 — Cross-cutting/US-F8-001-BUSCA-GLOBAL.md
@foundationDocs/HUs/F8 — Cross-cutting/US-F8-002-SUPORTE-FAQ.md
```

### Etapa 11 (Transversais — adicionar)

```
@foundationDocs/analysis/mvp_v2_solicitacoes_workflow_engine.md
@foundationDocs/analysis/endpoints_canonicos_presenca_eventos_v4.md
@agents/workflow-engine-specialist.md
@agents/security-engineer.md
@agents/devops-engineer.md
@foundationDocs/requisitos/por-fase/RF-F0-publico.md
@foundationDocs/requisitos/por-fase/RF-F1-aluno.md
@foundationDocs/requisitos/por-fase/RF-F3-professor.md
@foundationDocs/requisitos/por-fase/RF-F5-secretaria.md
@foundationDocs/requisitos/por-fase/RF-F7-admin.md
```

### Etapa 12 (Revisão — adicionar todos os arquivos gerados)

```
@foundationDocs/requisitos/02-requisitos-nao-funcionais.md
@foundationDocs/requisitos/por-fase/RF-F0-publico.md
@foundationDocs/requisitos/por-fase/RF-F1-aluno.md
@foundationDocs/requisitos/por-fase/RF-F2-egresso.md
@foundationDocs/requisitos/por-fase/RF-F3-professor.md
@foundationDocs/requisitos/por-fase/RF-F4-comissoes.md
@foundationDocs/requisitos/por-fase/RF-F5-secretaria.md
@foundationDocs/requisitos/por-fase/RF-F6-coordenacao.md
@foundationDocs/requisitos/por-fase/RF-F7-admin.md
@foundationDocs/requisitos/por-fase/RF-F8-cross-cutting.md
@foundationDocs/requisitos/por-fase/RF-TR-transversais.md
```

---

*Última atualização: 2026-06-23 — Etapa 10 concluída*
