# Hoja de Ruta: Integración Front-Back MKGO

Esta documentación sirve como guía para conectar la aplicación Flutter (Frontend) con los nuevos módulos del Backend (Laminas).

## Descripción General

El backend expone una API RESTful que consume y produce JSON. La autenticación se maneja vía tokens JWT (JSON Web Tokens).

### Base URL

La URL base para las peticiones depende del entorno, pero típicamente será:
`http://localhost/mkgo/back/public` o el virtual host configurado.

### Headers Comunes

Todas las peticiones autenticadas deben incluir:

```http
Authorization: Bearer <TOKEN_JWT>
Content-Type: application/json
Accept: application/json
```

---

## Módulos y Endpoints

### 1. Usuarios (Users)

Gestión de perfil del usuario actual.

| Método   | Endpoint     | Descripción                         | Body (JSON)                                    |
| :------- | :----------- | :---------------------------------- | :--------------------------------------------- |
| **GET**  | `/me`        | Obtener datos del usuario logueado. | N/A                                            |
| **POST** | `/me/update` | Actualizar perfil.                  | `{"display_name": "...", "avatar_url": "..."}` |

### 2. Reseñas (Reviews)

Calificar baños. Un usuario solo puede tener una reseña por baño.

| Método   | Endpoint               | Descripción                         | Body (JSON)                                   |
| :------- | :--------------------- | :---------------------------------- | :-------------------------------------------- |
| **POST** | `/toilets/:id/reviews` | Crear o actualizar reseña.          | `{"rating": 5, "body": "Excelente servicio"}` |
| **POST** | `/reviews/:id/delete`  | Borrar reseña propia (soft delete). | N/A                                           |

### 3. Comentarios (Comments)

Discusión tipo hilo en cada baño.

| Método   | Endpoint                       | Descripción                    | Body (JSON)                           |
| :------- | :----------------------------- | :----------------------------- | :------------------------------------ |
| **GET**  | `/toilets/:id/comments`        | Listar comentarios de un baño. | N/A                                   |
| **POST** | `/toilets/:id/comments/create` | Crear comentario raíz.         | `{"body": "..."}`                     |
| **POST** | `/comments/:id/reply`          | Responder a un comentario.     | `{"body": "..."}`                     |
| **POST** | `/comments/:id/photos/attach`  | Adjuntar foto a comentario.    | `{"media_id": 123, "caption": "..."}` |

### 4. Reportes (Reports)

Sistema de denuncias para moderación.

| Método   | Endpoint                     | Descripción                       | Body (JSON)                                                                          |
| :------- | :--------------------------- | :-------------------------------- | :----------------------------------------------------------------------------------- |
| **POST** | `/reports`                   | Crear reporte.                    | `{"target_type": "toilet", "target_id": 1, "reason_code": "spam", "details": "..."}` |
| **GET**  | `/admin/reports`             | (Admin) Listar reportes abiertos. | N/A                                                                                  |
| **POST** | `/admin/reports/:id/resolve` | (Admin) Resolver reporte.         | `{"status": "resolved", "resolved_action": "ban_user", "resolved_note": "..."}`      |

---

## Flujo de Trabajo Recomendado

1.  **Autenticación**:

    - El frontend debe obtener el token JWT (login con Google -> Backend genera JWT si no existe o lo recupera).
    - _Nota_: El endpoint de login/registro inicial no fue parte de esta tarea específica, pero se asume que existe o se debe implementar en `Users` o `Auth`.

2.  **Interacción con Baños**:

    - Al entrar al detalle de un baño, llamar a `/toilets/:id` (asumiendo módulo `Toilets` tiene endpoint de lectura, si no, consultar directo a BD o crear endpoint).
    - Cargar reseñas y comentarios en paralelo.

3.  **Manejo de Errores**:
    - El backend devuelve siempre `{"ok": false, "error": "CODIGO_ERROR"}` en caso de fallo.
    - El frontend debe mapear estos códigos a mensajes amigables para el usuario.

## Próximos Pasos (Frontend)

- [ ] Crear modelos de datos en Dart para `User`, `Review`, `Comment`, `Report`.
- [ ] Implementar servicio HTTP genérico con interceptor para añadir el Token JWT.
- [ ] Crear pantallas para:
  - Perfil de usuario (`/me`).
  - Formulario de reseña.
  - Lista y formulario de comentarios.
  - Formulario de reporte.

## Estructura de Directorios Backend

Los nuevos módulos se encuentran en `c:/xampp_php8/htdocs/mkgo/back/module/`:

- `App/`: Utilidades transversales.
- `Toilets/`, `Media/`: Módulos base de entidades.
- `Reviews/`, `Comments/`, `Reports/`, `Users/`: Lógica de negocio implementada.

Configuración global en: `c:/xampp_php8/htdocs/mkgo/back/config/modules.config.php`.
