Pelo schema proposto em `a_new_app_design/analise_arquitetural_secretariaonline2.md`, o número é:

- **29 tabelas de aplicação** (contando os `CREATE TABLE` do documento).

Além disso, na prática, geralmente aparecem tabelas técnicas:

- **+1 do Flyway** (`flyway_schema_history`) quando você roda migrations.
- possivelmente outras de suporte, dependendo da implementação final (ex.: idempotência/segurança/sessões), mas isso não está fechado como `CREATE TABLE` no draft principal.

Então, resposta curta: **para o modelo completo desenhado hoje, pense em ~29 tabelas de domínio + tabelas técnicas de operação (mínimo 30 com Flyway).**



### IAM
- `UsuarioJpaRepository` → `usuario`
- `RoleJpaRepository` → `role`
- `AuthorityJpaRepository` → `authority`
- `RoleAuthorityJpaRepository` → `role_authority` *(opcional se mapear só via `@ManyToMany`)*
- `UsuarioRoleJpaRepository` → `usuario_role`

### Acadêmico
- `CursoJpaRepository` → `curso`
- `DisciplinaJpaRepository` → `disciplina`
- `PeriodoLetivoJpaRepository` → `periodo_letivo`
- `CalendarioAcademicoJpaRepository` → `calendario_academico`

### Solicitações
- `RequestTypeJpaRepository` → `request_type`
- `RequestJpaRepository` → `request`
- `RequestEventJpaRepository` → `request_event`
- `RequestLineItemJpaRepository` → `request_line_item`
- `RequestAttachmentJpaRepository` → `request_attachment`

### Formativas
- `FormativeActivityJpaRepository` → `formative_activity`
- `FormativeEntryJpaRepository` → `formative_entry`

### Estágio
- `InternshipJpaRepository` → `internship`
- `InternshipDocumentJpaRepository` → `internship_document`

### TCC
- `TccJpaRepository` → `tcc`
- `TccMemberJpaRepository` → `tcc_member`
- `TccExaminerJpaRepository` → `tcc_examiner`

### Comunicação / Notificações
- `CommunicationJpaRepository` → `communication`
- `CommunicationDeliveryJpaRepository` → `communication_delivery`
- `NotificationPreferenceJpaRepository` → `notification_preference`
- `OutboxEventJpaRepository` *(ou `OutboxRepository`, como no doc)* → `outbox_event`

### Presença / Certificados (v4.1 — `attendance_session`, modos configuráveis)
- `EventAttendanceJpaRepository` → `event_attendance`
- `AttendanceSessionJpaRepository` → `attendance_session`
- `AttendanceValidationWindowJpaRepository` → *(opcional)* `attendance_validation_window` — se a normalização 1:N substituir `validation_windows` JSONB
- `CertificateJpaRepository` → `certificate`

### Auditoria
- `AuditLogJpaRepository` → `audit_log`

---


No Spring Data JPA, “interface concreta” normalmente significa: **você cria a interface** e o Spring gera a implementação concreta em runtime.

## Repositórios sugeridos (`interface` ↔ tabela)

### PK simples (`UUID`)
- `UsuarioJpaRepository` ↔ `usuario`
- `RoleJpaRepository` ↔ `role`
- `AuthorityJpaRepository` ↔ `authority`
- `CursoJpaRepository` ↔ `curso`
- `DisciplinaJpaRepository` ↔ `disciplina`
- `PeriodoLetivoJpaRepository` ↔ `periodo_letivo`
- `CalendarioAcademicoJpaRepository` ↔ `calendario_academico`
- `RequestTypeJpaRepository` ↔ `request_type`
- `RequestJpaRepository` ↔ `request`
- `RequestEventJpaRepository` ↔ `request_event`
- `RequestLineItemJpaRepository` ↔ `request_line_item`
- `RequestAttachmentJpaRepository` ↔ `request_attachment`
- `FormativeActivityJpaRepository` ↔ `formative_activity`
- `FormativeEntryJpaRepository` ↔ `formative_entry`
- `InternshipJpaRepository` ↔ `internship`
- `InternshipDocumentJpaRepository` ↔ `internship_document`
- `TccJpaRepository` ↔ `tcc`
- `CommunicationJpaRepository` ↔ `communication`
- `CommunicationDeliveryJpaRepository` ↔ `communication_delivery`
- `NotificationPreferenceJpaRepository` ↔ `notification_preference` *(PK também é UUID, mas é `id_usuario`)*
- `OutboxEventJpaRepository` *(ou `OutboxRepository`)* ↔ `outbox_event`
- `EventAttendanceJpaRepository` ↔ `event_attendance` *(campos `attendance_mode`, `validation_windows` ou tabela filha de janelas)*
- `AttendanceSessionJpaRepository` ↔ `attendance_session`
- `CertificateJpaRepository` ↔ `certificate`
- `AuditLogJpaRepository` ↔ `audit_log`

### PK composta (`@Embeddable` + `@EmbeddedId`)
- `RoleAuthorityJpaRepository` ↔ `role_authority` (`id_role`, `id_authority`)
- `UsuarioRoleJpaRepository` ↔ `usuario_role` (`id_usuario`, `id_role`)
- `TccMemberJpaRepository` ↔ `tcc_member` (`id_tcc`, `id_aluno`)
- `TccExaminerJpaRepository` ↔ `tcc_examiner` (`id_tcc`, `id_professor`)

---

## Esqueleto Kotlin (Spring Data JPA)

```kotlin
interface UsuarioJpaRepository : JpaRepository<UsuarioEntity, UUID>
interface RequestJpaRepository : JpaRepository<RequestEntity, UUID>
interface RequestEventJpaRepository : JpaRepository<RequestEventEntity, UUID>
interface OutboxEventJpaRepository : JpaRepository<OutboxEventEntity, UUID>
interface CommunicationJpaRepository : JpaRepository<CommunicationEntity, UUID>
interface EventAttendanceJpaRepository : JpaRepository<EventAttendanceEntity, UUID>
interface AttendanceSessionJpaRepository : JpaRepository<AttendanceSessionEntity, UUID>
interface CertificateJpaRepository : JpaRepository<CertificateEntity, UUID>
interface AuditLogJpaRepository : JpaRepository<AuditLogEntity, UUID>
// Se `validation_windows` for normalizado em tabela filha:
// interface AttendanceValidationWindowJpaRepository : JpaRepository<AttendanceValidationWindowEntity, UUID>
```

### Exemplo de PK composta

```kotlin
@Embeddable
data class UsuarioRoleId(
    @Column(name = "id_usuario") val idUsuario: UUID = UUID(0, 0),
    @Column(name = "id_role") val idRole: UUID = UUID(0, 0)
) : Serializable

@Entity
@Table(name = "usuario_role")
data class UsuarioRoleEntity(
    @EmbeddedId val id: UsuarioRoleId,
    @Column(name = "escopo", columnDefinition = "jsonb") val escopo: String = "{}"
)

interface UsuarioRoleJpaRepository : JpaRepository<UsuarioRoleEntity, UsuarioRoleId>
```

---

