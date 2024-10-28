#!/usr/bin/env fish
# handle Architecture Division's special taxonomies, which include departmental codes
# usage:
#   ./arch-division.fish
#
# run ONLY AFTER extracting all the departmental CSVs, e.g. by running the Informer
# report & running ./make-all-taxo-csvs.fish data/_informer.csv

# load log function
source log.fish
set -x LOGFILE logs/(date "+%Y-%m-%d")-architecture.txt
set taxo_file data/taxonomies.json
set depts ARCHT BARCH INTER MARCH
set div 'ARCH DIV'
set dir data
set taxo_file data/taxonomies.json

set un (jq -r '.username' .equellarc)
set pw $argv[1]
if [ -z $pw ]
    set pw (op >/dev/null && op item get "VAULT ($un)" --reveal --fields password || jq -r '.password' .equellarc)
end

if [ $un = "" ]
    echo "Error: requires a username property in .equellarc"
    exit 1
else if [ -z $pw ]; or [ $pw = null ]
    echo "Error: requires either a OnePassword login named 'VAULT ($un)' or a password property in .equellarc"
    exit 1
end

if [ ! -e "$taxo_file" ]
    log "Downloading taxonomy list to $taxo_file"
    # make sure to get all of them with the length param
    eq tax --path '?length=5000' >$taxo_file
    sleep 5
end

# combine departmental CSVs into division-level ones
# wipe out any previous division-level taxos, lets the script be run multiple times
log 'Deleting any previous taxonomy files'
rm -v $dir/$div-course-list-taxo.csv $dir/$div-course-titles.csv \
    $dir/$div-courses.csv $dir/$div-faculty-names.csv \
    $dir/$div-section-names.csv 2>/dev/null

# concatenate program data to make division-level taxos,
# silencing stderr because one of ARCHT/BARCH will always be missing
for dept in $depts
    cat $dir/$dept-course-list-taxo.csv 2>/dev/null >>$dir/$div-course-list-taxo.csv
    cat $dir/$dept-course-titles.csv 2>/dev/null >>$dir/$div-course-titles.csv
    cat $dir/$dept-courses.csv 2>/dev/null >>$dir/$div-courses.csv
    cat $dir/$dept-faculty-names.csv 2>/dev/null >>$dir/$div-faculty-names.csv
    cat $dir/$dept-section-names.csv 2>/dev/null >>$dir/$div-section-names.csv
    csvcut -c 7 $dir/$dept.csv 2>/dev/null | sort | uniq | sed '/""/d' >>$dir/$div-xlist.csv
end

# upload new, division-level CSVs to appropriate taxonomies

# main course list
set tax "$div - COURSE LIST"
set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
if [ -n "$uuid" ]
    log "Updating $tax taxonomy"
    log (uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-course-list-taxo.csv)
    sleep 5
end

# course titles
set tax "$div - course titles"
set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
if [ -n "$uuid" ]
    log "Updating $tax taxonomy"
    log (uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-course-titles.csv)
    sleep 5
end

# faculty names
set tax "$div - faculty"
set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
if [ -n "$uuid" ]
    log "Updating $tax taxonomy"
    log (uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-faculty-names.csv)
    sleep 5
end

# course names e.g. ARCHT-101
set tax "$div - course names"
set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
if [ -n "$uuid" ]
    log "Updating $tax taxonomy"
    log (uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-courses.csv)
    sleep 5
end

# course sections
set tax "$div - course sections"
set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
if [ -n "$uuid" ]
    log "Updating $tax taxonomy"
    log (uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-section-names.csv)
    sleep 5
end

# XList IDs
set tax "$div - cross-list keys"
set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
if [ -n "$uuid" ]
    log "Updating $tax taxonomy"
    log (uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$div-xlist.csv)
    sleep 5
end
