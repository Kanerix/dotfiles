# Repository guidance

## Purpose and scope

This repository maintains shared dotfiles and CLI tools for the owner's computers.
It uses a Nix flake and symlinked configuration, not a NixOS or Home Manager setup.
Keep changes small, portable, and consistent with the existing patterns.

## Repository map

- `flake.nix`: CLI packages grouped by category and combined into one `buildEnv`.
  Both `packages.<system>.cli-tools` and `default` refer to this bundle.
- `flake.lock`: pinned `nixpkgs` revision shared across machines.
- `config/`: files linked into `~/.config/`, preserving relative paths. Includes
  Fish, Git, Nix, direnv, Alacritty, and Starship configuration.
- `config/fish/completions/`: checked-in completion files, loaded lazily by Fish.
- `skills/`: agent skill directories linked into `~/.agents/skills/`.
- `justfile`: concise command interface for repository workflows and secret scanning.
- `scripts/`: Bash implementations for linking, diagnostics, and completion generation;
  invoked by `just` with explicit path arguments.
- `README.md`: setup, update, rollback, and integration documentation.
- `WHAT.md`: alphabetically ordered tool inventory.

## Nix packages

- Preserve support for `aarch64-darwin`, `x86_64-darwin`, `aarch64-linux`, and
  `x86_64-linux`. Avoid unguarded platform-specific packages or assumptions.
- Add tools to the appropriate existing category in `flake.nix`. Categories are
  alphabetical; package entries are grouped logically, not necessarily sorted.
- Follow the inline-comment style: describe the purpose or replacement and the
  actual executable names when they differ from the package name.
- Update `WHAT.md` when adding or removing a tool. Update `README.md` when setup,
  behavior, or workflows change; do not duplicate the full inventory there.
- Use the existing lockfile unless a dependency update is requested or required.
  Do not run `nix flake update` merely to add a package.
- Keep the unfree allowlist narrow; it currently permits only `1password-cli`.
- Nix supplies tooling; pnpm and uv manage project dependencies outside the Nix
  store. Rustup supplies shims and manages separately installed Rust toolchains.

## Configuration and shell conventions

- Edit repository sources rather than copies or links under the user's home.
  Existing links mean source edits may immediately affect the live configuration.
- Guard optional Fish integrations with command/file availability checks. Keep
  prompt and interactive bindings inside `if status is-interactive`; environment
  setup needed by noninteractive commands belongs outside that block.
- Keep PATH changes idempotent. Use the existing `fish_add_path --global --path`
  pattern instead of persisting shared settings in universal variables.
- Do not generate completions at shell startup. When applicable, extend
  `just fish-completions` using its existing generator or vendor-file helpers.
  Regenerate only when needed and review the output for unrelated changes.
- Preserve host `grep` and `rm`; the current wrappers use eza for `ls`/`tree`,
  zoxide for `cd`, and a separate `del` command for recoverable deletion.
- Do not introduce user-specific absolute paths, credentials, or signing keys.
  Fonts, themes, authentication, and account login-shell selection are host setup.
- Alacritty intentionally has no shell override. For startup failures, first
  inspect the account shell and inherited `SHELL`; see `README.md` before changing
  shell configuration to work around a stale GUI launcher environment.
- Keep machine-local/generated state ignored: `fish_variables`, `.direnv/`, Nix
  `result` links, `.DS_Store`, and `*.backup-*`.

## Workflows and safety

- Read the relevant recipes and their `scripts/` implementations before running
  them. `just --list` lists workflows. Preserve the `just --set` path overrides.
- `just status` and `just doctor` are read-only, advisory checks. Doctor warnings
  do not fail the recipe and cannot rule out stale GUI launcher environments.
- `just link` links config files and skill directories, backing up real entries;
  it can replace links that point elsewhere. `just unlink` removes only exact
  owned links. `just restore` restores the most recent backups.
- Do not run link/unlink/restore, profile upgrades or rollbacks, login-shell
  changes, authentication, or toolchain installation without user authorization.
- The normal requested update sequence is `nix flake update`,
  `nix profile upgrade cli-tools`, `just fish-completions`, then `just link`.
  Review changed lockfile and completion files before committing.
- Never commit, stage files, or discard existing work unless explicitly asked.

## Validation

Use focused checks appropriate to the files changed, checking tool availability
first. There is no application test suite; do not install tools just for checks.

- Nix formatting: `nixfmt --check flake.nix`.
- Package evaluation: `nix build --dry-run --no-write-lock-file .#cli-tools`.
  This is a host-system dry run, not a full build or verification of all platforms.
- Nix linting when relevant: `statix check .` and `deadnix --fail .`.
- Fish changes: `fish --no-execute <changed-file>` for syntax and
  `fish_indent --check <changed-file>` for formatting. Avoid sourcing live config
  merely to validate syntax.
- Bash scripts: `bash -n scripts/<changed-script>.sh` for syntax; use ShellCheck
  when available. Scripts are invoked with `bash`, so executable bits are optional.
- Justfile changes: `just --list` for parsing; test filesystem-mutating recipes
  only with isolated paths via the existing `just --set` overrides.
- Whitespace: `git diff --check`.
- Credential scanning when relevant: `just scan` (uses gitleaks with redaction).

Report which checks actually ran and any failures or unavailable tools. A dry run
is not an installation, and successful host evaluation is not cross-platform
validation.
