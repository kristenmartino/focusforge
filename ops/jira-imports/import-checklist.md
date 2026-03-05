# Jira CSV Import Checklist

## Files

| File | Contents | Count |
|------|----------|-------|
| `epics.csv` | All epics | 10 |
| `children.csv` | All stories (MVP only) | 51 |

## Import Order

Epics first, then children — the `Epic Link` column in `children.csv` references epic Summaries.

### Step 1 — Import Epics

1. **Jira > System > Import > CSV** — upload `epics.csv`
2. Map columns:
   - Summary -> Summary
   - Issue Type -> Issue Type
   - Description -> Description
   - Priority -> Priority
   - Labels -> Labels
3. Validate and import. Confirm 10 epics in the backlog.

### Step 2 — Import Stories

1. Upload `children.csv`
2. Map columns (same as above, plus):
   - Epic Link -> Epic Link
3. Verify every `Epic Link` value matches an existing epic Summary exactly
4. Import. Confirm 51 stories linked to correct epics.

## Post-Import

- [ ] Spot-check epic links are correct
- [ ] Drag stories into sprints using the `Labels` column as a guide
- [ ] Set story point estimates during sprint planning
- [ ] Assign owners

## Sprint Load

| Sprint | Epics in play | Stories |
|--------|---------------|---------|
| 1 | Timer & Sessions | 7 |
| 2 | Timer & Sessions, Streaks & Rewards | 6 |
| 3 | Character & Cosmetics, Platform & Sync | 6 |
| 4 | Character & Cosmetics, Quests, Stats & Insights, Platform & Sync | 10 |
| 5 | AI Coach, Platform & Sync | 11 |
| 6 | Accessibility, Release & QA | 8 |
| Post-MVP | Monetization | 2 |

## Label Key

| Label | Meaning |
|-------|---------|
| `sprint-1` through `sprint-6` | Target sprint |
| `sprint-3-4` / `sprint-3-5` | Spans multiple sprints |
| `post-mvp` | After initial launch |

## What's NOT in this import

- **AI Coach Waves 2 and 3** — create these after Wave 1 rollout hits 100% and KPIs pass. Specs are in `docs/focus-forge-ai-prd-addendum.md`.
- **Monetization details** — 2 placeholder stories. Break down during post-MVP planning.

## Notes

- Stories are scoped at roughly 1-3 day grain. Break further during sprint planning if needed.
- iPad adaptation (`sprint-3-4`) starts alongside Character & Cosmetics so layouts are built responsive from the start, rather than retrofitted in sprint 5.
- CloudKit sync (`sprint-4`) starts once core models stabilize, giving sprint 5 room for AI Coach.
- Analytics SDK integration is in sprint 6 / Release & QA — instrument early enough to capture beta metrics.
- Descriptions scope the work; full specs live in `docs/PRD.md` and `docs/focus-forge-ai-prd-addendum.md`.
