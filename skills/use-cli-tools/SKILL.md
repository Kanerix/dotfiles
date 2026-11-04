---
name: use-cli-tools
description: Choose CLI tools from the user's environment to work faster and reduce unnecessary output. Use when searching code or paths, inspecting JSON/CSV or GitHub data, running project tasks, formatting or checking code, benchmarking, or choosing shell commands—even when the user does not explicitly ask for tool recommendations.
---

# Use CLI tools

Choose the smallest reliable operation that answers the question. Save tokens by returning relevant evidence, not by hiding failures. Prefer built-in agent search, read, and edit tools when they provide better targeting or safer edits than shell commands.

## Workflow

1. Identify the needed result: paths, matching lines, selected data fields, a test result, or a change.
2. Choose a tool below. These tools are declared in the dotfiles flake, not guaranteed to be installed or on the agent's PATH. Check only relevant executables with `command -v`. Do not install tools or switch package managers just to use this skill.
3. Discover paths before reading; narrow searches to known subtrees; read only relevant sections. Inspect project recipes and manifests before running tasks.
4. Use finite, noninteractive commands, plain text or structured output, and the terminal tool's timeout/output limits. Avoid pagers, REPLs, watchers, and decorative output.
5. Verify changes with focused checks. Report the result and any missing dependencies or incomplete evidence; do not claim measured speed or token savings without a comparison.

## High-value choices

| Need                  | Tool                                                  | Benefit / approach                                                                                                                             |
| --------------------- | ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Locate paths          | `fd`                                                  | Filter by extension or name instead of listing entire trees.                                                                                   |
| Search contents       | `rg`                                                  | Use `-l` for filenames, `-n` for evidence, `-F` for literal strings, `-g` for file scope.                                                      |
| Filter JSON           | `jaq`                                                 | Select fields or aggregate before returning data to the model.                                                                                 |
| Inspect GitHub        | `gh`                                                  | Request only needed `--json` fields; use `--jq` for further filtering. Authentication and network access may be needed.                        |
| Inspect CSV           | `xan`                                                 | Select columns, filter rows, and aggregate instead of reading whole datasets. Check subcommand help for syntax.                                |
| Run project tasks     | `just`                                                | Use established recipes rather than reconstructing setup, build, and test commands. Read recipes before executing them.                        |
| Python tooling        | `uv`, `uvx`                                           | Reuse project environments and pinned tools. Downloads and third-party tool execution may occur.                                               |
| Text replacement      | `sd`                                                  | Useful for precise, predictable replacements; inspect scope first and review the diff afterwards. Prefer targeted editor edits when available. |
| Formatting/checks     | `nixfmt`, `statix`, `deadnix`, `gofmt`, `fish_indent` | Delegate mechanical work to deterministic tools; distinguish checks from commands that modify files.                                           |
| Secret scanning       | `gitleaks`                                            | Detect likely leaked credentials; request redacted output.                                                                                     |
| Code overview         | `tokei`                                               | Get a compact language/size summary.                                                                                                           |
| Benchmarking          | `hyperfine`                                           | Measure performance rather than guess. It executes each command repeatedly; benchmark only safe operations.                                    |
| Quick syntax examples | `tldr`                                                | Read short examples instead of lengthy manuals. Verify exact flags with the installed tool's help.                                             |

## Examples

Paths first, then targeted content (use these paths only after confirming they exist):

```sh
fd -e ts -e tsx . src/
rg -l -F 'createClient' src/
rg -n -F 'createClient' src/client.ts
```

`fd` and `rg` normally skip hidden and ignored files. For a confirmed hidden config directory, use `rg --hidden -n -F 'delta' .config/git/`. Add `--no-ignore` only if ignore rules exclude the needed target; scope carefully to avoid secrets and generated files. `rg` exit status 1 means no matches, not an execution error.

Compact data and Git evidence:

```sh
jaq '.items[] | {id, title}' response.json
gh pr view 42 --json title,files --jq '{title, paths: [.files[].path]}'
git --no-pager diff --stat
git --no-pager diff -- path/to/file
```

Repeatable tasks and checks:

```sh
just --list
uv run --locked python -m unittest
statix check .
deadnix --fail .
gitleaks dir . --no-banner --redact
```

Use task commands only when the project supports them. `uv run` may synchronize the environment and download dependencies. Rust's `cargo`/`rustc` shims need an installed toolchain; rustup alone does not provide one.

## Output and safety

- Prefer explicit executable names over interactive Fish aliases; an agent may run Bash or another shell.
- For Git inspection, put `--no-pager` immediately after `git`. Prefer `git --no-optional-locks status --short` for status.
- Do not choose tools whose only meaningful benefit for the task is visual presentation, such as `bat`, `delta`, or `glow`. Prefer native targeted reads and plain text or structured output; highlighting, decorative tables, and rendered Markdown do not help agents work faster or use fewer tokens. Keep these tools in the inventory for completeness, not as recommendations. Use them only when the user requests their presentation or a concrete nonvisual capability justifies them.
- Preserve enough error output to diagnose failures. Do not blindly truncate test logs or swallow nonzero statuses. Narrow the query before limiting output.
- Avoid unbounded servers/watchers. Check installed help before relying on a tool's batch, JSON, or finite-run mode.
- Respect project lockfiles and toolchains. Do not replace npm with Bun, Git with Jujutsu, or project commands with personal preferences.
- Read a project's environment configuration before approving it with direnv or invoking devenv; environment setup can execute code.
- Secrets tools (`op`, `sops`, `age`) are for authorized workflows, not discovery shortcuts. Keep plaintext credentials out of output and model context; prefer injection into the intended process.
- File removal, bulk replacement, archive extraction, network writes, and repository mutations still require appropriate scope and authorization. Recoverable trash does not make deletion harmless.

## Additional tools

Read [references/tools.md](references/tools.md) only when a task involves tools not covered above or needs the complete inventory. It lists only packages/executables provided by this repository's `flake.nix`; do not assume additional host tools are installed. Keep the inventory aligned with the flake when tools change.
