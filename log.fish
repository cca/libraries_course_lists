function log -d 'write message to given log file'
    set msg $argv[1]
    set logfile $argv[2]
    set timestamp (date "+%Y-%m-%d %H:%M")
    echo -e $timestamp '\t' $msg >> $logfile
end
