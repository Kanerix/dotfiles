# dotfiles

macOS dotfiles and Homebrew packages.

## Install

Install [Homebrew](https://brew.sh/) and follow its instructions to add `brew`
to PATH. Clone this repository and open its directory.

Install Fish and initialise Rust before installing the bundle's Cargo packages:

```sh
brew install fish rustup
fish
```

Run the remaining commands in Fish:

```fish
fish_add_path (brew --prefix rustup)/bin
rustup default stable
rustup component add rustfmt clippy rust-analyzer
brew bundle --file Brewfile
just fish-completions
just link
```

`just link` links configuration into `~/.config/` and agent skills into
`~/.agents/skills/`, backing up existing files. Review the shared Zed agent
permissions before linking. Ensure `~/.config/zed/` is not a symlink to a
cloud-synced directory.

If you use a custom `XDG_CONFIG_HOME`, link to that directory instead:

```fish
just --set target_dir "$XDG_CONFIG_HOME" link
```

## Login shell

Find the Homebrew Fish executable:

```fish
printf '%s/bin/fish\n' (brew --prefix)
```

Add the printed path to `/etc/shells` if absent, then run `chsh -s` with that
path. Log out of the desktop session and back in.

## Git and 1Password

Install the [1Password desktop app](https://1password.com/downloads/mac/).
The Brewfile installs only its CLI.

1. Enable **Settings > Developer > Use the SSH agent** and follow the app's
   instructions to configure local `~/.ssh/config`.
2. Generate or import an SSH key in 1Password.
3. Add its public key to GitHub as both an **Authentication Key** and a
   **Signing Key**.
4. Set your Git identity and signing key locally:

```fish
git config --global user.name "Your Name"
git config --global user.email "your-verified-github-email"
git config --global user.signingkey "your-public-ssh-key"
git config --global gpg.ssh.program /Applications/1Password.app/Contents/MacOS/op-ssh-sign
```

Use the actual 1Password app path if installed elsewhere. The shared Git config
requires SSH authentication for GitHub and enables SSH commit signing.

For local signature verification, add a line to `~/.ssh/allowed_signers` for
each commit email, using this format:

```text
your-verified-github-email namespaces="git" ssh-ed25519 YOUR_PUBLIC_KEY
```

Then configure Git:

```fish
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```

Keep private keys and credentials outside the repository.

## Formatters

`just link` installs Ruff's user-level config and the shared Biome config.
Zed's JSON and JSONC formatters invoke Biome with the shared config directly;
no shell environment variable or Biome language server is required.
Start a new Fish session to activate `BIOME_CONFIG_PATH` for CLI commands.

Ruff uses project configurations before the user-level config. Zed's JSON
formatter always uses the shared config. For project-specific Biome formatting,
configure that project's formatter separately.

## Optional setup

- npm global packages: run `npm config set prefix ~/.local` and
  `mkdir -p ~/.local/lib/node_modules`.
- GitHub CLI: run `gh auth login`.
- tealdeer: run `tldr --update`.
- Zed: install the extensions and configure access to the AI provider used in
  `config/zed/settings.json`.
- Nix-backed projects: follow the [devenv setup guide](https://devenv.sh/getting-started/).
  Review each project's `.envrc` before running `direnv allow`.
