# CLI inventory

Source: the dotfiles repository's macOS Homebrew `Brewfile`, including preserved Go/Cargo entries and the CLI cask. GUI apps and fonts are not CLI inventory entries. Homebrew tracks unpinned current releases, not a locked CLI bundle. Package names can differ from executable names. Installed versions, PATH, authentication, optional toolchains, and external services must be checked on the current machine. Read only the relevant category; check installed help before using unfamiliar flags.

## Search, text, and data

| Package / executable        | Agent use                                                                                                      |
| --------------------------- | -------------------------------------------------------------------------------------------------------------- |
| ripgrep / `rg`              | Scoped content searches, matching filenames, counts, and small evidence snippets.                              |
| ast-grep / `ast-grep`, `sg` | Syntax-aware code search and linting; scope by language and path, and review matches before applying rewrites. |
| fd / `fd`                   | Fast path discovery; hidden and ignored files are excluded by default.                                         |
| sd / `sd`                   | Predictable replacements after checking exact scope; inspect changes afterwards.                               |
| sad / `sad`                 | Interactive bulk replacement, mainly for humans; prefer targeted agent edits or sd.                            |
| bat / `bat`                 | Bounded file reading with paging, color, and decorations disabled.                                             |
| choose-rust / `choose`      | Concise selection of whitespace-delimited fields; not a parser for arbitrary CSV.                              |
| jaq / `jaq`                 | Filter and aggregate JSON before it enters context.                                                            |
| jless / `jless`             | Interactive JSON browser; prefer jaq for agent queries.                                                        |
| xan / `xan`                 | CSV selection, filtering, and aggregation; avoid its interactive view mode.                                    |
| glow / `glow`               | Markdown rendering, mostly for humans; agents usually need plain source.                                       |
| difftastic / `difft`        | Syntax-aware comparisons when normal diffs obscure a structural change; use noninteractive output.             |
| hexyl / `hexyl`             | Inspect a bounded region of binary data; avoid dumping whole binaries.                                         |

## Development and languages

| Package / executable                  | Agent use                                                                                                                                                                                                            |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| zerobrewhq/tap/zerobrew / `zb`, `zbx` | Experimental alternative Homebrew package client; use alongside Homebrew, not as an automatic replacement for `brew`. Initialization can modify shell config; package operations require authorization.              |
| just / `just`                         | Discover and reuse project recipes; inspect them before execution.                                                                                                                                                   |
| ruff / `ruff`                         | Python linting and formatting; checks are read-only, while fixes and formatting modify files.                                                                                                                        |
| pnpm / `pnpm`, `pnpx`                 | Reuse project JavaScript dependency workflows and lockfiles; installs can execute lifecycle scripts.                                                                                                                 |
| uv / `uv`, `uvx`                      | Fast Python environments and tool execution; prefer pinned project dependencies and account for downloads.                                                                                                           |
| watchexec / `watchexec`               | Useful for human watch workflows; agents should normally run a single build/test instead.                                                                                                                            |
| hyperfine / `hyperfine`               | Benchmark safe commands with repeated runs.                                                                                                                                                                          |
| tokei / `tokei`                       | Compact language and code-size overview.                                                                                                                                                                             |
| oven-sh/bun/bun / `bun`, `bunx`       | JavaScript/TypeScript execution, packages, tests, and bundling when the project uses Bun.                                                                                                                            |
| node / `node`, `npm`, `npx`           | Existing Node workflows; preserve the project's package manager and lockfile.                                                                                                                                        |
| go / `go`, `gofmt`                    | Compile/test Go and format code deterministically.                                                                                                                                                                   |
| python / `python3`                    | Small structured-data scripts and validation; preserve the project's existing environment manager. Use uv where the project supports it; keep project dependencies separate from Homebrew's interpreter.             |
| ruby / `ruby`, `gem`, `bundle`        | Ruby execution and gem dependencies; preserve project Ruby versions and `Gemfile.lock`. Keg-only binaries use the `bin` directory under `brew --prefix ruby` on PATH.                                                |
| rustup / `rustup`, `cargo`, `rustc`   | Rust toolchain management and compiler/build shims; a toolchain must be installed separately. Keg-only shims need the `bin` directory under `brew --prefix rustup` on PATH. Do not assume optional components exist. |
| zig / `zig`                           | Build/test Zig and use project-supported cross-compilation workflows.                                                                                                                                                |
| libpq / `psql`                        | Keg-only PostgreSQL client library/tools; check PATH and connection target before database operations.                                                                                                               |
| mkcert / `mkcert`                     | Local development certificates; trust-store changes require authorization.                                                                                                                                           |
| nss                                   | Security libraries/tools; do not assume a particular executable is on PATH.                                                                                                                                          |

Keep npm global installs under `~/.local` with `npm config set prefix ~/.local`
and `mkdir -p ~/.local/lib/node_modules`; Fish already adds `~/.local/bin` to PATH.
Do not install host packages or Rust toolchains just to use this inventory.

## Separately installed Nix environments

Nix and devenv are noted in Brewfile comments, not installed by Homebrew. Projects
using `use devenv`, `use nix`, or `use flake` still require Nix. Devenv supplies
packages declared in the project's `devenv.nix`; do not assume they are global
Homebrew dependencies. Review `.envrc` before authorizing environment loading,
which may execute code and download/build packages. Do not uninstall Nix while
projects still depend on it.

## Cloud and Kubernetes

| Package / executable                                  | Agent use                                                                                                                    |
| ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| awscli / `aws`                                        | Official AWS CLI v2; use focused queries and keep credentials out of output. Cloud mutations require authorization.          |
| azure-cli (cask) / `az`                               | Official Azure CLI; select output fields and confirm the subscription before authorized mutations.                           |
| hcloud / `hcloud`                                     | Official Hetzner Cloud CLI; verify project context, keep API tokens local, and require authorization for resource mutations. |
| kubernetes-cli / `kubectl`                            | Inspect Kubernetes resources; verify context and namespace before authorized mutations.                                      |
| helm / `helm`                                         | Inspect charts and releases; installs, upgrades, and uninstalls change cluster state.                                        |
| aztfexport / `aztfexport`                             | Export Azure resources for Terraform; review subscription, credentials, and generated files.                                 |
| azure/functions/azure-functions-core-tools@4 / `func` | Local Azure Functions tooling; avoid starting long-running hosts in one-shot terminals.                                      |
| hashicorp/tap/terraform / `terraform`                 | Reuse project infrastructure workflows; apply/destroy require explicit authorization.                                        |

## Git and GitHub

| Package / executable    | Agent use                                                                                        |
| ----------------------- | ------------------------------------------------------------------------------------------------ |
| git / `git`             | Focused status, history, and diff inspection; disable pagers. Mutations need authorization.      |
| git-delta / `delta`     | Human-friendly diff pager; bypass it with `git --no-pager` for agent inspection.                 |
| git-cliff / `git cliff` | Generate changelogs using project conventions rather than hand-summarizing every commit.         |
| gh / `gh`               | Focused GitHub queries through JSON fields and filters; distinguish read operations from writes. |
| jujutsu / `jj`          | Use in repositories already using Jujutsu; do not migrate Git workflows automatically.           |
| gitleaks / `gitleaks`   | Secret detection with redaction; never echo discovered credentials.                              |

## Files, system, and containers

| Package / executable                                   | Agent use                                                                                                                        |
| ------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| eza / `eza`                                            | Small directory overviews with color disabled; fd is better for targeted discovery.                                              |
| ouch / `ouch`                                          | Archive compression/extraction; inspect destination and overwrite behavior first.                                                |
| xcp / `xcp`                                            | File copying when needed; progress output rarely helps agents and overwrites need care.                                          |
| trash-cli / `trash-put`, `trash-list`, `trash-restore` | Recoverable deletion and recovery; do not delete without authorization.                                                          |
| procs / `procs`                                        | Filter process inspection; select relevant processes rather than return full tables.                                             |
| bottom / `btm`                                         | Interactive monitoring, primarily for humans.                                                                                    |
| dua-cli / `dua`                                        | Scoped disk-usage summaries; `dua interactive` is for human exploration. Deletion requires authorization and does not use trash. |
| duf / `duf`                                            | Filesystem capacity overview; choose machine-readable output if supported by the installed version.                              |
| viddy / `viddy`                                        | Watch-style interface; avoid indefinite monitoring in one-shot agent terminals.                                                  |
| lazydocker / `lazydocker`                              | Human container TUI; installation does not provide a Docker runtime.                                                             |
| dive / `dive`                                          | Image-layer analysis; use documented noninteractive/CI mode when appropriate. Image access/runtime requirements are separate.    |
| ddrescue / `ddrescue`                                  | Data recovery; device access and destination writes require explicit authorization.                                              |
| kind / `kind`                                          | Local Kubernetes clusters; runtime setup and cluster mutations need authorization.                                               |
| metalbear-co/mirrord/mirrord / `mirrord`               | Connect local processes to cloud environments; confirm context and traffic implications.                                         |

## Networking, media, and math

| Package / executable                   | Agent use                                                                                                                                                             |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| xh / `xh`, `xhs`                       | HTTP requests with focused response output; check method, credentials, and data-sharing implications.                                                                 |
| doggo / `doggo`                        | DNS queries; select relevant records and structured output where supported.                                                                                           |
| gping / `gping`                        | Interactive latency graphs; generally not useful for one-shot agents.                                                                                                 |
| bandwhich / `bandwhich`                | Interactive network monitoring, potentially requiring elevated privileges; not a default agent tool.                                                                  |
| cloudflared / `cloudflared`            | Cloudflare Tunnel client; tunnels are long-running and can expose local services. Do not start one without authorization.                                             |
| exiftool / `exiftool`                  | Read selected file metadata; metadata edits modify files and need explicit scope.                                                                                     |
| ffmpeg / `ffmpeg`, `ffprobe`, `ffplay` | Media conversion and focused metadata extraction. Prefer selected ffprobe fields in JSON; avoid large logs. ffplay is interactive playback, not a default agent tool. |
| numbat / `numbat`                      | Deterministic calculations and unit conversions using documented noninteractive invocation; avoid the default REPL.                                                   |
| feroxbuster / `feroxbuster`            | Web content discovery only on explicitly authorized targets; account for request volume.                                                                              |
| oxvg                                   | SVG optimization tooling; inspect installed help and output destinations before modifying assets.                                                                     |
| sherlock / `sherlock`                  | Username/account discovery; respect privacy, authorization, and network implications.                                                                                 |
| yt-dlp / `yt-dlp`                      | Download media only with authorization; account for network, storage, and site rules.                                                                                 |

## Preserved Go/Cargo tools

Go packages may download code and need authentication; the private `daix` entry
may require access credentials. Cargo packages require a separately installed
Rust toolchain. Preserve these entries when updating the shared CLI inventory.

| Package / executable                                                           | Agent use                                                                       |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| github.com/egmont-data-and-intelligent-tech/daix (Go)                          | Preserved private package; check authorized project documentation before use.   |
| github.com/nametake/golangci-lint-langserver (Go) / `golangci-lint-langserver` | Editor lint integration, not a normal one-shot CLI.                             |
| cargo-machete (Cargo) / `cargo machete`                                        | Find unused Rust dependencies; inspect results before removing declarations.    |
| cargo-watch (Cargo) / `cargo watch`                                            | Human watch workflows; agents should run finite checks instead.                 |
| sqlx-cli (Cargo) / `sqlx`                                                      | Database and migration tooling; verify database target and authorize mutations. |
| surrealkit (Cargo)                                                             | Preserved package; inspect installed help and project documentation before use. |

## Secrets and shell sessions

| Package / executable         | Agent use                                                                                    |
| ---------------------------- | -------------------------------------------------------------------------------------------- |
| age / `age`, `age-keygen`    | Authorized file encryption; key generation/decryption needs careful handling of secrets.     |
| gnupg / `gpg`, `gpg-agent`   | Authorized OpenPGP encryption and signing; avoid exposing private keys or decrypted secrets. |
| pinentry-mac / `pinentry-mac` | Native macOS GPG passphrase dialog; configure its Homebrew executable path in local `gpg-agent.conf`. Never collect passphrases through agent tools. |
| sops / `sops`                | Edit encrypted configuration through approved workflows; avoid plaintext in logs or context. |
| 1password-cli (cask) / `op`  | Authorized secret injection into processes; avoid printing vault values.                     |
| fish / `fish`, `fish_indent` | Fish execution and formatting; do not assume interactive initialization or aliases.          |
| bash / `bash`                | Script execution when Bash is required; syntax differs from Fish.                            |
| vim / `vim`                  | Human terminal editing; use isolated, noninteractive Ex mode for configuration checks.       |
| sk / `sk`                    | Mostly interactive selection; use only a documented finite mode for automation.              |
| zoxide / `zoxide`            | Human directory navigation; agents should use explicit known working directories.            |
| starship / `starship`        | Prompt rendering; no meaningful token-saving role for agents.                                |
| tealdeer / `tldr`            | Short command examples; cache population/update needs network access.                        |
| direnv / `direnv`            | Project environment loading after reviewing and trusting its configuration.                  |
