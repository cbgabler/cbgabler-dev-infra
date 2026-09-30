---
name: dev-infra-add-skill
description: Add or update a skill in Carson's cbgabler-dev-infra repo (the home for all project skills and dev infrastructure), install it, and commit + push it. Use whenever a new reusable workflow, project skill, or piece of dev infra should be saved, or when asked to "put this in dev infra".
---

# Adding to cbgabler-dev-infra

Repo: `~/cbgabler-dev-infra` (GitHub: `cbgabler/cbgabler-dev-infra`, **public**).

## Layout

```
skills/<project>/<skill>/SKILL.md   e.g. skills/autores/resume-tailor/SKILL.md
scripts/install-skills.sh           links every skill into ~/.claude/skills/<project>-<skill>
```

- `<project>` is the product name (`autores` for the resume-tailor repo). Use `dev-infra` for meta skills.
- The frontmatter `name` must be `<project>-<skill>` (lowercase, hyphens), which matches the installed link name.
- The `description` says what the skill does **and when to use it**, since that's what triggers it.
- Supporting files (scripts, references) sit next to `SKILL.md` in the same directory.

## Rules

- **Public repo.** Never commit personal data (phone, address, email beyond the GitHub handle), secrets,
  `.env` contents, ledger data, or copies of private-repo files. Describe workflows and point at paths in
  the private repos instead of copying their contents.
- Put facts in the skill only if they're durable (paths, invariants, commands). Skip anything that
  changes weekly.

## Steps

1. Write or edit `skills/<project>/<skill>/SKILL.md`.
2. Run `scripts/install-skills.sh` so the skill is live locally.
3. Commit and push directly to `main`. Carson has pre-authorized auto-commits to this repo and reviews
   them himself. Use a short message saying which skill was added or changed and why.
