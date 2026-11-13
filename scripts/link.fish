#!/usr/bin/env fish

if test (count $argv) -ne 4
    printf 'Usage: link.fish CONFIG_DIR TARGET_DIR SKILLS_DIR SKILLS_TARGET_DIR\n' >&2
    exit 1
end

function list_entries --argument-names scope
    if test "$scope" = config
        command find . -type f ! -name .DS_Store
    else
        command find . -mindepth 1 -maxdepth 1 -type d ! -name .DS_Store
    end | command sort
    set -l codes $pipestatus
    for code in $codes
        if test "$code" -ne 0
            return "$code"
        end
    end
end

set -l stamp (command date +%Y%m%d-%H%M%S)
or exit $status

for scope in config skills
    switch $scope
        case config
            set source_dir "$argv[1]"
            set destination_dir "$argv[2]"
        case skills
            set source_dir "$argv[3]"
            set destination_dir "$argv[4]"
    end
    printf '\n%s -> %s\n' "$scope" "$destination_dir"
    or exit $status
    cd "$source_dir"
    or exit $status
    set -l entries (list_entries "$scope")
    or exit $status
    for entry in $entries
        set -l rel (string replace -r '^\./' '' -- "$entry")
        or exit $status
        set -l src "$source_dir/$rel"
        set -l dst "$destination_dir/$rel"
        set -l parent (command dirname "$dst")
        or exit $status
        set -l checked_parent "$parent"
        while true
            if test -L "$checked_parent"
                printf '  WARN      Refusing to traverse symlink parent %s; replace it with a real directory or choose another destination\n' "$checked_parent" >&2
                exit 1
            end
            set -l next_parent (command dirname "$checked_parent")
            or exit $status
            if test "$next_parent" = "$checked_parent"
                break
            end
            set checked_parent "$next_parent"
        end
        command mkdir -p "$parent"
        or exit $status
        if test -L "$dst"
            set -l target (command readlink "$dst")
            or exit $status
            if test "$target" = "$src"
                printf '  ok        %s\n' "$rel"
                or exit $status
                continue
            end
            printf '  relink    %s\n' "$rel"
            or exit $status
            command rm "$dst"
            or exit $status
        else if test -e "$dst"
            printf '  backup    %s -> %s.backup-%s\n' "$rel" "$rel" "$stamp"
            or exit $status
            command mv "$dst" "$dst.backup-$stamp"
            or exit $status
        else
            printf '  new       %s\n' "$rel"
            or exit $status
        end
        command ln -s "$src" "$dst"
        or exit $status
    end
end
