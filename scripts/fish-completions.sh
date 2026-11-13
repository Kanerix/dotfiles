#!/usr/bin/env bash
set -euo pipefail

config_dir=$1

out="$config_dir/fish/completions"
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
# Some packages ship a completion file rather than a generator.
vendor() {
    name="$1"
    if ! command -v brew >/dev/null 2>&1; then
        printf '  skip    %s (Homebrew is not available)\n' "$name"
        return
    fi
    prefix="$(brew --prefix)"
    src="$prefix/share/fish/vendor_completions.d/$name.fish"
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
gen ruff ruff generate-shell-completion fish
gen helm helm completion fish
gen kubectl kubectl completion fish
gen op op completion fish
gen xh xh --generate complete-fish
gen watchexec watchexec --completions fish
gen glow glow completion fish
gen doggo doggo completions fish
gen procs procs --gen-completion-out fish
gen zellij zellij setup --generate-completion fish
vendor bun
