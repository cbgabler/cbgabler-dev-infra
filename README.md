# cbgabler-dev-infra

Shared dev infrastructure for my projects, mostly Claude Code skills, organized by project.

## Layout

```
skills/
  autores/            # resume-tailor / autores job pipeline
    resume-tailor/    # tailor the LaTeX resume to a posting
    pr-review/        # review autores changes against project invariants
  dev-infra/
    add-skill/        # how to add a skill to this repo
scripts/
  install-skills.sh   # link skills into ~/.claude/skills
```

Each skill is `skills/<project>/<skill>/SKILL.md` and installs as `<project>-<skill>`.

## Install

```sh
git clone https://github.com/cbgabler/cbgabler-dev-infra.git ~/cbgabler-dev-infra
~/cbgabler-dev-infra/scripts/install-skills.sh
```

Skills are symlinked, so a `git pull` updates them. Re-run the script after adding or removing a skill.
