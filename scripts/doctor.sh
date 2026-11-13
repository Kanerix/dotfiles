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
