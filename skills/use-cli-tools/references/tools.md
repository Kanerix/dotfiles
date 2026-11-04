# CLI inventory

Source: the dotfiles repository's `flake.nix`. Package names can differ from executable names. Installed versions, PATH, authentication, optional toolchains, and external services must be checked on the current machine. Read only the relevant category; check installed help before using unfamiliar flags.

## Search, text, and data

| Package / executable | Agent use                                                                                          |
| -------------------- | -------------------------------------------------------------------------------------------------- |
| ripgrep / `rg`       | Scoped content searches, matching filenames, counts, and small evidence snippets.                  |
| fd / `fd`            | Fast path discovery; hidden and ignored files are excluded by default.                             |
| sd / `sd`            | Predictable replacements after checking exact scope; inspect changes afterwards.                   |
| sad / `sad`          | Interactive bulk replacement, mainly for humans; prefer targeted agent edits or sd.                |
| bat / `bat`          | Bounded file reading with paging, color, and decorations disabled.                                 |
| choose / `choose`    | Concise selection of whitespace-delimited fields; not a parser for arbitrary CSV.                  |
| jaq / `jaq`          | Filter and aggregate JSON before it enters context.                                                |
| jless / `jless`      | Interactive JSON browser; prefer jaq for agent queries.                                            |
| xan / `xan`          | CSV selection, filtering, and aggregation; avoid its interactive view mode.                        |
| glow / `glow`        | Markdown rendering, mostly for humans; agents usually need plain source.                           |
| difftastic / `difft` | Syntax-aware comparisons when normal diffs obscure a structural change; use noninteractive output. |
| hexyl / `hexyl`      | Inspect a bounded region of binary data; avoid dumping whole binaries.                             |

## Development and languages

| Package / executable                | Agent use                                                                                                                                                                 |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| just / `just`                       | Discover and reuse project recipes; inspect them before execution.                                                                                                        |
| devenv / `devenv`                   | Reproduce project environments and tasks; configuration can execute code or start services.                                                                               |
| uv / `uv`, `uvx`                    | Fast Python environments and tool execution; prefer pinned project dependencies and account for downloads.                                                                |
| watchexec / `watchexec`             | Useful for human watch workflows; agents should normally run a single build/test instead.                                                                                 |
| hyperfine / `hyperfine`             | Benchmark safe commands with repeated runs.                                                                                                                               |
| tokei / `tokei`                     | Compact language and code-size overview.                                                                                                                                  |
| bun / `bun`, `bunx`                 | JavaScript/TypeScript execution, packages, tests, and bundling when the project uses Bun.                                                                                 |
| nodejs / `node`, `npm`, `npx`       | Existing Node workflows; preserve the project's package manager and lockfile.                                                                                             |
| go / `go`, `gofmt`                  | Compile/test Go and format code deterministically.                                                                                                                        |
| python3 / `python3`                 | Small structured-data scripts and validation; preserve the project's existing environment manager. Use uv where the project supports it; do not modify Nix's interpreter. |
| rustup / `rustup`, `cargo`, `rustc` | Rust toolchain management and compiler/build shims; a toolchain must be installed separately. Do not assume optional components exist.                                    |
| zig / `zig`                         | Build/test Zig and use project-supported cross-compilation workflows.                                                                                                     |

## Git and GitHub

| Package / executable                 | Agent use                                                                                        |
| ------------------------------------ | ------------------------------------------------------------------------------------------------ |
| git / `git`                          | Focused status, history, and diff inspection; disable pagers. Mutations need authorization.      |
| delta / `delta`                      | Human-friendly diff pager; bypass it with `git --no-pager` for agent inspection.                 |

| git-cliff / `git cliff`              | Generate changelogs using project conventions rather than hand-summarizing every commit.         |
| gh / `gh`                            | Focused GitHub queries through JSON fields and filters; distinguish read operations from writes. |
| jujutsu / `jj`                       | Use in repositories already using Jujutsu; do not migrate Git workflows automatically.           |
| gitleaks / `gitleaks`                | Secret detection with redaction; never echo discovered credentials.                              |

## Files, system, and containers

| Package / executable                                   | Agent use                                                                                                                     |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| eza / `eza`                                            | Small directory overviews with color disabled; fd is better for targeted discovery.                                           |
| ouch / `ouch`                                          | Archive compression/extraction; inspect destination and overwrite behavior first.                                             |
| xcp / `xcp`                                            | File copying when needed; progress output rarely helps agents and overwrites need care.                                       |
| trash-cli / `trash-put`, `trash-list`, `trash-restore` | Recoverable deletion and recovery; do not delete without authorization.                                                       |
| procs / `procs`                                        | Filter process inspection; select relevant processes rather than return full tables.                                          |
| bottom / `btm`                                         | Interactive monitoring, primarily for humans.                                                                                 |
| dust / `dust`                                          | Compact disk-usage summaries, scoped to the directory in question.                                                            |
| duf / `duf`                                            | Filesystem capacity overview; choose machine-readable output if supported by the installed version.                           |
| viddy / `viddy`                                        | Watch-style interface; avoid indefinite monitoring in one-shot agent terminals.                                               |
| lazydocker / `lazydocker`                              | Human container TUI; installation does not provide a Docker runtime.                                                          |
| dive / `dive`                                          | Image-layer analysis; use documented noninteractive/CI mode when appropriate. Image access/runtime requirements are separate. |

## Networking, media, and math

| Package / executable                  | Agent use                                                                                                                          |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| xh / `xh`, `xhs`                      | HTTP requests with focused response output; check method, credentials, and data-sharing implications.                              |
| doggo / `doggo`                       | DNS queries; select relevant records and structured output where supported.                                                        |
| gping / `gping`                       | Interactive latency graphs; generally not useful for one-shot agents.                                                              |
| bandwhich / `bandwhich`               | Interactive network monitoring, potentially requiring elevated privileges; not a default agent tool.                               |
| ffmpeg-headless / `ffmpeg`, `ffprobe` | Media conversion and focused metadata extraction. Prefer selected ffprobe fields in JSON; avoid large logs. No ffplay is included. |
| numbat / `numbat`                     | Deterministic calculations and unit conversions using documented noninteractive invocation; avoid the default REPL.                |

## Nix tooling

| Package / executable  | Agent use                                                                                          |
| --------------------- | -------------------------------------------------------------------------------------------------- |
| nixfmt / `nixfmt`     | Mechanical Nix formatting; formatting modifies files unless using a supported check mode.          |
| nil / `nil`           | Nix language server used by editors, not a normal one-shot CLI.                                    |
| statix / `statix`     | Nix linting; use checks before opting into fixes.                                                  |
| deadnix / `deadnix`   | Find unused Nix code; use `--fail` for a failing check and review before removing code.            |
| nix-tree / `nix-tree` | Interactive closure explorer, primarily for humans.                                                |
| nvd / `nvd`           | Compare Nix generations/closures before an authorized switch; inspect without changing the system. |

## Secrets and shell sessions

| Package / executable         | Agent use                                                                                    |
| ---------------------------- | -------------------------------------------------------------------------------------------- |
| age / `age`, `age-keygen`    | Authorized file encryption; key generation/decryption needs careful handling of secrets.     |
| sops / `sops`                | Edit encrypted configuration through approved workflows; avoid plaintext in logs or context. |
| 1password-cli / `op`         | Authorized secret injection into processes; avoid printing vault values.                     |
| fish / `fish`, `fish_indent` | Fish execution and formatting; do not assume interactive initialization or aliases.          |
| bash / `bash`                | Script execution when Bash is required; syntax differs from Fish.                            |
| skim / `sk`, `sk-tmux`       | Mostly interactive selection; use only a documented finite mode for automation.              |
| zoxide / `zoxide`            | Human directory navigation; agents should use explicit known working directories.            |
| starship / `starship`        | Prompt rendering; no meaningful token-saving role for agents.                                |
| zellij / `zellij`            | Human terminal sessions; avoid opening interactive sessions in one-shot agent tools.         |
| tealdeer / `tldr`            | Short command examples; cache population/update needs network access.                        |
| direnv / `direnv`            | Project environment loading after reviewing and trusting its configuration.                  |
| nix-direnv                   | Integration sourced by direnv, not a separate agent command.                                 |
