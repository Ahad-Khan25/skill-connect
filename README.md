# TeamUp

**TeamUp** helps university students (4th–8th semester) find balanced teammates for **Semester Projects** and **Final Year Projects (FYPs)** based on complementary skills, shared interests, project type, availability, and semester closeness.

Built with **Flutter (Material 3)** + **Supabase** + **Provider (`ChangeNotifier`)** + **SharedPreferences** for the **VisioSpark Intra Campus Mobile App Competition 2026 (COMSATS University Islamabad, Wah Campus)**.

---

## Quick Start

### 1. Prerequisites
- Flutter SDK (stable channel, Dart 3.x)
- A Supabase project (pre-configured in [`lib/core/env.dart`](lib/core/env.dart))

### 2. Database Setup (Supabase SQL Editor)
Run these two files in order in the Supabase **SQL Editor**:
1. [`supabase/schema.sql`](supabase/schema.sql) — creates tables (`profiles`, `requests`, `teams`, `team_members`), enables Row-Level Security (RLS), creates atomic `SECURITY DEFINER` RPCs (`send_request`, `accept_request`, `reject_request`, `cancel_request`, `create_team`, `leave_team`, `get_my_team`), adds the trigger that seeds 3 received requests for every new student profile, and adds an auto-confirm trigger on `auth.users` so sign-ups work immediately during a live demo.
2. [`supabase/seed.sql`](supabase/seed.sql) — inserts **18 realistic Pakistani student profiles** across CS, SE, AI, DS, Cyber Security, and EE (semesters 4–8) with diverse skills, interests, availabilities, and project types.

### 3. Run the App
```bash
flutter pub get

# Run against the live Supabase backend (default):
flutter run

# Or force the offline in-memory fake backend at any time:
flutter run --dart-define=FAKE_BACKEND=true
```

### 4. Build Release APK
```bash
flutter build apk --release
```
The release APK is output to `build/app/outputs/flutter-apk/app-release.apk` (`android.permission.INTERNET` is enabled in [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml)).

---

## How Matching Works (`lib/data/match_engine.dart`)

[`MatchEngine`](lib/data/match_engine.dart) is a **pure, deterministic, unit-tested** scoring engine (`0–100` points). It contains zero I/O or randomness so scores are 100% reproducible and easy to explain to judges.

### Needed Skills Definition
$$\text{NeededSkills} = \text{my } \texttt{skillsNeeded} \;\cup\; \bigcup_{r \,\in\, \text{team.openRoles}} \texttt{kRoleSkills}[r]$$

When you create a team or accept teammates, open roles automatically feed into what skills the match engine searches for.

### Scoring Weights Table (0–100 Points)

| Factor | Max Points | Formula | Example Reason Generated on Card |
| :--- | :---: | :--- | :--- |
| **1. Skill Fit** | **40** | $40 \times \dfrac{\|\text{candidate.skills} \cap \text{NeededSkills}\|}{\|\text{NeededSkills}\|}$<br>*(If $\text{NeededSkills} = \emptyset$: up to **20 pts** complementary bonus, 5 pts per skill the candidate has that I do not, max 4)* | `"Has 2 skills you need: Flutter, Figma"`<br>*(or `"Brings 3 skills you don't have: ..."`)* |
| **2. Shared Interests** | **25** | $25 \times \text{Jaccard}(I_{\text{me}}, I_{\text{cand}}) = 25 \times \dfrac{\|I_{\text{me}} \cap I_{\text{cand}}\|}{\|I_{\text{me}} \cup I_{\text{cand}}\|}$ | `"3 shared interests: AI, Mobile Apps, Health Tech"` |
| **3. Project Type** | **15** | **15** if `me.projectType == candidate.projectType` (`FYP` or `Semester Project`), else **0** | `"Both doing an FYP"` |
| **4. Availability** | **10** | **10** if any availability slot overlaps (`Flexible` overlaps with every schedule), else **0** | `"Both free on Evenings, Weekends"` or `"Flexible schedule fits yours"` |
| **5. Semester Closeness** | **10** | Same semester $\rightarrow$ **10**; $\pm 1$ semester $\rightarrow$ **6**; otherwise $\rightarrow$ **2** | `"Same semester (7)"` or `"One semester apart"` |
| **Total** | **100** | `sum.round().clamp(0, 100)` (sorted descending; ties broken alphabetically) | Only factors that contribute points add a reason |

### Exclusions & Skill Gap
- **Exclusions:** Yourself and anyone already in your team are excluded from `MatchController.matches`.
- **Skill Gap (`MatchController.skillGap`):** Every skill in $\text{NeededSkills}$ that neither you nor any current member of your team possesses. When a new member joins your team, the skill gap updates automatically.

---

## Data Persistence & Offline Cache Architecture

- **Instant Startup Cache:** [`CacheStore`](lib/data/cache_store.dart) caches `me`, `profiles`, `requests`, and `team` as JSON in `shared_preferences`, namespaced by the signed-in `userId`.
- **Cache-First + Network Refresh:** On launch, controllers immediately hydrate from `CacheStore` (`LoadState.ready`) and refresh from Supabase in the background.
- **Offline Resilience:** If a network call fails and cached data exists, the controller keeps showing the cached data and sets `offline = true` so the UI can show an offline banner. `LoadState.error` is only shown when no cache exists.
- **Sign-Out Cleanup:** Signing out clears the user's cached entries and drops the persisted session.

---

## Folder Map & Ownership

```text
lib/
├── main.dart                     # Bootstraps Supabase, CacheStore, AppCoordinator & MultiProvider
├── core/
│   ├── constants.dart            # kDepartments, kSemesters, kSkills, kInterests, kProjectTypes, kAvailability, kRoles, kRoleSkills
│   ├── env.dart                  # Supabase URL, publishable key & FAKE_BACKEND flag
│   ├── errors.dart               # AppException & friendlyError() translator for Auth/Postgrest/Socket errors
│   └── validators.dart           # Pure input validators for forms & controllers
├── models/
│   └── models.dart               # LoadState, RequestStatus, AuthStatus, Profile, TeamRequest, TeamMember, Team, MatchResult, DiscoverFilters, SortOption
├── data/
│   ├── match_engine.dart         # Pure 0-100 Smart Match & Skill Gap engine
│   ├── sample_data.dart          # 18 realistic Pakistani student profiles + seeded request messages
│   ├── cache_store.dart          # Per-user JSON cache on top of shared_preferences
│   ├── repository.dart           # Abstract Repository interface
│   ├── supabase_repository.dart  # Real Supabase implementation (tables + SECURITY DEFINER RPCs)
│   └── fake_repository.dart      # In-memory implementation with identical business rules
├── state/
│   ├── base_controller.dart      # LoadState, offline flag, error message & safe notifyListeners
│   ├── auth_controller.dart      # signUp, signIn, signOut & persistent session listener
│   ├── profile_controller.dart   # My profile CRUD, validation & completeness meter (0..1)
│   ├── discover_controller.dart  # Search (name/skill), 4 filters & 3 sort options
│   ├── match_controller.dart     # Ranked MatchResults, matchFor(id) & team skillGap
│   ├── requests_controller.dart  # Sent/Received requests, pending badge count, send/accept/reject/cancel
│   ├── team_controller.dart      # My team state, create team, leave/disband team
│   ├── app_coordinator.dart      # Wires controllers together across auth/profile changes
│   └── state.dart                # Barrel export for the UI layer
└── ui/
    └── app_root.dart             # Material 3 screens & widgets (UI teammate)
supabase/
├── schema.sql                    # Tables, RLS policies, atomic RPCs & triggers
└── seed.sql                      # 18 sample student profiles (generated by tool/gen_seed.dart)
test/
├── match_engine_test.dart        # Unit tests for scoring weights, reasons, ranking & skill gap
└── controllers_test.dart         # End-to-end controller & persistence QA test
```
