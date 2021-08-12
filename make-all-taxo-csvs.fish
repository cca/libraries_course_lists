#!/usr/bin/env fish
# usage:
#   ./make-all-taxo-csvs.fish data/_informer.csv
#
# where "_informer.csv" is the full semester course information, it can be
# created by the "course_lists2" project with "make_informer_csv.py"

set filename $argv[1]

source log.fish

# list out all department codes from the report
# trimming header row, might require Gnu (& not OS X) version of `tail`
# skip MAAD courses
set depts (csvcut -c 2 $filename | tail -n +2 | sort | uniq | sed -e '/MAAD/d')
set types 'course-list-taxo' 'course-titles' 'courses' 'faculty-names' 'section-names'

for dept in $depts
    # slice rows from deparment into own CSV
    csvgrep -c 2 -r $dept $filename > data/$dept.csv
    and log "Cut $dept department rows out of $filename report"
    # separate script breaks out all the necessary columns into own CSVs
    # and creates EQUELLA-ready taxonomy in the process
    ./get-columns.fish $dept data/$dept.csv
end

# CRITI courses are filed under INTDS
if test -e data/CRITI.csv -a -e data/INTDS.csv
    log 'Adding CRITI courses to INTDS taxonomies'
    for t in $types
        cat data/CRITI-$t.csv data/INTDS-$t.csv > tmp
        mv tmp data/INTDS-$t.csv
        rm -v data/CRITI-$t.csv
    end
    rm -v data/CRITI.csv
end

# ENGAGE courses could be under any department, handle as a special case
log 'Creating ENGAGE course taxonomies'
set dept ENGAGE
csvgrep -c 3 -r 'Engage:' $filename | tail -n +2 > data/$dept.csv
./course-csv-to-taxo.py data/ENGAGE.csv > data/$dept-course-list-taxo.csv
