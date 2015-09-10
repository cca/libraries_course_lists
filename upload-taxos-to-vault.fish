#!/usr/bin/env fish
# usage:
#   ./upload-taxos-to-vault.fish informer-report.csv
# where "informer-report.csv" is the full semester Informer report

source log.fish

set --local filename $argv[1]
set --local dir data
set --local logfile logs/(date "+%Y-%m-%d").txt
set --local pw (jq -r '.password' ~/.equellarc)
set --local un (jq -r '.username' ~/.equellarc)

# parse all department codes listed in the report
# trim header row with tail -n +2
set --local depts (csvcut -c 2 $filename | tail -n +2 | sort | uniq)

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
