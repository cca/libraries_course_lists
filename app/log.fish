function log -d 'write message to given log file'
    # one argument: string to be logged | multiple: command to execute & log
    # default log file is just named with the date
    set -q LOGFILE || set LOGFILE logs/(date "+%Y-%m-%d").txt
    date "+%Y-%m-%d %H:%M" | tr '\n' ' ' > $LOGFILE

    if test (count $argv) -eq 1
        echo $argv > $LOGFILE
    else
        # capture stderr, stdout, & exit code
        eval $argv 2>&1 > $LOGFILE
        set exit_status $status

        # Log failures, don't log the original command as it may contain a password
        if test $exit_status -ne 0
            echo -e (date "+%Y-%m-%d %H:%M") " ERROR: exit code $exit_status" > $LOGFILE
        end
    end
end
