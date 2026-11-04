# Dotfiles. `just --list` to see everything.

config_dir := justfile_directory() / "config"
target_dir := env('HOME') / ".config"
skills_dir := justfile_directory() / "skills"
skills_target_dir := env('HOME') / ".agents/skills"

# Show available recipes
default:
    @just --list

# Symlink config files and skill directories globally, backing up real entries
link:
    #!/usr/bin/env bash
    set -euo pipefail
    stamp="$(date +%Y%m%d-%H%M%S)"
    for scope in config skills; do
        case "$scope" in
            config) source_dir="{{ config_dir }}"; destination_dir="{{ target_dir }}" ;;
            skills) source_dir="{{ skills_dir }}"; destination_dir="{{ skills_target_dir }}" ;;
        esac
        printf '\n%s -> %s\n' "$scope" "$destination_dir"
        cd "$source_dir"
        {
            if [ "$scope" = config ]; then
                find . -type f ! -name '.DS_Store'
            else
                find . -mindepth 1 -maxdepth 1 -type d ! -name '.DS_Store'
            fi
        } | sed 's|^\./||' | sort | while read -r rel; do
            src="$source_dir/$rel"
            dst="$destination_dir/$rel"
            mkdir -p "$(dirname "$dst")"
            if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
                printf '  ok        %s\n' "$rel"
                continue
            fi
            if [ -L "$dst" ]; then
                printf '  relink    %s\n' "$rel"
                rm "$dst"
            elif [ -e "$dst" ]; then
                printf '  backup    %s -> %s.backup-%s\n' "$rel" "$rel" "$stamp"
                mv "$dst" "$dst.backup-$stamp"
            else
                printf '  new       %s\n' "$rel"
            fi
            ln -s "$src" "$dst"
        done
    done

# Report what is linked, what is not, and what is missing
status:
    #!/usr/bin/env bash
    set -euo pipefail
    for scope in config skills; do
        case "$scope" in
            config) source_dir="{{ config_dir }}"; destination_dir="{{ target_dir }}" ;;
            skills) source_dir="{{ skills_dir }}"; destination_dir="{{ skills_target_dir }}" ;;
        esac
        printf '\n%s -> %s\n' "$scope" "$destination_dir"
        cd "$source_dir"
        {
            if [ "$scope" = config ]; then
                find . -type f ! -name '.DS_Store'
            else
                find . -mindepth 1 -maxdepth 1 -type d ! -name '.DS_Store'
            fi
        } | sed 's|^\./||' | sort | while read -r rel; do
            src="$source_dir/$rel"
            dst="$destination_dir/$rel"
            if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
                printf '  linked    %s\n' "$rel"
            elif [ -L "$dst" ]; then
                printf '  UNLINKED  %s (symlink points elsewhere, run just link)\n' "$rel"
            elif [ -e "$dst" ]; then
                printf '  UNLINKED  %s (real file in place, run just link)\n' "$rel"
            else
                printf '  missing   %s\n' "$rel"
            fi
        done
    done

# Check links, shell environment and optional Rust setup without changing anything
doctor: status
    #!/usr/bin/env bash
    set -euo pipefail
    printf '\nShell (this process only; existing GUI launchers may differ)\n'
    login_shell=""
    case "$(uname -s)" in
        Darwin)
            login_shell="$(dscacheutil -q user -a uid "$(id -u)" 2>/dev/null | sed -n 's/^shell: //p')" || login_shell=""
            ;;
        Linux)
            if command -v getent >/dev/null 2>&1; then
                login_shell="$(getent passwd "$(id -u)" 2>/dev/null | cut -d: -f7)" || login_shell=""
            fi
            ;;
    esac
    if [ -z "$login_shell" ]; then
        printf '  WARN      Could not read the account login shell\n'
    elif [ ! -f "$login_shell" ] || [ ! -x "$login_shell" ]; then
        printf '  WARN      Account shell is not an executable file: %s\n' "$login_shell"
    else
        printf '  ok        Account shell: %s\n' "$login_shell"
    fi
    # Bash initializes its own SHELL when unset; printenv checks only the exported value.
    if inherited_shell="$(printenv SHELL)"; then
        if [ ! -f "$inherited_shell" ] || [ ! -x "$inherited_shell" ]; then
            printf '  WARN      Inherited SHELL is not an executable file: %s\n' "$inherited_shell"
        else
            printf '  ok        Inherited SHELL: %s\n' "$inherited_shell"
        fi
        if [ -n "$login_shell" ] && [ "$inherited_shell" != "$login_shell" ]; then
            printf '  WARN      SHELL differs from the account shell; this may be intentional or a stale session\n'
        fi
    else
        printf '  info      SHELL is unset; Alacritty can use the account login shell\n'
    fi
    printf '  info      After a shell change, log out and back in; restarting a launcher alone may retain stale state\n'
    printf '\nRust (optional)\n'
    if rustup_path="$(command -v rustup)" && [ -f "$rustup_path" ] && [ -x "$rustup_path" ]; then
        rustup_home="${RUSTUP_HOME:-$HOME/.rustup}"
        found_toolchain=false
        for toolchain in "$rustup_home"/toolchains/*; do
            if [ -d "$toolchain" ]; then
                found_toolchain=true
                break
            fi
        done
        if [ "$found_toolchain" = true ]; then
            printf '  ok        Installed toolchain directories found in %s/toolchains\n' "$rustup_home"
        else
            printf '  optional  No Rust toolchains found in %s/toolchains; install one when needed\n' "$rustup_home"
        fi
    else
        printf '  optional  rustup is not available on PATH\n'
    fi

# Remove only exact owned symlinks in both roots. Backups are left alone.
unlink:
    #!/usr/bin/env bash
    set -euo pipefail
    for scope in config skills; do
        case "$scope" in
            config) source_dir="{{ config_dir }}"; destination_dir="{{ target_dir }}" ;;
            skills) source_dir="{{ skills_dir }}"; destination_dir="{{ skills_target_dir }}" ;;
        esac
        printf '\n%s -> %s\n' "$scope" "$destination_dir"
        cd "$source_dir"
        {
            if [ "$scope" = config ]; then
                # Include legacy config .DS_Store links so they can still be removed.
                find . -type f
            else
                find . -mindepth 1 -maxdepth 1 -type d ! -name '.DS_Store'
            fi
        } | sed 's|^\./||' | sort | while read -r rel; do
            src="$source_dir/$rel"
            dst="$destination_dir/$rel"
            if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
                rm "$dst"
                printf '  removed   %s\n' "$rel"
            fi
        done
    done

# Restore the most recent backup of config files and skill directories
restore:
    #!/usr/bin/env bash
    set -euo pipefail
    for scope in config skills; do
        case "$scope" in
            config) source_dir="{{ config_dir }}"; destination_dir="{{ target_dir }}" ;;
            skills) source_dir="{{ skills_dir }}"; destination_dir="{{ skills_target_dir }}" ;;
        esac
        printf '\n%s -> %s\n' "$scope" "$destination_dir"
        cd "$source_dir"
        {
            if [ "$scope" = config ]; then
                find . -type f ! -name '.DS_Store'
            else
                find . -mindepth 1 -maxdepth 1 -type d ! -name '.DS_Store'
            fi
        } | sed 's|^\./||' | sort | while read -r rel; do
            dst="$destination_dir/$rel"
            # List directory backups themselves, not their contents.
            newest="$(ls -1dt "$dst".backup-* 2>/dev/null | head -1 || true)"
            if [ -n "$newest" ]; then
                [ -L "$dst" ] && rm "$dst"
                mv "$newest" "$dst"
                printf '  restored  %s\n' "$rel"
            fi
        done
    done

# Check the repo for committed credentials
scan:
    gitleaks dir . --no-banner --redact

# Regenerate fish completions into config/fish/completions/.
#
# Run this after `nix flake update`, not on every shell start. Generating
# them at startup cost 665ms per shell; fish autoloads files from
# completions/ lazily, on the first tab-complete, which costs nothing.
fish-completions:
    #!/usr/bin/env bash
    set -euo pipefail
    out="{{ config_dir }}/fish/completions"
    mkdir -p "$out"
    gen() {
        name="$1"
        shift
        if ! command -v "$name" >/dev/null 2>&1; then
            printf '  skip    %s (not installed here)\n' "$name"
            return
        fi
        if "$@" >"$out/$name.fish.tmp" 2>/dev/null && [ -s "$out/$name.fish.tmp" ]; then
            mv "$out/$name.fish.tmp" "$out/$name.fish"
            printf '  wrote   %s.fish\n' "$name"
        else
            rm -f "$out/$name.fish.tmp"
            printf '  FAILED  %s (flag may have changed upstream)\n' "$name"
        fi
    }
    # Some packages ship a completion file rather than a generator. fish only
    # scans the vendor dir inside its own store path, never the profile's, so
    # the file has to be copied in to be seen.
    vendor() {
        name="$1"
        src="$HOME/.nix-profile/share/fish/vendor_completions.d/$name.fish"
        if [ ! -f "$src" ]; then
            printf '  skip    %s (not installed here)\n' "$name"
            return
        fi
        cp "$src" "$out/$name.fish"
        printf '  copied  %s.fish\n' "$name"
    }
    gen bat bat --completion fish
    gen delta delta --generate-completion=fish
    gen rg rg --generate=complete-fish
    gen gh gh completion -s fish
    gen just just --completions fish
    gen jj jj util completion fish
    gen uv uv generate-shell-completion fish
    gen op op completion fish
    gen xh xh --generate complete-fish
    gen watchexec watchexec --completions fish
    gen glow glow completion fish
    gen doggo doggo completions fish
    gen procs procs --gen-completion-out fish
    gen zellij zellij setup --generate-completion fish
    vendor devenv
