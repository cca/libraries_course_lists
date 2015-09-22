#!/usr/bin/env fish
# usage:
#   ./upload-taxos-to-vault.fish informer.csv
# where "informer.csv" is the full semester Informer report

# load log function
source log.fish

set --local filename $argv[1]
set --local dir data
set --local logfile logs/(date "+%Y-%m-%d").txt
set --local pw (jq -r '.password' ~/.equellarc)
set --local un (jq -r '.username' ~/.equellarc)

# parse all department codes listed in the report
# trim header row with tail -n +2 (might need gnu tail not OS X?)
set --local depts (csvcut -c 2 $filename | tail -n +2 | sort | uniq | \
    # also remove Architecture Division programs which are handled separately
    sed -e '/ARCHT/d' -e '/INTER/d' -e '/MARCH/d' -e 'CRITI')

for dept in $depts
    # full course list
    set uuid (eq tax --name "$dept - COURSE LIST" | jq -r '.uuid')
    if [ $uuid ]
        log "UPDATING TAXONOMY ID $uuid" $logfile
        uptaxo --tid $uuid --pw $pw --un $un \
            --csv $dir/$dept-course-list-taxo.csv >> $logfile
    end

    # course titles
    set uuid (eq tax --name "$dept - course titles" | jq -r '.uuid')
    if [ $uuid ]
        log "UPDATING TAXONOMY ID $uuid" $logfile
        uptaxo --tid $uuid --pw $pw --un $un \
            --csv $dir/$dept-course-titles.csv >> $logfile
    end

    # faculty names
    set uuid (eq tax --name "$dept - faculty" | jq -r '.uuid')
    if [ $uuid ]
        log "UPDATING TAXONOMY ID $uuid" $logfile
        uptaxo --tid $uuid --pw $pw --un $un \
            --csv $dir/$dept-faculty-names.csv >> $logfile
    end

    # course names e.g. INDIV-101
    set uuid (eq tax --name "$dept - course names" | jq -r '.uuid')
    if [ $uuid ]
        log "UPDATING TAXONOMY ID $uuid" $logfile
        uptaxo --tid $uuid --pw $pw --un $un \
            --csv $dir/$dept-courses.csv >> $logfile
    end

    # course sections
    set uuid (eq tax --name "$dept - course sections" | jq -r '.uuid')
    if [ $uuid ]
        log "UPDATING TAXONOMY ID $uuid" $logfile
        uptaxo --tid $uuid --pw $pw --un $un \
            --csv $dir/$dept-section-names.csv >> $logfile
    end
end
