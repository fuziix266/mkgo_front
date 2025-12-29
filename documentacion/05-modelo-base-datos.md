# MKGO – Modelo de Base de Datos (MySQL / MariaDB)

Este documento describe el **modelo completo de base de datos** de MKGO, la aplicación para búsqueda, evaluación y reporte de baños públicos.

Diseñado para:
- MySQL / MariaDB
- UTF8MB4
- Laminas Framework (backend)
- Flutter (frontend)

---

## 1) Principios del diseño

- Soft delete en entidades críticas (`deleted_at`)
- Auditable (no se elimina información real)
- Escalable (caches denormalizados)
- Anti‑trolleo (reportes, votos de existencia)
- Compatible con GIS (Leaflet + OpenStreetMap)

---

## 2) Usuarios

### mkgo_users
Usuarios autenticados vía Google.

Campos clave:
- google_sub (único)
- email
- display_name
- avatar_url
- is_banned
- deleted_at

Relaciones:
- crea baños
- escribe reseñas
- comenta
- sube fotos
- reporta contenido

---

### mkgo_roles / mkgo_user_roles
Roles simples:
- user
- mod
- admin

Uso exclusivo para moderación.

---

## 3) Baños

### mkgo_toilets
Entidad central.

Campos:
- latitude / longitude
- venue_type (restaurant, hotel, street, etc)
- access_type (public_free, public_paid, customers_only)
- price_amount / currency
- status
- is_hidden_by_system

Caches:
- rating_avg
- rating_count
- reviews_count
- comments_count
- exist_yes_count
- exist_no_count

Estados:
- active
- temporarily_closed
- permanently_closed
- pending_review
- rejected

---

### mkgo_amenities / mkgo_toilet_amenities
Amenidades opcionales:
- accesibilidad
- mudador
- papel
- jabón

---

## 4) Media

### mkgo_media
Metadata de archivos.

Campos:
- storage_provider
- path
- public_url
- mime_type
- size
- width / height
- sha256

---

### mkgo_toilet_photos
Relación baño ↔ fotos.

Permite:
- galería
- foto portada

---

## 5) Reseñas

### mkgo_toilet_reviews
- 1 reseña por usuario por baño
- rating 1–5
- soft delete

Efecto:
- recalcula rating_avg y rating_count

---

## 6) Comentarios

### mkgo_toilet_comments
- comentarios raíz
- replies (parent_comment_id)

---

### mkgo_comment_photos
Fotos asociadas a comentarios.

Regla:
- solo el autor puede adjuntar

---

## 7) Existencia del baño

### mkgo_toilet_existence_votes
Votos:
- exists
- nonexistent

Regla:
- ≥5 votos nonexistent
- diferencia ≥4
→ auto-ocultamiento

---

## 8) Mantenciones

### mkgo_toilet_downtimes
Tipos:
- maintenance (≤24h)
- repair_major
- other

Campos:
- starts_at
- ends_at
- status

---

## 9) Reportes

### mkgo_reports
Targets:
- toilet
- review
- comment
- photo
- user

Estados:
- open
- in_review
- resolved
- rejected

---

## 10) Rate limit

### mkgo_rate_limits
Previene spam:
- reseñas
- comentarios
- reportes

---

## 11) Notificaciones

### mkgo_notifications
Tipos:
- comment
- reply
- report_update
- system

---

## 12) Diagrama lógico

USERS
 ├─ TOILETS
 │   ├─ REVIEWS
 │   ├─ COMMENTS ── COMMENT_PHOTOS ── MEDIA
 │   ├─ TOILET_PHOTOS ── MEDIA
 │   ├─ DOWNTIMES
 │   └─ EXISTENCE_VOTES
 ├─ REPORTS
 └─ NOTIFICATIONS

---

## 13) Conclusión

Modelo:
- completo
- coherente con backend Laminas
- listo para producción
- extensible sin refactor mayor
