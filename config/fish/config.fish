# Symlinked from https://github.com/kanerix/dotfiles/config/fish/config.fish.
# fish shell configuration.
#
# Every integration below is guarded, so this file is safe to drop on any
# machine. A tool that is not installed has its feature skipped silently,
# rather than erroring on every prompt.

# Run a command and source its output, but only when the command exists and
# actually produced something. If a tool changes its completion flag in some
# future release this yields no completions, rather than piping an error message
# into `source` and breaking the shell.
function __source_if --description 'Source a command output, when available'
    if not command -q $argv[1]
        return
    end
    set -l generated ($argv 2>/dev/null)
    if test (count $generated) -gt 0
        printf '%s\n' $generated | source
    end
end

if test -f ~/.config/fish/alias.fish
    source ~/.config/fish/alias.fish
end

# The nix installer writes its shell hook into the sysconfdir of whichever fish
# existed at install time, which here was homebrew's, at
# /opt/homebrew/etc/fish/conf.d/nix.fish. This fish comes from the nix profile,
# so its sysconfdir is inside the store and that hook is never read. Source the
# profile directly instead. It is what puts `nix` itself on PATH, since nix
# lives in /nix/var/nix/profiles/default/bin rather than ~/.nix-profile/bin, and
# it also sets NIX_SSL_CERT_FILE and NIX_PROFILES. It guards internally against
# running twice, so re-sourcing this file is safe.
if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

# fish_add_path is idempotent and silently skips directories that do not exist,
# so re-sourcing this file never stacks duplicate entries, and a machine without
# a given tool gets no stray entry. --global keeps these out of fish_variables,
# which is machine-local state rather than configuration.
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path --global --path $BUN_INSTALL/bin
fish_add_path --global --path ~/.local/bin
fish_add_path --global --path ~/.nix-profile/bin

# First editor found wins.
for __candidate in nvim vim hx
    if command -q $__candidate
        set -gx EDITOR $__candidate
        set -gx VISUAL $__candidate
        break
    end
end
set --erase __candidate

# bat as the man pager. col is needed to strip overstrike sequences.
if command -q bat; and command -q col
    set -gx MANPAGER "sh -c 'col -bx | bat --language man --plain'"
    set -gx MANROFFOPT -c
end

# fnm exports PATH entries, so it has to run outside the interactive block or
# non-interactive fish will not find node.
if command -q fnm
    fnm env --use-on-cd --shell fish | source
end

# Keep the real ls and tree when eza is missing.
if command -q eza
    function ls --wraps eza --description 'ls, via eza'
        eza $argv
    end

    function tree --wraps eza --description 'tree, via eza'
        eza --tree $argv
    end
end

# yazi, leaving the shell in whatever directory you browsed to.
# `builtin cd` because zoxide replaces cd below.
if command -q yazi
    function y --description 'yazi, then cd to where it left off'
        set -l tmp (mktemp -t yazi-cwd.XXXXXX)
        yazi $argv --cwd-file=$tmp
        set -l cwd (command cat -- $tmp)
        if test -n "$cwd"; and test "$cwd" != "$PWD"
            builtin cd -- $cwd
        end
        command rm -f -- $tmp
    end
end

# Safer rm, when trash-cli is around. Named separately rather than shadowing rm,
# so muscle memory and scripts keep the real thing.
if command -q trash-put
    function del --wraps trash-put --description 'rm, but recoverable'
        trash-put $argv
    end
end

if status is-interactive
    # Prompt.
    __source_if starship init fish

    # zoxide takes over cd entirely.
    __source_if zoxide init --cmd=cd fish

    # Per-project environments.
    __source_if direnv hook fish

    # Fuzzy finder key bindings. Use whichever one is installed.
    if command -q sk
        __source_if sk --shell fish
    else
        __source_if fzf --fish
    end

    # atuin is deliberately last. Fuzzy finders bind ctrl-r as well, and the
    # binding installed last is the one that wins.
    __source_if atuin init fish

    # Completions are deliberately not generated here. Doing so costs one
    # subprocess per tool on every shell start, which dominates startup time.
    # They are pre-generated into completions/ instead, which fish autoloads
    # lazily on the first tab-complete. Regenerate them after upgrading tools;
    # see the repository README.
end
