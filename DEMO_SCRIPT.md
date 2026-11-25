# TeamUp – 2-Minute Competition Demo & Pitch Script

**Competition:** VisioSpark Intra Campus Mobile App Competition 2026 (CUI Wah Campus)
**Time Limit:** 2:00 (120 seconds)
**Pre-Demo Check (30 sec before judges arrive):**
- App open on the **Sign In / Sign Up** screen (or signed in to a clean account).
- Internet connected (or offline fallback ready—app caches everything locally in `shared_preferences`).

---

## 0:00 – 0:15 | The Problem & Hook (15s)
> *"In every semester project and FYP, students group only with their immediate friends—even when nobody on the team knows UI design, testing, or technical writing. **TeamUp** solves this: students create a skill profile, our deterministic Smart Match engine ranks the best teammates out of 100 with transparent reasons, and one tap forms a balanced team."*

---

## 0:15 – 0:35 | Auth & Profile Setup (20s) — *Marks: Profile (10), Error Handling (5)*
1. **Action:** Sign up with a fresh student email (or tap **Edit Profile** if already signed in).
2. **Action:** Briefly try submitting an empty field to show clean validation (no crash).
3. **Action:** Select:
   - **Department:** Computer Science | **Semester:** 7 | **Project Type:** FYP
   - **My Skills:** `Flutter`, `Dart`, `Firebase`
   - **Skills I'm Looking For:** `UI/UX Design`, `Figma`, `Machine Learning`, `Technical Writing`
   - **Interests:** `Mobile Apps`, `AI`, `Health Tech`
   - **Availability:** `Evenings`, `Weekends`
4. **Action:** Tap **Save Profile**.
> *"Notice the profile completeness meter hits 100%, and our profile is saved both to Supabase and locally via SharedPreferences so it persists across restarts and offline mode."*

---

## 0:35 – 0:55 | Discover & Multi-Filter Search (20s) — *Marks: Discover + Filters (15)*
1. **Action:** Open the **Discover** tab showing 18 realistic Pakistani student profiles with department, semester, project type, and skill tags.
2. **Action:** Type `Figma` or `Fatima` in the search bar → instant filtering by name or skill.
3. **Action:** Clear search, tap **Filters**: select **Project Type = FYP** and **Semester = 7** (and optionally **Sort: Best Match / Semester / Name**).
4. **Action:** Tap **Clear Filters**.
> *"Judges can search by name or skill and combine department, semester, skill, and project-type filters with zero lag."*

---

## 0:55 – 1:25 | Smart Match & Skill Gap (30s) — *Marks: Smart Match (25)*
1. **Action:** Switch to the **Best Matches** tab.
2. **Action:** Point to the **Skill Gap** banner at the top showing which needed skills our team still lacks.
3. **Action:** Point to the #1 ranked student card (e.g., **Fatima Zahra** or **Sana Iqbal**) showing the **0–100% score badge** and the **human-readable reasons** right on the card:
   - *"Has 2 skills you need: UI/UX Design, Figma"*
   - *"2 shared interests: Mobile Apps, Health Tech"*
   - *"Both doing an FYP"*
   - *"Both free on Evenings, Weekends"*
   - *"Same semester (7)"*
> *"How does the score work? It's a pure, deterministic 100-point formula: **40%** skill fit against the union of my needed skills and my team's open roles, **25%** Jaccard similarity on shared interests, **15%** same project type, **10%** schedule overlap (where Flexible matches any slot), and **10%** semester closeness. Every point earned generates a plain-English reason on the card."*

---

## 1:25 – 1:45 | Team Requests: Send, Cancel, Accept, Reject (20s) — *Marks: Requests + My Team (20)*
1. **Action:** On the top match card, tap **Send Request**, enter *"Hi! Need a UI/UX designer for our Health Tech FYP"*, and send.
2. **Action:** Open the **Requests** tab (point out the **notification badge** count on Received).
3. **Action:** Switch to **Sent** → show the `Pending` badge → tap **Cancel** → show the **confirmation dialog** before cancelling.
4. **Action:** Switch to **Received** (3 sample requests are automatically seeded for every account so judges can test immediately).
   - Tap **Reject** on one request → badge updates to `Rejected`.
   - Tap **Accept** on **Fatima Zahra's** request → badge updates to `Accepted`.
> *"Accepting a request runs an atomic Supabase transaction: it creates our team if we don't have one yet, assigns Fatima the best-matching open role (`Designer`) based on her skills, and removes `Designer` from open roles."*

---

## 1:45 – 2:00 | My Team & Persistence Proof (15s) — *Marks: My Team (20), Saved Data (5)*
1. **Action:** Open the **My Team** tab.
2. **Action:** Show the team title, project type (`FYP`), **Members list** (Me as `Owner`, Fatima Zahra as `Designer`), and remaining **Open Roles** (`Developer`, `Tester`, `Report Writer`).
3. **Action:** Tap **Leave Team** just to show the **confirmation dialog** (tap *Cancel* so the team stays intact, or close & reopen the app to show everything persists instantly from local cache + Supabase session).
> *"And notice in Best Matches: Fatima is now excluded from candidates and `UI/UX Design` + `Figma` have automatically disappeared from our team's Skill Gap. Thank you—we're ready for your questions!"*
