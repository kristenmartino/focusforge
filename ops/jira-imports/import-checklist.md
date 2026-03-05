# Jira CSV Import Checklist

## Files

| File | Contents | Count |
|------|----------|-------|
| `epics.csv` | All epics | 9 |
| `children.csv` | All stories | 53 |

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
3. Validate and import. Confirm 9 epics in the backlog.

### Step 2 — Import Stories

1. Upload `children.csv`
2. Map columns (same as above, plus):
   - Epic Link -> Epic Link
3. Verify every `Epic Link` value matches an existing epic Summary exactly
4. Import. Confirm 53 stories linked to correct epics.

## Post-Import

- [ ] Spot-check epic links are correct
- [ ] Drag stories into sprints using the `Labels` column as a guide (sprint-1 through sprint-6, wave-2, wave-3, post-mvp)
- [ ] Set story point estimates during sprint planning
- [ ] Assign owners

## Label Key

| Label | Meaning |
|-------|---------|
| `sprint-1` through `sprint-6` | Target sprint |
| `wave-1` / `wave-2` / `wave-3` | AI Coach wave |
| `wave-1 rollout` | AI rollout phases |
| `post-mvp` | After initial launch |

## Notes

- Stories are scoped at roughly 1-3 day grain. Break further during sprint planning if needed.
- AI Coach epic contains stories across all 3 waves. Use `wave-*` labels to filter.
- Descriptions scope the work; full specs live in `docs/PRD.md` and `docs/focus-forge-ai-prd-addendum.md`.
