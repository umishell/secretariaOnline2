# Histórias de Usuário — Fase F0 (Público / Não Autenticado)

**Projeto:** SecretariaOnline2 — UFPR SEPT  
**Versão:** 1.0  
**Data:** 2026-06-14  
**Autor:** TCC — gerado a partir de `telasFigma/telas0/`, `foundationDocs/analysis/telas.md` e `fluxos_por_perfil.md`

---

## Visão geral da fase

O fluxo F0 cobre todas as rotas acessíveis **sem autenticação**: login, recuperação de credenciais, páginas institucionais e verificadores públicos anti-fraude. Nenhuma dessas telas exige `authority` do Spring Security; todas usam o shell `AuthLayout` ou `PublicLayout`.

---

## Épicos

| Épico | Escopo | Telas |
|-------|--------|-------|
| `AUTH-LOGIN` | Autenticação do usuário | F0.1 |
| `AUTH-RESET` | Recuperação e redefinição de senha | F0.2, F0.3 |
| `PUB-STATIC` | Páginas públicas informativas e de erro | F0.4, F0.5 |
| `PUB-VERIFY` | Verificadores públicos anti-fraude | F0.6, F0.7 |

---

## Histórias desta fase

| ID | Épico | Tela | Título curto | Prioridade | Arquivo |
|----|-------|------|-------------|------------|---------|
| US-F0-001 | AUTH-LOGIN | F0.1 | Autenticação de usuário (login) | **P0 — MVP v1** | [US-F0-001-LOGIN.md](./US-F0-001-LOGIN.md) |
| US-F0-002 | AUTH-RESET | F0.2 | Solicitar link de recuperação de senha | P1 | [US-F0-002-RECUPERAR-SENHA.md](./US-F0-002-RECUPERAR-SENHA.md) |
| US-F0-003 | AUTH-RESET | F0.3 | Definir nova senha via token | P1 | [US-F0-003-NOVA-SENHA.md](./US-F0-003-NOVA-SENHA.md) |
| US-F0-004 | PUB-STATIC | F0.4 | Visualizar informações de contato da secretaria | P2 | [US-F0-004-CONTATO.md](./US-F0-004-CONTATO.md) |
| US-F0-005 | PUB-STATIC | F0.5 | Exibir página de erro amigável | P1 | [US-F0-005-ERRO.md](./US-F0-005-ERRO.md) |
| US-F0-006 | PUB-VERIFY | F0.6 | Verificar autenticidade de protocolo PDF | P2 | [US-F0-006-VERIFICAR-PROTOCOLO.md](./US-F0-006-VERIFICAR-PROTOCOLO.md) |
| US-F0-007 | PUB-VERIFY | F0.7 | Verificar autenticidade de certificado digital | P2 | [US-F0-007-VERIFICAR-CERTIFICADO.md](./US-F0-007-VERIFICAR-CERTIFICADO.md) |

---

## Referências globais

| Recurso | Localização |
|---------|------------|
| Specs de tela (F0) | `telasFigma/telas0/F0.x-*.md` |
| Fluxos de autenticação | `foundationDocs/analysis/fluxos_por_perfil.md` §1 |
| Mapa de rotas | `foundationDocs/analysis/telas.md` §2 |
| Frames Figma | [Telas / F0 — Público](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=18-152) |
| Convenções de tela | `telasFigma/00-CONVENCOES.md` |

---

## Critério de "Pronto" global (DoD) para F0

- [ ] Fluxo validado no protótipo Figma (frames linkados em cada HU)
- [ ] Testes unitários cobrindo Use Cases do módulo `iam` ≥ 80%
- [ ] Teste de integração ponta a ponta para fluxo principal de cada HU
- [ ] Contrato OpenAPI publicado (`/v3/api-docs`) antes da implementação frontend
- [ ] Nenhum hardcode de cor/espaçamento nos componentes React (apenas tokens CSS)
- [ ] Mensagens de erro validadas contra padrão RFC 7807 (Problem Details)
- [ ] Acessibilidade WCAG 2.1 AA validada (contraste, foco, `aria-live`)
