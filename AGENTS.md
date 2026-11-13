# lerpz.com - Agent Specification

This is a general-purpose mono repository for the Lerpz organisation.

## Personas

ALWAYS READ YOUR PERSONA IF YOU HAVEN'T YET.

Unless told otherwise, work as the developer persona in
`.agents/personas/developer.md`. A persona covers how to work, this file covers
the conventions and the tooling it works with.

If personas folder does not exists, skip reading them. Don't notify the user.

## General rules

Keep things simple. Solve the problem that was asked for, in the smallest way
that fits the code around it.

- Do not build for requirements that do not exist yet. No extra abstraction
  layers, configuration options or generic helpers added on the assumption that
  something will need them later.
- Prefer the boring solution. A plain function beats a trait, a macro or a
  generic parameter unless there is a concrete reason for the latter.
- Change as little as possible. Do not rename, reformat or restructure code that
  is unrelated to the task.
- Reuse what is already in the repository before reaching for a new dependency,
  pattern or file.
- If something cannot be done simply, say so and explain the trade-off rather
  than hiding the complexity in clever code.
- Leave working code behind, not scaffolding. Finish one thing properly instead
  of half-doing several.

## Writing

This applies to commit messages, documentation, comments, pull request
descriptions and anything else written for a human to read.

- Do not use em dashes or en dashes. Use a comma, a full stop, or rewrite the
  sentence.
- Write short, direct sentences in plain language, and say each thing once.
- Cut filler words such as "simply", "just", "seamlessly", "robust", "powerful"
  and "leverage".
- Drop the summary that repeats what was already said, and the closing sentence
  that adds nothing.
- Avoid the patterns that read as machine written, such as "it is not just X, it
  is Y", lists of three adjectives, and headings or bold text sprinkled through
  a few short paragraphs.
- Use British spelling.

## Git conventions

Commit messages follow the [Conventional Commits](https://www.conventionalcommits.org)
specification and should be written in the imperative mood, as recommended by Git.

Never commit on your own. Finish the work, report what changed, and let the user
decide when it gets committed. The same goes for staging, amending, and pushing.

Drafting the message is a different matter, and it is welcome and encouraged.
When you finish a change, offer a commit message the user can take or edit. A
good draft saves them the work of reconstructing what you did.

Keep commit messages short and plain. No emoji. Write a subject line and stop
there. A body is the exception, not the default. Add one only when the change is
unusable without a reason the subject cannot hold, and keep it to a sentence or
two. If one message needs a paragraph to cover everything, the commit is
probably two commits.

## Comments

Prefer self-explanatory code over comments. Before writing a comment, try to make
it unnecessary. Use descriptive names for variables, functions, parameters and
types, extract a named function or constant, or restructure the code so the
intent is obvious.

Write a comment only when it explains something the code cannot, such as:

- Why a non-obvious approach was chosen, or why the obvious one does not work.
- Constraints, trade-offs, invariants and assumptions that are not visible locally.
- References to external context, such as a specification, ticket or upstream bug.
- Warnings about surprising behaviour or subtle edge cases.

Do not write comments that:

- Restate what the code already says.
- Narrate a change or its history. That belongs in the commit message.
- Assume the machine the code runs on, such as installed CLI tools, absolute
  paths or a particular operating system.

Documentation comments on public APIs are encouraged and are not covered by the
rules above, but they should explain purpose, behaviour and caveats rather than
repeat the signature. Follow the language's documentation conventions and keep
existing comments up to date when the surrounding code changes.

## Structure

Use the language's own structure to separate code, not comments. A file that
needs a banner to explain where one part ends and the next begins is a file that
wants to be split up.

Do not mark sections of a file with a comment, for example:

```
// ---------------------- Stuff here ----------------------
```

Split the code into smaller functions, modules or files instead, and let the
names carry the meaning the banner was trying to give.

## Testing

- Add tests only when the user explicitly asks for them. Do not add tests on
  your own initiative.
- When tests are requested, keep them simple. Use only the setup and assertions
  needed to check the requested behaviour.
- Split tests into focused cases with clear names. Each test should cover one
  behaviour or scenario; do not combine unrelated checks into one large test.
- Group related tests in the appropriate module or file. Split unrelated groups
  so their purpose is clear, without adding unnecessary helpers or abstractions.

## Command line tools

The environment provides faster replacements for the standard tools. Use them.
They respect `.gitignore`, so they skip `target/`, `node_modules/` and
`.svelte-kit/` without being told. The classic tools crawl those directories and
will waste time.

| Instead of   | Use        | Notes                                                            |
| ------------ | ---------- | ---------------------------------------------------------------- |
| `grep -r`    | `rg`       | Filter by language with `rg -t rust`, `rg -t ts`, `rg -t svelte` |
| `find -name` | `fd`       | `fd -e rs`, `fd handler svc/api`                                 |
| `sed -i`     | `sd`       | Literal by default, so no regex escaping for a plain rename      |
| `jq`         | `jaq`      | For the OpenAPI spec and the `.sqlx` cache entries               |
| `rg -U`      | `ast-grep` | Match by syntax tree. Rust and TS, no Svelte grammar             |

Search with `rg` before you search with anything else. Pair it with `sd` for a
mechanical rename, such as `rg -l OldName | xargs sd OldName NewName`, and read
the diff afterwards. Do not use a bulk replace for anything that needs judgement.

Reach for `ast-grep` when the shape matters more than the text, such as every
handler signature or every `.unwrap()` call:

```sh
ast-grep --lang rust --pattern 'pub async fn handler($$$A) -> $R { $$$B }' svc/
```

The pattern has to parse on its own, so match a whole item rather than a fragment
such as a single argument.

## README documentation

- Write `README.md` for readers who have not seen any agent conversation or
  repository change history. Describe the current setup and behaviour, not how
  they changed.
- Never assume knowledge of earlier decisions, previous configurations, or
  completed work. Avoid wording such as "now", "still", "as before", or "the
  former setup" when it depends on that history.
- State prerequisites and instructions explicitly, or link to the relevant
  documentation. Any migration guide must explain its starting configuration
  and intended result without relying on conversation context.
