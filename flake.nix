{
  description = "CLI tools shared across my machines";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
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

          cloud = with pkgs; [
            awscli2 # official AWS CLI v2 (aws)
            azure-cli # official Azure CLI (az)
          ];

          containers = with pkgs; [
            kubectl # Kubernetes cluster management (kubectl)
            kubernetes-helm # Kubernetes chart package manager (helm)
            lazydocker # docker ps, logs and exec in a TUI (lazydocker)
            dive # image layer explorer, shows what each layer costs (dive)
          ];

          devWorkflow = with pkgs; [
            just # make (just)
            devenv # per-project dev shells and services (devenv, pairs with direnv)
            uv # pip, venv, pyenv, poetry (uv, uvx)
            ruff # Python linter and formatter (ruff)
            watchexec # entr (watchexec)
            hyperfine # time, for benchmarking (hyperfine)
            tokei # cloc (tokei)
          ];

          filesAndArchives = with pkgs; [
            eza # ls, tree (eza, also installs exa for compat)
            ouch # tar, unzip, gzip (ouch)
            xcp # cp, with progress (xcp)
            trash-cli # rm, recoverable (trash-put, trash-list, trash-restore)
          ];

          gitTools = with pkgs; [
            git # was inherited from the host (git, ships git-credential-osxkeychain)
            delta # git pager (no command, set it as core.pager in gitconfig)

            git-cliff # changelog from conventional commits (git cliff)
            gh # GitHub CLI (gh)
            jujutsu # git-compatible VCS (jj)
            gitleaks # secret scanning (gitleaks)
          ];

          languages = with pkgs; [
            bun # JavaScript/TypeScript runtime, package manager and bundler (bun, bunx)
            nodejs # Node.js runtime and npm, for tools that require Node (node, npm, npx)
            pnpm # JavaScript package manager with a shared dependency store (pnpm, pnpx)
            go # Go compiler and tooling (go, gofmt)
            python3 # Python interpreter; uv handles project environments (python, python3)
            rustup # Rust toolchains (rustup, cargo and rustc shims; install a toolchain separately)
            zig # Zig compiler and C/C++ cross-compilation (zig)
          ];

          math = with pkgs; [
            numbat # bc, units (numbat, bare numbat opens a REPL)
          ];

          media = with pkgs; [
            # Headless build for transcoding; ffplay is not included.
            ffmpeg-headless # video and audio transcoding (ffmpeg, ffprobe)
            yt-dlp # download video and audio from supported sites (yt-dlp)
            exiftool # read and edit file metadata (exiftool)
          ];

          network = with pkgs; [
            cloudflared # Cloudflare Tunnel client (cloudflared)
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
            gnupg # OpenPGP encryption and signing (gpg, gpg-agent)
            sops # encrypted config kept in-repo (sops)
            _1password-cli # vault access from the shell (op)
          ];

          shellSession = with pkgs; [
            fish # the shell itself (fish, fish_indent)
            bash # macOS is stuck on 3.2 for GPLv3 reasons (bash, needs a #!/usr/bin/env bash shebang)
            vim # terminal text editor with shared XDG configuration (vim)
            skim # fzf (sk, sk-tmux)
            zoxide # cd (your config.fish inits it with --cmd=cd, so it *is* cd)
            starship # shell prompt (no command, it renders the prompt)
            zellij # tmux (zellij)
            tealdeer # tldr (tldr, run tldr --update once to fill the cache)
            direnv # per-project environments (direnv allow, then automatic)
            nix-direnv # no command, sourced by config/direnv/direnvrc
          ];

          systemAndProcess = with pkgs; [
            procs # ps (procs)
            bottom # top (btm)
            dua # disk usage summaries and interactive exploration (dua, dua interactive)
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
            xan # xsv, csvkit, csvlens (xan, xan view to browse a file)
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
              cloud
              ++ containers
              ++ devWorkflow
              ++ filesAndArchives
              ++ gitTools
              ++ languages
              ++ math
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
