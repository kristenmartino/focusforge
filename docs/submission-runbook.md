# FocusForge — Submission Runbook

End-to-end procedure from "Apple Developer enrollment confirmed" →
"TestFlight build live" → "App Store submission queued." Written
2026-05-17 the day enrollment landed.

Each section has the precise click path and (where possible) a script
or command. Time estimates assume nothing unexpected.

---

## Stage 1 — Account + App ID (30 min, one-time)

### 1.1 Find your Team ID

Open [Apple Developer → Membership Details](https://developer.apple.com/account#MembershipDetailsCard).
Note the **Team ID** (10-character alphanumeric, e.g. `A1B2C3D4E5`).
You'll need this in three places: project.yml, App Store Connect, and
the upload flow.

### 1.2 Register the App ID

Apple Developer → [Certificates, IDs & Profiles → Identifiers](https://developer.apple.com/account/resources/identifiers/list).

- Click **+** to add
- Type: **App IDs**
- Description: `FocusForge`
- Bundle ID: **Explicit**, `com.focusforge.app` (must match the
  `PRODUCT_BUNDLE_IDENTIFIER` in `app/project.yml:55`)
- Capabilities: leave defaults (don't enable iCloud until v1.1)
- Register

### 1.3 Update project.yml with Team ID

```yaml
# app/project.yml
settings:
  base:
    DEVELOPMENT_TEAM: "YOUR_TEAM_ID_HERE"  # <- the 10-char Team ID
```

Then regenerate: `cd app && xcodegen generate`

### 1.4 Verify automatic signing works in Xcode

Open `app/FocusForge.xcodeproj` → select the FocusForge target →
**Signing & Capabilities** tab. Confirm:

- "Automatically manage signing" is **on**
- Team dropdown shows your Apple Developer team
- "Provisioning Profile" auto-fills (Xcode generates one)
- No red error badges

---

## Stage 2 — App Store Connect record (45 min, one-time)

This is the "container" Apple needs before you can upload any build.
The metadata lives in `docs/app-store-listing.md` — copy from there
as you go.

### 2.1 Create the app

[App Store Connect → Apps → +](https://appstoreconnect.apple.com/apps) → **New App**

- Platforms: **iOS**
- Name: `FocusForge`
- Primary Language: **English (U.S.)**
- Bundle ID: select `com.focusforge.app` (created in §1.2)
- SKU: `focusforge-v1` (internal-only, never visible to users)
- User Access: **Full Access**
- Click **Create**

### 2.2 Fill the App Information page

- Name: `FocusForge`
- Subtitle: `Your focus grows your character` (30 chars exact — see
  app-store-listing.md §Subtitle)
- Primary Category: **Productivity**
- Secondary Category: **Health & Fitness**
- Content Rights: check "Does not contain, show, or access
  third-party content" (we ship our own catalog of templates, the
  Firebase SDK is first-party)

### 2.3 Pricing & Availability

- Price: **Free**
- Availability: All territories (or restrict if you have a
  jurisdiction reason)

### 2.4 App Privacy

This drives the "Privacy Nutrition Label" displayed on the store
page. Match these to `app-store-listing.md §Privacy Nutrition Labels`:

**Data Used to Track You:** None.

**Data Linked to You:** None.

**Data Not Linked to You:**
- Identifiers: Device ID (Firebase App Instance ID)
- Usage Data: Product Interaction
- Diagnostics: Crash Data, Performance Data

For each item, declare:
- Used for: Analytics + App Functionality
- Linked to user identity: **No**
- Used for tracking: **No**

### 2.5 Version Information (for v1.0)

- What's New: copy from `app-store-listing.md §What's New`
- Description: copy from `app-store-listing.md §Description`
- Keywords: copy from `app-store-listing.md §Keywords`
- Promotional Text: copy from `app-store-listing.md §Promotional Text`
- Support URL: `https://kristenmartino.ai/focusforge/support` (or
  your email as a fallback before the page is up)
- Marketing URL: `https://kristenmartino.ai/focusforge` (optional)

### 2.6 Upload required assets

- **App icon (1024×1024):** see `docs/app-icon-brief.md`. Hard
  blocker — Apple won't accept the metadata without this.
- **Screenshots:** at least 6.7" iPhone display (1290×2796). The
  drafts in `assets/app-store-screenshots/` are iPhone 16e sizes;
  re-capture on iPhone 17 Pro Max simulator for final canvas, OR
  letterbox in Preview.

### 2.7 Privacy Policy + Terms URLs

The App Store record requires a Privacy Policy URL. The Terms URL is
optional but recommended.

- Privacy Policy URL: `https://kristenmartino.ai/focusforge/privacy`
- Marketing URL with Terms: `https://kristenmartino.ai/focusforge/terms`

Drafts ready at `docs/legal/privacy-policy.md` and
`docs/legal/terms-of-use.md`. **Hosting these on the portfolio domain
is a hard blocker for submission.** Two TBD fields in Terms (governing
law state, arbitration venue) must be filled in first.

### 2.8 Age Rating

Fill out the questionnaire. From `app-store-listing.md §Age Rating`:
mostly **None** answers. Likely lands at **12+** due to cosmetic
naming ("Battle Scarred") but could argue 9+. Submit honest answers
and let Apple's tool calculate.

---

## Stage 3 — Pre-build verification (30 min)

Before archiving any build for TestFlight, run this verification once
to catch bugs that don't show up in Debug builds.

### 3.1 Switch to Release config in simulator

```bash
cd app
xcodebuild -project FocusForge.xcodeproj -scheme FocusForge \
  -configuration Release \
  -destination 'platform=iOS Simulator,name=iPhone 16e' build
```

Release builds disable `#if DEBUG` blocks — verify the Debug section
of Settings is hidden, no `print()` statements in the console, and
that the Crashlytics dSYM upload script runs without error.

### 3.2 Run unit tests

```bash
cd app
xcodebuild test -project FocusForge.xcodeproj -scheme FocusForge \
  -destination 'platform=iOS Simulator,name=iPhone 16e'
```

All tests must pass (46 last count, distributed across StreakManager,
MilestoneEngine, SessionLogger, DataExportService).

### 3.3 Firebase analytics walkthrough

Per `docs/analytics-verification-plan.md`:

- Launch with `-FIRDebugEnabled` argument
- Open Firebase Console → Analytics → DebugView
- Walk through scripts A-E (~45 min)
- Confirm 23 of 23 events appear with correct params
- Confirm no event leaks the actual task name

---

## Stage 4 — Archive + upload (15 min the first time, 2-5 min after)

### 4.1 Configure the Archive scheme

Open `app/FocusForge.xcodeproj` → **Product → Scheme → Edit Scheme**
→ **Archive** tab. Confirm:

- Build Configuration: **Release**
- Reveal Archive in Organizer: ✓

### 4.2 Select destination device

In the run destination dropdown, select **Any iOS Device (arm64)**.
Archive only works for device-targeted builds, not simulator.

### 4.3 Archive

**Product → Archive**

First archive takes 3-5 minutes (full Release build + dSYM
generation + Crashlytics upload). The Organizer window auto-opens
when done.

### 4.4 Validate the archive

In Organizer:
- Select the new archive
- Click **Validate App**
- Choose "App Store Connect" distribution
- Use automatic signing (Xcode pulls the provisioning profile)
- Apple does a server-side check (~30 seconds)
- Resolve any errors before proceeding

Common validation errors:
- "Missing App Icon" — finish §2.6 first
- "Missing Compliance" — answer the export compliance questions in
  the Validate dialog ("uses encryption" → No, since you don't use
  custom crypto beyond what iOS provides)
- "Invalid Bundle ID" — verify project.yml matches Apple Developer
  App ID exactly

### 4.5 Upload

After Validate passes, click **Distribute App** → **App Store
Connect** → **Upload**. Takes 1-3 minutes for the upload itself, then
Apple processes the build (10-30 minutes typically) before it appears
in App Store Connect as "Processing" → "Ready to Submit."

---

## Stage 5 — TestFlight (1 week minimum runtime)

### 5.1 Internal Testing (no Apple review needed)

App Store Connect → **TestFlight** tab → **Internal Testing** →
**+ Internal Testers**.

- Add yourself + any internal testers (other developers in your team
  — limited to 100 internal testers).
- Internal builds are immediately available for download after
  upload processing completes.
- Send the TestFlight link from your phone, install the app, run it.

This is the smoke test. Use it to:
- Confirm Release build works end-to-end on a real device
- Confirm Crashlytics receives a deliberate test crash (uncomment a
  `fatalError()` somewhere temporarily, archive, install, run, then
  re-comment)
- Walk the analytics events on a real device

### 5.2 External Beta (requires brief Apple review, ~24h)

App Store Connect → **TestFlight** → **External Testing** →
**+ Group**.

- Create group: "FocusForge v1.0 Beta"
- Add up to 10,000 external testers via email or TestFlight public
  link
- Submit the build for Beta App Review (lightweight review, usually
  approved in 24h)
- Once approved, link is live and testers can install

### 5.3 Runtime requirements (from PRD §17)

Per the launch criteria locked in MEMORY.md:

- Crash-free sessions ≥ 99.5% over the beta runtime
- Zero open P0/P1 defects
- 1-week minimum beta runtime
- End-to-end flow verified (start → complete → reward → re-engage)

Track crash-free percent in Firebase Crashlytics dashboard. If it
drops below 99.5%, do not submit — fix the crashes first.

---

## Stage 6 — App Store submission (30 min + review wait)

### 6.1 Pre-submission checklist (from app-store-listing.md)

- [ ] Apple Developer Program enrollment confirmed ✓ (2026-05-17)
- [ ] Provisioning profile + signing identity set up
- [ ] Privacy Policy + Terms hosted, URLs working
- [ ] App icon (1024×1024) finalized
- [ ] Screenshots taken at all required device sizes
- [ ] Privacy nutrition labels submitted in App Store Connect
- [ ] Bundle ID `com.focusforge.app` registered + matches plist
- [ ] Beta test feedback addressed (P0/P1 to zero)
- [ ] Crash-free rate ≥ 99.5% measured over beta runtime
- [ ] What's New finalized
- [ ] Submit for review

### 6.2 Submit

App Store Connect → app record → **App Store** tab → **+ Version**
(or use the v1.0 record already in 1.0 state) → fill in any missing
metadata → **Add for Review** → answer the App Review questions
(advertising identifier: No; export compliance: No; content rights:
yes).

**Submit for Review.**

### 6.3 Review timeline

Apple's first-submission review is typically 24-48 hours. Plan for one
rejection cycle (~3-5 days total) — common first-submission rejection
reasons include:

- Missing demo account info (if review needs to test a login — we
  don't have one, so this shouldn't apply)
- Privacy nutrition label mismatch (our labels match the code)
- App icon issue (must be the 1024×1024 exactly, no transparency)
- Crash during review (the reviewer's device hit a crash — analyze
  Crashlytics report and re-submit)

---

## What's blocking right now

After enrollment, in priority order:

1. **App icon design** — `docs/app-icon-brief.md` has the spec.
   Cannot pass §2.6 without this.
2. **Privacy/Terms hosting** — drafts at `docs/legal/`. Need a
   governing law state filled into Terms §13, then host the HTML on
   `kristenmartino.ai/focusforge/privacy` + `/terms`. Cannot pass
   §2.7.
3. **Pro Max-sized screenshots** — current set is iPhone 16e res.
   Re-capture on Pro Max simulator for §2.6. Or letterbox if pressed.
4. **Team ID in project.yml** — fill in the 10-char Team ID at
   `app/project.yml:21` (currently empty `""`), then regenerate the
   project.

Everything else can wait until the build is ready.
