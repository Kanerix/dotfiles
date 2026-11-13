#!/usr/bin/env fish

if test (count $argv) -ne 1
    printf 'Usage: fish-completions.fish TARGET_DIR\n' >&2
    exit 1
end

set -g out "$argv[1]/fish/completions"
if test -L "$out"
    printf 'Refusing to write completions into a symlinked directory: %s\n' "$out" >&2
    exit 1
end
command mkdir -p "$out"
or exit $status

set -g completion_dirs "$__fish_data_dir/completions"
if command -q brew
    set -l prefix (command brew --prefix)
    or exit $status
    set --prepend completion_dirs "$prefix/share/fish/vendor_completions.d"
end

function gen --argument-names name
    if not command -q "$name"
        printf '  skip    %s (not installed here)\n' "$name"
        return 0
    end
    for directory in $completion_dirs
        if test -f "$directory/$name.fish"
            printf '  skip    %s (completion supplied by Fish or Homebrew)\n' "$name"
            return 0
        end
    end
    if test -d "$out/$name.fish"
        printf '  FAILED  %s (completion destination is a directory)\n' "$name" >&2
        return 1
    end
    set -l temporary (command mktemp "$out/.$name.XXXXXX")
    or return $status
    if command $argv[2..] >"$temporary" 2>/dev/null; and test -s "$temporary"
        command mv -f "$temporary" "$out/$name.fish"
        or return $status
        printf '  wrote   %s.fish\n' "$name"
    else
        command rm -f "$temporary"
        or return $status
        printf '  FAILED  %s (flag may have changed upstream)\n' "$name" >&2
        return 1
    end
end


gen bat bat --completion fish; or exit $status
gen delta delta --generate-completion=fish; or exit $status
gen docker docker completion fish; or exit $status
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
