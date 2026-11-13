# Repository guidance

## Purpose and scope

This repository maintains shared dotfiles and CLI tools for the owner's computers.
It uses a macOS Homebrew Brewfile and symlinked configuration.
Keep changes small and consistent with the existing patterns; support both
Apple Silicon and Intel macOS without hardcoding a Homebrew prefix.

## Repository map

- `Brewfile`: Homebrew formulas and casks grouped by category, plus preserved
  Go and Cargo entries. Versions track available current releases, not a lockfile.
- `config/`: files linked into `~/.config/`, preserving relative paths. Includes
  Fish, Git, direnv, Alacritty, Vim, and Starship configuration.
- `config/fish/completions/`: checked-in completion files, loaded lazily by Fish.
- `skills/`: agent skill directories linked into `~/.agents/skills/`.
- `justfile`: concise command interface for repository workflows and secret scanning.
- `scripts/`: Bash implementations for linking, diagnostics, and completion generation;
  invoked by `just` with explicit path arguments.
- `README.md`: setup, migration, update, and integration documentation.
- `WHAT.md`: alphabetically ordered tool inventory.

## Homebrew packages

- Add tools to the appropriate existing category in `Brewfile`. Categories are
  alphabetical; package entries are grouped logically, not necessarily sorted.
- Follow the inline-comment style: describe the purpose or replacement and the
  actual executable names when they differ from the package name.
- Preserve existing dumped extra formulas, casks, Go and Cargo entries. Do not
  replace the manifest with only the former shared CLI bundle.
- Use Homebrew names: `awscli`, `git-delta`, `helm`, `node`, `python`, `rustup`,
  `ffmpeg`, and `dua-cli`; `1password-cli` is a cask. Bun uses the `oven-sh/bun`
  tap. Verify formula/cask names when changing entries.
- Update `WHAT.md` and `skills/use-cli-tools/references/tools.md` when adding or
  removing a tool. Update `README.md` when setup, behavior, or workflows change;
  do not duplicate the full inventory there.
- Homebrew tracks unpinned current releases; there is no Nix-style bundle rollback.
  Respect project lockfiles separately and do not update host packages merely to
  edit or validate the Brewfile.
- Homebrew supplies tooling; pnpm and uv manage project dependencies separately.
  Use `~/.local` for npm global installs (`npm config set prefix ~/.local` and
  `mkdir -p ~/.local/lib/node_modules`); Fish already adds `~/.local/bin` to PATH.
- Rustup is keg-only: use the `bin` directory under `brew --prefix rustup` for
  shims. Rust toolchains are installed separately; Cargo entries need one. The
  private Go package may require authentication; do not authenticate unasked.

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
- Keep machine-local/generated state ignored: `fish_variables`, `.direnv/`,
  `.DS_Store`, and `*.backup-*`.

## Workflows and safety

- Read the relevant recipes and their `scripts/` implementations before running
  them. `just --list` lists workflows. Preserve the `just --set` path overrides.
- `just status` and `just doctor` are read-only, advisory checks. Doctor warnings
  do not fail the recipe and cannot rule out stale GUI launcher environments.
- `just link` links config files and skill directories, backing up real entries;
  it can replace links that point elsewhere. `just unlink` removes only exact
  owned links. `just restore` restores the most recent backups.
- Do not run package installs/updates/uninstalls, link/unlink/restore, login-shell
  changes, authentication, or toolchain installation without user authorization.
- Setup is `brew bundle --file Brewfile`, `just fish-completions`, then `just link`.
  The normal requested update sequence adds `brew update` first. Review changed
  Brewfile and completion files before committing.
- Migration must install the Homebrew bundle first, then change the login shell
  to Homebrew Fish and refresh the desktop session before removing Nix. Use the
  original installer's uninstall instructions, not generic destructive scripts.
  Repository migration does not uninstall anything on the host.
- Never commit, stage files, or discard existing work unless explicitly asked.

## Validation

Use focused checks appropriate to the files changed, checking tool availability
first. There is no application test suite; do not install tools just for checks.

- Brewfile dependency check: `brew bundle check --file Brewfile` when Homebrew is
  available. Missing dependencies are not a reason to install tools unasked;
  this checks installed dependencies, not buildability or version reproducibility.
- Fish changes: `fish --no-execute <changed-file>` for syntax and
  `fish_indent --check <changed-file>` for formatting. Avoid sourcing live config
  merely to validate syntax.
- Bash scripts: `bash -n scripts/<changed-script>.sh` for syntax; use ShellCheck
  when available. Scripts are invoked with `bash`, so executable bits are optional.
- Justfile changes: `just --list` for parsing; test filesystem-mutating recipes
  only with isolated paths via the existing `just --set` overrides.
- Whitespace: `git diff --check`.
- Credential scanning when relevant: `just scan` (uses gitleaks with redaction).

Report which checks actually ran and any failures or unavailable tools.
Dependency checks are not installations or validation of another machine.
