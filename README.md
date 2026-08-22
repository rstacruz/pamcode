# Pamcode

**Pamcode = Pseudocode for agents in Markdown.** Informal pseudocode for describing agent workflows in `SKILL.md` files.

- Intuitively understandable by humans and agents, no need to read spec
- Token-efficient way to write agent workflows

## Usage

Use without installing:

```
run `npx skills use rstacruz/pamcode` and make me a skill to:
create a dsily digest report of latest Slack messages that need my attention
```

Or install it:


```
npx skills add rstacruz/pamcode
```

# The spec

<!-- Don't edit directly; use "just sync" to update below to keep in sync with skill file -->
<!-- spec-start -->

## Markdown shell

Markdown first; pseudocode lives in `## Workflow`, wrapped by frontmatter and `###` sections.

| Section | Role |
|---|---|
| `## Input` | The `$var`s and `--flags` accepted |
| `## Skill dependencies` | Other skills to read first, as `/path` links |
| `## Workflow` | The `begin()` pseudocode in a code fence |
| `### <name>()` | One per subroutine: prose instructions and/or a `def` block |
| `## Guidelines` | General guidance for writing the skill |

## Constructs

| Construct | Meaning | Example |
|---|---|---|
| `begin($args) { … }` | Workflow entry point | `begin($request) {` |
| `def name($args) { … }` | Subroutine, usually returning a structured result | `def plan($request) {` |
| `name($args)` | Invoke a routine defined elsewhere | `fetch-changes()` |
| `$var` | Parameter or state | `$request` |
| `if (cond) { … } else { … }` | Branch on category, effort, flags | `if (category == 'code-change') {` |
| `loop { … } until (cond)` | Repeat body until condition holds | `loop { retry() } until (verified)` |
| `loop { … }` | Repeat body until `break` | `loop { if ($tries == 3) { break } }` |
| `break` | Exit the loop early | `if ($tries == 3) { break }` |
| `subagent(tag) { … }` | Fork a subagent; body is its instructions | `subagent(fork) {` |
| `/command()` / `/command args` | Invoke another skill | `/polish-plan()`, `/loop 15m` |
| `return { field: value, ... }` / `return <value>` | Structured or plain result passed up | `return { posted: true }`, `return "nothing new"` |
| `# comment` / `# -- banner --` | Notes; section banners | `# -- plan phase --` |
| `--flag` | CLI-style option that alters flow | `--yolo` |
| plain prose | A step described in words | `post the draft to the thread for review` |

## Example

Every shell section and construct, annotated. The skill below is a teaching
example — it shows every construct; it is not meant to be run.

````markdown
---
name: daily-digest
description: Teaching example — demonstrates every pamcode construct; not a runnable skill.
---

## Input

- `$repo` - optional, defaults to the current repo
- `--draft` - post to the thread for review, don't publish

## Skill dependencies

Read first:

- `/format-prose` - formatting conventions the draft must follow (illustrative; substitute a real skill)

## Workflow

```
begin($repo, { --draft }) {
  # -- phase 1: gather --
  $changes = fetch-changes($repo)              # def returns a structured result

  if (there are no changes) {
    return "nothing new"                       # plain value; ends the run
  } else {
    # -- phase 2: draft --
    subagent(small) {                          # fork a subagent; body = its job
      group $changes into themes, one section per theme
    }
    /format-prose()                            # invoke another skill
    $digest-path = save-draft()                # keep the returned path
  }

  if (--draft) {                               # flag alters flow
    post the draft to the thread for review
    return { posted: false }                   # draft only; nothing published
  }

  # -- phase 3: publish --
  $tries = 0
  loop {
    $tries = $tries + 1
    post digest to thread
    if ($tries == 3) { break }
  } until (posted)
  return { posted, digest-path: $digest-path }
}
```

### fetch-changes()

- List commits and merged PRs since the last digest, newest first.
- Skip WIP branches and bot commits.

```
def fetch-changes($repo) {
  return { commits: [...], prs: [...] }
}
```

### save-draft()

- Write the draft to a file and return its path.

```
def save-draft() {
  return <path>
}
```

## Guidelines

- Run at most once per day; skip if already reported.
- Group by theme, one bullet per commit — not a raw commit dump.

````

## Conventions

- These are suggestions, not strict rules. Deviate if it brings more clarity.
- Keep it skimmable. Optimise to be read by agents and humans.

<!-- spec-end -->

## Thanks

2026
