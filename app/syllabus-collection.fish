#!/usr/bin/env fish
# Syllabus Collection is a bit special so gets its own script
# usage:
#   ./syllabus-collection.fish data/_informer.csv [password] [--courses]

source log.fish
set -x LOGFILE logs/(date "+%Y-%m-%d")-syllabus.txt

set dept SYLLABUS
set dir data
set filename $argv[1]
set taxo_file data/taxonomies.json

set un (jq -r '.username' .equellarc)
set pw $argv[2]
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

if [ ! -e $taxo_file ]
    log "Downloading taxonomy list to $taxo_file"
    # make sure to get all of them with the length param
    eq tax --path '?length=5000' >$taxo_file
    sleep 5
end

# create CSVs for all taxonomies
./get-columns.fish SYLLABUS $filename
# create a couple CSVs not made in any other steps
# XList IDs, deleting the empty row with sed
csvcut -c 7 $filename | tail -n +2 | sort | uniq | sed -e '/""/d' >$dir/$dept-xlist.csv
and log "Wrote $dept XList IDs CSV…"
csvcut -c 2 $filename | tail -n +2 | sort | uniq >$dir/$dept-dept-codes.csv
and log "Wrote $dept department codes CSV…"

# update all taxonomies
# main course list
set tax "$dept - COURSE LIST"
set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
if [ $uuid ]
    log "Updating $tax taxonomy"
    log (uptaxo --tid $uuid --pw $pw --un $un --csv $dir/$dept-course-list-taxo.csv)
    sleep 5
end

if not contains -- --courses $argv
    # course titles e.g. "Introduction to Painting"
    set tax "$dept - course titles"
    set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
    if [ $uuid ]
        log "Updating $tax taxonomy"
        log (uptaxo --tid $uuid --pw $pw --un $un --csv $dir/$dept-course-titles.csv)
        sleep 5
    end

    # faculty names e.g. "Annemarie Haar, Eric Phetteplace"
    set tax "$dept - faculty"
    set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
    if [ $uuid ]
        log "Updating $tax taxonomy"
        log (uptaxo --tid $uuid --pw $pw --un $un --csv $dir/$dept-faculty-names.csv)
        sleep 5
    end

    # course names e.g. INDIV-101
    set tax "$dept - course names"
    set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
    if [ $uuid ]
        log "Updating $tax taxonomy"
        log (uptaxo --tid $uuid --pw $pw --un $un --csv $dir/$dept-courses.csv)
        sleep 5
    end

    # course sections e.g. ANIMA-101-01
    set tax "$dept - course sections"
    set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
    if [ $uuid ]
        log "Updating $tax taxonomy"
        log (uptaxo --tid $uuid --pw $pw --un $un --csv $dir/$dept-section-names.csv)
        sleep 5
    end

    # Xlist IDs
    set tax "$dept - cross-list keys (XList)"
    set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
    if [ $uuid ]
        log "Updating $tax taxonomy"
        log (uptaxo --tid $uuid --pw $pw --un $un --csv $dir/$dept-xlist.csv)
        sleep 5
    end

    # deptartment codes e.g. ANIMA
    set tax "$dept - dept codes"
    set uuid (eq tax --name $tax | jq -r '.uuid')
    if [ $uuid ]
        log "Updating $tax taxonomy"
        log (uptaxo --tid $uuid --pw $pw --un $un --csv $dir/$dept-dept-codes.csv)
        sleep 5
    end
end
