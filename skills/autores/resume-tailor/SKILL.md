---
name: autores-resume-tailor
description: Tailor Carson's LaTeX resume to a specific job posting using the autores pipeline (fact bank → claude selection → LaTeX compile → verification gates), always filling one full page and leaning into the role rather than shrinking on a weak match. Use when asked to tailor a resume, when a tailored resume comes out short, add a job URL and produce a resume for it, debug a failed tailoring, or edit the fact bank / resume template in the resume-tailor repo.
---

# autores: resume tailoring

The repo is `~/resume-tailor` on the Mac, `~/Projects/autores` on Windows (package name `autores`, private). Tailoring is Stage 4 of the pipeline:
ingest → filter → enrich → **tailor** → notify → apply.

## The honesty boundary (never break this)

- `Resume/master-facts.yaml` is the **fact bank**: the only claims the resume may make. Tailoring may
  select, reorder, and rephrase bullets. It may never invent employers, metrics, technologies, dates or outcomes.
- A bullet with `verified: false` is a placeholder and must not ship. `src/tailor/verify.ts` hard-fails on it.
- Any number in the output must trace to a `metrics:` value in the fact bank (or the small allowlist in `verify.ts`).
- If a posting seems to need a claim the fact bank doesn't hold, **ask Carson**. Don't add it yourself.
  Only add a new fact when Carson supplies it, and mark it `verified: true` only when he confirms the figure.

## Fill the page, lean into the role (never shrink it)

A weak match, or a thin or missing job description, is **never** a reason to ship a shorter resume.
The fix is to lean harder into the role, not to leave bullets off.

- **Every job's bullets always go on.** Leaving an employer off to save space isn't allowed.
  `missingEmployers` in `src/tailor/plan.ts` checks the final text for this.
- **Every shippable project bullet goes on too.** `bulletsForResume` puts the model's ranked picks first,
  then backfills the rest of the projects in fact-bank order. The model's job is *ranking*, not gatekeeping.
- **One page is enforced by trimming, not by picking less.** The fit loop in `buildResume` drops the
  last project bullet first. Once projects run out, it drops job bullets through `nextJobBulletToDrop`,
  always leaving each job at least one.
- **The prompt (`buildPrompt` in `claude.ts`) asks for every project bullet, ranked.** On a sparse JD it
  tells the model to infer what the role does day to day, rank the bullets that show that work first,
  and rephrase them in that role's vocabulary. The honesty rules above still hold.

If a tailored resume comes out short, treat it as a bug in selection or fitting. Don't accept it as a
judgment about the match. `rebuildResume` re-renders under current rules from the saved
`claude-raw.json` without a new Claude call. It keeps the old ranking, so re-tailor when the
role-focused rewording matters.

## Key files

| File | Role |
|---|---|
| `Resume/master-facts.yaml` | Fact bank (source of truth) |
| `Resume/base.tex` | Template. The default render must reproduce `Resume/Carson_Gabler_Resume.tex` exactly (a regression test checks it). |
| `src/tailor/tailor.ts` | Orchestrates one job: facts → claude → render → compile → verify |
| `src/tailor/plan.ts` | Which bullets go on: all jobs, then ranked + backfilled projects; trim order |
| `src/tailor/claude.ts` | Selection call (`claude -p` CLI backend, or the API when `AUTORES_CLAUDE_BACKEND=api`) |
| `src/tailor/verify.ts` | Gates: selection is shippable, no invented numbers, one page, no placeholders |
| `src/tailor/latex.ts` | Rendering and escaping. A bare `\|` in text mode must become `\textbar{}`. |
| `.ai/preferences.yaml` | Graduation `allowedRange`. The claimed grad date is resolved per posting. |

## Workflows

Build first: `npm run build` (TypeScript → `dist/`).

- **Tailor a specific posting:**
  `node dist/cli.js add <url> [--company C --title T --internship]`, then
  `node dist/cli.js enrich && node dist/cli.js tailor -n 1`
- **Tailor the enriched queue:** `node dist/cli.js tailor -n 5`
- **Inspect state:** `node dist/cli.js status [--explain]`, `node dist/cli.js grad-audit`
- **Another user (multi-user mode):** add `--user <id>` to any command.

A failed tailoring lands the job in `failed` with a reason. Read the reason, fix the cause (fact bank,
template, escaping), and re-run. Never loosen a verify gate to get a resume through.

## Mac environment traps

- **Node version:** npm scripts can pick up a stray Node 25 from `~/node_modules/.bin`, while the shell
  and dashboard use nvm Node 22. `better-sqlite3` is native, so run tests with Node 22 directly:
  `~/.nvm/versions/node/v22.14.0/bin/node --test $(find dist -name "*.test.js")`.
  Don't `npm rebuild` it under Node 25.
- **LaTeX:** the Mac has BasicTeX. A missing `.sty` gets fixed with `tlmgr --usermode install <pkg>` (no sudo).
  launchd has a bare PATH, so `.env` pins `PDFLATEX_BIN` and `CLAUDE_BIN`.
- **`state/autores.db` is the real ledger** (tens of thousands of postings). Don't smoke-test against it.
  Use a temporary state dir.

## Git conventions in this repo

Work on a feature branch, never `main`. Commit after each finished phase of a multi-phase change, with tests green.
