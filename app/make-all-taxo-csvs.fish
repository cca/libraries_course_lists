#!/usr/bin/env fish
# usage:
#   ./make-all-taxo-csvs.fish [data/_informer.csv]
#
# where "_informer.csv" is the full semester course information, it can be
# created by the "course_lists2" project with "make_informer_csv.py"

set filename $argv[1]

if [ ! -f "$filename" ]
    if [ -f "data/_informer.csv" ]
        set filename "data/_informer.csv"
    else
        echo "Error: no data/_informer.csv and the first argument is not a path to the courses CSV" >&2
        exit 1
    end
end

source log.fish

# list out all department codes from the report
# trimming header row, might require Gnu (& not OS X) version of `tail`
# skip MAAD courses
set depts (csvcut -c 2 $filename | tail -n +2 | sort | uniq | sed -e '/MAAD/d')
set types course-list-taxo course-titles courses faculty-names section-names

for dept in $depts
    # slice rows from deparment into own CSV
    log "Cutting $dept department rows out of $filename report"
    csvgrep -c 2 -r $dept $filename > data/$dept.csv
    # separate script breaks out all the necessary columns into own CSVs
    # and creates EQUELLA-ready taxonomy in the process
    ./get-columns.fish $dept data/$dept.csv
end

# CRITI courses are filed under INTDS
if test -e data/CRITI.csv -a -e data/INTDS.csv
    log 'Adding CRITI courses to INTDS taxonomies'
    for t in $types
        cat data/CRITI-$t.csv data/INTDS-$t.csv >tmp
        mv tmp data/INTDS-$t.csv
        rm -v data/CRITI-$t.csv
    end
    rm -v data/CRITI.csv
end
