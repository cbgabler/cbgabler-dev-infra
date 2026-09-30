---
name: autores-pr-review
description: Review a branch or PR in the autores (resume-tailor) repo against its project-specific invariants (fact-bank honesty, template drift, per-user isolation, unattended-submit safety, personal data). Use when asked to review autores changes, a resume-tailor PR, or "check this branch" in ~/resume-tailor.
---

# autores: PR review

Review the diff (`git diff main...HEAD`, or `gh pr diff <n>`) for general correctness first. Then check the
project invariants below. These are the ways autores changes have gone wrong or would do real harm.

## Invariants to check

1. **Fact-bank honesty.** Does anything let an unverified or invented claim reach a PDF or an ATS form?
   Look for weakened checks in `src/tailor/verify.ts`, a bigger `NUMERIC_ALLOWLIST`, bypasses of
   `unshippableBullets`, or prompt changes in `src/tailor/claude.ts` that let the model write new content
   instead of selecting and rephrasing.
2. **Template drift.** If `Resume/base.tex` or `src/tailor/latex.ts` changed, the default render must still
   reproduce `Resume/Carson_Gabler_Resume.tex` exactly. Check that the regression test still passes and
   wasn't edited to match.
3. **Graduation date.** Claimed dates must stay within `.ai/preferences.yaml` `graduation.allowedRange`
   and be recorded per job (`claimed_grad_date`). A posting outside the range gets filtered out, never
   satisfied with a fabricated date.
4. **Autofill / apply safety.** A thumbs-up submits unattended, so any change in `src/apply/` that
   answers a screener must answer truthfully from the profile or the fact bank, or ask (`src/apply/ask.ts`).
   Guessing is a bug. Watch for new default answers.
5. **Multi-user isolation.** Every command acts for one user (`--user`). Check that new ledger queries,
   file paths and secrets are scoped through `ledger.forUser(...)` / per-user files, not the owner's.
   `serve` must not expose the owner's Claude subscription to other users.
6. **Personal data.** No phone numbers, addresses, credentials or `.env` values in committed code, logs,
   fixtures or test snapshots. `.ai/profile.yaml` and `state/` stay out of anything public.
7. **Ledger state machine.** State transitions go through `Ledger.setState`. A failure must never demote
   a job Carson can still apply to by hand.

## Verifying

- Build: `npm run build`.
- Tests: run them under Node 22 directly, not through `npm test`, which may pick up Node 25 and break
  `better-sqlite3`: `~/.nvm/versions/node/v22.14.0/bin/node --test $(find dist -name "*.test.js")`.
- Never run the pipeline against `state/autores.db` to verify. It's the real ledger.

## Output

Report findings ranked most-severe first, each with file:line and a concrete failure scenario.
Say plainly when an invariant was checked and holds. Don't pad the review with style nits.
