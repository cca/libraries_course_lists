#!/usr/bin/env fish
# usage:
#   ./upload-taxos-to-vault.fish data/_informer.csv
# where "informer.csv" is the full semester Informer report

# load log function
source log.fish

set filename $argv[1]
set dir 'data'
set logfile logs/(date '+%Y-%m-%d').txt
set pw (jq -r '.password' ~/.equellarc)
set un (jq -r '.username' ~/.equellarc)

# parse all department codes listed in the report
# trim header row with tail -n +2 (might need gnu tail not OS X?)
set depts (csvcut -c 2 $filename | tail -n +2 | sort | uniq | \
    # remove Architecture Division (handled separately)
    # plus Craft & Fine Arts critiques (no taxonomies for these)
    sed -e '/ARCHT/d' -e '/INTER/d' -e '/MARCH/d' -e '/CRAFT/d' -e '/CRITI/d' -e '/FNART/d')

for dept in $depts
    # full course list in EQUELLA taxonomy format
    set tax "$dept - COURSE LIST"
    set uuid (eq tax --name $tax | jq -r '.uuid')
    if [ $uuid ]
        log "Updating $tax taxonomy" $logfile
        uptaxo --tid $uuid --pw $pw --un $un \
            --csv $dir/$dept-course-list-taxo.csv >> $logfile
    end

    # course titles e.g. "Introduction to Printmaking"
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

    # course sections e.g. INDIV-101-01
    set tax "$dept - course sections"
    set uuid (eq tax --name $tax | jq -r '.uuid')
    if [ $uuid ]
        log "Updating $tax taxonomy" $logfile
        uptaxo --tid $uuid --pw $pw --un $un \
            --csv $dir/$dept-section-names.csv >> $logfile
    end
end

# ENGAGE is an exception which we handle as its own department
# but it's not listed in the informer CSV's department column
set dept ENGAGE
set tax "$dept - COURSE LIST"
set uuid (eq tax --name $tax | jq -r '.uuid')
log "Updating $tax taxonomy" $logfile
uptaxo --tid $uuid --pw $pw --un $un \
    --csv $dir/$dept-course-list-taxo.csv >> $logfile

# kick off the other, more complicated exceptions:
# Syllabus Collection, Architecture Division
echo 'Updating Syllabus Collection...' > /dev/stderr
./syllabus-collection.fish $filename
# since Architecture programs' individual taxonomies have
# already been created, the necessary files are in the "data"
# dir and we don't need to pass $filename to the script
echo 'Updating Architecture Division...' > /dev/stderr
./arch-division.fish
