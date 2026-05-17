de# API endpoints (resumen basico)

## Convenciones
- Base path: `/api/v1`
- Content-Type: `application/json`
- Tipos: `uuid` = string UUID, `datetime` = ISO-8601, `date` = ISO-8601, `string`, `number`, `boolean`, `array<T>`.

## Autenticacion y autorizacion
- Auth principal: JWT Bearer en header `Authorization: Bearer <token>`.
- Publicos: `/api/v1/auth/**`.
- En configuracion global se permite `/api/v1/announcements/**` y `/api/v1/comments/**`, pero algunos endpoints tienen `@PreAuthorize` (p. ej. comentarios), lo cual sigue exigiendo autenticacion.
- Varios endpoints validan empresa asociada (companyId) via `IamContextFacade`; en esos casos se requiere usuario autenticado y asociado a una compania.

## Endpoints REST

### Announcements
- `POST /api/v1/announcements` auth: Bearer + company. Body: `CreateAnnouncementResource`. Resp: `AnnouncementResource` (201)
- `GET /api/v1/announcements/{announcementId}` auth: Bearer + company. Resp: `AnnouncementResource`
- `GET /api/v1/announcements` auth: Bearer + company. Resp: `AnnouncementResource[]`
- `GET /api/v1/announcements/priority/{priority}` auth: Bearer + company. Path: `priority` = `NORMAL|HIGH|URGENT`. Resp: `AnnouncementResource[]`
- `GET /api/v1/announcements/creator/{createdBy}` auth: Bearer + company. Resp: `AnnouncementResource[]`
- `PUT /api/v1/announcements/{announcementId}` auth: Bearer + company. Body: `UpdateAnnouncementResource`. Resp: `AnnouncementResource`
- `DELETE /api/v1/announcements/{announcementId}` auth: Bearer + company. Resp: 204

### Comments
- `POST /api/v1/announcements/{announcementId}/comments` auth: Bearer (`@PreAuthorize isAuthenticated`). Body: `CreateCommentResource`. Resp: `CommentResource` (201)
- `GET /api/v1/announcements/{announcementId}/comments` auth: Bearer. Resp: `CommentResource[]`
- `GET /api/v1/comments/{commentId}` auth: Bearer. Resp: `CommentResource`
- `DELETE /api/v1/comments/{commentId}` auth: Bearer. Resp: 204

### Events
- `POST /api/v1/events` auth: Bearer + role `ROLE_ADMIN` or `MANAGER`. Body: `CreateEventResource`. Resp: `EventResource` (201)
- `GET /api/v1/events/{eventId}` auth: Bearer + company. Resp: `EventResource`
- `GET /api/v1/events` auth: Bearer + company. Query: `userId?: uuid`, `filterType?: recipient|creator`. Resp: `EventResource[]`
- `GET /api/v1/events/calendar` auth: Bearer + company. Query: `userId?: uuid`. Resp: `EventResource[]`
- `PUT /api/v1/events/{eventId}` auth: Bearer + role `ROLE_ADMIN` or `MANAGER`. Body: `UpdateEventResource`. Resp: `EventResource`
- `DELETE /api/v1/events/{eventId}` auth: Bearer + role `ROLE_ADMIN` or `MANAGER`. Resp: 204

### Company
- `POST /api/v1/companies` auth: Bearer + role `ROLE_ADMIN` or `ROLE_MANAGER`. Body: `CreateCompanyResource`. Resp: `CompanyResource` (201)
- `GET /api/v1/companies/{id}` auth: Bearer. Resp: `CompanyResource`
- `GET /api/v1/companies/user/{userId}` auth: Bearer. Resp: `CompanyResource`
- `GET /api/v1/companies` auth: Bearer. Resp: `CompanyResource[]`
- `PUT /api/v1/companies/{id}` auth: Bearer + role `ROLE_ADMIN` or `ROLE_MANAGER`. Body: `UpdateCompanyResource`. Resp: `CompanyResource`
- `DELETE /api/v1/companies/{id}` auth: Bearer + role `ROLE_ADMIN` or `ROLE_MANAGER`. Resp: 200 (string)

### IAM (auth)
- `POST /api/v1/auth/sign-in` public. Body: `SignInResource`. Resp: `AuthenticatedUserResource`
- `POST /api/v1/auth/sign-up` public. Body: `SignUpResource`. Resp: `UserResource` (201)

### Users
- `GET /api/v1/users` auth: Bearer. Resp: `UserResource[]`
- `GET /api/v1/users/{userId}` auth: Bearer. Resp: `UserResource`
- `PUT /api/v1/users/{userId}` auth: Bearer. Body: `UpdateUserResource`. Resp: `UserResource`
- `PUT /api/v1/users/{userId}/company` auth: Bearer + role `ROLE_ADMIN` or `ROLE_MANAGER`. Body: `AssignCompanyResource`. Resp: `UserResource`
- `POST /api/v1/users/me/company/join` auth: Bearer. Body: `JoinCompanyResource`. Resp: `UserResource`

### Roles
- `GET /ap/v1/roles` auth: Bearer. Resp: `RoleResource[]` (nota: ruta definida con `ap` en el controlador)

### Profiles
- `POST /api/v1/profiles` auth: Bearer. Body: `CreateProfileResource`. Resp: `ProfileResource` (201)
- `GET /api/v1/profiles/me` auth: Bearer. Resp: `ProfileResource`
- `GET /api/v1/profiles/{profileId}` auth: Bearer. Resp: `ProfileResource`
- `GET /api/v1/profiles/user/{userId}` auth: Bearer. Resp: `ProfileResource`
- `GET /api/v1/profiles` auth: Bearer. Resp: `ProfileResource[]`
- `GET /api/v1/profiles/company/{companyId}` auth: Bearer. Resp: `ProfileResource[]`
- `PUT /api/v1/profiles/{profileId}` auth: Bearer + (ROLE_ADMIN o propietario). Body: `UpdateProfileResource`. Resp: `ProfileResource`

### Notifications
- `GET /api/v1/notifications/{userId}` auth: Bearer. Resp: `NotificationResource[]`
- `GET /api/v1/notifications/{id}/status` auth: Bearer. Resp: `NotificationStatusResource`
- `GET /api/v1/notifications/notification/{id}` auth: Bearer. Resp: `NotificationResource`
- `PUT /api/v1/notifications/{id}/status` auth: Bearer. Body: `UpdateNotificationStatusResource`. Resp: `NotificationStatusResource`
- `POST /api/v1/notifications` auth: Bearer. Body: `CreateNotificationResource`. Resp: `NotificationResource` (201)

### Dashboard
- `GET /api/v1/dashboard/users/{userId}/announcements/views` auth: Bearer. Resp: `UserAnnouncementViewResource[]`
- `GET /api/v1/dashboard/announcements/{announcementId}/users/views` auth: Bearer. Resp: `AnnouncementViewerResource[]`
- `GET /api/v1/dashboard/users/{userId}/events/views` auth: Bearer. Resp: `UserEventViewResource[]`
- `GET /api/v1/dashboard/events/{eventId}/users/views` auth: Bearer. Resp: `EventViewerResource[]`
- `GET /api/v1/dashboard/views/summary` auth: Bearer. Resp: `ViewsSummaryResource`
- `GET /api/v1/dashboard/announcements/{announcementId}/stats` auth: Bearer. Resp: `AnnouncementStatsResource`
- `GET /api/v1/dashboard/events/{eventId}/stats` auth: Bearer. Resp: `EventStatsResource`

### Analytics
- `POST /api/v1/analytics/announcements/{announcementId}/views` auth: Bearer. Body: `RegisterViewResource`. Resp: `ViewRegistrationResponseResource` (200/201)
- `POST /api/v1/analytics/events/{eventId}/views` auth: Bearer. Body: `RegisterViewResource`. Resp: `ViewRegistrationResponseResource` (200/201)

### Chat - Groups
- `POST /api/v1/groups` auth: Bearer + company. Body: `CreateGroupResource`. Resp: `GroupResource` (201)
- `GET /api/v1/groups/{groupId}` auth: Bearer + company. Resp: `GroupResource`
- `GET /api/v1/groups?userId={uuid}` auth: Bearer + company. Resp: `GroupResource[]`
- `GET /api/v1/groups/visibility/{visibility}` auth: Bearer + company. Path: `PUBLIC|PRIVATE`. Resp: `GroupResource[]`
- `PUT /api/v1/groups/{groupId}` auth: Bearer + company. Body: `UpdateGroupResource`. Resp: `GroupResource`
- `PATCH /api/v1/groups/{groupId}/visibility` auth: Bearer + company. Body: `UpdateGroupVisibilityResource`. Resp: `GroupResource`
- `POST /api/v1/groups/{groupId}/members` auth: Bearer + company. Body: `AddMemberToGroupResource`. Resp: `GroupResource`
- `DELETE /api/v1/groups/{groupId}/members` auth: Bearer + company. Body: `RemoveMemberFromGroupResource`. Resp: `GroupResource`
- `DELETE /api/v1/groups/{groupId}` auth: Bearer + company. Resp: 204

### Chat - Messages
- `POST /api/v1/groups/{groupId}/messages` auth: Bearer + company. Body: `CreateMessageResource`. Resp: `MessageResource` (201)
- `GET /api/v1/groups/{groupId}/messages` auth: Bearer + company. Resp: `MessageResource[]`
- `GET /api/v1/groups/{groupId}/messages/{messageId}` auth: Bearer + company. Resp: `MessageResource`
- `GET /api/v1/groups/{groupId}/messages/status/{status}` auth: Bearer. Path: `SENT|EDITED|DELETED`. Resp: `MessageResource[]`
- `PUT /api/v1/groups/{groupId}/messages/{messageId}` auth: Bearer + company. Body: `UpdateMessageBodyResource`. Resp: `MessageResource`
- `PATCH /api/v1/groups/{groupId}/messages/{messageId}/status` auth: Bearer + company. Body: `UpdateMessageStatusResource`. Resp: `MessageResource`
- `DELETE /api/v1/groups/{groupId}/messages/{messageId}` auth: Bearer + company. Resp: 204

### Chat - Images
- `POST /api/v1/groups/{groupId}/images` auth: Bearer. Body: `CreateChatImageResource`. Resp: `ChatImageResource` (201)
- `GET /api/v1/groups/{groupId}/images` auth: Bearer + company. Resp: `ChatImageResource[]`
- `GET /api/v1/groups/{groupId}/images/{imageId}` auth: Bearer. Resp: `ChatImageResource`
- `DELETE /api/v1/groups/{groupId}/images/{imageId}` auth: Bearer. Resp: `ChatImageResource`

### FCM tokens (controlador desactivado)
- El controlador `FCMTokenController` tiene `@RestController` comentado, por lo que estos endpoints no estan expuestos salvo que se habilite.
- `POST /api/v1/users/{userId}/fcm-token` Body: `RegisterFcmTokenResource`. Resp: `FcmTokenResource`
- `GET /api/v1/users/{userId}/fcm-tokens` Resp: `FcmTokenResource[]`
- `DELETE /api/v1/users/{userId}/fcm-token?fcmToken=...` Resp: 200/404
- `DELETE /api/v1/users/{userId}/fcm-tokens` Resp: 200

## WebSocket (chat)
- Endpoint STOMP: `/ws-chat` (SockJS fallback)
- Envio: `/app/chat.send/{groupId}`
- Suscripcion: `/topic/group.{groupId}`
- Errores: `/user/queue/errors`
- Payload: `SendMessageWsPayload`
- Auth: JWT en frame STOMP `CONNECT` (validado por `WebSocketAuthChannelInterceptor`)

## Schemas (request/response)

### Announcement
**CreateAnnouncementResource**
```json
{
  "title": "string",
  "description": "string",
  "image": "string|null",
  "priority": "string (NORMAL|HIGH|URGENT)",
  "createdBy": "uuid"
}
```
**UpdateAnnouncementResource**
```json
{
  "title": "string",
  "description": "string",
  "image": "string|null",
  "priority": "string (NORMAL|HIGH|URGENT)"
}
```
**AnnouncementResource**
```json
{
  "id": "uuid",
  "title": "string",
  "description": "string",
  "image": "string|null",
  "priority": "string",
  "createdBy": "uuid",
  "createdAt": "date",
  "updatedAt": "date"
}
```

### Comment
**CreateCommentResource**
```json
{
  "employeeId": "uuid",
  "content": "string"
}
```
**CommentResource**
```json
{
  "id": "uuid",
  "announcementId": "uuid",
  "employeeId": "uuid",
  "content": "string",
  "createdAt": "date",
  "updatedAt": "date"
}
```

### Event
**CreateEventResource**
```json
{
  "title": "string",
  "description": "string",
  "date": "datetime",
  "location": "string|null",
  "recipientIds": "array<uuid>",
  "createdBy": "uuid"
}
```
**UpdateEventResource**
```json
{
  "title": "string|null",
  "description": "string|null",
  "date": "datetime|null",
  "location": "string|null",
  "recipientIds": "array<uuid>|null"
}
```
**EventResource**
```json
{
  "id": "uuid",
  "title": "string",
  "description": "string",
  "date": "datetime",
  "location": "string|null",
  "createdBy": "uuid",
  "recipientIds": "array<uuid>",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Company
**CreateCompanyResource**
```json
{
  "ruc": "string",
  "nombre": "string",
  "iconUrl": "string|null",
  "isActive": "boolean",
  "userId": "uuid"
}
```
**UpdateCompanyResource**
```json
{
  "ruc": "string",
  "nombre": "string",
  "iconUrl": "string|null",
  "isActive": "boolean"
}
```
**CompanyResource**
```json
{
  "id": "uuid",
  "ruc": "string",
  "nombre": "string",
  "iconUrl": "string|null",
  "isActive": "boolean",
  "userId": "uuid",
  "joinCode": "string"
}
```
**JoinCompanyResource**
```json
{
  "joinCode": "string (len=6)"
}
```

### IAM
**SignInResource**
```json
{
  "username": "string",
  "password": "string"
}
```
**SignUpResource**
```json
{
  "username": "string",
  "password": "string",
  "name": "string",
  "lastname": "string",
  "email": "string",
  "roles": "array<string>"
}
```
**AuthenticatedUserResource**
```json
{
  "id": "string",
  "username": "string",
  "token": "string",
  "companyId": "string|null"
}
```
**UserResource**
```json
{
  "id": "uuid",
  "username": "string",
  "roles": "array<string>",
  "createdAt": "string",
  "updatedAt": "string",
  "companyId": "uuid|null"
}
```
**UpdateUserResource**
```json
{
  "newPassword": "string"
}
```
**AssignCompanyResource**
```json
{
  "companyId": "uuid"
}
```
**RoleResource**
```json
{
  "id": "number",
  "name": "string"
}
```

### Profile
**CreateProfileResource**
```json
{
  "userId": "uuid",
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "avatarUrl": "string|null"
}
```
**UpdateProfileResource**
```json
{
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "avatarUrl": "string|null"
}
```
**ProfileResource**
```json
{
  "profileId": "uuid",
  "userId": "uuid",
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "fullName": "string",
  "avatarUrl": "string|null",
  "companyId": "uuid|null"
}
```

### Notification
**CreateNotificationResource**
```json
{
  "title": "string",
  "message": "string",
  "recipientIds": "array<string>",
  "priority": "string (HIGH|MEDIUM|NORMAL)"
}
```
**NotificationResource**
```json
{
  "id": "uuid",
  "title": "string",
  "message": "string",
  "recipientIds": "array<string>",
  "priority": "string (HIGH|MEDIUM|NORMAL)",
  "status": "string (PENDING|SENT|FAILED|READ)",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```
**NotificationStatusResource**
```json
{
  "id": "uuid",
  "status": "string (PENDING|SENT|FAILED|READ)"
}
```
**UpdateNotificationStatusResource**
```json
{
  "status": "string (PENDING|SENT|FAILED|READ)"
}
```
**RegisterFcmTokenResource**
```json
{
  "fcmToken": "string",
  "deviceType": "string|null",
  "deviceId": "string|null"
}
```
**FcmTokenResource**
```json
{
  "id": "uuid",
  "userId": "string",
  "fcmToken": "string",
  "deviceType": "string|null",
  "deviceId": "string|null",
  "isActive": "boolean",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Dashboard / Analytics
**RegisterViewResource**
```json
{
  "userId": "string"
}
```
**ViewRegistrationResponseResource**
```json
{
  "viewId": "string",
  "userId": "string",
  "contentId": "string",
  "viewedAt": "datetime",
  "message": "string",
  "isNewView": "boolean"
}
```
**UserAnnouncementViewResource**
```json
{
  "viewId": "string",
  "announcementId": "string",
  "announcementTitle": "string",
  "announcementContent": "string",
  "viewedAt": "datetime",
  "userId": "string",
  "userFullName": "string"
}
```
**AnnouncementViewerResource**
```json
{
  "viewId": "string",
  "userId": "string",
  "userFullName": "string",
  "userEmail": "string",
  "viewedAt": "datetime",
  "announcementId": "string",
  "announcementTitle": "string"
}
```
**UserEventViewResource**
```json
{
  "viewId": "string",
  "eventId": "string",
  "eventTitle": "string",
  "eventDescription": "string",
  "eventDate": "datetime",
  "eventLocation": "string|null",
  "viewedAt": "datetime",
  "userId": "string",
  "userFullName": "string"
}
```
**EventViewerResource**
```json
{
  "viewId": "string",
  "userId": "string",
  "userFullName": "string",
  "userEmail": "string",
  "viewedAt": "datetime",
  "eventId": "string",
  "eventTitle": "string"
}
```
**ViewsSummaryResource**
```json
{
  "totalAnnouncementViews": "number",
  "totalEventViews": "number",
  "totalUniqueUsers": "number",
  "mostViewedAnnouncement": {
    "announcementId": "string",
    "title": "string",
    "viewCount": "number"
  },
  "mostViewedEvent": {
    "announcementId": "string",
    "title": "string",
    "viewCount": "number"
  },
  "topActiveUsers": [
    {
      "userId": "string",
      "userFullName": "string",
      "totalViews": "number"
    }
  ]
}
```
**AnnouncementStatsResource**
```json
{
  "announcementId": "string",
  "announcementTitle": "string",
  "totalUsers": "number",
  "totalViews": "number",
  "viewPercentage": "number",
  "notViewedPercentage": "number",
  "viewStats": {
    "viewed": { "count": "number", "percentage": "number", "color": "string" },
    "notViewed": { "count": "number", "percentage": "number", "color": "string" }
  }
}
```
**EventStatsResource**
```json
{
  "eventId": "string",
  "eventTitle": "string",
  "totalUsers": "number",
  "totalViews": "number",
  "viewPercentage": "number",
  "notViewedPercentage": "number",
  "viewStats": {
    "viewed": { "count": "number", "percentage": "number", "color": "string" },
    "notViewed": { "count": "number", "percentage": "number", "color": "string" }
  }
}
```

### Chat - Groups
**CreateGroupResource**
```json
{
  "name": "string",
  "description": "string|null",
  "imageUrl": "string|null",
  "visibility": "string (PUBLIC|PRIVATE)",
  "memberIds": "array<uuid>",
  "createdBy": "uuid"
}
```
**UpdateGroupResource**
```json
{
  "name": "string|null",
  "description": "string|null",
  "imageUrl": "string|null"
}
```
**UpdateGroupVisibilityResource**
```json
{
  "visibility": "string (PUBLIC|PRIVATE)"
}
```
**AddMemberToGroupResource**
```json
{
  "userId": "uuid"
}
```
**RemoveMemberFromGroupResource**
```json
{
  "userId": "uuid"
}
```
**GroupResource**
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string|null",
  "imageUrl": "string|null",
  "visibility": "string",
  "memberIds": "array<uuid>",
  "memberCount": "number",
  "createdBy": "uuid",
  "createdAt": "date",
  "updatedAt": "date"
}
```

### Chat - Messages
**CreateMessageResource**
```json
{
  "senderId": "uuid",
  "body": "string"
}
```
**UpdateMessageBodyResource**
```json
{
  "body": "string"
}
```
**UpdateMessageStatusResource**
```json
{
  "status": "string (SENT|EDITED|DELETED)"
}
```
**MessageResource**
```json
{
  "messageId": "uuid",
  "groupId": "uuid",
  "senderId": "uuid",
  "body": "string",
  "status": "string (SENT|EDITED|DELETED)",
  "sentAt": "date",
  "editedAt": "date|null",
  "isEdited": "boolean",
  "isVisible": "boolean"
}
```

### Chat - Images
**CreateChatImageResource**
```json
{
  "senderId": "uuid",
  "imageUrl": "string"
}
```
**ChatImageResource**
```json
{
  "imageId": "uuid",
  "groupId": "uuid",
  "senderId": "uuid",
  "imageUrl": "string",
  "sentAt": "date",
  "isVisible": "boolean"
}
```

### WebSocket
**SendMessageWsPayload**
```json
{
  "senderId": "uuid",
  "body": "string"
}
```

