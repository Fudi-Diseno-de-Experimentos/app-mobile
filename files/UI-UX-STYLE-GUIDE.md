# CENTRALIS Mobile — UI / UX Style Guide

A description of the visual language and interaction patterns that already exist in `lib/`. Use this as the source of truth when adding new screens so the app stays consistent.

- **Design system**: Material Design 3 (`useMaterial3: true`)
- **Color mode**: Light only — no dark theme implemented
- **Type system**: Google Fonts **Manrope**
- **Language**: Spanish-first user copy, with some English strings still present (see §9)

---

## 1. Color tokens

Source: `lib/core/theme/app_colors.dart`. Use these names from `Theme.of(context).colorScheme` rather than hard-coding hex.

| Token         | Hex       | ColorScheme role | Used for |
| ------------- | --------- | ---------------- | -------- |
| Primary       | `#556973` | `primary`        | Buttons, focused borders, active tab icon, brand accents |
| Secondary     | `#B4BFC4` | `secondary`      | Input backgrounds (at 10–30% alpha), subtle borders |
| Tertiary      | `#92A1A9` | `tertiary`       | Supporting accents |
| Neutral       | `#273035` | `onSurface`      | Default text, icons |
| Destructive   | `#D32F2F` | `error`          | Validation, urgent badges, delete actions |
| Background    | `#F4F7F8` | `background`     | Scaffold/page background |
| Surface       | `#FFFFFF` | `surface`        | Cards, sheets, app bars |

Opacity conventions:

- `secondary.withValues(alpha: 0.1)` — input fill
- `secondary.withValues(alpha: 0.2)` — card border
- `onSurface.withValues(alpha: 0.05)` — card shadow
- `onSurface.withValues(alpha: 0.5)` — placeholder icon
- `primary.withValues(alpha: 0.1)` / `0.5` — priority badge fill / border

---

## 2. Typography

Source: `lib/core/theme/app_typography.dart`. All styles default to Manrope and `AppColors.neutral`.

| Style            | Weight     | When to use |
| ---------------- | ---------- | ----------- |
| `headlineLarge`  | w700 bold  | Page titles on hero screens |
| `headlineMedium` | w600       | Section headers inside a screen |
| `headlineSmall`  | w600       | Subsection / card titles |
| `bodyLarge`      | w500       | Emphasized body text |
| `bodyMedium`     | w400       | Default body copy |
| `bodySmall`      | w400       | Secondary / helper text |
| `labelLarge`     | w600, +1.0 letter-spacing | Button labels |
| `labelMedium`    | w500, +1.2 letter-spacing | Form labels |
| `labelSmall`     | w500, +1.2 letter-spacing | Captions, metadata |

Pull from `Theme.of(context).textTheme.*` — never instantiate `TextStyle` ad hoc inside a screen.

---

## 3. Spacing & radius scale

The codebase converges on a small set of values. Stick to them.

| Token        | Value | Used for |
| ------------ | ----- | -------- |
| Page padding | `24`  | Outer padding of scrollable content |
| Section gap  | `32`  | Between major form sections |
| Field gap    | `24`  | Between two adjacent form fields |
| Label gap    | `8`   | Between a field label and the input |
| Card padding | `16`  | Inside `AnnouncementCard`, list rows |
| Card margin  | `16` horizontal × `8` vertical | Spacing between cards in lists |
| Radius S     | `4`   | Badges (priority pill) |
| Radius M     | `8`   | Buttons, inputs |
| Radius L     | `12`  | Cards, image upload boxes |
| Radius XL    | `Circle` | Avatars, avatar upload |

Button height is fixed at **48px**, full-width by default.

---

## 4. Components

### 4.1 Buttons

Use `shared/widgets/primary_button.dart`. Properties:

- Full-width `FilledButton` (Material 3) at 48px height
- Border radius 8
- Loading state replaces label with a 20×20 white `CircularProgressIndicator`
- Label: 16px / w600

```dart
PrimaryButton(
  label: 'Continuar',
  isLoading: state is AuthSubmitting,
  onPressed: _onSubmit,
)
```

For secondary actions, use Material's default `TextButton` from the theme — do not introduce custom outlined variants.

### 4.2 Text fields

Use `shared/widgets/custom_text_field.dart` for auth / profile flows, or a directly styled `TextFormField` matching the same decoration for in-screen forms:

- Fill color `secondary.withValues(alpha: 0.1)` (0.3 in `CustomTextField`)
- Content padding 16×16
- Border radius 8, `BorderSide.none` for the normal state
- Focused border: `primary` at 1.5px
- Password fields: built-in suffix toggle with `Icons.visibility` / `Icons.visibility_off`
- Hint color: placeholder at 40% alpha

A field is always preceded by a w600 / 14px label using `colorScheme.onSurface` (see `create_announcement_page.dart`).

### 4.3 Cards

Reference: `features/announcements/presentation/widgets/announcement_card.dart`.

```dart
Container(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.2)),
    boxShadow: [
      BoxShadow(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ...,
)
```

Don't use Material `Card` directly — the project prefers the explicit `Container` recipe above so radii and shadow match.

### 4.4 Priority / status badges

Small pill: 8×4 padding, radius 4, font 10px bold. Background = source color at 10% alpha, border at 50% alpha.

Color mapping (announcements):

- `URGENT` → `Colors.red`
- `HIGH` → `Colors.orange`
- everything else → `primary`

Reuse this recipe for any future status indicator (e.g. event RSVP, notification level).

### 4.5 App bar

`shared/widgets/main_app_bar.dart` — elevation 0, centered title, default Material 3 styling. Use this everywhere instead of building a bespoke `AppBar`, so nav back arrows and title typography stay consistent.

### 4.6 Bottom navigation

`shared/widgets/main_layout.dart` wraps the shell route. Four tabs in fixed order:

1. **Home** — `assets/icons/home-icon.svg`
2. **Files** (Feed / Anuncios) — `assets/icons/file-icon.svg`
3. **Messages** — `assets/icons/message-square-icon.svg`
4. **Profile** — `assets/icons/user-icon.svg`

- Icons are 24×24 SVG, color-filtered (`primary` when active, grey otherwise).
- Type: `BottomNavigationBarType.fixed`, elevation 8.
- Adding a 5th tab requires both an SVG asset and a new branch in the `StatefulShellRoute`.

### 4.7 Image upload picker

`shared/widgets/image_upload_picker.dart`:

- Announcement variant: 200px tall rectangle, radius 12, dashed/secondary border at 0.5 alpha
- Avatar variant: 120px circle
- Spanish copy: "Toca para subir una imagen"
- Loading: `CircularProgressIndicator` overlay at 50% opacity
- Errors are shown via `SnackBar`, e.g. "Error al subir la imagen a la nube"
- Uses `image_picker` for source selection (Galería / Cámara) and `cloudinary_public` for upload; the resulting secure URL is what gets sent to the backend.

### 4.8 Avatars

Profile page (`features/profile/presentation/pages/profile_page.dart:87`):

- 138×138 circular container, network image with `fit: cover`
- Fallback: `Icon(Icons.person, size: 80)` at 50% alpha when there's no avatar URL

---

## 5. Screen composition pattern

Every screen follows the same skeleton:

```dart
Scaffold(
  backgroundColor: colorScheme.surface,   // white scaffold
  appBar: const MainAppBar(title: 'Crear Anuncio'),
  body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // section header (headlineSmall)
            // label (labelMedium) + field, ×N
            // SizedBox(height: 32) between sections
            PrimaryButton(...),
          ],
        ),
      ),
    ),
  ),
)
```

Rules of thumb:

- Always wrap in `SafeArea`.
- Always make form pages scrollable — keyboards on small phones will overlap otherwise.
- `crossAxisAlignment: stretch` ensures buttons and fields fill the width.
- Submit button lives at the bottom of the form, not floating.

For list screens, the body is a `BlocBuilder` on the feature's BLoC, rendering one of: loading (`CircularProgressIndicator` centered), error (centered text + retry), data (`ListView.builder` of cards).

---

## 6. Navigation

- Router: `go_router ^17.2.3`
- Entry point: `lib/app/router.dart`
- Initial route: `/sign-in`
- Auth-free routes: `/sign-in`, `/register`, `/join-company`
- Shell routes (with bottom nav): `/home`, `/files`, `/messages`, `/profile`
- Nested routes (no bottom nav):
  - `/files/create-announcement`
  - `/files/create-event`
  - `/profile/update`
- Pass entities via `context.push('/profile/update', extra: profile)` and `state.extra as ProfileEntity` on the destination side.
- Wrap routes with `BlocProvider` at the route level when a screen needs a fresh BLoC instance.

---

## 7. State, errors, and loading UX

- **Per feature BLoC**: events from UI → state class → BlocBuilder/Listener in the page.
- **Submitting**: disable the form (`PrimaryButton(isLoading: true)`); never show a full-screen spinner over a submitted form.
- **Validation**: synchronous via `validator:` on each `TextFormField`. Surface a `SnackBar` only for server-side errors.
- **Server errors**: `BlocListener` reacts to a `*Failure` state and shows a red `SnackBar`. The error message is the `Failure.message` produced by the repository.
- **Empty states**: centered icon + short Spanish copy (use `colorScheme.onSurface` at 50% alpha). Avoid empty `ListView` with no message.

---

## 8. Icons & imagery

- All bottom-nav and inline UI icons are **SVG** (`flutter_svg ^2.2.4`), kept under `assets/icons/`.
- All Material icons used inline come from the default `Icons.*` set — keep their size to 20 or 24.
- Brand logo: `assets/images/logo-centralis.svg`, 65×65 inside the `LogoHeader` widget used on auth screens.
- Network images: always wrap with a `loadingBuilder` + an error fallback (`Icon(Icons.image_not_supported)` or `Icons.person` for avatars).

---

## 9. Copy & language

The app ships primarily in **Spanish**. Examples of canonical strings already in the codebase:

- "Toca para subir una imagen"
- "Imagen del Anuncio"
- "Se requiere permiso de cámara"
- "Galería" / "Cámara"
- "Error al subir la imagen a la nube"

A few English strings still appear (mostly placeholder copy inside the announcement create page, e.g. "Enter announcement title"). When you touch any of those, translate them to Spanish at the same time.

There is no localization layer yet (no `.arb` / `intl` setup). Strings are inline in widgets. If you introduce new copy, keep it inline and in Spanish; we will migrate to `flutter_localizations` once a second language is needed.

---

## 10. Do / Don't cheat-sheet

**Do**

- Read tokens from `Theme.of(context)` — colors via `colorScheme`, text via `textTheme`.
- Reuse `PrimaryButton`, `CustomTextField`, `MainAppBar`, `MainLayout`, `ImageUploadPicker`.
- Keep page padding at 24, card padding at 16, button height at 48.
- Wrap async UI in `BlocBuilder` + `BlocListener` pairs.
- Write user-facing strings in Spanish.

**Don't**

- Don't hard-code hex colors or call `Color(0xFF...)` inside screens.
- Don't instantiate `TextStyle` ad hoc — pick one from `textTheme` and apply `.copyWith()`.
- Don't introduce a new component when one of the seven shared widgets already covers the case.
- Don't add a dark theme yet — design hasn't been validated for it.
- Don't bypass `ApiClient` for direct `Dio()` instances; auth and base URL won't apply.
