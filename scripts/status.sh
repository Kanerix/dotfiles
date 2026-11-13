#!/usr/bin/env bash
set -euo pipefail

config_dir=$1
target_dir=$2
skills_dir=$3
skills_target_dir=$4

for scope in config skills; do
    case "$scope" in
        config) source_dir="$config_dir"; destination_dir="$target_dir" ;;
        skills) source_dir="$skills_dir"; destination_dir="$skills_target_dir" ;;
    esac
    printf '\n%s -> %s\n' "$scope" "$destination_dir"
    cd "$source_dir"
    {
        if [ "$scope" = config ]; then
            find . -type f ! -name '.DS_Store'
        else
            find . -mindepth 1 -maxdepth 1 -type d ! -name '.DS_Store'
        fi
    } | sed 's|^\./||' | sort | while read -r rel; do
        src="$source_dir/$rel"
        dst="$destination_dir/$rel"
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
            printf '  linked    %s\n' "$rel"
        elif [ -L "$dst" ]; then
            printf '  UNLINKED  %s (symlink points elsewhere, run just link)\n' "$rel"
        elif [ -e "$dst" ]; then
            printf '  UNLINKED  %s (real file in place, run just link)\n' "$rel"
        else
            printf '  missing   %s\n' "$rel"
        fi
    done
done
