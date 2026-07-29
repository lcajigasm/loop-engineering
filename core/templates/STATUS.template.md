# Status — <project name>

Source of truth for what actually works. Updated in the same change that
alters behavior. Nothing outside this file (README, marketing, comments)
promises a capability this file does not confirm.

Legend: `not-started` · `partial` (incomplete, clearly flagged as such in
the product) · `implemented` (behavior verified by its goal's gate).

<!-- One table per functional area. Add a column per platform/target only
     if the project has more than one. Rows come from the goal map. -->

## <Functional area> (M1)

| Capability | Status | Verification | Verified by |
|---|---|---|---|
| <capability from G-101> | not-started | current | `<verify command or "human — who/when">` |
| <capability from G-102> | not-started | current | |

## Known gaps

<!-- Honest list: measured misses, deferred fixes, platform holes. Link the
     receipt or ADR that explains each one. -->

## Revalidation required

<!-- When commits after a passed goal's final revision touch its Scope, add:
- <goal id> — <scope> changed after <revision>; re-run `<VERIFY>` before
  claiming the evidence is current. Remove only after a new passing receipt
  records the revalidation. -->
