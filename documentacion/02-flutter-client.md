# MKGO – Flutter – Cliente (Services + Widgets)

Este documento contiene el cliente Flutter para consumir los endpoints ya definidos en el backend.

Incluye:
- ReviewsService (upsert + delete)
- CommentsService (list + create + reply + attach photo)
- MediaService (upload multipart)
- ReportsService (report)
- UsersService (/me + /me/update)
- Widgets mínimos (ReviewForm + CommentsBlock)

> Requisito: existe `ApiClient` en `lib/services/api_client.dart` con `get/post`, `baseUrl` y `getToken()`.

---

## 1) Reviews

### `lib/services/reviews_service.dart`
```dart
import 'dart:convert';
import 'api_client.dart';

class ReviewsService {
  final ApiClient api;
  ReviewsService(this.api);

  Future<bool> upsert({
    required int toiletId,
    required int rating,
    String? body,
  }) async {
    final res = await api.post(
      '/toilets/$toiletId/reviews',
      body: {
        'rating': rating,
        'body': body,
      },
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<bool> delete(int reviewId) async {
    final res = await api.post('/reviews/$reviewId/delete');
    return res.statusCode == 200;
  }
}
```

---

## 2) Comments

### `lib/services/comments_service.dart`
```dart
import 'dart:convert';
import 'api_client.dart';

class CommentsService {
  final ApiClient api;
  CommentsService(this.api);

  Future<List<Map<String, dynamic>>> list(int toiletId) async {
    final res = await api.get('/toilets/$toiletId/comments');
    if (res.statusCode != 200) return [];

    final json = jsonDecode(res.body);
    return (json['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<bool> create({
    required int toiletId,
    required String body,
  }) async {
    final res = await api.post(
      '/toilets/$toiletId/comments/create',
      body: {'body': body},
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<bool> reply({
    required int commentId,
    required String body,
  }) async {
    final res = await api.post(
      '/comments/$commentId/reply',
      body: {'body': body},
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<bool> attachPhoto({
    required int commentId,
    required int mediaId,
    String? caption,
  }) async {
    final res = await api.post(
      '/comments/$commentId/photos/attach',
      body: {
        'media_id': mediaId,
        'caption': caption,
      },
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }
}
```

---

## 3) Media (upload)

### `lib/services/media_service.dart`
```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class MediaService {
  final ApiClient api;
  MediaService(this.api);

  Future<int?> upload(File file) async {
    final uri = Uri.parse('${api.baseUrl}/media/upload');
    final token = await api.getToken();

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode != 201 && response.statusCode != 200) return null;

    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);
    return (json['media']?['id'] as num?)?.toInt();
  }
}
```

---

## 4) Reports

### `lib/services/reports_service.dart`
```dart
import 'dart:convert';
import 'api_client.dart';

class ReportsService {
  final ApiClient api;
  ReportsService(this.api);

  Future<bool> report({
    required String targetType,
    required int targetId,
    required String reasonCode,
    String? details,
  }) async {
    final res = await api.post(
      '/reports',
      body: {
        'target_type': targetType,
        'target_id': targetId,
        'reason_code': reasonCode,
        'details': details,
      },
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }
}
```

---

## 5) Users (`/me`)

### `lib/services/users_service.dart`
```dart
import 'dart:convert';
import 'api_client.dart';

class UsersService {
  final ApiClient api;
  UsersService(this.api);

  Future<Map<String, dynamic>?> me() async {
    final res = await api.get('/me');
    if (res.statusCode != 200) return null;
    return jsonDecode(res.body)['user'];
  }

  Future<bool> update({
    String? displayName,
    String? avatarUrl,
  }) async {
    final res = await api.post(
      '/me/update',
      body: {
        'display_name': displayName,
        'avatar_url': avatarUrl,
      },
    );
    return res.statusCode == 200;
  }
}
```

---

## 6) Widgets mínimos

### `lib/widgets/review_form.dart`
```dart
import 'package:flutter/material.dart';
import '../services/reviews_service.dart';

class ReviewForm extends StatefulWidget {
  final ReviewsService service;
  final int toiletId;
  const ReviewForm({super.key, required this.service, required this.toiletId});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  int rating = 5;
  final body = TextEditingController();
  bool loading = false;

  Future<void> submit() async {
    setState(() => loading = true);
    await widget.service.upsert(
      toiletId: widget.toiletId,
      rating: rating,
      body: body.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<int>(
          value: rating,
          items: List.generate(
            5,
            (i) => DropdownMenuItem(
              value: i + 1,
              child: Text('${i + 1} estrellas'),
            ),
          ),
          onChanged: (v) => setState(() => rating = v ?? rating),
        ),
        TextField(
          controller: body,
          decoration: const InputDecoration(labelText: 'Comentario'),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: loading ? null : submit,
          child: loading ? const CircularProgressIndicator() : const Text('Guardar reseña'),
        ),
      ],
    );
  }
}
```

### `lib/widgets/comments_block.dart`
```dart
import 'package:flutter/material.dart';
import '../services/comments_service.dart';

class CommentsBlock extends StatefulWidget {
  final CommentsService service;
  final int toiletId;
  const CommentsBlock({super.key, required this.service, required this.toiletId});

  @override
  State<CommentsBlock> createState() => _CommentsBlockState();
}

class _CommentsBlockState extends State<CommentsBlock> {
  List<Map<String, dynamic>> items = [];
  final body = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final res = await widget.service.list(widget.toiletId);
    setState(() => items = res);
  }

  Future<void> send() async {
    if (body.text.trim().isEmpty) return;
    await widget.service.create(
      toiletId: widget.toiletId,
      body: body.text.trim(),
    );
    body.clear();
    await load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final c in items)
          ListTile(
            title: Text(c['display_name'] ?? 'Usuario'),
            subtitle: Text(c['body'] ?? ''),
          ),
        TextField(
          controller: body,
          decoration: const InputDecoration(labelText: 'Comentar'),
        ),
        ElevatedButton(onPressed: send, child: const Text('Enviar')),
      ],
    );
  }
}
```
