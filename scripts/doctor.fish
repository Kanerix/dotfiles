#!/usr/bin/env fish

printf '\nShell (this process only; existing GUI launchers may differ)\n'
set -l login_shell ''
switch (command uname -s)
    case Darwin
        set login_shell (command dscacheutil -q user -a uid (command id -u) 2>/dev/null | string replace --filter --regex '^shell: (.*)$' '$1')
    case Linux
        if command -q getent
            set login_shell (command getent passwd (command id -u) 2>/dev/null | command cut -d: -f7)
        end
end
if test -z "$login_shell"
    printf '  WARN      Could not read the account login shell\n'
else if not test -f "$login_shell"; or not test -x "$login_shell"
    printf '  WARN      Account shell is not an executable file: %s\n' "$login_shell"
else
    printf '  ok        Account shell: %s\n' "$login_shell"
end

# Check the exported environment rather than a shell-local variable.
set -l inherited_shell (command printenv SHELL)
if test $status -eq 0
    if not test -f "$inherited_shell"; or not test -x "$inherited_shell"
        printf '  WARN      Inherited SHELL is not an executable file: %s\n' "$inherited_shell"
    else
        printf '  ok        Inherited SHELL: %s\n' "$inherited_shell"
    end
    if test -n "$login_shell"; and test "$inherited_shell" != "$login_shell"
        printf '  WARN      SHELL differs from the account shell; this may be intentional or a stale session\n'
    end
else
    printf '  info      SHELL is unset; Alacritty can use the account login shell\n'
end
printf '  info      After a shell change, log out and back in; restarting a launcher alone may retain stale state\n'

printf '\nRust (optional)\n'
set -l rustup_path (command -s rustup)
if test -f "$rustup_path"; and test -x "$rustup_path"
    set -l rustup_home "$HOME/.rustup"
    if set -q RUSTUP_HOME; and test -n "$RUSTUP_HOME"
        set rustup_home "$RUSTUP_HOME"
    end
    set -l found_toolchain false
    for toolchain in "$rustup_home"/toolchains/*
        if test -d "$toolchain"
            set found_toolchain true
            break
        end
    end
    if test "$found_toolchain" = true
        printf '  ok        Installed toolchain directories found in %s/toolchains\n' "$rustup_home"
    else
        printf '  optional  No Rust toolchains found in %s/toolchains; install one when needed\n' "$rustup_home"
    end
else
    printf '  optional  rustup is not available on PATH\n'
end
