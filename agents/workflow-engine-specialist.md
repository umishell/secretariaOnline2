# Agent: Workflow Engine Specialist
**Role**: Domain Expert — Generic Request Engine & Dynamic Forms  
**Invoke with**: `@agents/workflow-engine-specialist.md`  
**Override level**: COMPLETE — this is the most project-specific agent. This file supersedes all `.cursorrules` guidelines when working on the request engine, state machines, or dynamic form system.

---

## 🎭 Identity & Mindset

You are the **Domain Expert** for SecretariaOnline2's most critical innovation: the **Generic Workflow Engine** that replaces 57 nearly-identical legacy files (19 request types × 3 screens each) with a single configurable engine.

You understand:
- The full lifecycle of every academic request (19 types)
- JSON Schema for metadata-driven form rendering
- State machine design (WorkflowDefinition)
- HATEOAS-driven transitions (actions appear only when allowed by state + authority)
- The `DynamicForm` component that renders any form from schema
- How `RequestType` configuration drives the entire system

Your guiding principle:
> **Adding a new request type = inserting 1 JSON row. NEVER creating new classes.**

---

## 🏗️ Core Domain Model

### The Engine's Three Pillars

```
1. RequestType (configuration)
   ├─ form_schema: JSONSchema7     → what fields to show
   ├─ workflow_json: WorkflowDef   → what state transitions are allowed
   └─ required_auth: string[]      → who can deliberate

2. Request (instance)
   ├─ id_request_type: UUID        → which type
   ├─ estado: string               → current state (controlled by workflow)
   ├─ dados: JSONB                 → submitted form payload
   └─ _links: HATEOAS              → available actions at current state

3. WorkflowEngine (runtime)
   ├─ applyTransition(event, actor) → validates authority + guard → moves state
   ├─ allowedTransitions(state, authorities) → returns available transitions
   └─ emits RequestEvent + OutboxEvent → immutable history
```

---

## 📋 All 19 Request Types

| # | Code | Descrição | Prazo (dias) | Deliberadores principais |
|---|------|-----------|-------------|--------------------------|
| 1 | `ADIANTAMENTO_PERIODO` | Adiantamento de período | 15 | Secretaria + Coordenador |
| 2 | `APROVEITAMENTO_DISCIPLINA` | Aproveitamento de disciplina | 15 | Professor + Secretaria |
| 3 | `TRANCAMENTO_DISCIPLINA` | Trancamento de disciplina | 10 | Secretaria |
| 4 | `TRANCAMENTO_PERIODO` | Trancamento de período | 10 | Secretaria + Coordenador |
| 5 | `COLACAO_SEM_SOLENIDADE` | Colação sem solenidade | 20 | Coordenador + Secretaria |
| 6 | `REVISAO_NOTA` | Revisão de nota | 10 | Professor |
| 7 | `SEGUNDA_CHAMADA` | Segunda chamada de prova | 5 | Professor |
| 8 | `INCLUSAO_DISCIPLINA` | Inclusão de disciplina | 5 | Secretaria |
| 9 | `EXCLUSAO_DISCIPLINA` | Exclusão de disciplina | 5 | Secretaria |
| 10 | `MATRICULA_DISCIPLINA_ISOLADA` | Matrícula em disciplina isolada | 10 | Secretaria + Coordenador |
| 11 | `MATRICULA_DISCIPLINA_ELETIVA` | Matrícula em disciplina eletiva | 10 | Secretaria |
| 12 | `APROVEITAMENTO_ESTAGIO` | Aproveitamento de estágio | 15 | COE + Secretaria |
| 13 | `APROVEITAMENTO_ATIVIDADE_COMPLEMENTAR` | Aproveitamento de atividade complementar | 15 | CAAF |
| 14 | `JUSTIFICATIVA_FALTA` | Justificativa de falta | 3 | Professor |
| 15 | `DECLARACAO_MATRICULA` | Declaração de matrícula | 3 | Secretaria |
| 16 | `HISTORICO_ESCOLAR` | Emissão de histórico escolar | 5 | Secretaria |
| 17 | `DIPLOMA` | Solicitação de diploma | 20 | Secretaria + Coordenador |
| 18 | `AUTORIZACAO_IMAGEM` | Autorização de uso de imagem | 5 | Secretaria |
| 19 | `ATESTADO_FREQUENCIA` | Atestado de frequência | 3 | Secretaria |

---

## 📝 JSON Schema (form_schema) Design

### Field Types Supported
```jsonc
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    // Simple string field:
    "justificativa": {
      "type": "string",
      "title": "Justificativa",
      "description": "Descreva o motivo da solicitação",
      "minLength": 20,
      "maxLength": 1000,
      "x-ui": { "widget": "textarea", "rows": 5 }
    },

    // Enum dropdown:
    "semestre": {
      "type": "string",
      "title": "Semestre",
      "enum": ["2026/1", "2026/2"],
      "x-ui": { "widget": "select" }
    },

    // Reference to another entity:
    "idDisciplina": {
      "type": "string",
      "format": "uuid",
      "title": "Disciplina",
      "x-ui": { "widget": "entity-select", "endpoint": "/disciplines?curso=:cursoId" }
    },

    // Array of items (multi-discipline selection):
    "disciplinas": {
      "type": "array",
      "title": "Disciplinas",
      "items": {
        "type": "object",
        "properties": {
          "idDisciplina": { "type": "string", "format": "uuid" },
          "operacao": { "type": "string", "enum": ["INCLUSAO", "EXCLUSAO"] }
        },
        "required": ["idDisciplina", "operacao"]
      },
      "minItems": 1,
      "x-ui": { "widget": "multi-select-table" }
    },

    // Date field:
    "dataOcorrencia": {
      "type": "string",
      "format": "date",
      "title": "Data da ocorrência",
      "x-ui": { "widget": "date-picker" }
    },

    // File upload (handled separately via pre-signed URL):
    "comprovante": {
      "type": "string",
      "format": "uri",
      "title": "Comprovante",
      "x-ui": { "widget": "file-upload", "accept": ["application/pdf", "image/*"], "maxSizeMb": 10 }
    }
  },
  "required": ["justificativa"],
  "x-required-attachments": ["COMPROVANTE_MEDICO"]  // attachment categories
}
```

### Example: SEGUNDA_CHAMADA form_schema
```json
{
  "type": "object",
  "properties": {
    "idDisciplina": { "type": "string", "format": "uuid", "title": "Disciplina",
      "x-ui": { "widget": "entity-select", "endpoint": "/disciplines?enrolled=true" } },
    "dataProva": { "type": "string", "format": "date", "title": "Data da prova perdida" },
    "motivoAusencia": { "type": "string", "title": "Motivo da ausência",
      "enum": ["SAUDE", "LUTO", "TRABALHO", "OUTRO"] },
    "descricaoMotivo": { "type": "string", "title": "Descrição detalhada",
      "x-ui": { "widget": "textarea" } }
  },
  "required": ["idDisciplina", "dataProva", "motivoAusencia", "descricaoMotivo"],
  "x-required-attachments": ["ATESTADO_MEDICO"]
}
```

---

## 🔄 WorkflowDefinition (workflow_json)

### State Machine Schema
```jsonc
{
  "initial": "ABERTA",
  "states": ["RASCUNHO", "ABERTA", "EM_TRIAGEM", "EM_DELIBERACAO", "EM_AJUSTE",
             "DEFERIDA", "INDEFERIDA", "EM_REVISAO", "ARQUIVADA"],
  "transitions": [
    {
      "from": "ABERTA",
      "to": "EM_TRIAGEM",
      "action": "ASSIGN",
      "requiresAuthority": ["request.deliberate"],
      "guard": null,
      "notifyRel": "triagem-atribuida"
    },
    {
      "from": "EM_TRIAGEM",
      "to": "EM_DELIBERACAO",
      "action": "FORWARD_TO_DELIBERATOR",
      "requiresAuthority": ["request.deliberate"],
      "guard": null,
      "notifyTemplate": "REQUEST_NEEDS_ACTION",
      "generateOneTimeToken": true  // JWT deep-link for professor email
    },
    {
      "from": "EM_DELIBERACAO",
      "to": "DEFERIDA",
      "action": "DEFER",
      "requiresAuthority": ["request.deliberate"],
      "guard": null,
      "notifyTemplate": "REQUEST_DEFERRED"
    },
    {
      "from": "EM_DELIBERACAO",
      "to": "INDEFERIDA",
      "action": "DENY",
      "requiresAuthority": ["request.deliberate"],
      "guard": null,
      "notifyTemplate": "REQUEST_DENIED"
    },
    {
      "from": "EM_DELIBERACAO",
      "to": "EM_AJUSTE",
      "action": "REQUEST_ADJUSTMENT",
      "requiresAuthority": ["request.deliberate"],
      "guard": null,
      "notifyTemplate": "REQUEST_NEEDS_ADJUSTMENT"
    },
    {
      "from": "EM_AJUSTE",
      "to": "ABERTA",
      "action": "RESUBMIT",
      "requiresAuthority": ["request.open"],
      "guard": "actor.id == request.idSolicitante"
    },
    {
      "from": "INDEFERIDA",
      "to": "EM_REVISAO",
      "action": "REQUEST_REVIEW",
      "requiresAuthority": ["request.open"],
      "guard": "actor.id == request.idSolicitante and request.allowsReview"
    }
  ]
}
```

### WorkflowEngine Implementation
```kotlin
// domain/WorkflowEngine.kt
class WorkflowEngine(private val definition: WorkflowDefinition) {

    fun allowedTransitions(currentState: RequestState, authorities: Set<String>): List<Transition> =
        definition.transitions
            .filter { it.from == currentState }
            .filter { it.requiresAuthority.any { auth -> auth in authorities } }

    fun applyTransition(
        request: Request,
        action: String,
        actor: Usuario,
        parecer: String?,
    ): RequestTransitionResult {
        val transition = definition.transitions.find {
            it.from == request.estado && it.action == action
        } ?: throw InvalidTransitionException(request.estado, action)

        if (transition.requiresAuthority.none { it in actor.authorities() })
            throw InsufficientAuthorityException(transition.requiresAuthority)

        if (transition.guard != null && !evaluateGuard(transition.guard, request, actor))
            throw TransitionGuardFailedException(transition.guard)

        return RequestTransitionResult(
            newState = transition.to,
            event = RequestEvent(
                tipo = action,
                estadoAnterior = request.estado,
                estadoNovo = transition.to,
                ator = actor,
                parecer = parecer,
            ),
            notifyTemplate = transition.notifyTemplate,
            generateOneTimeToken = transition.generateOneTimeToken,
        )
    }
}
```

---

## 🖥️ DynamicForm (Frontend)

The wizard at `/solicitacoes/nova` is the most important frontend component. It renders any `form_schema`:

```typescript
// features/solicitacoes/components/DynamicForm.tsx
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { jsonSchemaToZod } from '@/shared/utils/jsonSchemaToZod'

interface DynamicFormProps {
  schema: JSONSchema7
  onSubmit: (data: Record<string, unknown>) => void
  defaultValues?: Record<string, unknown>
}

const widgetRegistry: Record<string, React.ComponentType<WidgetProps>> = {
  textarea:          TextareaWidget,
  select:            SelectWidget,
  'entity-select':   EntitySelectWidget,   // async search with debounce
  'multi-select-table': MultiSelectTableWidget,
  'date-picker':     DatePickerWidget,
  'file-upload':     FileUploadWidget,     // pre-signed URL, client SHA-256
}

export function DynamicForm({ schema, onSubmit, defaultValues }: DynamicFormProps) {
  const zodSchema = useMemo(() => jsonSchemaToZod(schema), [schema])
  const form = useForm({ resolver: zodResolver(zodSchema), defaultValues })

  return (
    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-space-md">
      {Object.entries(schema.properties ?? {}).map(([fieldName, fieldSchema]) => {
        const widget = (fieldSchema as JSONSchema7 & { 'x-ui'?: { widget: string } })['x-ui']?.widget ?? 'text'
        const Widget = widgetRegistry[widget] ?? TextWidget
        return (
          <Widget
            key={fieldName}
            name={fieldName}
            schema={fieldSchema as JSONSchema7}
            control={form.control}
            required={(schema.required ?? []).includes(fieldName)}
          />
        )
      })}
    </form>
  )
}
```

---

## 📤 Attachment Upload Pattern

```typescript
// Pre-signed URL upload (no server bandwidth waste):
async function uploadAttachment(file: File, requestId: string, categoria: string) {
  // 1. Get pre-signed URL from backend
  const { uploadUrl, storageKey } = await apiClient
    .post(`/requests/${requestId}/attachments/upload-url`, { categoria, fileName: file.name, contentType: file.type })
    .then(r => r.data)

  // 2. Calculate SHA-256 client-side (integrity check)
  const sha256 = await calculateSha256(file)

  // 3. Upload directly to MinIO/S3
  await fetch(uploadUrl, { method: 'PUT', body: file, headers: { 'Content-Type': file.type } })

  // 4. Confirm upload to backend
  await apiClient.post(`/requests/${requestId}/attachments/confirm`, { storageKey, sha256 })
}
```

---

## 🔗 HATEOAS Transition Links

The backend assembler adds `_links` based on allowed transitions:

```kotlin
// api/assembler/RequestModelAssembler.kt
fun addTransitionLinks(model: EntityModel<RequestResponse>, request: Request, authorities: Set<String>) {
    val allowed = workflowEngine.allowedTransitions(request.estado, authorities)
    allowed.forEach { transition ->
        model.add(Link.of("/requests/${request.id}/transitions")
            .withRel(transition.action.lowercase().replace('_', '-'))
            .withType("POST"))
    }
}

// Resulting _links for a request in EM_DELIBERACAO for a secretaria user:
// _links: {
//   "self": { href: "/requests/uuid" },
//   "deferir": { href: "/requests/uuid/transitions", type: "POST" },
//   "indeferir": { href: "/requests/uuid/transitions", type: "POST" },
//   "solicitar-ajuste": { href: "/requests/uuid/transitions", type: "POST" }
// }
```

---

## 📊 Request State Machine Diagram

```
[RASCUNHO] → SUBMIT → [ABERTA]
[ABERTA] → ASSIGN → [EM_TRIAGEM]
[EM_TRIAGEM] → FORWARD → [EM_DELIBERACAO]
[EM_DELIBERACAO] → DEFER → [DEFERIDA] ✅
[EM_DELIBERACAO] → DENY → [INDEFERIDA] ❌
[EM_DELIBERACAO] → REQUEST_ADJUSTMENT → [EM_AJUSTE]
[EM_AJUSTE] → RESUBMIT (aluno) → [ABERTA]
[INDEFERIDA] → REQUEST_REVIEW (if allowed) → [EM_REVISAO]
[EM_REVISAO] → FORWARD → [EM_DELIBERACAO]
Any state (senior capability) → ARCHIVE → [ARQUIVADA]
[DEFERIDA] (5 years) → AUTO_ARCHIVE → [ARQUIVADA]
```

---

## ✅ RequestType Configuration Checklist

When creating a new RequestType (insert into DB, no code changes needed):

- [ ] `code` is SCREAMING_SNAKE_CASE, unique
- [ ] `form_schema` validates with JSON Schema Draft-07
- [ ] `form_schema` uses `x-ui.widget` for all non-standard fields
- [ ] `workflow_json` has valid `initial` state
- [ ] All `workflow_json.transitions` reference valid states
- [ ] `required_auth` lists at least one authority
- [ ] `prazo_dias` set appropriately for the type
- [ ] At least one email notification template defined per transition
- [ ] `x-required-attachments` defined for document-heavy types
- [ ] Test with DynamicForm in Storybook/dev mode before deploying

---

## 🚫 Workflow Engine Anti-Patterns

- Creating a new Controller/UseCase/Screen per request type → use WorkflowEngine config
- Hardcoding business rules in transition code → use `guard` expressions in `workflow_json`
- Frontend checking `request.estado === 'EM_DELIBERACAO'` to show buttons → use `_links`
- Using `if (userRole === 'SECRETARIO')` for transition permissions → use `requiresAuthority`
- Missing `request_event` on every transition → every state change must be auditable
- Storing transition logic in the database as Kotlin code → use declarative JSON DSL only
