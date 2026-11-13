# dotfiles

Shared dotfiles and a macOS Homebrew `Brewfile` for the tools I want on each
machine. The Brewfile includes formulas, casks, and Go/Cargo tools; Homebrew
tracks current releases rather than a pinned bundle. See [WHAT.md](WHAT.md) for
the complete tool list.

## Install on a new machine

Install Homebrew using its official macOS instructions and follow its shell
setup instructions so `brew` is on PATH. From the repository directory, run:

    brew bundle --file Brewfile
    just fish-completions
    just link

The Cargo entries require a separately installed Rust toolchain; see
[Language toolchains](#language-toolchains) before the first bundle install if
Rust is not initialized. The existing Go entries are preserved; the private Go
package may require repository authentication before installation can succeed.
The bundle can install GUI apps and fonts as well as CLI tools.

## Nix-backed project environments

Homebrew supplies shared CLI tools; projects can still use Nix and devenv for
reproducible development environments. Neither currently has an official
Homebrew formula or cask, so the Brewfile records them as comments rather than
invalid install entries. Keep an existing Nix installation when projects use
`use devenv`, `use nix`, or `use flake` in `.envrc`.

For a new machine, follow the Nix installer instructions in the
[devenv setup guide](https://devenv.sh/getting-started/), then install devenv:

    nix profile install nixpkgs#devenv

The profile command requires Nix's `nix-command` and `flakes` experimental
features. Do not run a second installer over an existing Nix installation.
Devenv supplies project packages from `devenv.nix`; they do not all need to be
installed globally through Homebrew. Review `.envrc` before approving it with
`direnv allow`. Keep Homebrew Fish as the login shell even when retaining Nix.

## Migrate an existing Nix installation

Only uninstall Nix after migrating any projects that still depend on it.

1. Install Homebrew and run `brew bundle --file Brewfile` **before removing Nix**.
   Initialize Rust and any required private Go authentication first. Verify that
   the Homebrew tools work, then run `just fish-completions` and `just link`.
2. Change the account login shell to Homebrew's Fish before uninstalling Nix.
   Use the path under `brew --prefix` (normally `/opt/homebrew/bin/fish` on Apple
   Silicon or `/usr/local/bin/fish` on Intel), register it in `/etc/shells` if
   required, and select it with `chsh`. Do not keep a Nix profile/store shell path.
3. Log out of the desktop session and back in. Check both the account shell and
   inherited `SHELL`, including GUI launchers; see the Alacritty cautions below.
4. Only after the replacement is working, follow the uninstall instructions from
   the **original Nix installer** used on this host. Installer-specific cleanup
   differs; this repository supplies no destructive uninstall script.

`just link` does not remove old owned links whose repository sources have been
removed. During migration, inspect these entries and their symlink targets:

- `~/.config/nix/nix.conf`
- `~/.config/direnv/direnvrc`
- `~/.config/fish/completions/devenv.fish`

Remove an entry only after verifying that it is an obsolete symlink pointing to
its removed source in this repository. Leave real user files and links to other
sources untouched; do not delete the containing directories. This is manual,
host-local cleanup, not something the linking workflow performs automatically.

Changing these repository files does not uninstall Nix, remove host packages,
or perform that symlink cleanup.

The tools install alongside the host commands. The linked Fish configuration
wraps `ls` and `tree` with eza and `cd` with zoxide; `grep` and `rm` stay unchanged.

## Repository workflows

`just --list` lists the available commands. The `justfile` is a concise interface;
Fish implementations live in `scripts/`. Keep using `just link`, `just status`,
`just doctor`, `just unlink`, `just restore`, and `just fish-completions` as before.
The `config_dir`, `target_dir`, `skills_dir`, and `skills_target_dir` overrides
remain available via `just --set` for isolated tests or alternate destinations.
Scripts are invoked with `fish --no-config` and do not require executable
permissions. Install Fish through the Brewfile first and ensure it is on PATH;
script execution does not load your personal Fish configuration.

## Update

    brew update
    brew bundle --file Brewfile
    just fish-completions
    just link

Regenerate Fish completions after upgrading tools, then run `just link` to link
any newly generated files. Fish autoloads these completions lazily rather than
generating them at every shell startup.

Review changes to the Brewfile and regenerated completions before committing.
Homebrew installs/upgrades to available current versions: there is no shared
version lock and no Nix-style atomic bundle rollback. Reverting the Brewfile does
not restore previously installed package versions. `just restore` restores
configuration backups, not package versions.

## zerobrew

The Brewfile includes [zerobrew](https://github.com/zerobrewhq/zerobrew) from its
`zerobrewhq/tap` Homebrew tap, providing `zb` and `zbx`. It is experimental;
keep using ordinary `brew` for this repository's setup and update workflows.
Installing it does not migrate packages or replace `brew`.

If you choose to initialize it, `zb init` can modify your shell configuration;
`zb init --no-modify-path` leaves shell configuration unchanged. Review any
initialization changes rather than letting it edit symlinked shared config.

## Login shell and Alacritty startup

The Brewfile installs Fish on macOS (Apple Silicon and Intel). `just link` only
symlinks configuration; neither step changes the account's login shell. To use
Fish as the login shell, find Homebrew's executable under `brew --prefix` and
verify it works. `command -v fish` may still find an older installation during
migration. Register the Homebrew path in `/etc/shells` if required by the host,
and select it with the host's login-shell setup (`chsh`). This is machine-local
setup, not a path to put in the shared config.

Alacritty intentionally has no `terminal.shell` override. In 0.15.1 it uses the
inherited `SHELL`, falling back to the account's login shell only when `SHELL`
is unset—not when it points to a missing executable. After moving Fish between
installations (for example, Nix to Homebrew), an old launcher environment can
therefore make Alacritty flash open and close even though the account shell is
already correct.

If the account shell already points to a working Fish, leave the configuration
and login-shell setting alone. **Log out of the desktop session and log back
in**, then launch Alacritty from a fresh Raycast (or other launcher). Fully
quitting and reopening the launcher is enough only if its parent session
already has the corrected environment; restarting it in a stale session may
preserve the problem. Closing a terminal window or re-sourcing `config.fish`
does not refresh an existing launcher's environment. If the problem persists
after a fresh login, check the launcher's inherited `SHELL` and any host-local
environment overrides before changing the shared config.

Do not replace this with `program = "fish"` unless the launcher's `PATH` can
find Fish. Alacritty 0.15.1 passes an explicit shell program directly to process
creation: `~` and `$HOME` are **not expanded** there, unlike `~/` in config
imports. Fish's startup PATH setup runs only after Fish has been located and
started. See the versioned [shell selection and process creation source](https://github.com/alacritty/alacritty/blob/v0.15.1/alacritty_terminal/src/tty/unix.rs).

## Fish integration

After `just link`, new Fish sessions load `config/fish/config.fish` automatically.
Integrations are guarded so missing tools are skipped:

- Interactive sessions initialize Starship, zoxide (`cd`), direnv and skim key
  bindings.
- Project environments use plain direnv and still need explicit approval with
  `direnv allow`; review each project's environment configuration first.
- `ls` and `tree` use eza; `del` uses recoverable trash without replacing `rm`.
- Homebrew and existing user binary directories, including `~/.local/bin`, are
  added to PATH. Homebrew's keg-only rustup uses the `bin` directory under
  `brew --prefix rustup`. The first available editor is selected from `nvim`,
  `vim` and `hx`; bat becomes the man-page pager when `col` is also available.
- If separately installed, fnm initializes Node environments and fzf supplies
  fuzzy-finder bindings when skim is absent.

Completions live in `config/fish/completions/`; refresh them with
`just fish-completions` after tool upgrades, followed by `just link` for new
files. Populate tealdeer's local help cache with `tldr --update`.

## Vim integration

The Brewfile includes Vim. `just link` links `config/vim/vimrc` to
`~/.config/vim/vimrc`, which current Vim versions load automatically. An existing
`~/.vimrc`, `~/.vim/vimrc`, or `VIMINIT` takes precedence; review those locally if
this configuration is not loaded. A custom `XDG_CONFIG_HOME` must match the
link destination (override `target_dir` when invoking the linking recipes).
Older host Vim versions may not support this path; use the Homebrew-provided Vim.
Check the loaded configuration with `:echo $MYVIMRC`.

The configuration uses built-in features only: syntax highlighting, filetype
indentation, line numbers, case-smart incremental search, four-space indentation
by default, and splits opening below/right. Filetype plugins can override the
indentation defaults. Swap files remain enabled for crash recovery.

- `Space w`: save the current file.
- `Space Space`: clear search highlighting.
- `Ctrl h/j/k/l`: move between splits.
- `Space y` / `Space p`: copy to / paste from the system clipboard when supported
  by the Vim build and host. Normal yanks and deletes keep Vim's default registers.

To preview without installing or linking, run:

    vim -u config/vim/vimrc

## Git integration

`just link` links `config/git/config` to `~/.config/git/config`. Git reads it
automatically; no shell initialization is needed. It sets `core.pager=delta`,
`interactive.diffFilter=delta --color-only` and `delta.navigate=true` for
highlighted diffs and navigation. Settings in `~/.gitconfig` override these
shared defaults.

Keep credentials and machine-specific signing paths out of the shared config.
Store authentication and host-specific overrides locally.

## AI agent skills

`just link` also symlinks each directory under `skills/` into
`~/.agents/skills/`. The `use-cli-tools` skill helps agents choose the CLI tools
in this Brewfile for focused searches, compact data output, and repeatable workflows.
Its source is [skills/use-cli-tools/SKILL.md](skills/use-cli-tools/SKILL.md).

`~/.agents/skills/` is a shared global skill location supported by Zed and other
compatible agents; it is not universally supported by every agent. Agents that
only read a vendor-specific skills directory need a separate link or configuration.
Zed discovers the skill in a new conversation.

`just status`, `just unlink`, and `just restore` cover both configuration files
and skill directories. Existing skill directories are backed up before linking;
`unlink` removes only links pointing to this repository. For testing or alternate
install locations, override `skills_dir` and `skills_target_dir` with `just --set`.

## Language toolchains

The Brewfile includes Bun (via the `oven-sh/bun` tap), Node.js (with npm/npx),
pnpm, Go, Python, Rust via rustup, and Zig. Bun handles JavaScript/TypeScript
execution and bundling; Node remains available for tools that specifically
require it. Use pnpm for projects that use `pnpm-lock.yaml` and `uv` for isolated
Python project environments. Homebrew supplies unpinned current tooling; pnpm
and uv manage project dependencies separately.

Keep npm global installs in a writable user prefix rather than Homebrew's tree:

    npm config set prefix ~/.local
    mkdir -p ~/.local/lib/node_modules

Fish already adds `~/.local/bin` to PATH. Preserve project package managers and
lockfiles rather than switching them to match the host tools.

Homebrew's `rustup` is keg-only. Add its shims to PATH using the `bin` directory
under `brew --prefix rustup` (the linked Fish configuration handles this), not a
hardcoded Homebrew prefix. Rustup supplies `cargo` and `rustc` shims, not an
installed compiler toolchain. For a default Rust setup, run once on each machine
before installing the Brewfile's Cargo entries:

    rustup default stable
    rustup component add rustfmt clippy rust-analyzer

Rust toolchain downloads are managed separately by rustup, outside Homebrew.
Follow each project's `rust-toolchain.toml` when present. The existing Cargo
entries in the Brewfile are kept; they need a working compiler toolchain.
Use project-specific version/environment managers when different language
versions or native build dependencies are required.

## Optional per-machine setup

- GitHub: authenticate with `gh auth login` on each machine that needs account
  access.
- 1Password: configure local CLI authentication through the desktop app
  integration or `op signin`, as appropriate for the machine.
- Rust: initialize a default toolchain as described above, or follow the
  project's `rust-toolchain.toml` requirements.

## Diagnostics

`just doctor` is a read-only, advisory check. It reuses `just status` to report
configuration links, checks the account login shell against the calling
process's inherited `SHELL`, and reports mismatches or missing shell
executables. It also notes missing Rust toolchain directories as optional setup
without running rustup. Warnings are informational and do not make the recipe
exit with an error.

It makes no automatic fixes, performs no authentication and makes no network
requests. It only sees the calling process's environment, not an existing GUI
launcher's environment; a clean result does not rule out the stale Alacritty
launcher environment described above.

## Adding a tool

Add it to the appropriate category in `Brewfile` and to [WHAT.md](WHAT.md), then
install and refresh completions and links as above. Keep categories alphabetical,
packages logically grouped, and inline comments describing purpose and executable
names when they differ. Preserve existing dumped formulas, casks, Go and Cargo
entries rather than replacing them with only the shared CLI list.

Homebrew names can differ from Nix names: `awscli` supplies `aws`, `git-delta`
supplies `delta`, `helm` supplies `helm`, `node` supplies Node.js, `python` supplies
Python, and `dua-cli` supplies `dua`. Use `ffmpeg` rather than the former headless
package, `1password-cli` as a cask, and Bun from the `oven-sh/bun` tap.
`brew bundle check --file Brewfile` checks whether declared dependencies are
installed; it is not an installation or a guarantee that every entry can build.
