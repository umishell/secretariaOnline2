# US-F0-004 — Visualizar Informações de Contato da Secretaria

| Campo | Valor |
|-------|-------|
| **ID** | US-F0-004 |
| **Épico** | PUB-STATIC |
| **Tela** | F0.4 — `/contato` |
| **Prioridade** | P2 |
| **Plataforma** | Web (mobile abre URL externa) |
| **API primária** | Estático (sem chamada de API) |
| **Frames Figma** | [Desktop](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=30-278) · [Mobile](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=30-305) |
| **Spec de tela** | `telasFigma/telas0/F0.4-contato.md` |
| **Substitui (legado)** | `web/contato.jsp` [T14 — RF53] |

---

## 1. História de Usuário

> **Como** um visitante ou usuário do sistema,  
> **Quero** acessar a página de contato da secretaria,  
> **Para** obter o endereço, telefone, e-mail e horário de atendimento sem precisar fazer login.

---

## 2. Regras de Negócio

| ID | Regra |
|----|-------|
| **RN-F0.4-01** | A página é estática (sem chamada de API). O conteúdo — endereço, telefones, e-mail institucional e horário de atendimento da secretaria — deve ser configurável via variável de ambiente ou arquivo de configuração, não hardcoded no código. |
| **RN-F0.4-02** | Links de telefone devem usar o protocolo `tel:` para acionamento direto no mobile. |
| **RN-F0.4-03** | O link "Voltar ao login" no rodapé da página deve direcionar para `/login`. |
| **RN-F0.4-04** | O mapa embutido deve ter texto alternativo acessível descrevendo a localização (ex.: "Mapa mostrando a localização da Secretaria do SEPT — UFPR, Rua Coronel Francisco Heráclito dos Santos, Curitiba"). |
| **RN-F0.4-05** | Em dispositivos mobile, a página não deve ser renderizada diretamente no app — o link abre em browser externo. |

---

## 3. Critérios de Aceitação

### CA-01 — Exibição dos dados de contato

```gherkin
Dado que um visitante acessa /contato em desktop
Quando a página carrega
Então exibe card com:
  - ícone MapPin + endereço completo da secretaria
  - ícone Phone + número(s) de telefone como links tel:
  - ícone Mail + e-mail institucional como link mailto:
  - ícone Clock + horário de atendimento
  E ao lado (coluna direita) exibe placeholder do mapa com label de localização
```

### CA-02 — Layout responsivo

```gherkin
Dado que um visitante acessa /contato
Quando a viewport é ≥ 1024px
Então exibe grid de 2 colunas: informações | mapa
Quando a viewport é < 1024px
Então exibe layout de 1 coluna empilhada: informações acima, mapa abaixo
```

### CA-03 — Link de retorno ao login

```gherkin
Dado que o visitante está na página /contato
Quando clica em "Voltar ao login"
Então é redirecionado para /login (F0.1)
```

### CA-04 — Acessibilidade

```gherkin
Dado que o visitante usa leitor de tela
Então o mapa possui atributo alt descrevendo a localização da secretaria
  E os links de telefone têm aria-label legível (ex: "Ligar para (41) 3361-XXXX")
```

---

## 4. Componentes de UI (Design System)

| Componente | Variante | Uso |
|------------|---------|-----|
| `Shell/PublicLayout` | `state=default` | Shell da tela |
| `DS/Card` | `default` | Container das informações |
| Ícones Lucide | `MapPin, Phone, Clock, Mail` (20px) | Marcadores dos campos |

---

## 5. Fora de escopo

- Formulário de contato online — não previsto no MVP
- Chat com a secretaria — não previsto
- Atualização dinâmica de horários via API — configuração estática é suficiente para o MVP

---

## 6. Definição de Pronto (DoD)

- [ ] Frames Figma aprovados: Desktop e Mobile
- [ ] Conteúdo parametrizável (sem hardcode de telefone/endereço no código-fonte)
- [ ] Links `tel:` e `mailto:` funcionais e testados
- [ ] Acessibilidade: alt text no mapa, aria-label nos telefones
- [ ] Responsividade validada em 375px e 1440px

---

## 7. Referências

| Recurso | Link / Caminho |
|---------|---------------|
| Spec de tela | `telasFigma/telas0/F0.4-contato.md` |
| Mapa de rotas | `foundationDocs/analysis/telas.md` §2 F0.4 |
| Página Figma F0 | [Telas / F0 — Público](https://www.figma.com/design/y1ZC44ThrXH0CIpEWZITh6/secretariaOnline2?node-id=18-152) |
