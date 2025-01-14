#!/usr/bin/env fish
# deletes all the taxonomy terms of a given semester from VAULT course lists
# useful because we can't really "update" existing semester course lists
# so instead we delete them all & then re-upload a new set of courses
#
# usage:
#   ./delete-all-of-a-semester.fish data/_informer.csv 'Fall 2021'
# add --no-syllabus on the end to prevent deleting Syllabus Collection terms

# load log function
source log.fish

set filename $argv[1]
set taxo_file data/taxonomies.json
set semester $argv[2]
set depts (csvcut -c 2 $filename | tail -n +2 | sort | uniq | \
    # delete special snowflakes
    sed -e '/ARCHT/d' -e '/BARCH/d' -e '/CRITI/d' -e '/FNART/d' -e '/INTER/d' \
    -e '/MARCH/d' -e '/MAAD/d' )
# manually add exceptions: Architecture Division, & Syllabus Coll (formerly ENGAGE, too)
set depts $depts 'ARCH DIV'
# --no-syllabus skips Syllabus Collection, see https://github.com/cca/libraries_course_lists/issues/4
if not contains -- --no-syllabus $argv
    set depts $depts SYLLABUS
end

# cache taxonomy list in data file
if [ ! -e "$taxo_file" ]
    log "Downloading taxonomy list to $taxo_file"
    # make sure to get all of them with the length param
    eq tax --path '?length=5000' >$taxo_file
end

if not string match --regex "[A-Z][a-z]+ [0-9]{4}" "$semester" >/dev/null
    echo "Error: '$semester' is not a valid semester string in the form 'SEASON YEAR' e.g. 'Spring 2023'" >&2
    exit 1
end

for dept in $depts
    set taxoID (jq -r ".results[] | select(.name == \"$dept - COURSE LIST\") | .uuid" $taxo_file)

    if [ -n "$taxoID" ]
        set termID (eq tax "$taxoID/term" | jq -r ".[] | select(.term | contains(\"$semester\")) | .uuid")

        if [ -n "$termID" ]
            eq --method del tax $taxoID/lock # unlock the taxonomy
            eq --method del tax $taxoID/term/$termID >/dev/null
            and log "deleted $semester from $dept - COURSE LIST"
        else
            log "couldn't find \"$semester\" term in $dept - COURSE LIST taxo"
        end
    else
        log "couldn't find \"$dept - COURSE LIST\" in data file $taxo_file"
    end
end
