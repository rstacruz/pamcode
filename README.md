<div align='center' class='hidden'>
  <br/>
  <br/>
  <h1>pamcode</h1>
  <p>grammar for pseudocode for agentic workflows</p>
  <br/>
  <br/>
  <br/>
</div>

Look... you totally can talk to agents in pseudocode. Just paste this into Claude Code. Agents will figure it out.

```
loop (3 times) {
  parallel {
    subagent { evaluate this PR for simplification opportunities }
    subagent { review this PR for bugs }
  }
  triage feedback
}
```

How about we write our skills in the same way?

- Intuitively understandable by humans and agents
- Token-efficient way to write agent workflows
- Write skills in a way that can be code reviewed by agents

**Pamcode = Pseudocode for agents in Markdown.** It's loosely-defined pseudocode grammar for describing agent workflows in `SKILL.md` files. Writing or editing a skill? Point your agent to the [pamcode spec](./skills/pamcode/SKILL.md).

## Usage

Use without installing:

```
run `npx skills use rstacruz/pamcode` and make me a skill to:
create a daily digest report of latest Slack messages
```

Or install it:


```
npx skills add rstacruz/pamcode
```

## Examples

- [Example: daily digest](#daily-digest)
- [Example: autofix PRs](https://github.com/rstacruz/agentic-toolkit/blob/main/skills/atk-pr-autofix/SKILL.md)
- ...more to come

# The spec

Pamcode is available as a skill ([`pamcode`](./skills/pamcode/SKILL.md)). Here's the full skill contents below.

<!-- Don't edit directly; use "just sync" to update below to keep in sync with skill file -->
<!-- spec-start -->

## Markdown shell

Markdown first; pseudocode appears only in `## Workflow` and `###` def blocks.

| Section | Role |
|---|---|
| `## Input` | The `$var`s and `--flags` accepted |
| `## Skill dependencies` | Other skills to read first, as `/path` links |
| `## Workflow` | The `begin()` pseudocode in a `pseudocode` code fence |
| `### <name>()` | One per subroutine: prose instructions and/or a `def` block |
| `## Guidelines` | General guidance for writing the skill |


## Constructs

| Construct | Meaning | Example |
|---|---|---|
| `begin($args) { … }` | Workflow entry point | `begin($request) {` |
| `def name($args) { … }` | Subroutine, usually returning a structured result | `def plan($request) {` |
| `name($args)` | Invoke a routine defined elsewhere | `fetch-changes()` |
| `` `cmd` `` | Run a shell command; yields its stdout | `` `git log --oneline` `` |
| `$var` | Parameter or state | `$request` |
| `if (cond) { … } else { … }` | Branch on category, effort, flags | `if (category == 'code-change') {` |
| `loop { … } until (cond)` | Repeat body until condition holds | `loop { retry() } until (verified)` |
| `loop { … }` | Repeat body until `break` | `loop { if ($tries == 3) { break } }` |
| `break` | Exit the loop early | `if ($tries == 3) { break }` |
| `for each ($x in $xs) { … }` | Repeat the body once per item in `$xs` | `for each ($pr in $prs) { summarize($pr) }` |
| `for each ($x in $xs) in parallel { … }` | Repeat the body once per item, running iterations concurrently; join before moving on | `for each ($file in $files) in parallel { review($file) }` |
| `parallel { … }` | Run each statement at the same time; join before moving on | `parallel { fetch-a(); fetch-b() }` |
| `subagent(tag) { … }` | Fork a subagent; body is its instructions | `subagent(fork) {` |
| `/command()` / `/command args` | Invoke another skill | `/polish-plan()`, `/loop 15m` |
| `return { field: value, ... }` / `return <value>` | Structured or plain result passed up | `return { posted: true }`, `return "nothing new"` |
| `abort "reason"` | Stop the workflow with a failure reason | `abort "couldn't post after 3 tries"` |
| `# comment` / `# -- banner --` | Notes; section banners | `# -- plan phase --` |
| `--flag` | CLI-style option that alters flow | `--yolo` |
| plain prose | A step described in words | `post the draft to the thread for review` |

## Examples

Every skill section and construct, annotated. The skills below are teaching
examples — they demonstrate most constructs; they are not meant to be run.

### daily-digest

````markdown
---
name: daily-digest
description: Teaching example — demonstrates most pamcode constructs; not a runnable skill.
---

## Input

- `$repo` - optional, defaults to the current repo
- `--draft` - post to the thread for review, don't publish

## Skill dependencies

Read first:

- `/format-prose` - formatting conventions the draft must follow (illustrative; substitute a real skill)

## Workflow

```pseudocode
begin($repo, { --draft }) {
  # -- phase 1: gather --
  $changes = fetch-changes($repo)

  if (there are no changes) {
    return "nothing new"
  }

  # -- phase 2: draft --
  subagent(small) {
    group $changes into themes, one section per theme
  }
  /format-prose()
  $digest-path = save-draft()

  if (--draft) {
    post the draft to the thread for review
    return { posted: false }
  }

  # -- phase 3: publish --
  $tries = 0
  loop {
    $tries += 1
    post digest to thread
    if ($tries == 3) { break }
  } until (posted)

  if (not posted) { abort "couldn't post after 3 tries" }
  return { posted, digest-path: $digest-path }
}
```

### fetch-changes()

- List commits and merged PRs since the last digest, newest first.
- Skip WIP branches and bot commits.

```pseudocode
def fetch-changes($repo) {
  $commits = `git log --oneline`
  return { commits: $commits, prs: [...] }
}
```

### save-draft()

Write the draft to a file and return its path.

## Guidelines

- Run at most once per day; skip if already reported.
- Group by theme, one bullet per commit — not a raw commit dump.

````

Example for verifying files:

```pseudocode
begin($files) {
  for each ($file in $files) {
    lint($file)
  }

  for each ($file in $files) in parallel {
    subagent { test($file); fix as needed }
  }

  parallel {
    update-status()
    notify-maintainers()
  }
}
```

## Conventions

- These are suggestions, not strict rules. Deviate if it brings more clarity.
- Add or remove sections as needed. Some information may be best expressed outside of Pamcode conventions.
- Don't reach for writing pseudocode immediately. Opt for prose if it can be expressed better with words.
- Prefer prose for describing intent.
- Keep fan-outs bounded: `for each … in parallel` is for small, independent iterations.
- Keep it skimmable. Optimise to be read by agents and humans.

<!-- spec-end -->

## Thanks

2026
