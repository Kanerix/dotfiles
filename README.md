# dotfiles

A Nix flake holding the CLI tools I want on every machine. The tools are wrapped
in a single `buildEnv`, so they install, upgrade and roll back as one profile
entry instead of 28 separate ones.

## Install on a new machine

Nix must be installed with `nix-command` and `flakes` enabled.

    git clone <this repo> ~/Projects/dotfiles
    nix profile install ~/Projects/dotfiles#cli-tools

The tools do not replace the originals. `grep` and `ls` still work, the new ones
sit alongside them under their own names.

## Update

    nix flake update
    nix profile upgrade cli-tools

Commit the changed `flake.lock` afterwards. The lock file is what keeps the
machines on identical versions, so pull it on the others before upgrading them.

## Roll back

    nix profile rollback

## Shell integration

Four of these need a line in the shell rc file before they do anything. The
package alone is not enough.

    eval "$(zoxide init zsh)"
    eval "$(starship init zsh)"
    source <(sk --shell zsh)

`delta` needs configuring in `~/.gitconfig` rather than the shell:

    [core]
        pager = delta
    [interactive]
        diffFilter = delta --color-only

`tealdeer` needs its cache populated once with `tldr --update`.

## Adding a tool

Add it to the `paths` list in `flake.nix`, then run the install command again.
`nix build --dry-run .#cli-tools` checks the name resolves without downloading
anything.
