#!/usr/bin/env fish
# handle Architecture Division's special taxonomies, which include departmental codes
# usage:
#   ./arch-division.fish
#
# run ONLY AFTER extracting all the departmental CSVs, e.g. by running the Informer
# report & running ./make-all-taxo-csvs.fish informer.csv

# load log function
source log.fish

set --local depts 'ARCHT' 'INTER' 'MARCH'
set --local div 'ARCH DIV'
set --local dir data
set --local pw (jq -r '.password' ~/.equellarc)
set --local un (jq -r '.username' ~/.equellarc)
set --local logfile logs/(date "+%Y-%m-%d")-architecture.txt

# combine departmental CSVs into division-level ones
for dept in $depts
    cat $dir/$dept-course-list-taxo.csv >> $dir/$div-course-list-taxo.csv
    cat $dir/$dept-course-titles.csv >> $dir/$div-course-titles.csv
    cat $dir/$dept-courses.csv >> $dir/$div-courses.csv
    cat $dir/$dept-faculty-names.csv >> $dir/$div-faculty-names.csv
    cat $dir/$dept-section-names.csv >> $dir/$div-section-names.csv
end
# create XList ID CSV
grep 'Xlist",".*","faculty' $dir/$div-course-list-taxo.csv --color=never \
    | sed -e 's|".*Xlist",||' -e 's|,"faculty.*||' | sort | uniq | sed '/""/d' \
    > $dir/$div-xlist.csv

# upload new, division-level CSVs to appropriate taxonomies

# main course list
set uuid (eq tax --name "$div - COURSE LIST" | jq -r '.uuid')
if [ $uuid ]
    log "UPDATING TAXONOMY ID $uuid" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-course-list-taxo.csv >> $logfile
end

# course titles
set uuid (eq tax --name "$div - course titles" | jq -r '.uuid')
if [ $uuid ]
    log "UPDATING TAXONOMY ID $uuid" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-course-titles.csv >> $logfile
end

# faculty names
set uuid (eq tax --name "$div - faculty" | jq -r '.uuid')
if [ $uuid ]
    log "UPDATING TAXONOMY ID $uuid" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-faculty-names.csv >> $logfile
end

# course names e.g. ARCHT-101
set uuid (eq tax --name "$div - course names" | jq -r '.uuid')
if [ $uuid ]
    log "UPDATING TAXONOMY ID $uuid" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-courses.csv >> $logfile
end

# course sections
set uuid (eq tax --name "$div - course sections" | jq -r '.uuid')
if [ $uuid ]
    log "UPDATING TAXONOMY ID $uuid" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-section-names.csv >> $logfile
end

# XList IDs
set uuid (eq tax --name "$div - cross-list keys" | jq -r '.uuid')
if [ $uuid ]
    log "UPDATING TAXONOMY ID $uuid" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-xlist.csv >> $logfile
end
