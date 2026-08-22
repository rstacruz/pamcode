---
name: pamcode
description: Specifies the pamcode format — pseudocode in Markdown for describing agent workflows. Use when authoring or editing SKILL.md files that define agent workflows, when interpreting `begin()`/`def()` pseudocode in a skill, or when writing a skill spec in pamcode.
---

# Pamcode

**Pamcode = Pseudocode for agents in Markdown.** Informal pseudocode for describing agent workflows in `SKILL.md` files.

Intuitively understandable by humans and agents, no need to read spec.

<!-- spec-start -->

## Markdown shell

Markdown first; pseudocode lives in `## Workflow`, wrapped by frontmatter and `###` sections.

| Section | Role |
|---|---|
| `## Input` | The `$var`s and `--flags` accepted |
| `## Skill dependencies` | Other skills to read first, as `/path` links |
| `## Workflow` | The `begin()` pseudocode in a code fence |
| `### <name>()` | One per subroutine: prose instructions or a `def` block |
| `## Guidelines` | General guidance for writing the skill |

## Constructs

| Construct | Meaning | Example |
|---|---|---|
| `begin($args) { … }` | Workflow entry point | `begin($request) {` |
| `def name($args) { … }` | Subroutine, usually returning a structured result | `def plan($request) {` |
| `name($args)` | Invoke a routine defined elsewhere | `pick-default-repo()` |
| `$var` | Parameter or state | `$request` |
| `if (cond) { … } else { … }` | Branch on category, effort, flags | `if (category == 'code-change') {` |
| `subagent(tag) { … }` | Fork a subagent; body is its instructions | `subagent(fork) {` |
| `/command()` / `/command args` | Invoke another skill | `/polish-plan()`, `/loop 15m` |
| `return { field: value, ... }` | Structured result passed up | `return { plan-file: <path>, multi-PR: y/n }` |
| `# comment` / `# -- banner --` | Notes; section banners | `# -- plan phase --` |
| `--flag` | CLI-style option that alters flow | `--yolo` |
| plain prose | A step described in words | `answer now` |

Values are loose: strings, numbers, effort levels (`L1`–`L5`), `y/n`, or prose.

## Example

Every shell section and construct, annotated:

````markdown
---
name: weekly-digest
description: Triage a weekly digest request.
---

## Input

- `$repo` - required
- `$slack-thread` - (optional) thread to notify
- `--yolo` - run unattended, skip gates

## Skill dependencies

Read first:

- `/polish-plan`

## Workflow

```
begin($repo, $slack-thread, --yolo) {
  # -- phase 1: scope --
  if ($repo == '') {
    $repo = pick-default-repo()          # call a subroutine
  }

  # -- phase 2: research --
  subagent(fork) {                       # fork a subagent; body = its job
    scan last week's commits, group by theme
  }

  if (changes-are-trivial) {
    answer now                           # prose is a valid statement
  } else {
    /polish-plan()                       # invoke another skill
    confirm-with-user("Ready to write the report?")
  }

  # -- phase 3: write --
  subagent(small) {
    draft digest in /skimmable format
  }
  digest ready: <artefact path>

  if ($slack-thread) {
    post digest to thread
  }
}
```

### pick-default-repo()

- Prefer `$repo` when set, else default to `rsc/dotfiles`
- Single-repo digest: `multi-PR: n`
- Quick lookup, effort `L1`

```
def pick-default-repo() {
  return { repo: 'rsc/dotfiles', effort: L1, multi-PR: n }
}
```

## Guidelines

- Run at most once per week per repo; never re-digest a week already reported.
- Digest window is fixed at 7 days; don't backfill older weeks.

````

## Conventions

- Structured returns only where a caller consumes them.
- Keep it skimmable. Read by agents and humans; one glance shows phases and gates.

<!-- spec-end -->
