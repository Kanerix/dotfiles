# Categories are alphabetical; entries within them are grouped by purpose.
# Homebrew tracks current releases. Preserve project dependency lockfiles separately.

# Cloud
brew 'awscli' # official AWS CLI v2 (aws)
cask 'azure-cli' # official Azure CLI (az)
brew 'aztfexport' # bring existing Azure resources into Terraform (aztfexport)
brew 'hcloud' # official Hetzner Cloud CLI (hcloud)
brew 'hashicorp/tap/terraform', trusted: true # infrastructure as code (terraform)

# Containers
brew 'kubernetes-cli' # Kubernetes cluster management (kubectl)
brew 'helm' # Kubernetes chart package manager (helm)
brew 'kind' # local Kubernetes clusters in Docker (kind)
brew 'lazydocker' # Docker management TUI (lazydocker)
brew 'dive' # container image layer explorer (dive)
brew 'metalbear-co/mirrord/mirrord', trusted: true # connect local processes to cloud environments (mirrord)

# Desktop apps
cask 'dbeaver-community' # database browser and SQL client (DBeaver)
cask 'zed' # code editor (Zed)

# Development workflow
# Nix (nix) and devenv are installed separately, not available as Homebrew packages.
# Required by projects using `use devenv`; see README.md for setup.
brew 'just' # concise task runner, replaces make (just)
brew 'zerobrewhq/tap/zerobrew', trusted: true # experimental alternative Homebrew package client (zb, zbx)
brew 'uv' # Python packages and environments (uv, uvx)
brew 'ruff' # Python linter and formatter (ruff)
brew 'biome' # Web-language formatter and linter (biome)
brew 'watchexec' # rerun commands on file changes (watchexec)
brew 'hyperfine' # benchmark commands (hyperfine)
brew 'tokei' # code statistics, replaces cloc (tokei)
brew 'libpq' # PostgreSQL client library and tools, keg-only (psql)
brew 'mkcert' # locally trusted development certificates (mkcert)
brew 'nss' # certificate support for Firefox and other NSS clients

# Files and archives
brew 'eza' # ls and tree (eza)
brew 'ouch' # archive compression and extraction (ouch)
brew 'xcp' # copying with progress (xcp)
brew 'trash-cli' # recoverable deletion (trash-put, trash-list, trash-restore)
brew 'ddrescue' # data recovery from failing storage (ddrescue)
brew 'testdisk' # partition and deleted-file recovery, includes PhotoRec (testdisk, photorec)

# Fonts
cask 'font-recursive-mono-nerd-font' # RecMonoCasual Nerd Font Mono and other Recursive variants

# Git tools
brew 'git' # version control (git)
brew 'git-delta' # highlighted Git pager (delta)
brew 'git-cliff' # changelogs from conventional commits (git cliff)
brew 'gh' # GitHub CLI (gh)
brew 'jujutsu' # Git-compatible version control (jj)
brew 'gitleaks' # credential scanning (gitleaks)

# Languages
brew 'oven-sh/bun/bun', trusted: true # JavaScript/TypeScript runtime, packages and bundling (bun, bunx)
brew 'node' # Node.js runtime and npm (node, npm, npx)
brew 'pnpm' # JavaScript package manager (pnpm, pnpx)
brew 'go' # Go compiler and tooling (go, gofmt)
brew 'python' # Python interpreter; uv manages project environments (python3)
brew 'ruby' # Ruby interpreter and gem tooling, keg-only (ruby, gem, bundle)
brew 'rustup' # Rust toolchain manager, keg-only (rustup, cargo, rustc shims)
brew 'zig' # Zig compiler and C/C++ cross-compilation (zig)

# Math
brew 'numbat' # unit-aware calculator, replaces bc and units (numbat)

# Media
brew 'ffmpeg' # video and audio processing (ffmpeg, ffprobe, ffplay)
brew 'yt-dlp' # download video and audio (yt-dlp)
brew 'exiftool' # read and edit file metadata (exiftool)
brew 'oxvg' # SVG optimisation and tooling (oxvg)

# Network
brew 'cloudflared' # Cloudflare Tunnel client (cloudflared)
brew 'xh' # HTTP client, replaces curl/httpie (xh, xhs)
brew 'gping' # graphical ping (gping)
brew 'doggo' # DNS queries (doggo)
brew 'bandwhich' # per-process network usage (bandwhich)
brew 'feroxbuster' # recursive web content discovery (feroxbuster)
brew 'sherlock' # find public social accounts by username (sherlock)

# Secrets
brew 'age' # file encryption (age, age-keygen)
brew 'gnupg' # OpenPGP encryption and signing (gpg, gpg-agent)
brew 'pinentry-mac' # native macOS passphrase dialog for GPG (pinentry-mac)
brew 'sops' # encrypted configuration (sops)
cask '1password-cli' # vault access from the shell (op)

# Shell session
brew 'fish' # interactive shell (fish, fish_indent)
brew 'bash' # current Bash rather than macOS Bash 3.2 (bash)
brew 'vim' # terminal editor with shared XDG configuration (vim)
brew 'sk' # skim fuzzy finder (sk)
brew 'zoxide' # directory navigation (zoxide, configured as cd)
brew 'starship' # shell prompt (starship)
brew 'tealdeer' # concise command examples (tldr)
brew 'direnv' # approved per-project environments (direnv)

# System and process
brew 'procs' # process listing, replaces ps (procs)
brew 'bottom' # system monitor, replaces top (btm)
brew 'dua-cli' # disk usage summaries and exploration (dua)
brew 'duf' # filesystem usage, replaces df (duf)
brew 'viddy' # repeated command output, replaces watch (viddy)

# Taps
# Preserve existing taps, including those used by dumped packages.
tap 'hashicorp/tap'
tap 'metalbear-co/mirrord'
tap 'oven-sh/bun'
tap 'shopify/shopify', trusted: true
tap 'zerobrewhq/tap'

# Text and data
brew 'ripgrep' # content search, preserves host grep (rg)
brew 'ast-grep' # syntax-aware code search, linting and rewriting (ast-grep, sg)
brew 'fd' # file search, replaces find (fd)
brew 'sd' # text replacement (sd)
brew 'sad' # interactive bulk replacement (sad)
brew 'bat' # syntax-highlighted file viewer (bat)
brew 'choose-rust' # field selection, replaces cut (choose)
brew 'jaq' # JSON filtering, replaces jq (jaq)
brew 'jless' # interactive JSON browser (jless)
brew 'xan' # CSV processing and browsing (xan)
brew 'glow' # Markdown rendering (glow)
brew 'difftastic' # syntax-aware diffs (difft)
brew 'hexyl' # binary viewer (hexyl)

# Toolchain packages (preserved from the installed-state dump)
cargo 'cargo-machete'
cargo 'cargo-watch'
cargo 'sqlx-cli'
