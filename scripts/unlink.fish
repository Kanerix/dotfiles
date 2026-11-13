#!/usr/bin/env fish

if test (count $argv) -ne 4
    printf 'Usage: unlink.fish CONFIG_DIR TARGET_DIR SKILLS_DIR SKILLS_TARGET_DIR\n' >&2
    exit 1
end

function list_entries --argument-names scope
    if test "$scope" = config
        # Include legacy config .DS_Store links so they can still be removed.
        command find . -type f
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
        if test -L "$dst"
            set -l target (command readlink "$dst")
            or exit $status
            if test "$target" = "$src"
                command rm "$dst"
                or exit $status
                printf '  removed   %s\n' "$rel"
                or exit $status
            end
        end
    end
end
