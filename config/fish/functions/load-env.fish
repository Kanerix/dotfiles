function load-env --description 'Export variables from a dotenv file (default: .env)'
    if test (count $argv) -gt 1
        printf 'Usage: load-env [file]\n' >&2
        return 1
    end

    set -l file .env
    if test (count $argv) -eq 1
        set file $argv[1]
    end
    if not test -f "$file"; or not test -r "$file"
        printf 'load-env: cannot read file: %s\n' "$file" >&2
        return 1
    end

    set -l keys
    set -l values
    set -l line_number 0
    while read -l line
        set line_number (math $line_number + 1)
        set line (string trim -- "$line")
        if test -z "$line"; or string match -q '#*' -- "$line"
            continue
        end
        set line (string replace -r '^export[ \t]+' '' -- "$line")
        if not string match -rq '^[A-Za-z_][A-Za-z0-9_]*[ \t]*=' -- "$line"
            printf 'load-env: invalid assignment at %s:%s\n' "$file" "$line_number" >&2
            return 1
        end

        set -l key (string replace -r '[ \t]*=.*$' '' -- "$line")
        set -l value (string replace -r '^[^=]*=[ \t]*' '' -- "$line")
        if string match -rq '^[\x22\x27]' -- "$value"
            if not string match -rq '^(\x22[^\x22]*\x22|\x27[^\x27]*\x27)([ \t]+#.*)?$' -- "$value"
                printf 'load-env: unsupported quoted value at %s:%s\n' "$file" "$line_number" >&2
                return 1
            end
            set value (string replace -r '^[\x22\x27](.*)[\x22\x27]([ \t]+#.*)?$' '$1' -- "$value")
        else
            set value (string replace -r '[ \t]+#.*$' '' -- "$value")
            set value (string trim -- "$value")
        end
        set -a keys "$key"
        set -a values "$value"
    end <"$file"

    # Validate the entire file before changing the environment.
    if test (count $keys) -eq 0
        return 0
    end
    for index in (seq (count $keys))
        if not set --global --export $keys[$index] "$values[$index]"
            printf 'load-env: cannot export %s\n' "$keys[$index]" >&2
            return 1
        end
    end
    return 0
end
