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
        dst="$destination_dir/$rel"
        # List directory backups themselves, not their contents.
        newest="$(ls -1dt "$dst".backup-* 2>/dev/null | head -1 || true)"
        if [ -n "$newest" ]; then
            [ -L "$dst" ] && rm "$dst"
            mv "$newest" "$dst"
            printf '  restored  %s\n' "$rel"
        fi
    done
done
