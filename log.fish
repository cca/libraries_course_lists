# abstraction for writing messages to a provided log file
function log -d 'write message to given log file'
    set msg $argv[1]
    # default log file is just named with the date
    set -q LOGFILE || set LOGFILE logs/(date "+%Y-%m-%d").txt
    set timestamp (date "+%Y-%m-%d %H:%M")
    echo -e $timestamp '\t' $msg >> $LOGFILE
end
