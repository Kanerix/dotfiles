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

set -l biome_config_dir ~/.config
if set -q XDG_CONFIG_HOME; and test -n "$XDG_CONFIG_HOME"
    set biome_config_dir "$XDG_CONFIG_HOME"
end
if test -f "$biome_config_dir/biome.json"; and not set -q BIOME_CONFIG_PATH
    set -gx BIOME_CONFIG_PATH "$biome_config_dir/biome.json"
end

# Discover Homebrew paths rather than assuming an Apple Silicon or Intel prefix.
if command -q brew
    set -l brew_prefix (command brew --prefix)
    if test -n "$brew_prefix"
        fish_add_path --global --path $brew_prefix/bin $brew_prefix/sbin
    end

    set -l ruby_prefix (command brew --prefix ruby 2>/dev/null)
    if test -n "$ruby_prefix"
        fish_add_path --global --path $ruby_prefix/bin
    end

    # Rustup is keg-only; these shims select separately installed toolchains.
    set -l rustup_prefix (command brew --prefix rustup 2>/dev/null)
    if test -n "$rustup_prefix"
        fish_add_path --global --path $rustup_prefix/bin
    end
end

# fish_add_path is idempotent and silently skips directories that do not exist,
# so re-sourcing this file never stacks duplicate entries, and a machine without
# a given tool gets no stray entry. --global keeps these out of fish_variables,
# which is machine-local state rather than configuration.
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path --global --path $BUN_INSTALL/bin
fish_add_path --global --path ~/.local/bin

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

    # Completions are deliberately not generated here. Doing so costs one
    # subprocess per tool on every shell start, which dominates startup time.
    # They are pre-generated into completions/ instead, which fish autoloads
    # lazily on the first tab-complete. Regenerate them after upgrading tools;
    # see the repository README.
end
