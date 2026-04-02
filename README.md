# MotoTracker

MotoTracker is a dark-first, premium motorcycle management app built with Flutter 3.x+, Dart 3, Material 3, Riverpod, GoRouter, Supabase, and Gemini AI.

## Implemented Scope

- Dark-only custom design system in `lib/core/theme/AppTheme.dart` with required tokens.
- Auth flow (email/password) with session persistence via Supabase.
- Garage list, add motorcycle with AI autofill, motorcycle detail, and profile/sign out.
- AI parsing service in `lib/features/ai/data/groq_ai_service.dart`.
- Feature-based localization in English and Spanish using `slang` (`lib/i18n/*_en.i18n.json`, `lib/i18n/*_es.i18n.json`).
- Feature-modular structure aligned with Clean Architecture boundaries.

## Tech Stack

- Flutter (Material 3)
- Riverpod
- GoRouter
- Supabase (Auth, Postgres, Storage)
- Gemini API
- intl
- flutter_animate

## Project Structure

```text
lib/
 ├── app/
 ├── core/
 │    ├── router/
 │    ├── theme/
 │    ├── constants/
 │    └── utils/
 ├── features/
 │    ├── auth/
 │    ├── garage/
 │    ├── ai/
 │    └── profile/
 ├── shared/
 │    └── widgets/
 ├── i18n/
 │    ├── auth_en.i18n.json
 │    ├── auth_es.i18n.json
 │    ├── garage_en.i18n.json
 │    ├── garage_es.i18n.json
 │    └── strings.g.dart
 └── main.dart
```

## Environment Variables

Pass these as Dart defines at runtime/build time:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Quick setup for this repo:

1. Copy `config/env.example.json` to `config/env.json`.
2. Set your real Supabase and Gemini values in `config/env.json`.
3. Keep `config/env.json` local (it is gitignored).

## Supabase SQL (table + RLS)

```sql
create table if not exists public.motorcycles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  make text not null,
  model text not null,
  year int not null,
  color text,
  license_plate text,
  current_km int default 0,
  image_url text,
  created_at timestamptz not null default now()
);

alter table public.motorcycles enable row level security;

create policy "users_select_own_motorcycles"
on public.motorcycles for select
using (auth.uid() = user_id);

create policy "users_insert_own_motorcycles"
on public.motorcycles for insert
with check (auth.uid() = user_id);

create policy "users_update_own_motorcycles"
on public.motorcycles for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users_delete_own_motorcycles"
on public.motorcycles for delete
using (auth.uid() = user_id);
```

Create a public storage bucket named `motorcycles` for image upload.

## Run

```zsh
flutter pub get
dart run slang
flutter run --dart-define-from-file=config/env.json
```

## i18n Watch Mode

Use this during development to regenerate `lib/i18n/strings.g.dart` automatically when any `lib/i18n/*.i18n.json` file changes.

```zsh
./tool/slang_watch.sh
```

Typical workflow: run watcher in one terminal and app in another.

```zsh
flutter run --dart-define-from-file=config/env.json
```

## Code Formatter

This project uses the built-in Dart formatter (`dart format`) with shared config:

- `analysis_options.yaml` -> `formatter.page_width: 100`
- `.editorconfig` -> consistent line endings/indentation across IDEs

Format all project Dart files:

```zsh
./tool/format.sh
```

Check formatting only (useful for CI/pre-commit):

```zsh
./tool/check_format.sh
```

Android Studio: open **Settings > Editor > Code Style > Dart** and keep
`Line length = 100`, then use **Code > Reformat Code**.

## Android Studio Run Configuration

If you do not see a Flutter configuration, install/enable the **Flutter** and **Dart** plugins first, then create one:

1. **Run > Edit Configurations...**
2. Click **+** and select **Flutter**
3. Set **Dart entrypoint** to `lib/main.dart`
4. In **Additional run args**, add:

```text
--dart-define-from-file=config/env.json
```

5. Apply and Run.

## Test

```zsh
flutter test
```
