# Mapa de Telas — SecretariaOnline2 (v4.1 — presença configurável em eventos formativos)

> **Documento complementar** à seção 6.2 de `analise_arquitetural_secretariaonline2.md`.
> A **v4.1** estende o submódulo de **presença em eventos que geram horas formativas**: o professor define **modo de confirmação** (QR único, QR duplo início/fim, senha ou PIN único, senha ou PIN duplo) e **janelas de tempo** em que o aluno pode validar (ex.: dia inteiro ou duas janelas curtas no início e no fim). O evento segue **agenda** (`início` / `fim` planejados); estados visíveis incluem **Agendado**, **Em andamento** e **Concluído**. **Sem** geofence, *trust score* ou gestão de aula regular no app (SIGA / UFPR Virtual). Detalhes de API: `endpoints_canonicos_presenca_eventos_v4.md` (canônico v4.1).
> **Total: ~48 rotas** (pequeno acréscimo por telas de gestão de eventos no professor). O perfil **Professor** não possui CRUD de aulas diárias, diário de classe ou chamada visual de disciplinas — essa gestão permanece nos sistemas institucionais (SIGA / UFPR Virtual).

---

## 1. Convenções

- **Rota** segue padrão React Router 6 / Expo Router. Entre `:` é parâmetro.
- **Capability** é a `authority` exigida pelo backend (Spring Security `@PreAuthorize`); a UI **não conhece perfis** — apenas confere `_links` HATEOAS na resposta da API.
- **Plataforma**: Web (frontend-web), Mobile (mobile RN/Expo), Ambas (responsivo + nativo). Algumas rotas são exclusivas de uma plataforma — anotadas explicitamente.
- **Fonte de dados** indica os endpoints REST primários consumidos pela tela. Detalhes de payload OpenAPI estão fora do escopo deste mapa.
- **Notas de UX**: pontos onde a tela difere do legado em usabilidade, performance ou segurança.

### Fluxos (agrupadores)

| Código | Fluxo | Audiência principal |
|---|---|---|
| **F0** | Público / não autenticado | Visitantes, links de email, verificadores externos |
| **F1** | Aluno (estudante ativo) | TIPO_USUARIO_ALUNO equivalente |
| **F2** | Egresso | TIPO_USUARIO_EGRESSO equivalente |
| **F3** | Professor | TIPO_USUARIO_PROFESSOR + COORDENADOR |
| **F4** | Comissões (CAAF, COE) | Subset de professores com `formative.review` / `internship.review` |
| **F5** | Secretaria | TIPO_USUARIO_SECRETARIO |
| **F6** | Coordenação | TIPO_USUARIO_COORDENADOR (capabilities aditivas) |
| **F7** | Admin / Plataforma | `system.admin` |
| **F8** | Cross-cutting | Disponível a todo logado (busca, perfil, suporte) |

---

## 2. F0 — Público / Não autenticado

### F0.1 `/login`

- **Propósito**: Autenticação central. Aceita email institucional, email pessoal cadastrado ou GRR.
- **Capability**: pública.
- **Plataforma**: ambas.
- **Fonte de dados**: `POST /auth/login` → `{accessToken, refreshToken, mustChangePassword?}`.
- **Componentes**: form (Zod + RHF) + link "Esqueci minha senha" + link "Contato" + link "Verificar protocolo/certificado público" (acessível sem login).
- **Estado**: redireciona para `/primeiro-acesso` se `mustChangePassword=true`; senão para `/inicio`.
- **Notas UX**: rate-limit cliente (debounce) + servidor (Bucket4j). Mensagens **genéricas** ("credenciais inválidas") para evitar enumeração.
- **Substitui**: [T01] `web/logarUsuario.jsp`. Diferenças do legado: Argon2id em vez de MD5; sem cookie JSESSIONID; CSRF via SameSite + token.

### F0.2 `/recuperar-senha`

- **Propósito**: Solicita link de redefinição.
- **Capability**: pública.
- **Plataforma**: ambas.
- **Fonte**: `POST /auth/forgot-password` (sempre 202 mesmo se email não existir — anti-enumeração).
- **Notas UX**: mensagem padrão "Se este email existir, enviaremos um link válido por 24h".
- **Substitui**: [T02].

### F0.3 `/nova-senha?token=`

- **Propósito**: Define nova senha a partir do JWT 1-uso recebido por email.
- **Capability**: pública (porém o JWT carrega `sub`).
- **Plataforma**: ambas.
- **Fonte**: `POST /auth/reset-password { token, novaSenha }`.
- **Validações**: força mínima (12 chars, complexidade), não pode reutilizar últimas 3 senhas.
- **Substitui**: [T03], [T04]. Diferenças: token é JWT assinado com `JTI` em blacklist após consumo (em vez de `Random.nextInt()` de 32 bits do legado).

### F0.4 `/contato`

- **Propósito**: Página institucional (endereço, telefone, mapa, horários).
- **Capability**: pública.
- **Plataforma**: web (no mobile, abre URL externa).
- **Substitui**: [T14] `web/contato.jsp` (RF53).

### F0.5 `/erro/:codigo`

- **Propósito**: Tela canônica de 401/403/404/500. Exibe mensagem amigável, ID do incidente para suporte, link para `/inicio` ou `/login`.
- **Capability**: pública.
- **Plataforma**: ambas.
- **Substitui**: [T11] `menuErrado.jsp` + uso indevido de [T155] `exibirErro.jsp`.

### F0.6 `/publico/verificar-protocolo/:id`

- **Propósito**: Verificador externo de protocolo PDF gerado pela aplicação. Mostra: número, aluno (parcial), tipo, datas, status, hash do PDF, e atesta que o número existe e bate com o conteúdo enviado por upload reverso (drag-and-drop opcional).
- **Capability**: pública.
- **Plataforma**: web.
- **Fonte**: `GET /publico/protocolos/{id}/verificacao`.
- **Substitui**: [T144], [T145], [T146], [T147] (todas as variantes de protocolo + impressão).

### F0.7 `/publico/verificar-certificado/:hash`

- **Propósito**: Verifica certificado emitido pelo sistema (anti-fraude por nascimento, seção 11). Mostra dados, hash SHA-256 e validação da assinatura ED25519 com a JWKS pública (`/.well-known/jwks.json`).
- **Capability**: pública.
- **Plataforma**: web.
- **Origem**: novo (legado não tinha certificado auditável).

---

## 3. F1 — Aluno

### F1.1 `/inicio` (dashboard)

- **Propósito**: Visão única do estudante: pendências de ação (solicitação aguardando ajuste, formativa rejeitada, ciência de atendimento), eventos com **janela de presença aberta** (conforme `_links` HATEOAS), último parecer recebido, indicadores de horas formativas, próximos prazos do calendário acadêmico.
- **Capability**: `dashboard.view_own`.
- **Plataforma**: ambas.
- **Fonte**: `GET /bff/dashboard/aluno` (BFF agrega 5–6 chamadas em uma para reduzir round-trips no mobile).
- **Notas UX**: cards expansíveis; badge no Hub mostra avisos não lidos; pull-to-refresh no mobile.
- **Substitui**: [T08] `home.jsp`, [T09] `homeOld.jsp`.

### F1.2 `/primeiro-acesso`

- **Propósito**: Forçar troca da senha inicial e aceite explícito da política de privacidade (LGPD). Bloqueante: nenhuma outra rota acessível enquanto `senha_alterada=false`.
- **Capability**: `auth.first_access` (concedida ao usuário com flag `mustChangePassword`).
- **Plataforma**: ambas.
- **Fonte**: `POST /auth/first-access {novaSenha, aceiteLgpd}`.
- **Substitui**: [T06] `novaSenhaAluno.jsp`. Diferenças: no legado, senha inicial era CPF; aqui é gerada aleatoriamente e enviada por canal seguro.

### F1.3 `/perfil`

- **Propósito**: Dados pessoais não-acadêmicos (foto, telefone, email pessoal, nome social, identidade de gênero opcional).
- **Capability**: `user.update_own_profile`.
- **Plataforma**: ambas.
- **Fonte**: `GET /me`, `PATCH /me`.
- **Substitui**: [T05] (parte), [T119] (visão do próprio usuário).

### F1.4 `/perfil/seguranca`

- **Propósito**: Trocar senha; visualizar/encerrar **sessões ativas** (refresh tokens válidos); espaço para futuro MFA.
- **Capability**: `user.update_own_password`.
- **Plataforma**: ambas.
- **Fonte**: `POST /me/password`, `GET /me/sessions`, `DELETE /me/sessions/:id`.
- **Substitui**: [T05] (alterar senha). **Adiciona** sessões — não existia no legado (que sequer tinha conceito explícito de refresh token).

### F1.5 `/perfil/notificacoes`

- **Propósito**: Preferências granulares por canal e prioridade. Permite definir DND (do-not-disturb) entre faixas horárias e digest (1 email por dia).
- **Capability**: `user.update_own_preferences`.
- **Plataforma**: ambas.
- **Fonte**: `GET/PUT /me/notification-preferences`.
- **Substitui**: nada — **lacuna L04** corrigida (`notification_preference` existia no schema mas não tinha UI no mapa original).

### F1.6 `/comunicacao`

- **Propósito**: Hub unificado (notícias, avisos institucionais, comunicados de professor, oportunidades). Filtros por tipo/curso/lido. Marca como lido. Possui **Inbox** (atendimentos pendentes de ciência + transições críticas de solicitações que pedem ação do aluno).
- **Capability**: `communication.read`.
- **Plataforma**: ambas.
- **Fonte**: `GET /communications?audience=me&status=...`.
- **Substitui**: `mensagem` legado, [T133] `listarNotificacoes.jsp`.

### F1.7 `/solicitacoes`

- **Propósito**: Lista das **próprias** solicitações com filtros (estado, tipo, curso, ano), busca por palavra do título, ordenação por prazo. SLA visualmente destacado.
- **Capability**: `request.view_own`.
- **Plataforma**: ambas.
- **Fonte**: `GET /requests?solicitante=me`.
- **Substitui**: [T17]–[T20] (escopo aluno).

### F1.8 `/solicitacoes/nova`

- **Propósito**: **Wizard genérico** dirigido por `form_schema` do `RequestType`. 3 passos: (1) escolher tipo + escopo (curso/disciplina), (2) preencher formulário dinâmico + anexar arquivos, (3) revisar + confirmar. Suporta rascunho local (PWA/AsyncStorage no mobile) e retomada.
- **Capability**: `request.open`.
- **Plataforma**: ambas.
- **Fonte**: `GET /request-types/{code}` para schema + workflow inicial; `POST /requests` para abrir.
- **Substitui**: [T15] + 19 telas `novaSol*` ([T21], [T26], [T29], [T33], [T36], [T39], [T42], [T46], [T49], [T52]/[T53], [T56]/[T57]/[T58], [T61], [T64], [T67], [T70], [T73]/[T74], [T77], [T80], [T83]) e telas auxiliares "Efetivar" ([T43], [T74]).
- **Notas UX**: validações Zod alinhadas ao JSON Schema; upload com pré-cálculo de SHA-256 no cliente para evitar re-upload de duplicatas.

### F1.9 `/solicitacoes/:id`

- **Propósito**: Detalhe do pedido: dados estruturados, anexos, **timeline** de eventos (`request_event`), status, prazo, ações disponíveis via `_links` HATEOAS, botão "Gerar protocolo PDF" (com QR de verificação pública).
- **Capability**: `request.view_own` (escopo: solicitante = self) **OU** `request.deliberate` (deliberadores).
- **Plataforma**: ambas.
- **Fonte**: `GET /requests/{id}`.
- **Substitui**: 19 telas `consultarSol*` + [T144]/[T145]/[T146]/[T147].

### F1.10 `/formativas`

- **Propósito**: Resumo das atividades formativas do aluno: cadastradas, em revisão, aprovadas, rejeitadas. Soma horas validadas vs requeridas pelo curso.
- **Capability**: `formative.view_own`.
- **Plataforma**: ambas.
- **Fonte**: `GET /formative-entries?aluno=me`.
- **Substitui**: [T96] `administrarFormativasAluno.jsp`.

### F1.11 `/formativas/nova`

- **Propósito**: Submissão de atividade. O aluno escolhe a `formative_activity` aplicável ao seu curso, declara horas, anexa comprovante (PDF/imagem). Se a atividade veio de **evento interno com presença validada**, o sistema pré-preenche horas e dispensa upload de comprovante (seção 11.5).
- **Capability**: `formative.submit`.
- **Plataforma**: ambas.
- **Fonte**: `POST /formative-entries`.
- **Substitui**: parte de [T96] (botão "incluir") + [T146]/[T147].

### F1.12 `/formativas/:id`

- **Propósito**: Detalhe da entrada formativa, parecer da CAAF, comprovante anexado, certificado vinculado (se houver).
- **Capability**: `formative.view_own`.
- **Plataforma**: ambas.
- **Fonte**: `GET /formative-entries/{id}`.

### F1.13 `/estagios`

- **Propósito**: Lista dos estágios ativos/históricos do aluno. Cada item mostra empresa, supervisor, vigência, situação, próximas pendências (relatório parcial, TCE, plano de atividades).
- **Capability**: `internship.view_own`.
- **Plataforma**: ambas.
- **Fonte**: `GET /internships?aluno=me`.
- **Substitui**: [T88] `administrarEstagiosAluno.jsp`.

### F1.14 `/estagios/:id`

- **Propósito**: Detalhe + upload de documentos (TCE, relatório parcial, relatório final, prorrogação) + pareceres do COE.
- **Capability**: `internship.view_own` + `internship.upload_doc_own`.
- **Plataforma**: ambas.
- **Fonte**: `GET /internships/{id}`, `POST /internships/{id}/documents`.
- **Substitui**: [T86], [T87] (visão aluno).

### F1.15 `/tccs`

- **Propósito**: Página do TCC do aluno (1 ativo por vez normalmente). Mostra equipe, banca, datas-chave, situação.
- **Capability**: `tcc.view_own`.
- **Plataforma**: ambas.
- **Fonte**: `GET /tccs?aluno=me`.
- **Substitui**: [T107] (escopo aluno).

### F1.16 `/tccs/:id`

- **Propósito**: Detalhe + upload do arquivo final + agendamento de defesa (se aluno tem capability) + chat com orientador (futuro).
- **Capability**: `tcc.view_own` + `tcc.upload_final` (se aluno é o autor).
- **Plataforma**: ambas.
- **Fonte**: `GET /tccs/{id}`, `POST /tccs/{id}/submission`.
- **Substitui**: [T108]–[T111].

### F1.17 `/eventos`

- **Propósito**: **Tela principal de eventos do aluno** — tabela **somente leitura** dos eventos cadastrados pelos docentes (e demais criadores autorizados), com colunas mínimas: título, período (**agenda**), **estado do evento** (**Agendado** / **Em andamento** / **Concluído**), organizador, **horas formativas creditadas** (valor definido pelo professor, pode diferir da duração real do evento) e indicador da **situação da presença** do aluno (pendente / parcial / completa / inelegível), conforme modo configurado.
- **Interação**: abrir **modal** (ou painel) com nome, descrição e demais metadados. Quando o evento está **Em andamento** e existe janela de validação ativa, **abaixo da descrição** surge **dinamicamente** o **componente de validação** cujo layout depende do `attendanceMode` do evento (campo PIN/senha, leitura de QR via redirecionamento web, etc.). Se o modo usar **QR** e o cliente não for web, o fluxo pode **redirecionar** para a rota web `/eventos/:id/presenca` com o mesmo contexto.
- **Não autenticado**: se o aluno acessar link de evento/presença sem sessão, exibir **notificação** com botão **Entrar**; após login bem-sucedido, **retorno automático** à mesma URL de evento/presença.
- **Capability**: `attendance.view_open` (ou equivalente de leitura de catálogo de eventos elegíveis).
- **Plataforma**: ambas.
- **Fonte**: `GET /events?audience=me`; `GET /events/{id}` para detalhe; `GET /events/{id}/attendance/session` quando for necessário compor ações (`_links` HATEOAS por modo e fase).
- **Origem**: nova (não havia equivalente no legado).

### F1.18 `/eventos/:id/presenca`

- **Propósito**: Rota **web-first** para conclusão da validação quando o fluxo exige página dedicada (ex.: retorno pós-login, **QR** ou deep link). Conteúdo **dirigido por HATEOAS** e pelo `attendanceMode`: pode ser formulário PIN/senha (uma ou duas fases), instruções para QR, temporizadores conforme **janelas configuradas** no evento (não mais fixas em 10 min como única regra de produto).
- **Capability**: `attendance.check_in`.
- **Plataforma**: web (preferencial para QR); mobile pode reutilizar WebView ou redirecionar ao browser externo conforme política de UX.
- **Fonte**: `GET /events/{id}/attendance/session`; mutações canônicas em `endpoints_canonicos_presenca_eventos_v4.md` (§5–§8).
- **Regras UX (UI cega)**:
  - Fora da janela configurada: **403**; limpar campos sensíveis; mensagem genérica.
  - Modos **duplos**: quem perde a primeira fase inelegível para a segunda, salvo política explícita no backend.
- **Integridade**: onde aplicável, manter **`deviceUuid`** e política **um vínculo de presença por dispositivo por evento** (mitigação a compartilhamento indevido de aparelho).
- **Origem**: evolução da rota antiga `.../checkin` (v2/v3).

### F1.19 `/certificados`

- **Propósito**: Certificados emitidos para o aluno (presença validada, formativa aprovada, conclusão). Cada certificado tem download do PDF com QR de verificação pública.
- **Capability**: `certificate.view_own`.
- **Plataforma**: ambas.
- **Fonte**: `GET /certificates?beneficiario=me`.
- **Origem**: nova (substitui upload de PDFs do legado por certificado nascido auditado).

### F1.20 `/meus-atendimentos`

- **Propósito**: Lista de atendimentos registrados pela secretaria com necessidade de ciência. Botão "Estou ciente" pulsa enquanto pendente.
- **Capability**: `service_record.view_own`.
- **Plataforma**: ambas.
- **Fonte**: `GET /service-records?aluno=me`, `POST /service-records/{id}/acknowledge`.
- **Substitui**: parte da visão aluno em [T134]/[T135] (RF42).

---

## 4. F2 — Egresso

### F2.1 `/egresso/inicio`

- **Propósito**: Dashboard read-only para ex-alunos: histórico final, certificados, diploma, dados de colação. Permite reemissão de certificados (regenera PDF; não re-emite chave de assinatura).
- **Capability**: `alumni.view_own`.
- **Plataforma**: ambas.
- **Fonte**: `GET /alumni/me`.
- **Origem**: nova — preenche o vácuo da Árvore 5 do legado (egresso ficava sem UI).

> Egresso reaproveita: `/perfil`, `/perfil/seguranca`, `/certificados`, `/publico/verificar-*`.

---

## 5. F3 — Professor

### F3.1 `/inicio` (visão professor)

- **Propósito**: Fila pessoal — solicitações para deliberar, **atalhos para revisão de formativas somente se o docente for membro CAAF** (`formative.review`), estágios sob orientação/COE, TCCs orientando ou em banca, **eventos em que atua como organizador** e atalhos para **gestão de eventos** (`event.manage`). Indicadores de SLA pessoal.
- **Capability**: `dashboard.view_self_professor`.
- **Plataforma**: ambas.
- **Fonte**: `GET /bff/dashboard/professor`.
- **Substitui**: [T08] (perfil PRF/COO).

### F3.2 `/professor/eventos`, `/professor/eventos/:id`, `/professor/eventos/:id/operacao` (gestão e operação v4.1)

- **Propósito**:
  - **`/professor/eventos`**: **CRUD e listagem** de eventos de presença para quem possui **`event.manage`** (professor, secretaria e admin — ver matriz FGAC). Filtro **`onlyMine=true`** (query canônica) restringe aos eventos em que o usuário é organizador; sem o filtro, lista também eventos de **outros** professores — nestes, ações **editar/excluir** ficam desabilitadas (**somente leitura**). Campos de cadastro incluem: agenda (`inicioEm`, `fimEm`), público/curso, **`chCreditadas`** (horas formativas a creditar, independente da duração civil do evento), vínculo opcional com `formative_activity`, **`attendanceMode`** (QR único, QR duplo, PIN/senha único, PIN/senha duplo) e configuração de **janelas de validação** (ex.: intervalo único longo ou duas sub-janelas).
  - **`/professor/eventos/:id`**: formulário de **edição** se o usuário for organizador ou tiver permissão institucional de mutação; caso contrário, **visualização**.
  - **`/professor/eventos/:id/operacao`**: painel **no dia do evento** para o anfitrião (`event.host`) ou quem tenha `event.manage`: exibe estado **Agendado / Em andamento / Concluído**, aciona abertura de janelas conforme o modo (PIN, QR, etc.), contadores e leitura de inelegibilidades. Equivalente operacional a **F5.15** para a secretaria.
- **Capability**: **`event.manage`** (entradas de menu e CRUD); **`event.host`** (operação ao vivo do próprio evento ou delegado).
- **Plataforma**: web (preferencial na sala) + mobile onde fizer sentido.
- **Fonte**: `GET/POST/PATCH/DELETE /events` conforme regras de escopo; `GET /events?host=me` ou `GET /events?managedBy=me`; endpoints de sessão/janelas em `endpoints_canonicos_presenca_eventos_v4.md`.
- **Origem**: evolução do módulo F3.2 (v4.0 → v4.1 configurável).

**Alias de rota (legado no mapa):** `/professor/eventos/:id/chamadas` pode redirecionar para `/professor/eventos/:id/operacao`.

### F3.3 `/solicitacoes?to=me`

- **Propósito**: Lista de solicitações que **eu** posso ou devo deliberar (filtro de capability + assignment). Permite ações em lote.
- **Capability**: `request.deliberate`.
- **Plataforma**: ambas.
- **Fonte**: `GET /requests?canDeliberate=true`.
- **Substitui**: deep-links via email ([T24], [T31], [T35], [T55], [T60], [T63], [T66], [T69], [T72], [T76], [T79], [T82], [T85] entradas de email) + Ramo H da árvore do professor.

### F3.4 `/solicitacoes/:id/deliberar?token=`

- **Propósito**: Tela de deliberação (acessível direta via deep-link com JWT 1-uso ou navegando pela fila). Apresenta os dados, anexos, parecer prévio (se houver), opções via `_links` (Deferir, Indeferir, Solicitar ajustes, Encaminhar). O JWT do deep-link **só abre a tela**; ações de mutação exigem sessão autenticada.
- **Capability**: `request.deliberate` (granular pelo `request_type.required_auth`).
- **Plataforma**: ambas.
- **Fonte**: `GET /requests/{id}` (com `token` query string para abrir sem login prévio + auto-redireciona para login após validar JTI), `POST /requests/{id}/transitions`.
- **Substitui**: 19 telas `deliberarSol*Professor` + 14 servlets `*EntradaEmail`.

### F3.5 `/formativas?to=me` (somente membros CAAF)

- **Propósito**: **Apenas professores alocados à CAAF** (papel/comissão com `formative.review` **e** vínculo institucional à comissão) enxergam esta rota e a fila de revisão. Professores **fora** da CAAF **não** acessam esta tela (card no dashboard também não aparece). Lista de atividades aguardando avaliação; avaliação em lote quando aplicável (seção 11.8).
- **Capability**: `formative.review` **+** flag/escopo `commission.caaf_member` (nome exato a fixar no IAM; a UI só oculta se a API negar).
- **Plataforma**: web (preferência) + mobile.
- **Fonte**: `GET /formative-entries?canReview=true`.
- **Substitui**: [T102]–[T105].

### F3.6 `/estagios?to=me` (orientador / COE)

- **Propósito**: Estágios sob orientação ou nos quais é membro COE. Permite emitir parecer por documento.
- **Capability**: `internship.review` (subset COE) ou `internship.supervise` (orientador).
- **Plataforma**: ambas.
- **Fonte**: `GET /internships?canReview=true`.
- **Substitui**: [T90], deep-link `administrarEstagiosAlunoEntradaEmail`.

### F3.7 `/tccs?to=me`

- **Propósito**: TCCs em que o professor é orientador ou banca. Permite registrar nota/parecer.
- **Capability**: `tcc.supervise` ou `tcc.examine`.
- **Plataforma**: ambas.
- **Fonte**: `GET /tccs?canReview=true`.
- **Substitui**: visão professor de [T107]–[T110].

### F3.8 `/comunicacao/publicar`

- **Propósito**: Compor comunicado para os alunos da turma/disciplina. Editor Markdown + preview + audiência (turma, curso, todos), prioridade, expiração.
- **Capability**: `communication.publish_class`.
- **Plataforma**: web.
- **Fonte**: `POST /communications`.
- **Origem**: nova — formaliza algo que no legado era email manual.

---

## 6. F4 — Comissões (CAAF, COE)

### F4.1 `/comissoes/caaf`

- **Propósito**: Visão consolidada para a comissão (lote de revisão, atribuição interna entre membros, indicadores). Abre cada item em `/formativas/:id`.
- **Capability**: `formative.review` (vinculada a `usuario_role` com escopo do curso).
- **Plataforma**: web.
- **Fonte**: `GET /commissions/caaf/dashboard`.
- **Substitui**: [T101] (alocar membros) + [T102] (visão).

### F4.2 `/comissoes/coe`

- **Propósito**: Mesma ideia para estágios. Inclui alocação de membros COE para estágios específicos (delegação interna).
- **Capability**: `internship.review`.
- **Plataforma**: web.
- **Fonte**: `GET /commissions/coe/dashboard`.
- **Substitui**: [T90], parte de [T89].

---

## 7. F5 — Secretaria

### F5.1 `/inicio` (visão secretaria)

- **Propósito**: Dashboard com filas de deliberação, contadores por estado e curso, alertas de SLA, atalhos para CRUDs frequentes, agenda do dia (eventos, atendimentos marcados).
- **Capability**: `dashboard.view_secretary`.
- **Plataforma**: web.
- **Fonte**: `GET /bff/dashboard/secretary`.
- **Substitui**: [T08] (perfil SEC).

### F5.2 `/solicitacoes` (fila central)

- **Propósito**: A "consulta geral" do legado, mas como **fila viva** — filtros por estado, tipo, curso, atraso, deliberador atribuído. Persistência de filtros por usuário. Ações em lote (encaminhar, atribuir, exportar). Ações em uma linha via `_links`.
- **Capability**: `request.view_curso` (escopo cursos vinculados).
- **Plataforma**: web.
- **Fonte**: `GET /requests` com query params; suporta export CSV.
- **Substitui**: [T17] `consultarGeralSolicitacao.jsp`, [T18] `consultarSolicitacoesTodas.jsp`, [T19]/[T20] `consultarSolicitacoesConcluidas*.jsp`.

### F5.3 `/solicitacoes/nova` (interna)

- **Propósito**: Mesmo wizard de F1.8 mas com capability extra: pode selecionar o **aluno** em nome de quem se abre a solicitação.
- **Capability**: `request.internal_open` (a UI mostra um campo extra "Em nome de" baseado na capability).
- **Plataforma**: web.
- **Fonte**: `POST /requests {onBehalfOf: alunoId}`.
- **Substitui**: [T16] `novaSolicitacaoInterna.jsp`. **Não cria duas telas** — é a mesma do aluno com 1 campo a mais via FGAC.

### F5.4 `/solicitacoes/:id/deliberar`

- **Propósito**: Mesma rota de F3.3 quando alcançada pela secretaria (sem token de email). Ações disponíveis dependem do `request_type.required_auth` × authorities do usuário.
- **Capability**: `request.deliberate` (subset secretaria).
- **Plataforma**: web.
- **Substitui**: 26 telas `deliberarSol*Secretario` (e variantes) + roteador `deliberarSolicitacao`.

### F5.5 `/secretaria/atrasados`

- **Propósito**: Filtro persistente sobre `/solicitacoes` que mostra apenas itens com `prazo_em < now AND concluded_at IS NULL`. Listagem consolidada para a equipe acompanhar SLA.
- **Capability**: `request.view_curso`.
- **Plataforma**: web.
- **Fonte**: `GET /requests?slaBreached=true`.
- **Substitui**: [T133] `listarNotificacoes.jsp`. **Lacuna L08** corrigida.

### F5.6 `/secretaria/alunos`

- **Propósito**: CRUD + busca avançada (GIN trigram em `nome`, equality em `grr`, `cpf`). Permite ações: editar, resetar senha (gera link 1-uso por email), atribuir/desfazer matrícula, vincular curso.
- **Capability**: `user.manage_students`.
- **Plataforma**: web.
- **Fonte**: `/students` CRUD + `POST /students/{id}/password-reset`.
- **Substitui**: [T120]–[T123].

### F5.7 `/secretaria/cursos`

- **Propósito**: CRUD de cursos + alocação de secretários (subform).
- **Capability**: `course.manage`.
- **Plataforma**: web.
- **Fonte**: `/courses` CRUD + `PUT /courses/{id}/secretaries`.
- **Substitui**: [T125], [T126].

### F5.8 `/secretaria/disciplinas`

- **Propósito**: CRUD com filtros (curso, período, ativa). Permite arrastar para reordenar dentro do curso.
- **Capability**: `subject.manage`.
- **Plataforma**: web.
- **Substitui**: [T127]–[T129].

### F5.9 `/secretaria/calendarios`

- **Propósito**: CRUD de períodos letivos e eventos do calendário acadêmico. Filtros por ano e tipo (15/18 semanas mantidos como property).
- **Capability**: `calendar.manage`.
- **Plataforma**: web.
- **Substitui**: [T136]–[T138].

### F5.10 `/secretaria/egressos`

- **Propósito**: Lista de formados, com filtros por ano, curso, presença em colação. Exportação CSV.
- **Capability**: `alumni.list`.
- **Plataforma**: web.
- **Substitui**: [T124].

### F5.11 `/secretaria/diplomas`

- **Propósito**: Registrar colação de grau (alunos elegíveis por curso/turma) e marcar entrega física do diploma. Transiciona o usuário para perfil `EGRESSO` automaticamente.
- **Capability**: `diploma.register`.
- **Plataforma**: web.
- **Fonte**: `POST /graduations`, `POST /graduations/{id}/diploma-delivery`.
- **Substitui**: [T112], [T113]. **Lacuna L05** corrigida.

### F5.12 `/secretaria/autorizacoes-imagem`

- **Propósito**: Aprovação/rejeição em massa de termos de autorização. Como os termos são tratados como `RequestType=AUTORIZACAO_IMAGEM`, esta tela é um **filtro persistente sobre `/solicitacoes`** (DRY) — mas com UI compactada para revisão em lote.
- **Capability**: `image_authorization.review`.
- **Plataforma**: web.
- **Fonte**: `GET /requests?type=AUTORIZACAO_IMAGEM`.
- **Substitui**: [T114]–[T116]. **Lacuna L06** corrigida.

### F5.13 `/secretaria/atendimentos`

- **Propósito**: Registrar atendimento ao aluno (assunto, resposta, anexo opcional). Quando salvo, dispara `outbox_event` para Hub (notifica aluno em F1.20).
- **Capability**: `service_record.create`.
- **Plataforma**: web.
- **Substitui**: [T134], [T135].

### F5.14 `/secretaria/eventos`

- **Propósito**: Mesmo **CRUD institucional** descrito em **F3.2** (`/professor/eventos`), reutilizando componentes e contratos (`/events`). Secretaria vê eventos conforme escopo de cursos; pode listar todos ou filtrar por organizador. Eventos de terceiros: **somente leitura** se a política não permitir edição cruzada.
- **Capability**: `event.manage`.
- **Plataforma**: web.
- **Fonte**: `/events` CRUD + mesmas queries auxiliares.
- **Origem**: nova. **Lacuna L07** corrigida.

### F5.15 `/secretaria/eventos/:id/operacao`

- **Propósito**: Painel operacional no dia do evento — **paridade funcional** com `/professor/eventos/:id/operacao`: estados **Agendado / Em andamento / Concluído**, abertura de janelas conforme **modo** e **durações configuradas**, exibição de QR/PIN conforme política, lista ao vivo e inelegibilidades. Countdown reflete a **janela ativa**, não um fixo de 10 min obrigatório.
- **Capability**: `event.host` ou `event.manage` (conforme política institucional).
- **Plataforma**: web.
- **Fonte**: endpoints canônicos de presença v4.1 (`endpoints_canonicos_presenca_eventos_v4.md`).
- **Origem**: substitui a rota legada `.../qr` (v2/v3).

### F5.16 `/secretaria/importacoes`

- **Propósito**: Tela única para importar planilhas (alunos, disciplinas, usuários, alocação de professor). Wizard: baixar modelo → enviar → preview com validação por linha → confirmar → relatório.
- **Capability**: `import.run`.
- **Plataforma**: web.
- **Fonte**: `POST /imports/{kind}` (multipart) + `GET /imports/{id}` para acompanhar.
- **Substitui**: [T130], [T131], [T132], [T152]. **Reduz 4 telas em 1** com kind como parâmetro.

### F5.17 `/secretaria/exportacoes`

- **Propósito**: Catálogo de exportações disponíveis (alunos TADS, professores, egressos, solicitações abertas, concluídas, estágios filtrados, formativas por aluno). Cada item gera CSV/XLSX assíncrono e disponibiliza link.
- **Capability**: `export.run`.
- **Plataforma**: web.
- **Fonte**: `POST /exports/{kind}`.
- **Substitui**: ações de `baixar*` espalhadas pelo legado (RF39).

### F5.18 `/secretaria/estatisticas`

- **Propósito**: Dashboards quantitativos (volume de solicitações por tipo/mês, tempo médio de deliberação, gargalos). Filtros por curso, período. Charts via Recharts.
- **Capability**: `report.view_secretary`.
- **Plataforma**: web.
- **Fonte**: `GET /reports/secretary?...`.
- **Substitui**: [T148].

### F5.19 `/secretaria/tarefas` (opcional)

- **Propósito**: CRUD simples de tarefas internas (lista pendente / concluída). Mantido **opcional** — se a secretaria adotar Linear/Jira, esta rota é desativada.
- **Capability**: `task.manage`.
- **Plataforma**: web.
- **Fonte**: `/tasks` CRUD (módulo opt-in via flag de configuração).
- **Substitui**: [T139]–[T143] (decisão registrada em ADR-018 sugerida).

---

## 8. F6 — Coordenação

### F6.1 `/coordenacao/cursos/:id/configurar`

- **Propósito**: Configurações específicas do coordenador: horas formativas mínimas, tipo de calendário (15/18), perfis de banca de TCC, regimento. Submódulo de F5.7.
- **Capability**: `course.config`.
- **Plataforma**: web.
- **Fonte**: `PATCH /courses/{id}/config`.
- **Origem**: nova (refina o que estava embutido em "secretário").

### F6.2 `/coordenacao/relatorios`

- **Propósito**: Visão analítica para coordenação — séries históricas, comparativos por curso, indicadores de evasão, taxa de aprovação de formativas.
- **Capability**: `report.view_coordinator`.
- **Plataforma**: web.
- **Fonte**: `GET /reports/coordinator?...`.
- **Origem**: extensão de [T148].

> Coordenação reaproveita: tudo de Secretaria + as duas rotas acima.

---

## 9. F7 — Admin / Plataforma

### F7.1 `/admin/usuarios`

- **Propósito**: CRUD de qualquer usuário (alunos, professores, secretários, comissões). Atribuir roles. Reset de senha administrativo. Trocar email institucional.
- **Capability**: `user.manage_all`.
- **Plataforma**: web.
- **Fonte**: `/users` CRUD.
- **Substitui**: [T117], [T118], [T119].

### F7.2 `/admin/perfis` (Roles)

- **Propósito**: CRUD de `Role` (agregadores). Cada role tem nome, descrição e set de `authorities`.
- **Capability**: `iam.manage_roles`.
- **Plataforma**: web.
- **Fonte**: `/roles` CRUD.
- **Origem**: substitui a noção rígida de 10 perfis fixos do legado por configuração.

### F7.3 `/admin/autoridades`

- **Propósito**: CRUD de `Authority` (capabilities granulares). Visualiza matriz `role × authority` com toggle.
- **Capability**: `iam.manage_authorities`.
- **Plataforma**: web.
- **Fonte**: `/authorities` CRUD + `PUT /roles/{id}/authorities`.
- **Origem**: nova (FGAC).

### F7.4 `/admin/tipos-solicitacao`

- **Propósito**: **Coração do DRY (ADR-003)**. CRUD do `RequestType`: editor JSON Schema (com preview do formulário ao vivo) + editor visual de máquina de estados (drag-and-drop com validação de invariantes) + capabilities exigidas + prazo padrão (`prazo_dias`).
- **Capability**: `request_type.manage`.
- **Plataforma**: web.
- **Fonte**: `/request-types` CRUD.
- **Origem**: nova. **Lacuna L01** corrigida.

### F7.5 `/admin/templates-comunicacao`

- **Propósito**: CRUD de `communication_template` (Markdown + placeholders + canal-alvo). Preview com substituição de variáveis. Versionamento (manter histórico de revisões).
- **Capability**: `communication.manage_templates`.
- **Plataforma**: web.
- **Fonte**: `/communication-templates` CRUD.
- **Origem**: nova. **Lacuna L02** corrigida.

### F7.6 `/admin/jobs`

- **Propósito**: Observabilidade do Outbox — lista de `outbox_event` por status (PENDING/SENT/FAILED/DEAD), filtros, ação manual de "reentregar". Inclui seção de scheduled jobs (frequência, último run, próximo run).
- **Capability**: `system.observe`.
- **Plataforma**: web.
- **Fonte**: `/admin/outbox?status=...`, `POST /admin/outbox/{id}/retry`.
- **Origem**: nova. **Lacuna L03** corrigida (ADR-006 + seção 9 prometeram o Outbox; faltava a UI).

### F7.7 `/admin/audit-log`

- **Propósito**: Pesquisa em `audit_log` por ator, alvo, tipo, intervalo. Visualização do payload diff (estado antes / depois).
- **Capability**: `audit.read`.
- **Plataforma**: web.
- **Fonte**: `/audit-log?...`.
- **Substitui**: [T153]–[T156] (gestão de erros do legado vira sub-aba "ERROR").

### F7.8 `/admin/usuarios/:id/reset-senha`

- **Propósito**: Reset administrativo. Em vez de gerar senha "123" como o legado, gera **link 1-uso (24h)** e envia ao email cadastrado. Operador **nunca vê** a senha.
- **Capability**: `user.reset_password`.
- **Plataforma**: web.
- **Fonte**: `POST /users/{id}/password-reset`.
- **Substitui**: [T07] `reiniciarSenhaPara123.jsp` corrigindo o anti-padrão de senha padrão fixa.

### F7.9 (opcional) `/admin/sistema/saude`

- **Propósito**: Painel resumido do Spring Actuator + métricas chave (latência, fila Outbox, erros 5xx). Linka para Grafana externo. Extra-MVP.
- **Capability**: `system.admin`.
- **Plataforma**: web.

---

## 10. F8 — Cross-cutting (todo logado)

### F8.1 `/buscar?q=`

- **Propósito**: Busca global por GRR, nome de aluno, número de protocolo, evento. Resultado tipado com ícones e atalho de teclado (`Ctrl+K`/`⌘K`).
- **Capability**: derivada por escopo (busca só retorna o que o usuário pode ver).
- **Plataforma**: ambas (no mobile vira aba "Buscar").
- **Fonte**: `GET /search?q=...`.
- **Origem**: nova. **Lacuna L15** corrigida.

### F8.2 `/suporte`

- **Propósito**: Abrir ticket (vira atendimento estruturado) ou contatar a secretaria. Inclui base de conhecimento (FAQ).
- **Capability**: pública (logado).
- **Plataforma**: ambas.
- **Origem**: nova.

---

## 11. Rastreabilidade — telas legadas × rotas novas

### O que sumiu (eliminado por DRY)

| Legado | Razão | Substituto |
|---|---|---|
| 19× `novaSol*` | Wizard genérico (form_schema) | `/solicitacoes/nova` |
| 19× `consultarSol*` | Detalhe genérico HATEOAS | `/solicitacoes/:id` |
| 26× `deliberarSol*(Professor/Secretario)` | Ação por capability + `_links` | `/solicitacoes/:id/deliberar` |
| 14× `deliberarSol*EntradaEmail` | JWT 1-uso na rota acima | `/solicitacoes/:id/deliberar?token=` |
| Telas `*Efetivar` ([T43], [T74]) | Step "Revisar" do wizard | `/solicitacoes/nova` (passo 3) |
| Cadastro de aluno em isolada/eletiva ([T52], [T57]) | Onboarding fluido no `/login` (link "Sem cadastro? Começar") | `/login` + `/solicitacoes/nova` |
| `homeOld.jsp`, `reiniciarSenhaUsuarioOld.jsp`, `limparHistoricoOLD0.jsp`, `consultarSolicitacoesConcluidas1.jsp` | Versões legadas | descartadas |
| `index.html` ([T13]) | redirect inicial | servidor faz redirect → `/login` ou `/inicio` |
| `menu.jsp`, `header.jspf` | Layout/component shell | `<AppLayout>` reutilizável |

### O que migrou (com mapeamento direto)

| Legado | Rota nova |
|---|---|
| [T01] | `/login` |
| [T02] | `/recuperar-senha` |
| [T03], [T04] | `/nova-senha?token=` |
| [T05] (parte) | `/perfil/seguranca` |
| [T06] | `/primeiro-acesso` |
| [T07] | `/admin/usuarios/:id/reset-senha` |
| [T08], [T09] | `/inicio` (contextual) |
| [T11] | `/erro/:codigo` |
| [T14] | `/contato` |
| [T15] + 19× `novaSol*` | `/solicitacoes/nova` |
| [T16] | `/solicitacoes/nova` (com `request.internal_open`) |
| [T17]–[T20] | `/solicitacoes` |
| 19× `consultarSol*` | `/solicitacoes/:id` |
| 26× `deliberarSol*` | `/solicitacoes/:id/deliberar` |
| [T86]–[T87] | `/estagios/:id` |
| [T88] | `/estagios` |
| [T89]–[T91] | `/comissoes/coe` + `/secretaria/eventos`-similar para estágio |
| [T90] | `/comissoes/coe` (alocação inline) |
| [T92] | `/secretaria/exportacoes` |
| [T93]–[T100], [T106] | `/secretaria/exportacoes` + visões secretaria das formativas no Hub |
| [T96] | `/formativas` |
| [T101] | `/comissoes/caaf` |
| [T102]–[T105] | `/formativas?to=me` (professor) |
| [T107] | `/tccs` |
| [T108]–[T111] | `/tccs/:id` |
| [T112], [T113] | `/secretaria/diplomas` |
| [T114] | `/solicitacoes/nova` (tipo `AUTORIZACAO_IMAGEM`) |
| [T115], [T116] | `/secretaria/autorizacoes-imagem` |
| [T117]–[T119] | `/admin/usuarios` (e `/perfil` quando próprio) |
| [T120]–[T123] | `/secretaria/alunos` |
| [T124] | `/secretaria/egressos` |
| [T125], [T126] | `/secretaria/cursos` |
| [T127]–[T129] | `/secretaria/disciplinas` |
| [T130]–[T132], [T152] | `/secretaria/importacoes` |
| [T133] | `/secretaria/atrasados` |
| [T134], [T135] | `/secretaria/atendimentos` (secretaria) + `/meus-atendimentos` (aluno) |
| [T136]–[T138] | `/secretaria/calendarios` |
| [T139]–[T143] | `/secretaria/tarefas` (opcional) ou Linear |
| [T144]–[T147] | `/publico/verificar-protocolo/:id` + ação "Gerar protocolo" em `/solicitacoes/:id` e `/formativas/:id` |
| [T148] | `/secretaria/estatisticas` (+ `/coordenacao/relatorios`) |
| [T149], [T150] | job de retenção (fora da UI; ADR-019 sugerida) |
| [T151] | backup operacional (fora da UI) |
| [T153]–[T156] | `/admin/audit-log` |
| [T157], [T158] | descartado (módulo `piloto` é resíduo) |

### O que é novo (não existia no legado)

| Rota | Justificativa | Seção do doc |
|---|---|---|
| `/comunicacao` (Hub) | Comunicação unificada | §7 |
| `/perfil/notificacoes` | Preferências granulares | §7.3 + 5.3 |
| `/eventos`, `/eventos/:id/presenca`, `/professor/eventos`, `/professor/eventos/:id`, `/professor/eventos/:id/operacao` | Presença v4.1 (modos configuráveis, janelas, estados, HATEOAS) | §10 |
| `/secretaria/eventos`, `/secretaria/eventos/:id/operacao` | CRUD/operación paritário com professor (`event.manage`) | §10 |
| `/certificados` + `/publico/verificar-certificado/:hash` | Certificados auditáveis | §11 |
| `/admin/autoridades`, `/admin/perfis` | FGAC | §6.1, ADR-002 |
| `/admin/tipos-solicitacao` | Workflow Engine | ADR-003 |
| `/admin/templates-comunicacao` | Templates versionados | §7.4 |
| `/admin/jobs` | Observabilidade Outbox | §9 + ADR-006 |
| `/buscar` | UX moderna em volume | recomendação dev |
| `/comissoes/caaf`, `/comissoes/coe` | Espaço dedicado às comissões | §6.1 |
| `/coordenacao/...` | Diferenciação coord × secret | §6.1 |
| `/egresso/inicio` | Preenche vácuo da Árvore 5 do legado | gap detectado |

---

## 12. Resumo quantitativo

| Categoria | Legado | SecretariaOnline2 v2 | Redução |
|---|---:|---:|---:|
| Login/senha/erro | 7 | 6 | -14% |
| Solicitações (incluindo deliberação) | ~71 | 4 | **-94%** |
| Formativas | 14 | 4 | -71% |
| Estágios | 7 | 3 | -57% |
| TCC | 5 | 3 | -40% |
| Diploma + autorização imagem | 5 | 2 | -60% |
| Alunos / cursos / disciplinas | 10 | 3 | -70% |
| Calendários | 3 | 1 | -67% |
| Importação | 3 | 1 | -67% |
| Atendimentos | 3 | 2 | -33% |
| Tarefas | 5 | 1 (opcional) | -80% |
| Protocolo | 4 | 0 (ação inline) + 1 verificador | -75% |
| Estatísticas / relatórios | 1 | 2 (secret + coord) | +100% (capacidade analítica) |
| Erros / backup / limpeza | 7 | 1 (`/admin/audit-log`) + jobs | -86% |
| Pilotos | 2 | 0 (descartado) | -100% |
| **Comunicação (Hub)** | 0 | 3 | (novo) |
| **Eventos / certificados** | 0 | 6 | (novo) |
| **FGAC / templates / jobs** | 0 | 5 | (novo) |
| **Cross-cutting (busca, suporte)** | 0 | 2 | (novo) |
| **TOTAL** | **~158** | **~46** | **-71%** |

A redução é menos agressiva do que os "75%" anunciados na 6.2 porque **somei rotas que faltavam** e que **a arquitetura exigia ter**. Mesmo assim, o ganho permanece massivo (-71%) e o produto fica funcionalmente **completo** (não dependendo de "edita JSON no banco" para criar tipo novo de solicitação, configurar template ou monitorar Outbox).

---

## 13. Notas finais para implementação

1. **Cada rota** deve nascer com **OpenAPI spec** versionada antes do código. Frontend e backend só conversam via contrato.
2. **HATEOAS** + helper `useActions(resource)` no frontend garante que **adicionar uma ação** = adicionar um link no backend (zero deploy de UI).
3. **Skeletons + suspense** em todas as listas; **virtual scroll** quando > 200 linhas.
4. **A11y**: foco gerenciado, ARIA-live para feedbacks, contraste mínimo 4.5:1, navegação por teclado total.
5. **i18n**: pt-BR padrão; estrutura de chaves preparada para en-US (egresso/parceiros internacionais).
6. **Telemetria**: cada rota emite evento `view_route` com `routeId`, `latency`, `userAgent` para Grafana.
7. **Mobile**: rotas marcadas "ambas" devem ser responsive web e ter contraparte Expo Router `app/<rota>.tsx`.
