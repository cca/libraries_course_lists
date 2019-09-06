#!/usr/bin/env fish
# handle Architecture Division's special taxonomies, which include departmental codes
# usage:
#   ./arch-division.fish
#
# run ONLY AFTER extracting all the departmental CSVs, e.g. by running the Informer
# report & running ./make-all-taxo-csvs.fish data/_informer.csv

# load log function
source log.fish

set depts 'ARCHT' 'BARCH' 'INTER' 'MARCH'
set div 'ARCH DIV'
set dir data
set pw (jq -r '.password' ~/.equellarc)
set un (jq -r '.username' ~/.equellarc)
set logfile logs/(date "+%Y-%m-%d")-architecture.txt

# combine departmental CSVs into division-level ones
# wipe out any previous division-level taxos, lets the script be run multiple times
log 'deleting any previous taxonomy files' $logfile
rm $dir/$div-course-list-taxo.csv $dir/$div-course-titles.csv $dir/$div-courses.csv  $dir/$div-faculty-names.csv $dir/$div-section-names.csv 2>/dev/null

# concatenate program data to make division-level taxos,
# silencing stderr because one of ARCHT/BARCH will always be missing
for dept in $depts
    cat $dir/$dept-course-list-taxo.csv ^/dev/null>> $dir/$div-course-list-taxo.csv
    cat $dir/$dept-course-titles.csv ^/dev/null>> $dir/$div-course-titles.csv
    cat $dir/$dept-courses.csv ^/dev/null>> $dir/$div-courses.csv
    cat $dir/$dept-faculty-names.csv ^/dev/null>> $dir/$div-faculty-names.csv
    cat $dir/$dept-section-names.csv ^/dev/null>> $dir/$div-section-names.csv
    csvcut -c 7 $dir/$dept.csv ^/dev/null | sort | uniq | sed '/""/d' >> $dir/$div-xlist.csv
end

# upload new, division-level CSVs to appropriate taxonomies

# main course list
set tax "$div - COURSE LIST"
set uuid (eq tax --name $tax | jq -r '.uuid')
if [ $uuid ]
    log "Updating $tax taxonomy" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-course-list-taxo.csv >> $logfile
end

# course titles
set tax "$div - course titles"
set uuid (eq tax --name $tax | jq -r '.uuid')
if [ $uuid ]
    log "Updating $tax taxonomy" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-course-titles.csv >> $logfile
end

# faculty names
set tax "$div - faculty"
set uuid (eq tax --name $tax | jq -r '.uuid')
if [ $uuid ]
    log "Updating $tax taxonomy" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-faculty-names.csv >> $logfile
end

# course names e.g. ARCHT-101
set tax "$div - course names"
set uuid (eq tax --name $tax | jq -r '.uuid')
if [ $uuid ]
    log "Updating $tax taxonomy" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-courses.csv >> $logfile
end

# course sections
set tax "$div - course sections"
set uuid (eq tax --name $tax | jq -r '.uuid')
if [ $uuid ]
    log "Updating $tax taxonomy" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-section-names.csv >> $logfile
end

# XList IDs
set tax "$div - cross-list keys"
set uuid (eq tax --name $tax | jq -r '.uuid')
if [ $uuid ]
    log "Updating $tax taxonomy" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-xlist.csv >> $logfile
end
