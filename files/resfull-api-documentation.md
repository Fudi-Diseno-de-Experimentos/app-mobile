# RESTful API Documentation

This documentation provides an overview of the RESTful API endpoints for the Centralis platform. The API is divided into several bounded contexts: Announcements (`anuncios`), Events (`eventos`), Company (`company`), Profile (`profile`), Identity and Access Management (`iam`), and Chat (`chat`).

All endpoints are prefixed with `/api/v1` unless stated otherwise.

---

## 📢 Announcements Context (`/api/v1/announcements`)

Handles the creation, retrieval, updating, and deletion of announcements, as well as their comments.

### Announcements
- `GET /api/v1/announcements` - Retrieve all announcements.
    - **Output Example**: `[ { "id": "uuid", "title": "...", "description": "...", "priority": "HIGH", "createdBy": "uuid", "createdAt": "..." } ]`
- `GET /api/v1/announcements/{announcementId}` - Retrieve a specific announcement by its ID.
- `GET /api/v1/announcements/priority/{priority}` - Retrieve announcements by priority level (`NORMAL`, `HIGH`, `URGENT`).
- `GET /api/v1/announcements/creator/{createdBy}` - Retrieve announcements created by a specific user.
- `POST /api/v1/announcements` - Create a new announcement.
    - **Input Example**: `{ "title": "New Holiday Policy", "description": "Details...", "image": "url", "priority": "HIGH", "createdBy": "uuid" }`
    - **Output Example**: `{ "id": "uuid", "title": "New Holiday Policy", ... }`
- `PUT /api/v1/announcements/{announcementId}` - Update an existing announcement.
- `DELETE /api/v1/announcements/{announcementId}` - Delete an announcement.

### Comments
- `GET /api/v1/announcements/{announcementId}/comments` - Retrieve all comments for a specific announcement.
- `GET /api/v1/comments/{commentId}` - Retrieve a specific comment by ID.
- `POST /api/v1/announcements/{announcementId}/comments` - Add a comment to an announcement.
    - **Input Example**: `{ "content": "Great news!", "authorId": "uuid" }`
- `DELETE /api/v1/comments/{commentId}` - Delete a comment.

---

## 📅 Events Context (`/api/v1/events`)

Manages platform events and calendar items.

- `GET /api/v1/events` - Retrieve all events.
- `GET /api/v1/events/{eventId}` - Retrieve a specific event by its ID.
- `GET /api/v1/events/calendar` - Retrieve events formatted for a calendar view.
- `POST /api/v1/events` - Create a new event.
    - **Input Example**: `{ "title": "Q1 Planning", "description": "Sales sync", "date": "2025-02-15T14:30:00", "location": "Room A", "recipientIds": ["uuid1", "uuid2"] }`
    - **Output Example**: `{ "id": "uuid", "title": "Q1 Planning", "date": "2025-02-15T14:30:00", "createdBy": "uuid", ... }`
- `PUT /api/v1/events/{eventId}` - Update an existing event.
- `DELETE /api/v1/events/{eventId}` - Delete an event.

---

## 🏢 Company Context (`/api/v1/companies`)

Manages company data.

- `GET /api/v1/companies` - Retrieve a list of all companies.
- `GET /api/v1/companies/{id}` - Retrieve details of a specific company.
- `GET /api/v1/companies/user/{userId}` - Retrieve the company associated with a specific user.
- `POST /api/v1/companies` - Create a new company profile.
    - **Input Example**: `{ "ruc": "12345678901", "nombre": "Tech Corp", "iconUrl": "url" }`
    - **Output Example**: `{ "id": "uuid", "ruc": "12345678901", "nombre": "Tech Corp", "isActive": true, "joinCode": "CODE123" }`
- `PUT /api/v1/companies/{id}` - Update company details.
- `DELETE /api/v1/companies/{id}` - Delete a company.

---

## 👤 Profile Context (`/api/v1/profiles`)

Manages user profiles and their affiliations.

- `GET /api/v1/profiles` - Retrieve all user profiles.
- `GET /api/v1/profiles/{profileId}` - Retrieve a specific profile by its ID.
- `GET /api/v1/profiles/user/{userId}` - Retrieve a profile associated with a specific user ID.
    - **Output Example**: `{ "profileId": "uuid", "userId": "uuid", "firstName": "John", "lastName": "Doe", "email": "john@example.com", "fullName": "John Doe" }`
- `GET /api/v1/profiles/company/{companyId}` - Retrieve profiles associated with a specific company ID.
- `POST /api/v1/profiles` - Create a new profile.
    - **Input Example**: `{ "firstName": "John", "lastName": "Doe", "email": "john@example.com", "avatarUrl": "url" }`
- `PUT /api/v1/profiles/{profileId}` - Update a user profile.

---

## 🔐 IAM (Identity and Access Management) Context

Handles authentication, user management, and roles.

### Authentication (`/api/v1/auth`)
- `POST /api/v1/auth/sign-in` - Authenticate a user and return a token.
    - **Input Example**: `{ "username": "admin@example.com", "password": "SecurePassword123!" }`
    - **Output Example**: `{ "id": 1, "username": "admin@example.com", "token": "eyJhb..." }`
- `POST /api/v1/auth/sign-up` - Register a new user.
    - **Input Example**: `{ "username": "user@example.com", "password": "SecurePassword123!", "roles": ["ROLE_USER"] }`

### Users (`/api/v1/users`)
- `GET /api/v1/users` - Retrieve all users.
- `GET /api/v1/users/{userId}` - Retrieve details for a specific user.
- `PUT /api/v1/users/{userId}` - Update user data.
- `PUT /api/v1/users/{userId}/company` - Update the company association for a user.

### Roles (`/api/v1/roles`)
- `GET /api/v1/roles` - Retrieve all available roles.

---

## 💬 Chat Context (`/api/v1/groups`)

Manages chat groups, messages, and related media.

### Groups
- `GET /api/v1/groups` - Retrieve all chat groups.
- `GET /api/v1/groups/{groupId}` - Retrieve specific group details.
- `POST /api/v1/groups` - Create a new chat group.
    - **Input Example**: `{ "name": "General Chat", "description": "All hands", "visibility": "PUBLIC", "companyId": "uuid", "creatorId": "uuid" }`
    - **Output Example**: `{ "id": "uuid", "name": "General Chat", "visibility": "PUBLIC", ... }`

### Messages (`/api/v1/groups/{groupId}/messages`)
- `GET /api/v1/groups/{groupId}/messages` - Retrieve all messages in a group.
- `POST /api/v1/groups/{groupId}/messages` - Send a new message to the group.
    - **Input Example**: `{ "body": "Hello team!", "senderId": "uuid" }`
    - **Output Example**: `{ "id": "uuid", "groupId": "uuid", "senderId": "uuid", "body": "Hello team!", "status": "SENT" }`
- `PUT /api/v1/groups/{groupId}/messages/{messageId}` - Update a message.
- `PATCH /api/v1/groups/{groupId}/messages/{messageId}/status` - Update the status of a message.
- `DELETE /api/v1/groups/{groupId}/messages/{messageId}` - Delete a message.

---

## 💻 Frontend Models (TypeScript)

Use the following TypeScript interfaces in your frontend project (React, Angular, Vue, etc.) to safely type the responses and requests associated with this API.

```typescript
// IAM
export interface SignInRequest {
  username?: string;
  password?: string;
}

export interface AuthenticatedUser {
  id: number;
  username: string;
  token: string;
}

// Announcements
export interface Announcement {
  id: string;
  title: string;
  description: string;
  image?: string;
  priority: 'NORMAL' | 'HIGH' | 'URGENT';
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateAnnouncementRequest {
  title: string;
  description: string;
  image?: string;
  priority: 'NORMAL' | 'HIGH' | 'URGENT';
  createdBy: string;
}

// Events
export interface Event {
  id: string;
  title: string;
  description: string;
  date: string; // ISO String LocalDateTime
  location: string;
  createdBy: string;
  recipientIds: string[];
  createdAt: string;
  updatedAt: string;
}

export interface CreateEventRequest {
  title: string;
  description: string;
  date: string; // ISO String LocalDateTime
  location: string;
  recipientIds: string[];
}

// Company
export interface Company {
  id: string;
  ruc: string;
  nombre: string;
  iconUrl: string;
  isActive: boolean;
  userId: string;
  joinCode: string;
}

// Profile
export interface Profile {
  profileId: string;
  userId: string;
  firstName: string;
  lastName: string;
  email: string;
  fullName: string;
  avatarUrl?: string;
}

// Chat Messages
export interface Message {
  id: string;
  groupId: string;
  senderId: string;
  body: string;
  status: 'SENT' | 'EDITED' | 'DELETED';
  createdAt: string;
  updatedAt: string;
}

export interface CreateMessageRequest {
  body: string;
  senderId: string;
}
```
