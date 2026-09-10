{
  description = "CLI tools shared across my machines";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              # 1password-cli is unfree.
              config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "1password-cli" ];
            }
          )
        );
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          # Grouped so a category can be dropped, or moved to a host-specific
          # profile, without untangling one long list. Categories are in
          # alphabetical order so there is an obvious place to add the next one.
          #
          # Comments read: what it replaces (what you actually type). The
          # command is often not the package name.

          containers = with pkgs; [
            lazydocker # docker ps, logs and exec in a TUI (lazydocker)
            dive # image layer explorer, shows what each layer costs (dive)
          ];

          devWorkflow = with pkgs; [
            just # make (just)
            uv # pip, venv, pyenv, poetry (uv, uvx)
            rustup # rust toolchains (rustup, plus cargo and rustc shims)
            watchexec # entr (watchexec)
            hyperfine # time, for benchmarking (hyperfine)
            tokei # cloc (tokei)
          ];

          filesAndArchives = with pkgs; [
            eza # ls, tree (eza, also installs exa for compat)
            yazi # file manager (yazi, ya manages plugins)
            ouch # tar, unzip, gzip (ouch)
            xcp # cp, with progress (xcp)
            trash-cli # rm, recoverable (trash-put, trash-list, trash-restore)
          ];

          gitTools = with pkgs; [
            git # was inherited from the host (git, ships git-credential-osxkeychain)
            delta # git pager (no command, set it as core.pager in gitconfig)
            gitui # git TUI (gitui)
            lazygit # git TUI, the other one (lazygit)
            git-cliff # changelog from conventional commits (git cliff)
            gh # GitHub CLI (gh)
            jujutsu # git-compatible VCS (jj)
            gitleaks # secret scanning (gitleaks)
          ];

          media = with pkgs; [
            # The headless build, deliberately: it is the exact derivation yazi
            # already pulls in for previews, so this only links the binaries
            # rather than adding a second ffmpeg. It still has videotoolbox,
            # x264, x265 and aac; the only real loss is ffplay.
            ffmpeg-headless # video and audio transcoding (ffmpeg, ffprobe)
          ];

          network = with pkgs; [
            xh # curl, httpie (xh, xhs defaults to https)
            gping # ping (gping)
            doggo # dig (doggo)
            bandwhich # iftop, per-process network usage (bandwhich)
          ];

          nixTooling = with pkgs; [
            nixfmt # formatter (nixfmt)
            nil # Nix LSP (nil, spoken to by the editor, not by hand)
            statix # linter (statix check)
            deadnix # dead code (deadnix)
            nix-tree # closure explorer (nix-tree)
            nvd # diff generations before switching (nvd diff)
          ];

          secrets = with pkgs; [
            age # file encryption (age, age-keygen)
            sops # encrypted config kept in-repo (sops)
            _1password-cli # vault access from the shell (op)
          ];

          shellSession = with pkgs; [
            fish # the shell itself, was coming from Homebrew (fish, fish_indent)
            bash # macOS is stuck on 3.2 for GPLv3 reasons (bash, needs a #!/usr/bin/env bash shebang)
            skim # fzf (sk, sk-tmux)
            zoxide # cd (your config.fish inits it with --cmd=cd, so it *is* cd)
            atuin # shell history (atuin, plus ctrl-r once hooked)
            starship # shell prompt (no command, it renders the prompt)
            zellij # tmux (zellij)
            tealdeer # tldr (tldr, run tldr --update once to fill the cache)
            direnv # per-project environments (direnv allow, then automatic)
            nix-direnv # no command, source its direnvrc from ~/.config/direnv/direnvrc
          ];

          systemAndProcess = with pkgs; [
            procs # ps (procs)
            bottom # top (btm)
            dust # du (dust)
            duf # df (duf)
            viddy # watch (viddy)
          ];

          textAndData = with pkgs; [
            ripgrep # grep (rg)
            fd # find (fd)
            sd # sed (sd)
            sad # sed across many files, interactive (sad)
            bat # cat (bat)
            choose # cut, awk fields (choose)
            jaq # jq (jaq)
            jless # less, for JSON (jless)
            glow # markdown renderer (glow)
            difftastic # diff, syntax aware (difft)
            hexyl # xxd (hexyl)
          ];

          cliTools = pkgs.buildEnv {
            name = "cli-tools";
            extraOutputsToInstall = [
              "man"
              "doc"
            ];
            paths =
              containers
              ++ devWorkflow
              ++ filesAndArchives
              ++ gitTools
              ++ media
              ++ network
              ++ nixTooling
              ++ secrets
              ++ shellSession
              ++ systemAndProcess
              ++ textAndData;
          };
        in
        {
          cli-tools = cliTools;
          default = cliTools;
        }
      );
    };
}
