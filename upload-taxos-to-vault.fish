#!/usr/bin/env fish
# usage:
#   ./upload-taxos-to-vault.fish data/_informer.csv
# where "informer.csv" is the full semester of course information

source log.fish

set filename $argv[1]
set taxo_file data/taxonomies.json
set dir data
set pw (jq -r '.password' ~/.equellarc)
set un (jq -r '.username' ~/.equellarc)

# cache taxonomy list in data file
if [ ! -e "$taxo_file" ]
    log "Downloading taxonomy list to $taxo_file"
    # make sure to get all of them with the length param
    eq tax --path '?length=5000' >$taxo_file
end

# parse all department codes listed in the report
# trim header row with tail -n +2 (might need gnu tail not OS X?)
set depts (csvcut -c 2 $filename | tail -n +2 | sort | uniq | \
    # remove Architecture Division (handled separately) plus Fine Arts critiques
    sed -e '/ARCHT/d' \
        -e '/BARCH/d' \
        -e '/CRITI/d' \
        -e '/FNART/d' \
        -e '/INTER/d' \
        -e '/MAAD/d' \
        -e '/MARCH/d')

for dept in $depts
    # full course list in EQUELLA taxonomy format
    set tax "$dept - COURSE LIST"
    set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
    if [ -n "$uuid" ]
        log "Updating $tax taxonomy"
        log (uptaxo --tid $uuid --pw $pw --un $un \
            --csv $dir/$dept-course-list-taxo.csv)
    end

    # course titles e.g. "Introduction to Printmaking"
    set tax "$dept - course titles"
    set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
    if [ -n "$uuid" ]
        log "Updating $tax taxonomy"
        log (uptaxo --tid $uuid --pw $pw --un $un \
            --csv $dir/$dept-course-titles.csv)
    end

    # faculty names e.g. "Annemarie Haar, Eric Phetteplace"
    set tax "$dept - faculty"
    set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
    if [ -n "$uuid" ]
        log "Updating $tax taxonomy"
        log (uptaxo --tid $uuid --pw $pw --un $un \
            --csv $dir/$dept-faculty-names.csv)
    end

    # course names e.g. INDIV-101
    set tax "$dept - course names"
    set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
    if [ -n "$uuid" ]
        log "Updating $tax taxonomy"
        log (uptaxo --tid $uuid --pw $pw --un $un \
            --csv $dir/$dept-courses.csv)
    end

    # course sections e.g. INDIV-101-01
    set tax "$dept - course sections"
    set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
    if [ -n "$uuid" ]
        log "Updating $tax taxonomy"
        log (uptaxo --tid $uuid --pw $pw --un $un \
            --csv $dir/$dept-section-names.csv)
    end
end

# ENGAGE is an exception which we handle as its own department
# but it's not listed in the informer CSV's department column
# @TODO we have not had an ENGAGE course since 2020, is this convention still used?
# set dept ENGAGE
# set tax "$dept - COURSE LIST"
# set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
# log "Updating $tax taxonomy"
# log (uptaxo --tid $uuid --pw $pw --un $un --csv $dir/$dept-course-list-taxo.csv)

# kick off the other, more complicated exceptions:
# Syllabus Collection, Architecture Division
log 'Updating Syllabus Collection...'
./syllabus-collection.fish $filename
# since Architecture programs' individual taxonomies have
# already been created, the necessary files are in the "data"
# dir and we don't need to pass $filename to the script
log 'Updating Architecture Division...'
./arch-division.fish

# move files from "data" dir to "complete/${date}" where date is today's date
set today (date "+%Y-%m-%d")
mkdir -p "complete/$today"
mv data/* "complete/$today/"
