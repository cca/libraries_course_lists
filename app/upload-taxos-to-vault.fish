#!/usr/bin/env fish
# usage:
#   ./upload-taxos-to-vault.fish [data/_informer.csv] [--courses]
# where "informer.csv" is the full semester of course information

source log.fish

set filename $argv[1]

if [ ! -f "$filename" ]
    if [ -f "data/_informer.csv" ]
        set filename "data/_informer.csv"
    else
        echo "Error: no data/_informer.csv and the first argument is not a path to the courses CSV" >&2
        exit 1
    end
end

set un (jq -r '.username' .equellarc)
if [ -z $pw ]
    set pw (op >/dev/null && op item get "VAULT ($un)" --reveal --fields password --reveal || jq -r '.password' .equellarc)
end

if [ $un = "" ]
    echo "Error: requires a username property in .equellarc" >&2
    exit 1
else if [ -z $pw ]; or [ $pw = null ]
    echo "Error: requires either a OnePassword login named 'VAULT ($un)' or a password property in .equellarc" >&2
    exit 1
end

if contains -- --courses $argv
    set courses_flag "--courses"
end

set taxo_file data/taxonomies.json
set dir data

# cache taxonomy list in data file
if [ ! -e "$taxo_file" ]
    log "Downloading taxonomy list to $taxo_file"
    # make sure to get all of them with the length param
    eq tax --path '?length=5000' >$taxo_file
    sleep 5
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
        log uptaxo --tid $uuid --pw $pw --un $un --csv $dir/$dept-course-list-taxo.csv
        sleep 5
    end

    if not set --query courses_flag
        # course titles e.g. "Introduction to Printmaking"
        set tax "$dept - course titles"
        set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
        if [ -n "$uuid" ]
            log "Updating $tax taxonomy"
            log uptaxo --tid $uuid --pw $pw --un $un --csv $dir/$dept-course-titles.csv
            sleep 5
        end

        # faculty names e.g. "Annemarie Haar, Eric Phetteplace"
        set tax "$dept - faculty"
        set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
        if [ -n "$uuid" ]
            log "Updating $tax taxonomy"
            log uptaxo --tid $uuid --pw $pw --un $un --csv $dir/$dept-faculty-names.csv
            sleep 5
        end

        # course names e.g. INDIV-101
        set tax "$dept - course names"
        set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
        if [ -n "$uuid" ]
            log "Updating $tax taxonomy"
            log uptaxo --tid $uuid --pw $pw --un $un --csv $dir/$dept-courses.csv
            sleep 5
        end

        # course sections e.g. INDIV-101-01
        set tax "$dept - course sections"
        set uuid (jq -r ".results[] | select(.name == \"$tax\") | .uuid" $taxo_file)
        if [ -n "$uuid" ]
            log "Updating $tax taxonomy"
            log uptaxo --tid $uuid --pw $pw --un $un --csv $dir/$dept-section-names.csv
            sleep 5
        end
    end
end

# kick off the other, more complicated exceptions:
# Syllabus Collection, Architecture Division
# we provide the password to these so we don't have to reauthenticate
log 'Updating Syllabus Collection...'
./syllabus-collection.fish $filename $pw $courses_flag
# since Architecture programs' individual taxonomies have
# already been created, the necessary files are in the "data"
# dir and we don't need to pass $filename to the script
log 'Updating Architecture Division...'
./arch-division.fish $pw $courses_flag

# move files from "data" dir to "complete/${date}" where date is today's date
set today (date "+%Y-%m-%d")
set compdir "complete/$today"
echo "Moving files to $compdir"
mkdir -p $compdir
mv data/* $compdir
