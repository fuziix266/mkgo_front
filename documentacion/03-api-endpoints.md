# MKGO – API Endpoints (backend)

Lista de endpoints (según lo implementado en módulos Reviews/Comments/Reports/Users).

> Formato: `METHOD /path` → descripción → body esperado → respuesta típica.

---

## Auth (JWT)
- En endpoints protegidos: enviar header:
  - `Authorization: Bearer <JWT>`

---

## Reviews
### `POST /toilets/{id}/reviews`
- Crea o actualiza la reseña del usuario autenticado para el baño `{id}`.
- Body:
```json
{
  "rating": 5,
  "body": "Limpio, pero a veces hay fila."
}
```
- Respuesta (201):
```json
{
  "ok": true,
  "review_id": 123,
  "rating_avg": 4.38,
  "rating_count": 16
}
```

### `POST /reviews/{id}/delete`
- Soft delete de reseña (owner o admin/mod).
- Respuesta (200):
```json
{
  "ok": true,
  "toilet_id": 77,
  "rating_avg": 4.25,
  "rating_count": 15
}
```

---

## Comments
### `GET /toilets/{id}/comments`
- Lista comentarios (y fotos por comentario).
- Respuesta:
```json
{
  "ok": true,
  "items": [
    {
      "id": 1,
      "toilet_id": 77,
      "user_id": 10,
      "parent_comment_id": null,
      "body": "Buen baño para emergencia",
      "created_at": "2025-12-26 10:00:00",
      "display_name": "Fuzz",
      "avatar_url": "https://...",
      "photos": [
        { "id": 5, "media_id": 222, "public_url": "https://..." }
      ]
    }
  ]
}
```

### `POST /toilets/{id}/comments/create`
- Crea comentario raíz.
- Body:
```json
{ "body": "¿Hay papel?" }
```

### `POST /comments/{id}/reply`
- Responde a comentario `{id}`.
- Body:
```json
{ "body": "Sí, había la última vez." }
```

### `POST /comments/{id}/photos/attach`
- Adjunta foto a comentario (solo dueño del comentario).
- Body:
```json
{ "media_id": 222, "caption": "Estado del lavamanos" }
```

---

## Reports (denuncias)
### `POST /reports`
- Denuncia contenido.
- Body:
```json
{
  "target_type": "toilet",
  "target_id": 77,
  "reason_code": "fake",
  "details": "No existe en esa esquina."
}
```
- Respuesta (201):
```json
{ "ok": true, "report_id": 999 }
```

### `GET /admin/reports` (mod/admin)
- Lista reportes en estado `open`/`in_review`.

### `POST /admin/reports/{id}/resolve` (mod/admin)
- Body:
```json
{
  "status": "resolved",
  "resolved_action": "content_removed",
  "resolved_note": "Baño marcado como falso."
}
```

---

## Users
### `GET /me`
- Retorna perfil del usuario autenticado.
- Respuesta:
```json
{
  "ok": true,
  "user": {
    "id": 10,
    "email": "x@gmail.com",
    "display_name": "Fuzz",
    "avatar_url": "https://...",
    "created_at": "2025-12-26 10:00:00"
  },
  "roles": ["user"]
}
```

### `POST /me/update`
- Actualiza perfil.
- Body:
```json
{
  "display_name": "Nuevo Nombre",
  "avatar_url": "https://..."
}
```
