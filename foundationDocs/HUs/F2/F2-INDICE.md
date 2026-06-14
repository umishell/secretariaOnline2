# Histórias de Usuário — Fase F2 (Egresso)

**Projeto:** SecretariaOnline2 — UFPR SEPT  
**Versão:** 1.0  
**Data:** 2026-06-14  
**Autor:** TCC — gerado a partir de `telasFigma/telas2/`, `foundationDocs/analysis/telas.md` §4 e `fluxos_por_perfil.md` §3

---

## Visão geral da fase

O fluxo F2 cobre o perfil **Egresso** — ex-alunos que concluíram o curso e tiveram o diploma registrado pela secretaria. É uma fase **deliberadamente compacta**: o egresso tem acesso read-only ao seu histórico e pode baixar/reemitir certificados e diplomas, mas não pode abrir novas solicitações, registrar atividades ou confirmar presenças.

O perfil `EGRESSO` é concedido automaticamente quando a secretaria executa F5.11 (registrar diploma), que revoga as capabilities de aluno (`dashboard.view_own`, `request.open`, etc.) e concede `alumni.view_own`.

---

## Telas exclusivas de F2

| Tela | Rota | Descrição |
|------|------|-----------|
| F2.1 | `/egresso/inicio` | Dashboard read-only com histórico, certificados, diploma, colação |

---

## Telas reaproveitadas de outras fases

O egresso acessa diretamente as mesmas rotas de outras fases, com as mesmas capabilities que ainda existem para ele:

| Rota | História de origem | Acesso egresso |
|------|--------------------|---------------|
| `/perfil` | [US-F1-003](../F1/US-F1-003-PERFIL.md) | Atualizar e-mail pessoal, foto |
| `/perfil/seguranca` | [US-F1-003](../F1/US-F1-003-PERFIL.md) | Trocar senha, gerenciar sessões |
| `/perfil/notificacoes` | [US-F1-003](../F1/US-F1-003-PERFIL.md) | Opt-in/out de notificações |
| `/certificados` | [US-F1-010](../F1/US-F1-010-CERTIFICADOS.md) | Ver e baixar certificados (`certificate.view_own`) |
| `/publico/verificar-protocolo` | [US-F0-006](../F0/US-F0-006-VERIFICAR-PROTOCOLO.md) | Verificação pública |
| `/publico/verificar-certificado` | [US-F0-007](../F0/US-F0-007-VERIFICAR-CERTIFICADO.md) | Verificação pública |

---

## Épicos

| Épico | Escopo | Telas |
|-------|--------|-------|
| `EGRESSO-DASH` | Dashboard e ações do egresso | F2.1 |

---

## Histórias desta fase

| ID | Épico | Telas | Título curto | Prioridade | Frames Figma | Arquivo |
|----|-------|-------|-------------|------------|--------------|---------|
| US-F2-001 | EGRESSO-DASH | F2.1 | Dashboard do egresso e reemissão de certificados | P2 | [Default/Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=166-13644) · [Skeleton](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=166-13997) · [Empty](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=166-14115) · [Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=298-14168) | [US-F2-001-DASHBOARD-EGRESSO.md](./US-F2-001-DASHBOARD-EGRESSO.md) |

---

## Mapa de frames Figma (F2)

Página: [Telas / F2 — Egresso](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=132-18387)

| Tela | Frame | Variante | Plataforma | Node |
|------|-------|----------|------------|------|
| F2.1 | Dashboard Egresso | Default | Desktop | [166-13644](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=166-13644) |
| F2.1 | Dashboard Egresso | Skeleton | Desktop | [166-13997](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=166-13997) |
| F2.1 | Dashboard Egresso | Empty | Desktop | [166-14115](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=166-14115) |
| F2.1 | Dashboard Egresso | Default | Mobile | [298-14168](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=298-14168) |

---

## Referências globais

| Recurso | Localização |
|---------|------------|
| Spec de tela | `telasFigma/telas2/F2.1-egresso-inicio.md` |
| Fluxo do egresso | `foundationDocs/analysis/fluxos_por_perfil.md` §3 |
| Mapa de rotas | `foundationDocs/analysis/telas.md` §4 |
| Página Figma F2 | [Telas / F2 — Egresso](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=132-18387) |
| Trigger de transição | Coberto em F5.11 (registrar diploma — fase secretaria) |
