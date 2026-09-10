function kill-port --description 'Kill process on a given port'
    if test (count $argv) -eq 0
        echo "Usage: kill-port <port>"
        return 1
    end
    set -l pids (lsof -ti :$argv[1] 2>/dev/null)
    if test -n "$pids"
        for pid in $pids
            kill -9 $pid
            echo "Killed PID $pid on port $argv[1]"
        end
    else
        echo "No process found on port $argv[1]"
    end
end
