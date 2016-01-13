#!/usr/bin/env fish
# Syllabus Collection is a bit special so gets its own script
# usage:
#   ./syllabus-collection.fish informer.csv

# load log function
source log.fish

set dept SYLLABUS
set dir data
set pw (jq -r '.password' ~/.equellarc)
set un (jq -r '.username' ~/.equellarc)
set filename $argv[1]
set logfile logs/(date "+%Y-%m-%d")-syllabus.txt

# create CSVs for all taxonomies
./get-columns.fish SYLLABUS $filename
# create a couple CSVs not made in any other steps
# XList IDs, deleting the empty row with sed
csvcut -c 7 $filename | tail -n +2 | sort | uniq  | sed -e '/""/d' > $dir/$dept-xlist.csv
and echo "Wrote $dept XList IDs CSV…"
csvcut -c 2 $filename | tail -n +2 | sort | uniq  > $dir/$dept-dept-codes.csv
and echo "Wrote $dept department codes CSV…"

# update all taxonomies
# main course list
set tax "$dept - COURSE LIST"
set uuid (eq tax --name $tax | jq -r '.uuid')
# @TODO should a script delete current semester prior?
# place to do it would be in "delete-all-of-a-semester.fish" script
if [ $uuid ]
    log "Updating $tax taxonomy" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-course-list-taxo.csv >> $logfile
end

# course titles e.g. "Introduction to Painting"
set tax "$dept - course titles"
set uuid (eq tax --name $tax | jq -r '.uuid')
if [ $uuid ]
    log "Updating $tax taxonomy" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-course-titles.csv >> $logfile
end

# faculty names e.g. "Annemarie Haar, Eric Phetteplace"
set tax "$dept - faculty"
set uuid (eq tax --name $tax | jq -r '.uuid')
if [ $uuid ]
    log "Updating $tax taxonomy" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-faculty-names.csv >> $logfile
end

# course names e.g. INDIV-101
set tax "$dept - course names"
set uuid (eq tax --name $tax | jq -r '.uuid')
if [ $uuid ]
    log "Updating $tax taxonomy" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-courses.csv >> $logfile
end

# course sections e.g. ANIMA-101-01
set tax "$dept - course sections"
set uuid (eq tax --name $tax | jq -r '.uuid')
if [ $uuid ]
    log "Updating $tax taxonomy" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-section-names.csv >> $logfile
end

# Xlist IDs
set tax "$dept - cross-list keys (XList)"
set uuid (eq tax --name $tax | jq -r '.uuid')
if [ $uuid ]
    log "Updating $tax taxonomy" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-xlist.csv >> $logfile
end

# deptartment codes e.g. ANIMA
set tax "$dept - dept codes"
set uuid (eq tax --name $tax | jq -r '.uuid')
if [ $uuid ]
    log "Updating $tax taxonomy" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-dept-codes.csv >> $logfile
end
