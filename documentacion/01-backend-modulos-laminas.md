# MKGO – Backend (Laminas) – Módulos: Reviews, Comments, Reports, Users

Este documento contiene el código y estructura para implementar los módulos del backend en Laminas MVC:

- Reviews (reseñas con estrellas, upsert y delete + recálculo cache rating)
- Comments (comentarios, replies, fotos en comentarios + recálculo cache comments_count)
- Reports (denuncias + cola admin/mod)
- Users (/me + /me/update)

> Requisitos: ya existe el módulo `App` con utilidades `Jwt`, `JsonResponse`, `Request`, `Validator`, y módulo `Toilets` + `Media`.

---

## 1) REVIEWS (reseñas + estrellas + recálculo caches)

### `module/Reviews/Module.php`
```php
<?php
declare(strict_types=1);

namespace Reviews;

use Laminas\Mvc\MvcEvent;
use App\Util\Jwt;
use Laminas\Http\PhpEnvironment\Response;

class Module
{
    public function getConfig(): array
    {
        return require __DIR__ . '/config/module.config.php';
    }

    public function onBootstrap(MvcEvent $e): void
    {
        $app = $e->getApplication();
        $em  = $app->getEventManager();

        $em->attach(MvcEvent::EVENT_DISPATCH, function (MvcEvent $ev) {
            $rm = $ev->getRouteMatch();
            if (!$rm) return;

            $route = (string)$rm->getMatchedRouteName();
            $protected = [
                'reviews_upsert',
                'reviews_delete',
            ];
            if (!in_array($route, $protected, true)) return;

            $sm = $ev->getApplication()->getServiceManager();
            $config = $sm->get('config');
            $secret = (string)($config['mkgo']['jwt']['secret'] ?? '');

            $req = $ev->getRequest();
            $auth = $req->getHeader('Authorization')->getFieldValue();
            if (!is_string($auth) || !str_starts_with($auth, 'Bearer ')) {
                $resp = new Response();
                $resp->setStatusCode(401);
                $resp->setContent(json_encode(['ok'=>false,'error'=>'UNAUTHORIZED']));
                $resp->getHeaders()->addHeaderLine('Content-Type','application/json');
                $ev->stopPropagation(true);
                return $resp;
            }

            $token = trim(substr($auth, 7));
            $payload = Jwt::verify($token, $secret);
            if (!$payload) {
                $resp = new Response();
                $resp->setStatusCode(401);
                $resp->setContent(json_encode(['ok'=>false,'error'=>'UNAUTHORIZED']));
                $resp->getHeaders()->addHeaderLine('Content-Type','application/json');
                $ev->stopPropagation(true);
                return $resp;
            }

            $ev->getRequest()->getServerRequest()->withAttribute('auth', $payload);
        }, 100);
    }
}
```

### `module/Reviews/config/module.config.php`
```php
<?php
declare(strict_types=1);

use Reviews\Controller\ReviewsController;
use Reviews\Controller\ReviewsControllerFactory;
use Reviews\Service\ReviewsService;
use Reviews\Service\ReviewsServiceFactory;
use Reviews\Table\ReviewsTable;
use Reviews\Table\ReviewsTableFactory;
use Toilets\Table\ToiletsTable;
use Toilets\Table\ToiletsTableFactory;

return [
    'controllers' => [
        'factories' => [
            ReviewsController::class => ReviewsControllerFactory::class,
        ],
    ],
    'service_manager' => [
        'factories' => [
            ReviewsService::class => ReviewsServiceFactory::class,
            ReviewsTable::class => ReviewsTableFactory::class,
            ToiletsTable::class => ToiletsTableFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'reviews_upsert' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/toilets/:id/reviews',
                    'defaults' => [
                        'controller' => ReviewsController::class,
                        'action' => 'upsert',
                    ],
                ],
            ],
            'reviews_delete' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/reviews/:id/delete',
                    'defaults' => [
                        'controller' => ReviewsController::class,
                        'action' => 'delete',
                    ],
                ],
            ],
        ],
    ],
];
```

### `module/Reviews/src/Table/ReviewsTable.php`
```php
<?php
declare(strict_types=1);

namespace Reviews\Table;

use Laminas\Db\Adapter\Adapter;

final class ReviewsTable
{
    public function __construct(private Adapter $db) {}

    public function upsert(int $toiletId, int $userId, int $rating, ?string $body): int
    {
        $sql = "INSERT INTO mkgo_toilet_reviews (toilet_id, user_id, rating, body)
                VALUES (?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE rating=VALUES(rating), body=VALUES(body), updated_at=CURRENT_TIMESTAMP, deleted_at=NULL";
        $this->db->query($sql, [$toiletId, $userId, $rating, $body]);

        $row = $this->db->query(
            "SELECT id FROM mkgo_toilet_reviews WHERE toilet_id=? AND user_id=? LIMIT 1",
            [$toiletId, $userId]
        )->current();

        return (int)($row['id'] ?? 0);
    }

    public function softDelete(int $reviewId, int $actorUserId, bool $isAdmin): ?int
    {
        $rev = $this->db->query(
            "SELECT id, toilet_id, user_id FROM mkgo_toilet_reviews WHERE id=? AND deleted_at IS NULL",
            [$reviewId]
        )->current();

        if (!$rev) return null;

        $owner = (int)($rev['user_id'] ?? 0);
        if ($owner !== $actorUserId && !$isAdmin) return null;

        $this->db->query("UPDATE mkgo_toilet_reviews SET deleted_at=NOW(), updated_at=NOW() WHERE id=?", [$reviewId]);

        return (int)($rev['toilet_id'] ?? 0);
    }

    public function calcRating(int $toiletId): array
    {
        $row = $this->db->query(
            "SELECT COUNT(*) cnt, COALESCE(AVG(rating),0) avg_rating
             FROM mkgo_toilet_reviews
             WHERE toilet_id=? AND deleted_at IS NULL",
            [$toiletId]
        )->current();

        return [
            'count' => (int)($row['cnt'] ?? 0),
            'avg' => (float)($row['avg_rating'] ?? 0.0),
        ];
    }
}
```

### `module/Reviews/src/Table/ReviewsTableFactory.php`
```php
<?php
declare(strict_types=1);

namespace Reviews\Table;

use Psr\Container\ContainerInterface;

final class ReviewsTableFactory
{
    public function __invoke(ContainerInterface $c): ReviewsTable
    {
        return new ReviewsTable($c->get('DbAdapter'));
    }
}
```

### `module/Reviews/src/Service/ReviewsService.php`
```php
<?php
declare(strict_types=1);

namespace Reviews\Service;

use Reviews\Table\ReviewsTable;
use Toilets\Table\ToiletsTable;

final class ReviewsService
{
    public function __construct(
        private ReviewsTable $reviews,
        private ToiletsTable $toilets
    ) {}

    public function upsert(int $toiletId, int $userId, int $rating, ?string $body): array
    {
        if ($rating < 1 || $rating > 5) {
            return ['ok'=>false,'error'=>'INVALID_RATING'];
        }

        $t = $this->toilets->findById($toiletId);
        if (!$t || !empty($t['deleted_at'])) {
            return ['ok'=>false,'error'=>'TOILET_NOT_FOUND'];
        }

        if (!empty($t['is_hidden_by_system'])) {
            return ['ok'=>false,'error'=>'TOILET_HIDDEN'];
        }

        $id = $this->reviews->upsert($toiletId, $userId, $rating, $body);

        $calc = $this->reviews->calcRating($toiletId);

        $this->toilets->getAdapter()->query(
            "UPDATE mkgo_toilets
             SET rating_avg=?, rating_count=?, reviews_count=?
             WHERE id=?",
            [
                round($calc['avg'], 2),
                $calc['count'],
                $calc['count'],
                $toiletId
            ]
        );

        return ['ok'=>true,'review_id'=>$id, 'rating_avg'=>round($calc['avg'], 2), 'rating_count'=>$calc['count']];
    }

    public function delete(int $reviewId, int $actorUserId, array $roles): array
    {
        $isAdmin = in_array('admin', $roles, true) || in_array('mod', $roles, true);

        $toiletId = $this->reviews->softDelete($reviewId, $actorUserId, $isAdmin);
        if ($toiletId === null) return ['ok'=>false,'error'=>'FORBIDDEN_OR_NOT_FOUND'];

        $calc = $this->reviews->calcRating($toiletId);

        $this->toilets->getAdapter()->query(
            "UPDATE mkgo_toilets
             SET rating_avg=?, rating_count=?, reviews_count=?
             WHERE id=?",
            [
                round($calc['avg'], 2),
                $calc['count'],
                $calc['count'],
                $toiletId
            ]
        );

        return ['ok'=>true, 'toilet_id'=>$toiletId, 'rating_avg'=>round($calc['avg'], 2), 'rating_count'=>$calc['count']];
    }
}
```

> **Añadir a `ToiletsTable`** (para usar `$this->toilets->getAdapter()`):
```php
public function getAdapter(): \Laminas\Db\Adapter\Adapter
{
    return $this->db;
}
```

### `module/Reviews/src/Service/ReviewsServiceFactory.php`
```php
<?php
declare(strict_types=1);

namespace Reviews\Service;

use Psr\Container\ContainerInterface;
use Reviews\Table\ReviewsTable;
use Toilets\Table\ToiletsTable;

final class ReviewsServiceFactory
{
    public function __invoke(ContainerInterface $c): ReviewsService
    {
        return new ReviewsService(
            $c->get(ReviewsTable::class),
            $c->get(ToiletsTable::class)
        );
    }
}
```

### `module/Reviews/src/Controller/ReviewsController.php`
```php
<?php
declare(strict_types=1);

namespace Reviews\Controller;

use App\Util\JsonResponse;
use App\Util\Request;
use App\Util\Validator;
use Laminas\Mvc\Controller\AbstractActionController;
use Psr\Http\Message\ResponseInterface;
use Reviews\Service\ReviewsService;

final class ReviewsController extends AbstractActionController
{
    public function __construct(private ReviewsService $service) {}

    public function upsertAction(): ResponseInterface
    {
        $psr = $this->getRequest()->getServerRequest();
        $auth = $psr->getAttribute('auth');
        $userId = (int)($auth['uid'] ?? 0);
        if ($userId <= 0) return JsonResponse::error('UNAUTHORIZED', 401);

        $toiletId = (int)$this->params()->fromRoute('id', 0);
        if ($toiletId <= 0) return JsonResponse::error('INVALID_ID', 400);

        $data = Request::json($psr);
        $rating = Validator::requiredInt($data, 'rating', 1, 5);
        if ($rating === null) return JsonResponse::error('INVALID_RATING', 400);

        $body = Validator::optionalString($data, 'body', 2000);

        $res = $this->service->upsert($toiletId, $userId, $rating, $body);
        if (empty($res['ok'])) return JsonResponse::error((string)$res['error'], 400);

        return JsonResponse::ok($res, 201);
    }

    public function deleteAction(): ResponseInterface
    {
        $psr = $this->getRequest()->getServerRequest();
        $auth = $psr->getAttribute('auth');
        $userId = (int)($auth['uid'] ?? 0);
        $roles = is_array($auth['roles'] ?? null) ? $auth['roles'] : [];
        if ($userId <= 0) return JsonResponse::error('UNAUTHORIZED', 401);

        $reviewId = (int)$this->params()->fromRoute('id', 0);
        if ($reviewId <= 0) return JsonResponse::error('INVALID_ID', 400);

        $res = $this->service->delete($reviewId, $userId, $roles);
        if (empty($res['ok'])) return JsonResponse::error((string)$res['error'], 403);

        return JsonResponse::ok($res);
    }
}
```

### `module/Reviews/src/Controller/ReviewsControllerFactory.php`
```php
<?php
declare(strict_types=1);

namespace Reviews\Controller;

use Psr\Container\ContainerInterface;
use Reviews\Service\ReviewsService;

final class ReviewsControllerFactory
{
    public function __invoke(ContainerInterface $c): ReviewsController
    {
        return new ReviewsController($c->get(ReviewsService::class));
    }
}
```

---

## 2) COMMENTS (comentarios + replies + fotos + cache comments_count)

### `module/Comments/Module.php`
```php
<?php
declare(strict_types=1);

namespace Comments;

use Laminas\Mvc\MvcEvent;
use App\Util\Jwt;
use Laminas\Http\PhpEnvironment\Response;

class Module
{
    public function getConfig(): array
    {
        return require __DIR__ . '/config/module.config.php';
    }

    public function onBootstrap(MvcEvent $e): void
    {
        $app = $e->getApplication();
        $em  = $app->getEventManager();

        $em->attach(MvcEvent::EVENT_DISPATCH, function (MvcEvent $ev) {
            $rm = $ev->getRouteMatch();
            if (!$rm) return;

            $route = (string)$rm->getMatchedRouteName();
            $protected = [
                'comments_create',
                'comments_reply',
                'comments_attach_photo',
            ];
            if (!in_array($route, $protected, true)) return;

            $sm = $ev->getApplication()->getServiceManager();
            $config = $sm->get('config');
            $secret = (string)($config['mkgo']['jwt']['secret'] ?? '');

            $req = $ev->getRequest();
            $auth = $req->getHeader('Authorization')->getFieldValue();
            if (!is_string($auth) || !str_starts_with($auth, 'Bearer ')) {
                $resp = new Response();
                $resp->setStatusCode(401);
                $resp->setContent(json_encode(['ok'=>false,'error'=>'UNAUTHORIZED']));
                $resp->getHeaders()->addHeaderLine('Content-Type','application/json');
                $ev->stopPropagation(true);
                return $resp;
            }

            $token = trim(substr($auth, 7));
            $payload = Jwt::verify($token, $secret);
            if (!$payload) {
                $resp = new Response();
                $resp->setStatusCode(401);
                $resp->setContent(json_encode(['ok'=>false,'error'=>'UNAUTHORIZED']));
                $resp->getHeaders()->addHeaderLine('Content-Type','application/json');
                $ev->stopPropagation(true);
                return $resp;
            }

            $ev->getRequest()->getServerRequest()->withAttribute('auth', $payload);
        }, 100);
    }
}
```

### `module/Comments/config/module.config.php`
```php
<?php
declare(strict_types=1);

use Comments\Controller\CommentsController;
use Comments\Controller\CommentsControllerFactory;
use Comments\Service\CommentsService;
use Comments\Service\CommentsServiceFactory;
use Comments\Table\CommentsTable;
use Comments\Table\CommentsTableFactory;
use Comments\Table\CommentPhotosTable;
use Comments\Table\CommentPhotosTableFactory;
use Toilets\Table\ToiletsTable;
use Toilets\Table\ToiletsTableFactory;
use Media\Table\MediaTable;
use Media\Table\MediaTableFactory;

return [
    'controllers' => [
        'factories' => [
            CommentsController::class => CommentsControllerFactory::class,
        ],
    ],
    'service_manager' => [
        'factories' => [
            CommentsService::class => CommentsServiceFactory::class,
            CommentsTable::class => CommentsTableFactory::class,
            CommentPhotosTable::class => CommentPhotosTableFactory::class,
            ToiletsTable::class => ToiletsTableFactory::class,
            MediaTable::class => MediaTableFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'comments_list' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/toilets/:id/comments',
                    'defaults' => [
                        'controller' => CommentsController::class,
                        'action' => 'list',
                    ],
                ],
            ],
            'comments_create' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/toilets/:id/comments/create',
                    'defaults' => [
                        'controller' => CommentsController::class,
                        'action' => 'create',
                    ],
                ],
            ],
            'comments_reply' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/comments/:id/reply',
                    'defaults' => [
                        'controller' => CommentsController::class,
                        'action' => 'reply',
                    ],
                ],
            ],
            'comments_attach_photo' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/comments/:id/photos/attach',
                    'defaults' => [
                        'controller' => CommentsController::class,
                        'action' => 'attachPhoto',
                    ],
                ],
            ],
        ],
    ],
];
```

### `module/Comments/src/Table/CommentsTable.php`
```php
<?php
declare(strict_types=1);

namespace Comments\Table;

use Laminas\Db\Adapter\Adapter;

final class CommentsTable
{
    public function __construct(private Adapter $db) {}

    public function create(int $toiletId, int $userId, ?int $parentId, string $body): int
    {
        $sql = "INSERT INTO mkgo_toilet_comments (toilet_id, user_id, parent_comment_id, body)
                VALUES (?, ?, ?, ?)";
        $this->db->query($sql, [$toiletId, $userId, $parentId, $body]);
        return (int)$this->db->getDriver()->getLastGeneratedValue();
    }

    public function findById(int $id): ?array
    {
        $row = $this->db->query("SELECT * FROM mkgo_toilet_comments WHERE id=? AND deleted_at IS NULL", [$id])->current();
        return $row ? (array)$row : null;
    }

    public function listByToilet(int $toiletId, int $limit = 100): array
    {
        $sql = "SELECT c.id, c.toilet_id, c.user_id, c.parent_comment_id, c.body, c.created_at,
                       u.display_name, u.avatar_url
                FROM mkgo_toilet_comments c
                JOIN mkgo_users u ON u.id=c.user_id
                WHERE c.toilet_id=? AND c.deleted_at IS NULL
                ORDER BY c.created_at DESC
                LIMIT ?";
        $res = $this->db->query($sql, [$toiletId, $limit]);
        $rows = [];
        foreach ($res as $r) $rows[] = (array)$r;
        return $rows;
    }

    public function calcCount(int $toiletId): int
    {
        $row = $this->db->query(
            "SELECT COUNT(*) c FROM mkgo_toilet_comments WHERE toilet_id=? AND deleted_at IS NULL",
            [$toiletId]
        )->current();
        return (int)($row['c'] ?? 0);
    }
}
```

### `module/Comments/src/Table/CommentsTableFactory.php`
```php
<?php
declare(strict_types=1);

namespace Comments\Table;

use Psr\Container\ContainerInterface;

final class CommentsTableFactory
{
    public function __invoke(ContainerInterface $c): CommentsTable
    {
        return new CommentsTable($c->get('DbAdapter'));
    }
}
```

### `module/Comments/src/Table/CommentPhotosTable.php`
```php
<?php
declare(strict_types=1);

namespace Comments\Table;

use Laminas\Db\Adapter\Adapter;

final class CommentPhotosTable
{
    public function __construct(private Adapter $db) {}

    public function attach(int $commentId, int $mediaId, int $userId, ?string $caption): int
    {
        $sql = "INSERT INTO mkgo_comment_photos (comment_id, media_id, uploaded_by, caption)
                VALUES (?, ?, ?, ?)";
        $this->db->query($sql, [$commentId, $mediaId, $userId, $caption]);
        return (int)$this->db->getDriver()->getLastGeneratedValue();
    }

    public function listByComment(int $commentId, int $limit = 10): array
    {
        $sql = "SELECT cp.id, cp.caption, cp.created_at,
                       m.id media_id, m.public_url, m.path, m.mime_type, m.width, m.height
                FROM mkgo_comment_photos cp
                JOIN mkgo_media m ON m.id=cp.media_id
                WHERE cp.comment_id=? AND cp.deleted_at IS NULL AND m.deleted_at IS NULL AND m.status='active'
                ORDER BY cp.created_at DESC
                LIMIT ?";
        $res = $this->db->query($sql, [$commentId, $limit]);
        $rows = [];
        foreach ($res as $r) $rows[] = (array)$r;
        return $rows;
    }
}
```

### `module/Comments/src/Table/CommentPhotosTableFactory.php`
```php
<?php
declare(strict_types=1);

namespace Comments\Table;

use Psr\Container\ContainerInterface;

final class CommentPhotosTableFactory
{
    public function __invoke(ContainerInterface $c): CommentPhotosTable
    {
        return new CommentPhotosTable($c->get('DbAdapter'));
    }
}
```

### `module/Comments/src/Service/CommentsService.php`
```php
<?php
declare(strict_types=1);

namespace Comments\Service;

use Comments\Table\CommentsTable;
use Comments\Table\CommentPhotosTable;
use Media\Table\MediaTable;
use Toilets\Table\ToiletsTable;

final class CommentsService
{
    public function __construct(
        private CommentsTable $comments,
        private CommentPhotosTable $commentPhotos,
        private ToiletsTable $toilets,
        private MediaTable $media
    ) {}

    public function list(int $toiletId): array
    {
        $t = $this->toilets->findById($toiletId);
        if (!$t || !empty($t['deleted_at']) || !empty($t['is_hidden_by_system'])) {
            return ['ok'=>false,'error'=>'TOILET_NOT_FOUND'];
        }

        $items = $this->comments->listByToilet($toiletId, 120);

        foreach ($items as &$c) {
            $c['photos'] = $this->commentPhotos->listByComment((int)$c['id'], 6);
        }

        return ['ok'=>true,'items'=>$items];
    }

    public function create(int $toiletId, int $userId, string $body, ?int $parentId): array
    {
        $t = $this->toilets->findById($toiletId);
        if (!$t || !empty($t['deleted_at']) || !empty($t['is_hidden_by_system'])) {
            return ['ok'=>false,'error'=>'TOILET_NOT_FOUND'];
        }

        if ($parentId !== null) {
            $p = $this->comments->findById($parentId);
            if (!$p || (int)$p['toilet_id'] !== $toiletId) {
                return ['ok'=>false,'error'=>'INVALID_PARENT'];
            }
        }

        $id = $this->comments->create($toiletId, $userId, $parentId, $body);

        $count = $this->comments->calcCount($toiletId);
        $this->toilets->getAdapter()->query(
            "UPDATE mkgo_toilets SET comments_count=? WHERE id=?",
            [$count, $toiletId]
        );

        return ['ok'=>true,'comment_id'=>$id,'comments_count'=>$count];
    }

    public function attachPhoto(int $commentId, int $userId, int $mediaId, ?string $caption): array
    {
        $comment = $this->comments->findById($commentId);
        if (!$comment) return ['ok'=>false,'error'=>'COMMENT_NOT_FOUND'];

        $m = $this->media->findById($mediaId);
        if (!$m || (string)($m['status'] ?? '') !== 'active') return ['ok'=>false,'error'=>'MEDIA_NOT_FOUND'];

        if ((int)$comment['user_id'] !== $userId) {
            return ['ok'=>false,'error'=>'FORBIDDEN'];
        }

        $id = $this->commentPhotos->attach($commentId, $mediaId, $userId, $caption);
        return ['ok'=>true,'comment_photo_id'=>$id];
    }

    public function getParent(int $commentId): ?array
    {
        return $this->comments->findById($commentId);
    }
}
```

### `module/Comments/src/Service/CommentsServiceFactory.php`
```php
<?php
declare(strict_types=1);

namespace Comments\Service;

use Comments\Table\CommentsTable;
use Comments\Table\CommentPhotosTable;
use Media\Table\MediaTable;
use Psr\Container\ContainerInterface;
use Toilets\Table\ToiletsTable;

final class CommentsServiceFactory
{
    public function __invoke(ContainerInterface $c): CommentsService
    {
        return new CommentsService(
            $c->get(CommentsTable::class),
            $c->get(CommentPhotosTable::class),
            $c->get(ToiletsTable::class),
            $c->get(MediaTable::class)
        );
    }
}
```

### `module/Comments/src/Controller/CommentsController.php`
```php
<?php
declare(strict_types=1);

namespace Comments\Controller;

use App\Util\JsonResponse;
use App\Util\Request;
use App\Util\Validator;
use Laminas\Mvc\Controller\AbstractActionController;
use Psr\Http\Message\ResponseInterface;
use Comments\Service\CommentsService;

final class CommentsController extends AbstractActionController
{
    public function __construct(private CommentsService $service) {}

    public function listAction(): ResponseInterface
    {
        $toiletId = (int)$this->params()->fromRoute('id', 0);
        if ($toiletId <= 0) return JsonResponse::error('INVALID_ID', 400);

        $res = $this->service->list($toiletId);
        if (empty($res['ok'])) return JsonResponse::error((string)$res['error'], 404);

        return JsonResponse::ok($res);
    }

    public function createAction(): ResponseInterface
    {
        $psr = $this->getRequest()->getServerRequest();
        $auth = $psr->getAttribute('auth');
        $userId = (int)($auth['uid'] ?? 0);
        if ($userId <= 0) return JsonResponse::error('UNAUTHORIZED', 401);

        $toiletId = (int)$this->params()->fromRoute('id', 0);
        if ($toiletId <= 0) return JsonResponse::error('INVALID_ID', 400);

        $data = Request::json($psr);
        $body = Validator::requiredString($data, 'body', 2000);
        if (!$body) return JsonResponse::error('MISSING_BODY', 400);

        $res = $this->service->create($toiletId, $userId, $body, null);
        if (empty($res['ok'])) return JsonResponse::error((string)$res['error'], 400);

        return JsonResponse::ok($res, 201);
    }

    public function replyAction(): ResponseInterface
    {
        $psr = $this->getRequest()->getServerRequest();
        $auth = $psr->getAttribute('auth');
        $userId = (int)($auth['uid'] ?? 0);
        if ($userId <= 0) return JsonResponse::error('UNAUTHORIZED', 401);

        $parentId = (int)$this->params()->fromRoute('id', 0);
        if ($parentId <= 0) return JsonResponse::error('INVALID_ID', 400);

        $data = Request::json($psr);
        $body = Validator::requiredString($data, 'body', 2000);
        if (!$body) return JsonResponse::error('MISSING_BODY', 400);

        $parent = $this->service->getParent($parentId);
        if (!$parent) return JsonResponse::error('COMMENT_NOT_FOUND', 404);

        $toiletId = (int)$parent['toilet_id'];
        $res = $this->service->create($toiletId, $userId, $body, $parentId);
        if (empty($res['ok'])) return JsonResponse::error((string)$res['error'], 400);

        return JsonResponse::ok($res, 201);
    }

    public function attachPhotoAction(): ResponseInterface
    {
        $psr = $this->getRequest()->getServerRequest();
        $auth = $psr->getAttribute('auth');
        $userId = (int)($auth['uid'] ?? 0);
        if ($userId <= 0) return JsonResponse::error('UNAUTHORIZED', 401);

        $commentId = (int)$this->params()->fromRoute('id', 0);
        if ($commentId <= 0) return JsonResponse::error('INVALID_ID', 400);

        $data = Request::json($psr);
        $mediaId = Validator::requiredInt($data, 'media_id', 1, PHP_INT_MAX);
        if ($mediaId === null) return JsonResponse::error('MISSING_MEDIA_ID', 400);

        $caption = Validator::optionalString($data, 'caption', 300);

        $res = $this->service->attachPhoto($commentId, $userId, $mediaId, $caption);
        if (empty($res['ok'])) return JsonResponse::error((string)$res['error'], 400);

        return JsonResponse::ok($res, 201);
    }
}
```

### `module/Comments/src/Controller/CommentsControllerFactory.php`
```php
<?php
declare(strict_types=1);

namespace Comments\Controller;

use Comments\Service\CommentsService;
use Psr\Container\ContainerInterface;

final class CommentsControllerFactory
{
    public function __invoke(ContainerInterface $c): CommentsController
    {
        return new CommentsController($c->get(CommentsService::class));
    }
}
```

---

## 3) REPORTS (denuncias + admin/mod)

### `module/Reports/Module.php`
```php
<?php
declare(strict_types=1);

namespace Reports;

use Laminas\Mvc\MvcEvent;
use App\Util\Jwt;
use Laminas\Http\PhpEnvironment\Response;

class Module
{
    public function getConfig(): array { return require __DIR__ . '/config/module.config.php'; }

    public function onBootstrap(MvcEvent $e): void
    {
        $app = $e->getApplication();
        $em  = $app->getEventManager();

        $em->attach(MvcEvent::EVENT_DISPATCH, function (MvcEvent $ev) {
            $rm = $ev->getRouteMatch();
            if (!$rm) return;

            $route = (string)$rm->getMatchedRouteName();
            $protected = [
                'reports_create',
                'reports_admin_list',
                'reports_admin_resolve',
            ];
            if (!in_array($route, $protected, true)) return;

            $sm = $ev->getApplication()->getServiceManager();
            $config = $sm->get('config');
            $secret = (string)($config['mkgo']['jwt']['secret'] ?? '');

            $req = $ev->getRequest();
            $auth = $req->getHeader('Authorization')->getFieldValue();
            if (!is_string($auth) || !str_starts_with($auth, 'Bearer ')) {
                $resp = new Response();
                $resp->setStatusCode(401);
                $resp->setContent(json_encode(['ok'=>false,'error'=>'UNAUTHORIZED']));
                $resp->getHeaders()->addHeaderLine('Content-Type','application/json');
                $ev->stopPropagation(true);
                return $resp;
            }

            $token = trim(substr($auth, 7));
            $payload = Jwt::verify($token, $secret);
            if (!$payload) {
                $resp = new Response();
                $resp->setStatusCode(401);
                $resp->setContent(json_encode(['ok'=>false,'error'=>'UNAUTHORIZED']));
                $resp->getHeaders()->addHeaderLine('Content-Type','application/json');
                $ev->stopPropagation(true);
                return $resp;
            }

            if (in_array($route, ['reports_admin_list','reports_admin_resolve'], true)) {
                $roles = is_array($payload['roles'] ?? null) ? $payload['roles'] : [];
                if (!in_array('admin', $roles, true) && !in_array('mod', $roles, true)) {
                    $resp = new Response();
                    $resp->setStatusCode(403);
                    $resp->setContent(json_encode(['ok'=>false,'error'=>'FORBIDDEN']));
                    $resp->getHeaders()->addHeaderLine('Content-Type','application/json');
                    $ev->stopPropagation(true);
                    return $resp;
                }
            }

            $ev->getRequest()->getServerRequest()->withAttribute('auth', $payload);
        }, 100);
    }
}
```

### `module/Reports/config/module.config.php`
```php
<?php
declare(strict_types=1);

use Reports\Controller\ReportsController;
use Reports\Controller\ReportsControllerFactory;
use Reports\Service\ReportsService;
use Reports\Service\ReportsServiceFactory;
use Reports\Table\ReportsTable;
use Reports\Table\ReportsTableFactory;

return [
    'controllers' => [
        'factories' => [
            ReportsController::class => ReportsControllerFactory::class,
        ],
    ],
    'service_manager' => [
        'factories' => [
            ReportsService::class => ReportsServiceFactory::class,
            ReportsTable::class => ReportsTableFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'reports_create' => [
                'type' => 'Literal',
                'options' => [
                    'route' => '/reports',
                    'defaults' => [
                        'controller' => ReportsController::class,
                        'action' => 'create',
                    ],
                ],
            ],
            'reports_admin_list' => [
                'type' => 'Literal',
                'options' => [
                    'route' => '/admin/reports',
                    'defaults' => [
                        'controller' => ReportsController::class,
                        'action' => 'adminList',
                    ],
                ],
            ],
            'reports_admin_resolve' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/admin/reports/:id/resolve',
                    'defaults' => [
                        'controller' => ReportsController::class,
                        'action' => 'adminResolve',
                    ],
                ],
            ],
        ],
    ],
];
```

### `module/Reports/src/Table/ReportsTable.php`
```php
<?php
declare(strict_types=1);

namespace Reports\Table;

use Laminas\Db\Adapter\Adapter;

final class ReportsTable
{
    public function __construct(private Adapter $db) {}

    public function create(array $d): int
    {
        $sql = "INSERT INTO mkgo_reports
                (reported_by, target_type, target_id, reason_code, details, status)
                VALUES (?, ?, ?, ?, ?, 'open')";
        $this->db->query($sql, [
            $d['reported_by'],
            $d['target_type'],
            $d['target_id'],
            $d['reason_code'],
            $d['details'],
        ]);
        return (int)$this->db->getDriver()->getLastGeneratedValue();
    }

    public function listOpen(int $limit = 200): array
    {
        $sql = "SELECT r.*, u.display_name reporter_name
                FROM mkgo_reports r
                JOIN mkgo_users u ON u.id=r.reported_by
                WHERE r.status IN ('open','in_review')
                ORDER BY r.created_at DESC
                LIMIT ?";
        $res = $this->db->query($sql, [$limit]);
        $rows = [];
        foreach ($res as $r) $rows[] = (array)$r;
        return $rows;
    }

    public function resolve(int $id, int $resolvedBy, string $status, ?string $action, ?string $note): bool
    {
        $allowedStatus = ['resolved','rejected','in_review'];
        if (!in_array($status, $allowedStatus, true)) return false;

        $sql = "UPDATE mkgo_reports
                SET status=?, resolved_action=?, resolved_by=?, resolved_note=?, updated_at=NOW()
                WHERE id=?";
        $this->db->query($sql, [$status, $action, $resolvedBy, $note, $id]);
        return true;
    }
}
```

### `module/Reports/src/Table/ReportsTableFactory.php`
```php
<?php
declare(strict_types=1);

namespace Reports\Table;

use Psr\Container\ContainerInterface;

final class ReportsTableFactory
{
    public function __invoke(ContainerInterface $c): ReportsTable
    {
        return new ReportsTable($c->get('DbAdapter'));
    }
}
```

### `module/Reports/src/Service/ReportsService.php`
```php
<?php
declare(strict_types=1);

namespace Reports\Service;

use Reports\Table\ReportsTable;

final class ReportsService
{
    public function __construct(private ReportsTable $reports) {}

    public function create(int $userId, string $targetType, int $targetId, string $reasonCode, ?string $details): array
    {
        $allowedTarget = ['toilet','review','comment','photo','user'];
        if (!in_array($targetType, $allowedTarget, true)) return ['ok'=>false,'error'=>'INVALID_TARGET_TYPE'];

        $allowedReason = ['spam','fake','harassment','nudity','hate','illegal','wrong_location','duplicate','privacy','other'];
        if (!in_array($reasonCode, $allowedReason, true)) return ['ok'=>false,'error'=>'INVALID_REASON'];

        $id = $this->reports->create([
            'reported_by' => $userId,
            'target_type' => $targetType,
            'target_id' => $targetId,
            'reason_code' => $reasonCode,
            'details' => $details,
        ]);

        return ['ok'=>true,'report_id'=>$id];
    }

    public function adminList(): array
    {
        return ['ok'=>true,'items'=>$this->reports->listOpen(200)];
    }

    public function adminResolve(int $reportId, int $adminId, string $status, ?string $action, ?string $note): array
    {
        $ok = $this->reports->resolve($reportId, $adminId, $status, $action, $note);
        if (!$ok) return ['ok'=>false,'error'=>'INVALID_STATUS'];
        return ['ok'=>true,'report_id'=>$reportId];
    }
}
```

### `module/Reports/src/Service/ReportsServiceFactory.php`
```php
<?php
declare(strict_types=1);

namespace Reports\Service;

use Psr\Container\ContainerInterface;
use Reports\Table\ReportsTable;

final class ReportsServiceFactory
{
    public function __invoke(ContainerInterface $c): ReportsService
    {
        return new ReportsService($c->get(ReportsTable::class));
    }
}
```

### `module/Reports/src/Controller/ReportsController.php`
```php
<?php
declare(strict_types=1);

namespace Reports\Controller;

use App\Util\JsonResponse;
use App\Util\Request;
use App\Util\Validator;
use Laminas\Mvc\Controller\AbstractActionController;
use Psr\Http\Message\ResponseInterface;
use Reports\Service\ReportsService;

final class ReportsController extends AbstractActionController
{
    public function __construct(private ReportsService $service) {}

    public function createAction(): ResponseInterface
    {
        $psr = $this->getRequest()->getServerRequest();
        $auth = $psr->getAttribute('auth');
        $userId = (int)($auth['uid'] ?? 0);
        if ($userId <= 0) return JsonResponse::error('UNAUTHORIZED', 401);

        $data = Request::json($psr);

        $targetType = Validator::requiredString($data, 'target_type', 20);
        $targetId = Validator::requiredInt($data, 'target_id', 1, PHP_INT_MAX);
        $reason = Validator::requiredString($data, 'reason_code', 30);
        if (!$targetType || !$reason || $targetId === null) return JsonResponse::error('INVALID_PARAMS', 400);

        $details = Validator::optionalString($data, 'details', 1200);

        $res = $this->service->create($userId, $targetType, $targetId, $reason, $details);
        if (empty($res['ok'])) return JsonResponse::error((string)$res['error'], 400);

        return JsonResponse::ok($res, 201);
    }

    public function adminListAction(): ResponseInterface
    {
        $res = $this->service->adminList();
        return JsonResponse::ok($res);
    }

    public function adminResolveAction(): ResponseInterface
    {
        $psr = $this->getRequest()->getServerRequest();
        $auth = $psr->getAttribute('auth');
        $adminId = (int)($auth['uid'] ?? 0);
        if ($adminId <= 0) return JsonResponse::error('UNAUTHORIZED', 401);

        $reportId = (int)$this->params()->fromRoute('id', 0);
        if ($reportId <= 0) return JsonResponse::error('INVALID_ID', 400);

        $data = Request::json($psr);

        $status = Validator::requiredString($data, 'status', 20);
        if (!$status) return JsonResponse::error('MISSING_STATUS', 400);

        $action = Validator::optionalString($data, 'resolved_action', 40);
        $note = Validator::optionalString($data, 'resolved_note', 800);

        $res = $this->service->adminResolve($reportId, $adminId, $status, $action, $note);
        if (empty($res['ok'])) return JsonResponse::error((string)$res['error'], 400);

        return JsonResponse::ok($res);
    }
}
```

### `module/Reports/src/Controller/ReportsControllerFactory.php`
```php
<?php
declare(strict_types=1);

namespace Reports\Controller;

use Psr\Container\ContainerInterface;
use Reports\Service\ReportsService;

final class ReportsControllerFactory
{
    public function __invoke(ContainerInterface $c): ReportsController
    {
        return new ReportsController($c->get(ReportsService::class));
    }
}
```

---

## 4) USERS (`/me` + `/me/update`)

### `module/Users/Module.php`
```php
<?php
declare(strict_types=1);

namespace Users;

use Laminas\Mvc\MvcEvent;
use App\Util\Jwt;
use Laminas\Http\PhpEnvironment\Response;

class Module
{
    public function getConfig(): array
    {
        return require __DIR__ . '/config/module.config.php';
    }

    public function onBootstrap(MvcEvent $e): void
    {
        $app = $e->getApplication();
        $em  = $app->getEventManager();

        $em->attach(MvcEvent::EVENT_DISPATCH, function (MvcEvent $ev) {
            $rm = $ev->getRouteMatch();
            if (!$rm) return;

            $route = (string)$rm->getMatchedRouteName();
            $protected = [
                'users_me',
                'users_me_update',
            ];
            if (!in_array($route, $protected, true)) return;

            $sm = $ev->getApplication()->getServiceManager();
            $config = $sm->get('config');
            $secret = (string)($config['mkgo']['jwt']['secret'] ?? '');

            $req = $ev->getRequest();
            $auth = $req->getHeader('Authorization')->getFieldValue();
            if (!is_string($auth) || !str_starts_with($auth, 'Bearer ')) {
                $resp = new Response();
                $resp->setStatusCode(401);
                $resp->setContent(json_encode(['ok'=>false,'error'=>'UNAUTHORIZED']));
                $resp->getHeaders()->addHeaderLine('Content-Type','application/json');
                $ev->stopPropagation(true);
                return $resp;
            }

            $token = trim(substr($auth, 7));
            $payload = Jwt::verify($token, $secret);
            if (!$payload) {
                $resp = new Response();
                $resp->setStatusCode(401);
                $resp->setContent(json_encode(['ok'=>false,'error'=>'UNAUTHORIZED']));
                $resp->getHeaders()->addHeaderLine('Content-Type','application/json');
                $ev->stopPropagation(true);
                return $resp;
            }

            $ev->getRequest()->getServerRequest()->withAttribute('auth', $payload);
        }, 100);
    }
}
```

### `module/Users/config/module.config.php`
```php
<?php
declare(strict_types=1);

use Users\Controller\UsersController;
use Users\Controller\UsersControllerFactory;
use Users\Table\UsersTable;
use Users\Table\UsersTableFactory;

return [
    'controllers' => [
        'factories' => [
            UsersController::class => UsersControllerFactory::class,
        ],
    ],
    'service_manager' => [
        'factories' => [
            UsersTable::class => UsersTableFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'users_me' => [
                'type' => 'Literal',
                'options' => [
                    'route' => '/me',
                    'defaults' => [
                        'controller' => UsersController::class,
                        'action' => 'me',
                    ],
                ],
            ],
            'users_me_update' => [
                'type' => 'Literal',
                'options' => [
                    'route' => '/me/update',
                    'defaults' => [
                        'controller' => UsersController::class,
                        'action' => 'update',
                    ],
                ],
            ],
        ],
    ],
];
```

### `module/Users/src/Table/UsersTable.php`
```php
<?php
declare(strict_types=1);

namespace Users\Table;

use Laminas\Db\Adapter\Adapter;

final class UsersTable
{
    public function __construct(private Adapter $db) {}

    public function findById(int $id): ?array
    {
        $row = $this->db->query("SELECT id, email, display_name, avatar_url, created_at FROM mkgo_users WHERE id=? AND deleted_at IS NULL", [$id])->current();
        return $row ? (array)$row : null;
    }

    public function updateProfile(int $id, ?string $displayName, ?string $avatarUrl): void
    {
        $sql = "UPDATE mkgo_users SET display_name=COALESCE(?, display_name), avatar_url=COALESCE(?, avatar_url), updated_at=NOW() WHERE id=?";
        $this->db->query($sql, [$displayName, $avatarUrl, $id]);
    }
}
```

### `module/Users/src/Table/UsersTableFactory.php`
```php
<?php
declare(strict_types=1);

namespace Users\Table;

use Psr\Container\ContainerInterface;

final class UsersTableFactory
{
    public function __invoke(ContainerInterface $c): UsersTable
    {
        return new UsersTable($c->get('DbAdapter'));
    }
}
```

### `module/Users/src/Controller/UsersController.php`
```php
<?php
declare(strict_types=1);

namespace Users\Controller;

use App\Util\JsonResponse;
use App\Util\Request;
use App\Util\Validator;
use Laminas\Mvc\Controller\AbstractActionController;
use Psr\Http\Message\ResponseInterface;
use Users\Table\UsersTable;

final class UsersController extends AbstractActionController
{
    public function __construct(private UsersTable $users) {}

    public function meAction(): ResponseInterface
    {
        $psr = $this->getRequest()->getServerRequest();
        $auth = $psr->getAttribute('auth');
        $userId = (int)($auth['uid'] ?? 0);
        if ($userId <= 0) return JsonResponse::error('UNAUTHORIZED', 401);

        $u = $this->users->findById($userId);
        if (!$u) return JsonResponse::error('NOT_FOUND', 404);

        return JsonResponse::ok(['user'=>$u, 'roles'=>$auth['roles'] ?? []]);
    }

    public function updateAction(): ResponseInterface
    {
        $psr = $this->getRequest()->getServerRequest();
        $auth = $psr->getAttribute('auth');
        $userId = (int)($auth['uid'] ?? 0);
        if ($userId <= 0) return JsonResponse::error('UNAUTHORIZED', 401);

        $data = Request::json($psr);

        $displayName = Validator::optionalString($data, 'display_name', 120);
        $avatarUrl = Validator::optionalString($data, 'avatar_url', 700);

        if ($displayName === null && $avatarUrl === null) {
            return JsonResponse::error('NOTHING_TO_UPDATE', 400);
        }

        $this->users->updateProfile($userId, $displayName, $avatarUrl);

        $u = $this->users->findById($userId);
        return JsonResponse::ok(['user'=>$u]);
    }
}
```

### `module/Users/src/Controller/UsersControllerFactory.php`
```php
<?php
declare(strict_types=1);

namespace Users\Controller;

use Psr\Container\ContainerInterface;
use Users\Table\UsersTable;

final class UsersControllerFactory
{
    public function __invoke(ContainerInterface $c): UsersController
    {
        return new UsersController($c->get(UsersTable::class));
    }
}
```
