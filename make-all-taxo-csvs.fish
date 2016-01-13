#!/usr/bin/env fish
# usage:
#   ./make-all-taxo-csvs.fish informer-report.csv
#
# where "informer-report.csv" is the full semester Informer report
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
