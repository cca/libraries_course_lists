#!/usr/bin/env fish
# usage:
#   ./make-all-taxo-csvs.fish informer-report.csv
#
# where "informer-report.csv" is the full semester Informer report
# from this report:
# vm-informer-01.cca.edu/informer/#action=ReportRun&reportId=25428063&launch=false
# settings: no header row, mutli-value fields separated by commas

set --local filename $argv[1]

# parse all department codes listed in the report
set --local depts (csvcut -c 2 $filename | tail -n +2 | sort | uniq)

for dept in $depts
    # slice rows from this deparment into own CSV, trimming header row
    csvgrep -c 2 -r $dept $filename | tail -n +2 > data/$dept.csv
    and echo "Cut $dept department rows out of $filename report"
    # separate script breaks out all the necessary columns into own CSVs
    # and creates EQUELLA-ready taxonomy in the process
    ./get-columns.fish data/$dept.csv $dept
end
