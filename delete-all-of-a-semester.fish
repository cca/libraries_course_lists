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
        # couldn't find an easy way to filter to object where
        # .term == $semester with jq, so we store all IDs & iterate over them
        set termIDs (eq tax "$taxoID/term" | jq -r '.[].uuid')

        if [ (count $termIDs) -gt 0 ]
            for id in $termIDs
                set term "$taxoID/term/$id"

                if [ (eq tax $term | jq -r '.term') = $semester ]
                    # DELETE returns "undefined" on success so we silence that
                    eq --method del tax $term > /dev/null
                    and log "deleted $semester from $dept - COURSE LIST"
                end
            end
        end
    end
end
