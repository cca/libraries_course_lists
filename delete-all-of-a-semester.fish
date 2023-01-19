#!/usr/bin/env fish
# deletes all the taxonomy terms of a given semester from VAULT course lists
# useful because we can't really "update" existing semester course lists
# so instead we delete them all & then re-upload a new set of courses
#
# usage:
#   ./delete-all-of-a-semester.fish data/_informer.csv 'Fall 2021'

# load log function
source log.fish

set filename $argv[1]
set semester $argv[2]
set depts (csvcut -c 2 $filename | tail -n +2 | sort | uniq | \
    # delete the special snowflakes
    sed -e '/ARCHT/d' -e '/BARCH/d' -e '/CRITI/d' -e '/FNART/d' -e '/INTER/d' \
    -e '/MARCH/d' )
# manually add the exceptions: ENGAGE, Architecture Division, & Syllabus Coll
set depts $depts ENGAGE 'ARCH DIV' SYLLABUS

for dept in $depts
    set taxoID (eq tax --name "$dept - COURSE LIST" | jq -r '.uuid')

    if [ $taxoID ]
        set termID (eq tax "$taxoID/term" | jq -r ".[] | select(.term | contains("$semester")) | .uuid")

        if [ -n $termID ]
            eq --method del tax $term >/dev/null
            and log "deleted $semester from $dept - COURSE LIST"
        else
            log "couldn't find \"$semester\" term in $dept - COURSE LIST taxo"
        end
    end
end
