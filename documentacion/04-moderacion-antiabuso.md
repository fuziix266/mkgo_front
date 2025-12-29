# MKGO – Moderación / Anti-abuso (resumen operativo)

Este documento resume cómo queda el sistema de denuncias y control de troleo.

---

## Objetivos
- Reducir falsos baños / reseñas falsas / spam.
- Permitir denuncias por parte de usuarios.
- Permitir resolución por moderación (`mod`/`admin`).
- Mantener historial (soft delete) para auditoría.

---

## Denuncias
Los usuarios pueden reportar:

- `toilet` (baño)
- `review` (reseña)
- `comment` (comentario)
- `photo` (foto)
- `user` (usuario)

Razones disponibles (`reason_code`):
- `spam`
- `fake`
- `harassment`
- `nudity`
- `hate`
- `illegal`
- `wrong_location`
- `duplicate`
- `privacy`
- `other`

Endpoint:
- `POST /reports`

---

## Moderación
Endpoints de moderación:
- `GET /admin/reports`
- `POST /admin/reports/{id}/resolve`

Requiere rol:
- `admin` o `mod`

Estados de reporte:
- `open`
- `in_review`
- `resolved`
- `rejected`

Campos de resolución:
- `resolved_action` (ej: `content_removed`, `user_warned`, `user_banned`)
- `resolved_note` (nota interna)

---

## Acciones típicas
1) Reporte de baño falso (`fake`)
- Moderación marca `in_review`
- Verifica duplicación/ubicación
- Resuelve:
  - `resolved_action=content_removed` si es falso
  - o `rejected` si el reporte es incorrecto

2) Spam reiterado
- Resolver reporte
- Marcar usuario para sanción (warning/ban)

---

## Recomendación de reglas mínimas
- Rate-limit por IP/usuario:
  - reseñas: 10/h
  - comentarios: 30/h
  - reportes: 20/día
- Auto-ocultar contenido si recibe “X” reportes válidos (lo puedes implementar luego con un job):
  - 5 reportes `fake` → ocultar baño
  - 10 reportes `spam` → ocultar reseña/comentario

---

## Nota
Este documento es guía; el enforcement automático (autohide / autoban) se puede agregar después como cron/job.
