# dotfiles

A Nix flake holding the CLI tools I want on every machine. The tools are wrapped
in a single `buildEnv`, so they install, upgrade and roll back as one profile
entry. See [WHAT.md](WHAT.md) for the complete tool list.

## Install on a new machine

`config/nix/nix.conf` enables `nix-command` and `flakes`, but `just link` is
what puts it in place and `just` itself comes from this flake. So the first
install has to pass the features on the command line, once:

    git clone <this repo> ~/Projects/dotfiles
    nix --extra-experimental-features 'nix-command flakes' profile install ~/Projects/dotfiles#cli-tools
    just link

After `just link` the flag is no longer needed, here or in any other repo.

The tools install alongside the host commands. The linked Fish configuration
wraps `ls` and `tree` with eza and `cd` with zoxide; `grep` and `rm` stay unchanged.

## Update

    nix flake update
    nix profile upgrade cli-tools
    just fish-completions
    just link

Regenerate Fish completions after upgrading tools, then run `just link` to link
any newly generated files. Fish autoloads these completions lazily rather than
generating them at every shell startup.

Commit the changed `flake.lock` and regenerated completions afterwards. The lock
file is what keeps machines on identical versions, so pull it on the others
before upgrading and linking there.

## Roll back

    nix profile rollback

## Login shell and Alacritty startup

The flake installs Fish on macOS and Linux (Apple Silicon/ARM64 and x86_64).
`just link` only symlinks configuration; neither step changes the account's
login shell. To use Fish as the login shell, find the installed executable with
`command -v fish`, register its path in `/etc/shells` if required by the host,
and select it with the host's login-shell setup (`chsh`). For Nix installs, use
the stable profile path rather than resolving it to a versioned `/nix/store`
path. This is machine-local setup, not a path to put in the shared config.

Alacritty intentionally has no `terminal.shell` override. In 0.15.1 it uses the
inherited `SHELL`, falling back to the account's login shell only when `SHELL`
is unset—not when it points to a missing executable. After moving Fish between
installations (for example, Homebrew to Nix), an old launcher environment can
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
- The direnv configuration sources nix-direnv from the Nix profile and loads
  devenv's integration on demand. Project environments still need explicit
  approval with `direnv allow`.
- `ls` and `tree` use eza; `del` uses recoverable trash without replacing `rm`.
- The Nix daemon environment and existing user binary directories are added to
  the environment. The first available editor is selected from `nvim`, `vim`
  and `hx`; bat becomes the man-page pager when `col` is also available.
- If separately installed, fnm initializes Node environments and fzf supplies
  fuzzy-finder bindings when skim is absent.

Completions live in `config/fish/completions/`; refresh them with
`just fish-completions` after tool upgrades, followed by `just link` for new
files. Populate tealdeer's local help cache with `tldr --update`.

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
in this flake for focused searches, compact data output, and repeatable workflows.
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

The flake includes Bun, Node.js (with npm/npx), Go, Python, Rust via rustup,
and Zig. Bun handles JavaScript/TypeScript execution and bundling; Node remains
available for tools that specifically require it. Use `uv` for isolated Python
project environments rather than installing packages into Nix's read-only
Python interpreter.

Rustup supplies `cargo` and `rustc` shims, not an installed compiler toolchain.
For a default Rust setup, run once on each machine:

    rustup default stable
    rustup component add rustfmt clippy rust-analyzer

Rust toolchain downloads are managed by rustup, outside the flake lock. Other
included language versions follow `flake.lock`. Use project-specific devenv or
Nix development shells when a project needs a different version or native build
dependencies.

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

Add it to the appropriate package group in `flake.nix` and to [WHAT.md](WHAT.md),
then upgrade the profile and refresh completions and links as above.
`nix build --dry-run .#cli-tools` checks evaluation and reports what would be
built or fetched.
