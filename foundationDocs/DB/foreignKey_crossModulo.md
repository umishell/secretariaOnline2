---
## FKs cross-módulo — mapa completo

| Coluna origem | Módulo origem | → Tabela destino | Módulo destino |
|---|---|---|---|
| `usuario.id_curso` | M1 IAM | `curso.id` | M2 Acadêmico |
| `curso.id_coordenador` | M2 Acadêmico | `usuario.id` | M1 IAM (FK tardia — I7) |
| `calendario_academico.id_request_type` | M2 Acadêmico | `request_type.id` | M3 Solicitações (I8) |
| `request.id_solicitante` | M3 Solicitações | `usuario.id` | M1 IAM |
| `request.id_curso` | M3 Solicitações | `curso.id` | M2 Acadêmico |
| `request_event.id_ator` | M3 Solicitações | `usuario.id` | M1 IAM |
| `request_line_item.id_disciplina` | M3 Solicitações | `disciplina.id` | M2 Acadêmico |
| `request_attachment.uploaded_by` | M3 Solicitações | `usuario.id` | M1 IAM |
| `formative_activity.id_curso` | M4 Formativas | `curso.id` | M2 Acadêmico |
| `formative_entry.id_aluno` | M4 Formativas | `usuario.id` | M1 IAM |
| `formative_entry.reviewed_by` | M4 Formativas | `usuario.id` | M1 IAM |
| `internship.id_aluno` | M5 Estágio | `usuario.id` | M1 IAM |
| `internship.id_orientador` | M5 Estágio | `usuario.id` | M1 IAM |
| `internship.id_coe` | M5 Estágio | `usuario.id` | M1 IAM |
| `tcc.id_curso` | M6 TCC | `curso.id` | M2 Acadêmico |
| `tcc_member.id_aluno` | M6 TCC | `usuario.id` | M1 IAM |
| `tcc_examiner.id_professor` | M6 TCC | `usuario.id` | M1 IAM |
| `communication.id_curso_alvo` | M7 Comunicação | `curso.id` | M2 Acadêmico |
| `communication.id_autor` | M7 Comunicação | `usuario.id` | M1 IAM |
| `communication_delivery.id_destinatario` | M7 Comunicação | `usuario.id` | M1 IAM |
| `notification_preference.id_usuario` | M7 Comunicação | `usuario.id` | M1 IAM |
| `outbox_event.aggregate_id` | M7 Outbox | — | polimórfico (sem FK) |
| `event_attendance.id_curso` | M8 Presença | `curso.id` | M2 Acadêmico |
| `event_attendance.organizador` | M8 Presença | `usuario.id` | M1 IAM |
| `attendance_session.id_aluno` | M8 Presença | `usuario.id` | M1 IAM |
| `certificate.id_beneficiario` | M9 Certificados | `usuario.id` | M1 IAM |
| `certificate.id_evento` | M9 Certificados | `event_attendance.id` | M8 Presença |
| `certificate.id_formativa` | M9 Certificados | `formative_entry.id` | M4 Formativas |
| `audit_log.id_ator` | M9 Auditoria | `usuario.id` | M1 IAM (nullable) |

**Padrão dominante:** M1 (`usuario`) e M2 (`curso`) são os dois hubs — praticamente todos os módulos apontam para eles. O merge (Etapa 3) precisa garantir que as declarações `Ref:` intra-módulo não colidam com as cross-módulo.

Pronto para Etapa 3 (merge → `modelo-logico.dbml`).