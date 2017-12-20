#!/usr/bin/env fish
# usage:
#   ./make-all-taxo-csvs.fish data/_informer.csv
#
# where "_informer.csv" is the full semester Informer report
# from this report:
# vm-informer-01.cca.edu/informer/#action=ReportRun&reportId=25428063&launch=false
# settings: header row, mutli-value fields separated by commas

set filename $argv[1]

# list out all department codes from the report
# trimming header row, might require Gnu (& not OS X) version of `tail`
set depts (csvcut -c 2 $filename | tail -n +2 | sort | uniq)

for dept in $depts
    # slice rows from deparment into own CSV
    csvgrep -c 2 -r $dept $filename > data/$dept.csv
    and echo "Cut $dept department rows out of $filename report"
    # separate script breaks out all the necessary columns into own CSVs
    # and creates EQUELLA-ready taxonomy in the process
    ./get-columns.fish $dept data/$dept.csv
end

# CRITI courses are filed under INTDS
if test -e data/CRITI.csv -a -e data/INTDS.csv
    echo 'Adding CRITI courses to INTDS taxonomies'
    for type in course-list-taxo course-titles courses faculty-names section-names;
        cat data/CRITI-$type.csv data/INTDS-$type.csv > tmp
        mv tmp data/INTDS-$type.csv
        rm data/CRITI-$type.csv
    end
    rm data/CRITI.csv
end

# ENGAGE courses could be under any department
# so we handle them as a special case
set dept ENGAGE
csvgrep -c 3 -r 'Engage:' $filename | tail -n +2 > data/$dept.csv
./course-csv-to-taxo.py data/ENGAGE.csv > data/$dept-course-list-taxo.csv
