# CENTRALIS Mobile — API Endpoint Audit (Updated 2026-05-17)

Side-by-side comparison of every endpoint in `files/API-DOC.md` against what the
Flutter client (`lib/`) actually calls.

- **Base URL**: `${URL_SERVICE}/api/v1`
- **HTTP client**: Dio via `lib/core/network/api_client.dart`
- **Auth**: Bearer token via `auth_interceptor.dart`
- **Branch audited**: `feature/improve-ui`
- **Previous audit**: against the old (47-endpoint) doc; the prior revision
  re-baselined against the expanded API-DOC and recorded the resolution of
  Priorities 1–3. **This revision** records the announcements feed redesign
  (§8): the priority/creator filter chips were removed in favour of a single
  urgency-sorted feed, so `GET /announcements/priority/{priority}` and
  `GET /announcements/creator/{createdBy}` revert from USED to **Partial**
  (datasource + usecase + bloc retained, UI flow removed). Live end-to-end
  call sites drop 23 → 21.

> The API surface in `API-DOC.md` grew substantially since the last audit:
> Notifications, Dashboard, Analytics, Chat Images, expanded Groups/Messages,
> the STOMP WebSocket channel, and a (disabled) FCM controller were added. The
> coverage denominator therefore jumps from 47 → 72, so the overall percentage
> drops even though more endpoints are now wired.

---

## 1. Coverage Summary

| Service area  | Documented | Implemented | Partial† | Coverage |
| ------------- | ---------: | ----------: | -------: | -------: |
| Auth (IAM)    | 2          | 2           | 0        | 100%     |
| Users         | 5          | 2           | 0        | 40%      |
| Roles         | 1          | 0           | 0        | 0%       |
| Profiles      | 7          | 3           | 0        | 43%      |
| Announcements | 7          | 5           | 2        | 71%      |
| Comments      | 4          | 3           | 0        | 75%      |
| Events        | 6          | 4           | 0        | 67%      |
| Companies     | 6          | 0           | 0        | 0%       |
| Notifications | 5          | 0           | 0        | 0%       |
| Dashboard     | 7          | 0           | 0        | 0%       |
| Analytics     | 2          | 2           | 0        | 100%     |
| Groups (chat) | 9          | 0           | 0        | 0%       |
| Messages      | 7          | 0           | 0        | 0%       |
| Chat Images   | 4          | 0           | 0        | 0%       |
| **Total**     | **72**     | **21**      | **2**    | **~29%** |

† *Partial = datasource method exists but UI flow is not wired.* Two partial
flows this revision: `GET /announcements/priority/{priority}` and
`GET /announcements/creator/{createdBy}`. Their datasource methods, usecases
and bloc events remain, but the filter-chip UI that drove them was removed in
the feed redesign (§8). They are reusable but currently dead UI-side.

Excluded from the denominator:
- **FCM tokens (4 endpoints)** — `FCMTokenController` has `@RestController`
  commented out server-side; not exposed.
- **WebSocket / STOMP** — `/ws-chat` is not a REST endpoint; tracked separately
  in §6.

**Resolved in the prior revision (12 → 18 live call sites):**
- `PUT /announcements/{announcementId}` wired (announcement edit flow)
- `DELETE /announcements/{announcementId}` wired (delete action in `AnnouncementPage`)
- `GET /announcements/{announcementId}/comments` wired (comment thread)
- `POST /announcements/{announcementId}/comments` wired (submit comment) — **bug fixed, see §3**
- `DELETE /comments/{commentId}` wired (delete own comment)
- `PUT /events/{eventId}` wired (event edit, `CreateEventPage` edit mode)
- `DELETE /events/{eventId}` wired (event delete dialog → BLoC)

**Resolved in the prior revision (18 → 23 live call sites):**
- `GET /announcements/{announcementId}` wired (fresh detail fetch on
  `AnnouncementPage` open; route-passed data kept as fallback)
- `GET /announcements/priority/{priority}` wired (priority filter chips in
  `AnnouncementsView`)
- `GET /announcements/creator/{createdBy}` wired ("Mías" filter chip in
  `AnnouncementsView`; createdBy = current `profile.id` via `ProfileBloc`)
- `POST /analytics/announcements/{announcementId}/views` wired (fire-and-forget
  on announcement detail open)
- `POST /analytics/events/{eventId}/views` wired (fire-and-forget on event
  detail open)

**Changed this revision (23 → 21 live call sites) — feed redesign (§8):**
- `GET /announcements/{announcementId}` still wired (detail fetch unchanged)
- `GET /announcements/priority/{priority}` → **Partial**: filter chips removed.
  The feed now fetches `GET /announcements` once and sorts client-side by
  urgency (URGENT → HIGH → NORMAL) then recency. Datasource/usecase/bloc kept.
- `GET /announcements/creator/{createdBy}` → **Partial**: "Mine" chip removed.
  Datasource/usecase/bloc kept; no UI caller remains.

---

## 2. Endpoint-by-endpoint status

Legend: **USED** = wired end-to-end | **PARTIAL** = datasource/usecase/bloc
exist but no UI caller | **UNUSED** = not implemented

### 2.1 Auth

| Method | Path            | Status | File:line |
| ------ | --------------- | ------ | --------- |
| POST   | `/auth/sign-in` | USED   | `iam/data/datasources/iam_remote_datasource.dart:24` |
| POST   | `/auth/sign-up` | USED   | `iam/data/datasources/iam_remote_datasource.dart:39` |

### 2.2 Users

| Method | Path                       | Status | File:line |
| ------ | -------------------------- | ------ | --------- |
| GET    | `/users`                   | UNUSED | — |
| GET    | `/users/{userId}`          | USED   | `profile/data/datasources/profile_remote_datasource.dart:23` (called to merge roles into `/profiles/me`) |
| PUT    | `/users/{userId}`          | UNUSED | — |
| PUT    | `/users/{userId}/company`  | UNUSED | — |
| POST   | `/users/me/company/join`   | USED   | `iam/data/datasources/iam_remote_datasource.dart:54` |

### 2.3 Roles

| Method | Path             | Status | Notes |
| ------ | ---------------- | ------ | ----- |
| GET    | `/ap/v1/roles`   | UNUSED | API-DOC confirms the controller route is literally `/ap/v1/roles` (typo is server-side, not a doc error). Any client call must hit `/ap/v1/roles`, **not** `/api/v1/roles`. |

### 2.4 Profiles

| Method | Path                            | Status | File:line |
| ------ | ------------------------------- | ------ | --------- |
| POST   | `/profiles`                     | UNUSED | — (auto-created server-side on sign-up) |
| GET    | `/profiles/me`                  | USED   | `profile/data/datasources/profile_remote_datasource.dart:17` |
| GET    | `/profiles/{profileId}`         | UNUSED | — |
| GET    | `/profiles/user/{userId}`       | UNUSED | — |
| GET    | `/profiles`                     | UNUSED | — |
| GET    | `/profiles/company/{companyId}` | USED   | `profile/data/datasources/profile_remote_datasource.dart:50` |
| PUT    | `/profiles/{profileId}`         | USED   | `profile/data/datasources/profile_remote_datasource.dart:41` |

> **Mismatch fix (this revision):** `ProfileResource` has no `username` field,
> so `ProfileModel.username` was always empty. `getProfile()` now also copies
> `username` from the `/users/{userId}` merge response (`UserResource` carries
> it), alongside the existing `roles` merge. See §3.

### 2.5 Announcements

| Method | Path                                 | Status | File:line |
| ------ | ------------------------------------ | ------ | --------- |
| POST   | `/announcements`                     | USED   | `announcements/data/datasources/announcement_remote_datasource.dart:81` |
| GET    | `/announcements/{announcementId}`    | USED   | `announcements/data/datasources/announcement_remote_datasource.dart:45` (fresh detail fetch on `AnnouncementPage` open; route-passed data is the fallback) |
| GET    | `/announcements`                     | USED   | `announcements/data/datasources/announcement_remote_datasource.dart:33` |
| GET    | `/announcements/priority/{priority}` | PARTIAL | `announcements/data/datasources/announcement_remote_datasource.dart:52` (datasource/usecase/bloc intact; filter-chip UI removed in §8 feed redesign — no caller) |
| GET    | `/announcements/creator/{createdBy}` | PARTIAL | `announcements/data/datasources/announcement_remote_datasource.dart:64` (datasource/usecase/bloc intact; "Mine" chip removed in §8 feed redesign — no caller) |
| PUT    | `/announcements/{announcementId}`    | USED   | `announcements/data/datasources/announcement_remote_datasource.dart:102` (edit via `CreateAnnouncementPage` edit mode) |
| DELETE | `/announcements/{announcementId}`    | USED   | `announcements/data/datasources/announcement_remote_datasource.dart:116` (delete menu in `AnnouncementPage`) |

### 2.6 Comments

| Method | Path                                       | Status | File:line |
| ------ | ------------------------------------------ | ------ | --------- |
| POST   | `/announcements/{announcementId}/comments` | USED   | `announcements/data/datasources/comment_remote_datasource.dart:37` — **field bug fixed (see §3)** |
| GET    | `/announcements/{announcementId}/comments` | USED   | `announcements/data/datasources/comment_remote_datasource.dart:20` |
| GET    | `/comments/{commentId}`                    | UNUSED | — (list endpoint covers the UI; no single-comment fetch needed) |
| DELETE | `/comments/{commentId}`                    | USED   | `announcements/data/datasources/comment_remote_datasource.dart:46` |

### 2.7 Events

| Method | Path                | Status | File:line |
| ------ | ------------------- | ------ | --------- |
| POST   | `/events`           | USED   | `events/data/datasources/event_remote_datasource.dart:49` |
| GET    | `/events/{eventId}` | UNUSED | — (`EventPage` uses route-passed data) |
| GET    | `/events`           | USED   | `events/data/datasources/event_remote_datasource.dart:32` |
| GET    | `/events/calendar`  | UNUSED | — |
| PUT    | `/events/{eventId}` | USED   | `events/data/datasources/event_remote_datasource.dart:72` (`CreateEventPage` edit mode, `_isEditMode`) |
| DELETE | `/events/{eventId}` | USED   | `events/data/datasources/event_remote_datasource.dart:86` (`EventPage` delete dialog → `DeleteEventRequested`) |

### 2.8 Companies

Datasource (`company_remote_datasource.dart`) is an abstract stub — no
implementation. `CompanyPage` is an empty `Scaffold`.

| Method | Path                       | Status |
| ------ | -------------------------- | ------ |
| POST   | `/companies`               | UNUSED |
| GET    | `/companies/{id}`          | UNUSED |
| GET    | `/companies/user/{userId}` | UNUSED |
| GET    | `/companies`               | UNUSED |
| PUT    | `/companies/{id}`          | UNUSED |
| DELETE | `/companies/{id}`          | UNUSED |

### 2.9 Notifications *(new in API-DOC)*

| Method | Path                                | Status |
| ------ | ----------------------------------- | ------ |
| GET    | `/notifications/{userId}`           | UNUSED |
| GET    | `/notifications/{id}/status`        | UNUSED |
| GET    | `/notifications/notification/{id}`  | UNUSED |
| PUT    | `/notifications/{id}/status`        | UNUSED |
| POST   | `/notifications`                    | UNUSED |

### 2.10 Dashboard *(new in API-DOC)*

| Method | Path                                                       | Status |
| ------ | ---------------------------------------------------------- | ------ |
| GET    | `/dashboard/users/{userId}/announcements/views`            | UNUSED |
| GET    | `/dashboard/announcements/{announcementId}/users/views`    | UNUSED |
| GET    | `/dashboard/users/{userId}/events/views`                   | UNUSED |
| GET    | `/dashboard/events/{eventId}/users/views`                  | UNUSED |
| GET    | `/dashboard/views/summary`                                 | UNUSED |
| GET    | `/dashboard/announcements/{announcementId}/stats`          | UNUSED |
| GET    | `/dashboard/events/{eventId}/stats`                        | UNUSED |

### 2.11 Analytics *(new in API-DOC)*

| Method | Path                                              | Status | File:line |
| ------ | ------------------------------------------------- | ------ | --------- |
| POST   | `/analytics/announcements/{announcementId}/views` | USED   | `analytics/data/datasources/analytics_remote_datasource.dart:25` (fired from `AnnouncementPage` open) |
| POST   | `/analytics/events/{eventId}/views`               | USED   | `analytics/data/datasources/analytics_remote_datasource.dart:38` (fired from `EventPage` open) |

> Implemented this revision. New `lib/features/analytics/` clean-arch slice
> (`view_registration_entity/model` → `analytics_remote_datasource` →
> `analytics_repository(_impl)` → `register_announcement_view_usecase` /
> `register_event_view_usecase` → `AnalyticsBloc`). The bloc is a lazy
> singleton invoked directly via `sl<AnalyticsBloc>()` from the detail pages'
> `initState` — fire-and-forget; failures are swallowed so a failed telemetry
> ping never surfaces to the user. Actor id sent is `profile.id` (see open
> item #2 caveat).

### 2.12 Chat — Groups

Datasource (`chat_remote_datasource.dart`) is an abstract stub. `ChatPage`
returns an empty `Scaffold()`.

| Method | Path                                | Status |
| ------ | ----------------------------------- | ------ |
| POST   | `/groups`                           | UNUSED |
| GET    | `/groups/{groupId}`                 | UNUSED |
| GET    | `/groups?userId={uuid}`             | UNUSED |
| GET    | `/groups/visibility/{visibility}`   | UNUSED |
| PUT    | `/groups/{groupId}`                 | UNUSED |
| PATCH  | `/groups/{groupId}/visibility`      | UNUSED |
| POST   | `/groups/{groupId}/members`         | UNUSED |
| DELETE | `/groups/{groupId}/members`         | UNUSED |
| DELETE | `/groups/{groupId}`                 | UNUSED |

### 2.13 Chat — Messages

| Method | Path                                            | Status |
| ------ | ----------------------------------------------- | ------ |
| POST   | `/groups/{groupId}/messages`                    | UNUSED |
| GET    | `/groups/{groupId}/messages`                    | UNUSED |
| GET    | `/groups/{groupId}/messages/{messageId}`        | UNUSED |
| GET    | `/groups/{groupId}/messages/status/{status}`    | UNUSED |
| PUT    | `/groups/{groupId}/messages/{messageId}`        | UNUSED |
| PATCH  | `/groups/{groupId}/messages/{messageId}/status` | UNUSED |
| DELETE | `/groups/{groupId}/messages/{messageId}`        | UNUSED |

### 2.14 Chat — Images *(new in API-DOC)*

| Method | Path                                  | Status |
| ------ | ------------------------------------- | ------ |
| POST   | `/groups/{groupId}/images`            | UNUSED |
| GET    | `/groups/{groupId}/images`            | UNUSED |
| GET    | `/groups/{groupId}/images/{imageId}`  | UNUSED |
| DELETE | `/groups/{groupId}/images/{imageId}`  | UNUSED |

### 2.15 FCM tokens *(controller disabled server-side — not counted)*

`FCMTokenController` has `@RestController` commented out per API-DOC. Do not
implement on the client until the backend re-enables it.

| Method | Path                              | Status |
| ------ | --------------------------------- | ------ |
| POST   | `/users/{userId}/fcm-token`       | N/A (disabled) |
| GET    | `/users/{userId}/fcm-tokens`      | N/A (disabled) |
| DELETE | `/users/{userId}/fcm-token`       | N/A (disabled) |
| DELETE | `/users/{userId}/fcm-tokens`      | N/A (disabled) |
remian
---

## 3. Endpoint mismatch scan & fixes

### 3.1 Scan of all live call sites vs API-DOC schemas

Every one of the (then) 18 live call sites was checked, request body and
response parse, against the `API-DOC.md` request/response schemas:

| Call site | Verdict |
| --------- | ------- |
| `POST /auth/sign-in` (`SignInResource` → `AuthenticatedUserResource`) | OK |
| `POST /auth/sign-up` (`SignUpResource`) | OK |
| `POST /users/me/company/join` (`JoinCompanyResource`) | OK |
| `GET /profiles/me` (`ProfileResource`) | **Soft gap — fixed** |
| `GET /users/{userId}` (`UserResource`, roles merge) | OK |
| `PUT /profiles/{profileId}` (`UpdateProfileResource`) | OK |
| `GET /profiles/company/{companyId}` (`ProfileResource[]`) | OK |
| `GET/POST/PUT/DELETE /announcements**` (`*AnnouncementResource`) | OK |
| Comments (`CreateCommentResource` / `CommentResource`) | **Hard mismatch — fixed (prior revision)** |
| `GET/POST/PUT/DELETE /events**` (`*EventResource`) | OK |

Only the comments slice had a hard wire-format mismatch (already fixed in the
prior revision; detail below). One **soft gap** was found and fixed this
revision:

- **`ProfileResource` has no `username` field.** `ProfileModel.fromJson` reads
  `json['username']`, so `ProfileEntity.username` was always `''`. The
  `/users/{userId}` merge inside `getProfile()` previously copied only `roles`.
  Fix: it now also copies `userData['username']` into the profile data
  (`profile_remote_datasource.dart`). `UserResource` carries `username`, so the
  field is now populated. Not a crash (empty string previously), hence "soft".

No other request/response field mismatches exist among the live call sites.
(`AnnouncementModel`/`EventModel` parse ids without a `.toString()` guard, but
the server returns string UUIDs — not a defect; left as-is.)

### 3.2 Comments feature — validation & fix (prior revision, retained)

The previous audit's Priority 3 (comments) was implemented: full clean-arch
slice (`comment_entity` / `comment_model` / `comment_remote_datasource` /
`comment_repository(_impl)` / `get|create|delete_comment_usecase` /
`comment_bloc|event|state`), wired into `AnnouncementPage` and provided in
`router.dart` via `BlocProvider(create: (_) => sl<CommentBloc>())`.

**Why it did not work:** wire-format field mismatch against API-DOC.

- API-DOC `CreateCommentResource` = `{ "employeeId": "uuid", "content": "string" }`.
- API-DOC `CommentResource` returns `employeeId` (not `authorId`).
- The client POSTed `{ "content", "authorId" }` and parsed `json['authorId']`.

Effect: the backend never bound the author field on create (request rejected /
stored null), and every fetched comment had an empty `authorId`, so the
"delete own comment" affordance never appeared for non-admin authors.

**Fix applied (data boundary only — domain/bloc/UI untouched):**

- `comment_remote_datasource.dart:37` — POST body now `{ 'employeeId': authorId, 'content': content }`.
- `comment_model.dart` — `fromJson` now reads `json['employeeId']` into the
  domain `authorId`; all fields `.toString()`-guarded.
- `comment_remote_datasource.dart:20` — list parse casts each element to
  `Map<String, dynamic>` for parity with `profile_remote_datasource`.

`flutter analyze lib/features/announcements` → clean (1 pre-existing unrelated
`withOpacity` deprecation in `avatar_placeholder.dart`).

> Note on identity: the client uses `profile.id` (which resolves to
> `profileId` from `/profiles/me`) as the actor id for both
> `announcement.createdBy` and the comment `employeeId`. This is internally
> consistent across the app, but if the backend treats comment `employeeId`
> as a *user* id rather than a *profile* id, `_canDeleteComment` ownership
> checks will mismatch. Confirm the server's `employeeId` semantics — see
> open item #2.

---

## 4. Open items

| # | Issue | Still open? |
| - | ----- | ----------- |
| 1 | Roles route is `/ap/v1/roles` (server-side typo, confirmed in API-DOC) | Yes — still unimplemented; client must use `/ap/v1/roles` |
| 2 | Actor-id identity: app sends `profile.id` (= `profileId`) as comment `employeeId`, announcement `createdBy`, analytics `RegisterViewResource.userId`. Verify whether the server expects a profileId or a userId. | Open — still relevant for comments/createdBy/analytics. The `GET /announcements/creator/{createdBy}` caller was removed in the §8 feed redesign, so the "Mine"-filter symptom no longer applies; the underlying identity question remains |
| 3 | `GET /users/{userId}` still called inside `getProfile()` to merge roles (roles absent from `/profiles/me`) | Yes — dual call still in place |
| 4 | Sign-up always sends `['ROLE_USER']` | Yes — by design for now |
| 5 | View/analytics endpoints now exist (§2.11) but client sends nothing | **Resolved** — client now registers announcement & event views (§2.11) |
| 6 | Cloudinary upload is client-side; backend only stores the URL string | Yes — confirmed intentional |

---

## 5. What to implement next (re-prioritized)

**Resolved (prior revision):** event edit/delete, announcement delete,
announcement edit, comments.

**Resolved (prior revision, cont.):**
- Single announcement — `GET /announcements/{announcementId}` (fresh detail)
  wired and still in place.
- Analytics view registration — `POST /analytics/{announcements|events}/{id}/views`
  both wired fire-and-forget (§2.11).

**Changed (this revision):**
- Feed redesign (§8). Filter chips removed; `GET /announcements/priority/{priority}`
  and `GET /announcements/creator/{createdBy}` are now **Partial** (no UI
  caller). The feed loads `GET /announcements` once and sorts client-side by
  urgency then recency.

Remaining work:

### Priority 1 — Company context
- `GET /companies/user/{userId}`, `GET /companies/{id}`, `PUT /companies/{id}`,
  `POST /companies`
- The entire `lib/features/company/` tree is stubs (`CompanyEntity {}`,
  `CompanyModel {}`, abstract `CompanyRemoteDataSource {}`, empty
  `CompanyPage`); `CompanyPage` is **not even routed**. This is a from-scratch
  feature with UI/UX design work — larger than a wiring task.

### Priority 2 — Notifications *(deferred at request — not implemented)*
- `GET /notifications/{userId}`, `PUT /notifications/{id}/status`
- New slice + notification list UI; pairs with the (disabled) FCM controller —
  poll-based until FCM is re-enabled server-side. Intentionally skipped this
  pass per instruction.

### Priority 4 — Calendar view for events
- `GET /events/calendar` — calendar-formatted list; add a `table_calendar`-style
  widget as a new tab in the events section.

### Priority 5 — Chat (largest remaining feature)
- **Phase A — Groups**: `GET/POST /groups`, `GET /groups/{groupId}`,
  membership + visibility endpoints.
- **Phase B — Messages**: `GET/POST /groups/{groupId}/messages`, edit/delete/
  status; real-time via the STOMP WebSocket (§6) or polling.
- **Phase C — Chat images**: `POST/GET/DELETE /groups/{groupId}/images`.

### Priority 6 — Dashboard / stats
- `/dashboard/**` (7 endpoints) — admin analytics screens; depends on a
  company-admin context existing first (Priority 1).

### Priority 7 — User management
- `GET /users`, `PUT /users/{userId}`, `PUT /users/{userId}/company`,
  `GET /ap/v1/roles` — likely admin-only.

---

## 6. WebSocket (chat real-time) — non-REST, tracked separately

- STOMP endpoint: `/ws-chat` (SockJS fallback)
- Send: `/app/chat.send/{groupId}` — payload `SendMessageWsPayload`
- Subscribe: `/topic/group.{groupId}`
- Errors: `/user/queue/errors`
- Auth: JWT in the STOMP `CONNECT` frame
- Status: **UNUSED** — required for Priority 6 Phase B real-time messaging.

---

## 7. All current live call sites (21)

```
POST   /auth/sign-in                              iam_remote_datasource.dart:24
POST   /auth/sign-up                              iam_remote_datasource.dart:39
POST   /users/me/company/join                     iam_remote_datasource.dart:54
GET    /profiles/me                               profile_remote_datasource.dart:17
GET    /users/{userId}                            profile_remote_datasource.dart:23
PUT    /profiles/{profileId}                      profile_remote_datasource.dart:41
GET    /profiles/company/{companyId}              profile_remote_datasource.dart:50
GET    /announcements                             announcement_remote_datasource.dart:33
GET    /announcements/{announcementId}            announcement_remote_datasource.dart:45
POST   /announcements                             announcement_remote_datasource.dart:81
PUT    /announcements/{announcementId}            announcement_remote_datasource.dart:102
DELETE /announcements/{announcementId}            announcement_remote_datasource.dart:116
GET    /announcements/{announcementId}/comments   comment_remote_datasource.dart:20
POST   /announcements/{announcementId}/comments   comment_remote_datasource.dart:37
DELETE /comments/{commentId}                      comment_remote_datasource.dart:46
GET    /events                                    event_remote_datasource.dart:32
POST   /events                                    event_remote_datasource.dart:49
PUT    /events/{eventId}                          event_remote_datasource.dart:72
DELETE /events/{eventId}                          event_remote_datasource.dart:86
POST   /analytics/announcements/{id}/views        analytics_remote_datasource.dart:25
POST   /analytics/events/{id}/views               analytics_remote_datasource.dart:38
```

---

## 8. Announcements feed redesign (this revision)

UI/UX change with an API-coverage side effect — recorded here for traceability.

### 8.1 What changed

- **Filter chips removed.** `AnnouncementsView` no longer renders the
  All / Normal / High / Urgent / Mine chip row. It is now a `StatelessWidget`
  with no `_priority` / `_mine` state.
- **Single sorted feed.** The view consumes the `AnnouncementBloc` state
  produced by `FetchAnnouncements()` (`GET /announcements`, dispatched by the
  parent `CompanyFeedPage`/`HomePage` provider) and sorts client-side:
  1. urgency rank — `URGENT` → `HIGH` → `NORMAL`,
  2. then `createdAt` descending (most recent first) within a priority.
- **Text badge → urgency dot.** The `URGENT`/`HIGH`/`NORMAL` text pill was
  replaced by a colored circle: **red** = URGENT, **amber** = HIGH,
  **green** (`0xFF2E7D32`) = NORMAL. Applied in the feed card, the detail
  header, and the home mini-card for consistency.
- **New shared widget.** `announcements/presentation/widgets/priority_dot.dart`
  (`PriorityStyle.rank` / `PriorityStyle.color` + `PriorityDot`) is the single
  source of truth for urgency rank + color; removed three duplicated `switch`
  blocks.

### 8.2 API impact

| Endpoint | Before | After | Reason |
| -------- | ------ | ----- | ------ |
| `GET /announcements/priority/{priority}` | USED | PARTIAL | filter chips removed; no caller |
| `GET /announcements/creator/{createdBy}` | USED | PARTIAL | "Mine" chip removed; no caller |

Datasource methods, usecases (`GetAnnouncementsByPriorityUseCase`,
`GetAnnouncementsByCreatorUseCase`) and bloc events
(`FetchAnnouncementsByPriority`, `FetchAnnouncementsByCreator`) are
**intentionally retained** — they are correct and reusable if server-side
filtering is reintroduced, but no widget dispatches them anymore. Sorting is
purely client-side over the full `GET /announcements` payload.

`flutter analyze lib/features/announcements lib/features/home` → no new issues
(2 pre-existing unrelated deprecations: `avatar_placeholder.dart` `withOpacity`,
`home_page.dart:43` `colorScheme.background`).
