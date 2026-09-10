# Dotfiles. `just --list` to see everything.
#
# Config files are symlinked from config/ into ~/.config rather than
# generated, so they stay ordinary editable files. Individual files are
# linked, not whole directories, so that machine-local state fish writes
# itself (fish_variables) can sit alongside tracked config.

config_dir := justfile_directory() / "config"
target_dir := env('HOME') / ".config"

# Show available recipes
default:
    @just --list

# Symlink config/ into ~/.config, backing up any real file already there
link:
    #!/usr/bin/env bash
    set -euo pipefail
    stamp="$(date +%Y%m%d-%H%M%S)"
    cd "{{ config_dir }}"
    find . -type f | sed 's|^\./||' | sort | while read -r rel; do
        src="{{ config_dir }}/$rel"
        dst="{{ target_dir }}/$rel"
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

# Report what is linked, what is not, and what is missing
status:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{ config_dir }}"
    find . -type f | sed 's|^\./||' | sort | while read -r rel; do
        src="{{ config_dir }}/$rel"
        dst="{{ target_dir }}/$rel"
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
            printf '  linked    %s\n' "$rel"
        elif [ -e "$dst" ]; then
            printf '  UNLINKED  %s (real file in place, run just link)\n' "$rel"
        else
            printf '  missing   %s\n' "$rel"
        fi
    done

# Remove only the symlinks that point into this repo. Backups are left alone.
unlink:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{ config_dir }}"
    find . -type f | sed 's|^\./||' | sort | while read -r rel; do
        src="{{ config_dir }}/$rel"
        dst="{{ target_dir }}/$rel"
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
            rm "$dst"
            printf '  removed   %s\n' "$rel"
        fi
    done

# Restore the most recent backup of every file, undoing a link
restore:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{ config_dir }}"
    find . -type f | sed 's|^\./||' | sort | while read -r rel; do
        dst="{{ target_dir }}/$rel"
        newest="$(ls -1t "$dst".backup-* 2>/dev/null | head -1 || true)"
        if [ -n "$newest" ]; then
            [ -L "$dst" ] && rm "$dst"
            mv "$newest" "$dst"
            printf '  restored  %s\n' "$rel"
        fi
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
