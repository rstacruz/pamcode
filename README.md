# Pamcode

**Pamcode = Pseudocode Agent Markdown.** Informal pseudocode for describing agent workflows in `SKILL.md` files.

## Markdown shell

Markdown first; pseudocode lives in `## Workflow`, wrapped by frontmatter and `###` sections.

| Section | Role |
|---|---|
| `---` frontmatter | `name:`, `description:`, optional `disable-model-invocation` / `argument-hint` |
| `## Input` | The `$var`s and `--flags` accepted |
| `## Skill dependencies` | Other skills to read first, as `/path` links |
| `## Workflow` | The `begin()` pseudocode in a code fence |
| `### <name>()` | One per subroutine: prose instructions or a `def` block |

## Constructs

| Construct | Meaning | Example |
|---|---|---|
| `begin($args) { … }` | Workflow entry point | `begin($request) {` |
| `def name($args) { … }` | Subroutine, usually returning a structured result | `def plan($request) {` |
| `$var` | Parameter or state | `$request` |
| `if (cond) { … } else { … }` | Branch on category, effort, flags | `if (category == 'code-change') {` |
| `subagent(tag) { … }` | Fork a subagent; body is its instructions | `subagent(fork) {` |
| `notify(…)` | Fire-and-forget output to Slack/chat/thread | `notify(PR created, planning now)` |
| `/command()` / `/command args` | Invoke another skill | `/polish-plan()`, `/loop 15m` |
| `confirm-with-user("…")` | Pause for human approval (skipped with `--yolo`) | `confirm-with-user("Ready?")` |
| `return { field, field: y/n }` | Structured result passed up | `return { plan-file, multi-PR: y/n }` |
| `# comment` / `# -- banner --` | Notes; section banners | `# -- plan phase --` |
| `--flag` | CLI-style option that alters flow | `--yolo` |
| plain prose | A step described in words | `answer now` |

Values are loose: strings, numbers, effort levels (`L1`–`L5`), `y/n`, or prose.

## Kitchen sink example

Every shell section and construct, annotated:

````markdown
---
name: weekly-digest
description: Triage a weekly digest request.
disable-model-invocation: true
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
# -- weekly digest: pick a repo, review the week, report --

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
    notify(Short summary, no artefacts)
  } else {
    /polish-plan()                       # invoke another skill
    confirm-with-user("Ready to write the report?")
  }

  # -- phase 3: write --
  subagent(small) {
    draft digest in /skimmable format
  }
  notify(Digest ready: <artefact path>)

  if ($slack-thread) {
    notify(Post digest to thread)        # side-channel, not return value
  }
}
```

### pick-default-repo()

```
def pick-default-repo() {
  return { repo: 'rsc/dotfiles', effort: L1, multi-PR: n }
}
```
````

## Conventions

- **Orchestrator voice.** Top level directs; subagents do.
- **Subagent bodies are instructions**, not calls: prose or slash commands for the spawned agent.
- **`notify()` is fire-and-forget** — never a value to branch on.
- **Structured returns only where a caller consumes them.**
- **Keep it skimmable.** Read by agents and humans; one glance shows phases and gates.
