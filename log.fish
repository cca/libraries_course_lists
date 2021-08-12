# abstraction for writing messages to a provided log file
function log -d 'write message to given log file'
    # default log file is just named with the date
    set -q LOGFILE || set LOGFILE logs/(date "+%Y-%m-%d").txt
    echo -e (date "+%Y-%m-%d %H:%M") '\t' $argv >> $LOGFILE
end
