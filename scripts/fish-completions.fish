#!/usr/bin/env fish

if test (count $argv) -ne 1
    printf 'Usage: fish-completions.fish CONFIG_DIR\n' >&2
    exit 1
end

set -g out "$argv[1]/fish/completions"
command mkdir -p "$out"
or exit $status

function gen --argument-names name
    if not command -q "$name"
        printf '  skip    %s (not installed here)\n' "$name"
        return 0
    end
    if command $argv[2..] >"$out/$name.fish.tmp" 2>/dev/null; and test -s "$out/$name.fish.tmp"
        command mv "$out/$name.fish.tmp" "$out/$name.fish"
        or return $status
        printf '  wrote   %s.fish\n' "$name"
    else
        command rm -f "$out/$name.fish.tmp"
        or return $status
        printf '  FAILED  %s (flag may have changed upstream)\n' "$name"
    end
end

# Some packages ship a completion file rather than a generator.
function vendor --argument-names name
    if not command -q brew
        printf '  skip    %s (Homebrew is not available)\n' "$name"
        return 0
    end
    set -l prefix (command brew --prefix)
    or return $status
    set -l src "$prefix/share/fish/vendor_completions.d/$name.fish"
    if not test -f "$src"
        printf '  skip    %s (not installed here)\n' "$name"
        return 0
    end
    command cp "$src" "$out/$name.fish"
    or return $status
    printf '  copied  %s.fish\n' "$name"
end

gen bat bat --completion fish; or exit $status
gen delta delta --generate-completion=fish; or exit $status
gen rg rg --generate=complete-fish; or exit $status
gen gh gh completion -s fish; or exit $status
gen just just --completions fish; or exit $status
gen jj jj util completion fish; or exit $status
gen uv uv generate-shell-completion fish; or exit $status
gen ruff ruff generate-shell-completion fish; or exit $status
gen helm helm completion fish; or exit $status
gen kubectl kubectl completion fish; or exit $status
gen op op completion fish; or exit $status
gen xh xh --generate complete-fish; or exit $status
gen watchexec watchexec --completions fish; or exit $status
gen glow glow completion fish; or exit $status
gen doggo doggo completions fish; or exit $status
gen procs procs --gen-completion-out fish; or exit $status
gen zellij zellij setup --generate-completion fish; or exit $status
vendor bun; or exit $status
