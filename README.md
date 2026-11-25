# TeamUp

Find teammates for semester projects and FYPs by skills and interests. Flutter (Material 3) + Supabase.

> Full README (setup, Supabase steps, match logic, folder map) is being written – see below for the essentials.

## Run

```bash
flutter pub get
# Fake in-memory backend (no Supabase needed – great for UI work):
flutter run
# Real backend:
flutter run --dart-define=SUPABASE_ANON_KEY=<publishable/anon key>
```

In **fake mode**: *Sign in* with any email/password → demo account with a filled profile, sample team and 3 received requests. *Sign up* → new account without a profile (forces profile setup).

## For the UI teammate

Import everything from one file:

```dart
import 'package:teamup/state/state.dart'; // models, constants, validators, controllers
```

All controllers are provided at the root (`context.watch<DiscoverController>()` etc.).
Every data controller extends `BaseController` → `state` (LoadState), `offline` (show "offline – cached data" banner), `error` (message), `refresh()`.

Additive extras beyond the contract (optional to use):

| Where | Extra |
|---|---|
| `Profile` | `initials`, `copyWith`, `email` |
| `TeamRequest` | `other` (the other person), `teamId` |
| `Team` | `owner` |
| `ProfileController` | `saving`, `missingFields`, static `validate(p)` |
| `DiscoverController` | `all`, `byId(id)`, `dataState` |
| `MatchController` | `neededSkills` |
| `RequestsController` | `isBusy(id)` – spinner for a request's buttons |
| `TeamController` | `busy` |
| `AuthController` | `userId`, `email`, `signUpName` (prefill profile name) |
| `DiscoverFilters` | `copyWith(..., clearSkill: true)`, `activeCount` |
| constants | `kDepartmentShort` (CS/SE/AI…) |
| `Validators` | `name/email/password/requestMessage/teamTitle/bio` for `TextFormField.validator` |
