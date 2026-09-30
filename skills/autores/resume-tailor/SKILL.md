---
name: autores-resume-tailor
description: Tailor Carson's LaTeX resume to a specific job posting using the autores pipeline (fact bank → claude selection → LaTeX compile → verification gates). Use when asked to tailor a resume, add a job URL and produce a resume for it, debug a failed tailoring, or edit the fact bank / resume template in the resume-tailor repo.
---

# autores: resume tailoring

The repo is `~/resume-tailor` (package name `autores`, private). Tailoring is Stage 4 of the pipeline:
ingest → filter → enrich → **tailor** → notify → apply.

## The honesty boundary (never break this)

- `Resume/master-facts.yaml` is the **fact bank**: the only claims the resume may make. Tailoring may
  select, reorder, and rephrase bullets. It may never invent employers, metrics, technologies, dates or outcomes.
- A bullet with `verified: false` is a placeholder and must not ship. `src/tailor/verify.ts` hard-fails on it.
- Any number in the output must trace to a `metrics:` value in the fact bank (or the small allowlist in `verify.ts`).
- If a posting seems to need a claim the fact bank doesn't hold, **ask Carson**. Don't add it yourself.
  Only add a new fact when Carson supplies it, and mark it `verified: true` only when he confirms the figure.

## Key files

| File | Role |
|---|---|
| `Resume/master-facts.yaml` | Fact bank (source of truth) |
| `Resume/base.tex` | Template. The default render must reproduce `Resume/Carson_Gabler_Resume.tex` exactly (a regression test checks it). |
| `src/tailor/tailor.ts` | Orchestrates one job: facts → claude → render → compile → verify |
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
