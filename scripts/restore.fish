#!/usr/bin/env fish

if test (count $argv) -ne 4
    printf 'Usage: restore.fish CONFIG_DIR TARGET_DIR SKILLS_DIR SKILLS_TARGET_DIR\n' >&2
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
        set -l dst "$destination_dir/$rel"
        set -l backups "$dst".backup-*
        if test (count $backups) -eq 0
            continue
        end
        # List directory backups themselves, not their contents, newest mtime first.
        set -l ordered (command ls -1dt -- $backups)
        or exit $status
        set -l newest "$ordered[1]"
        if test -L "$dst"
            command rm "$dst"
            or exit $status
        end
        command mv "$newest" "$dst"
        or exit $status
        printf '  restored  %s\n' "$rel"
        or exit $status
    end
end
