#!/usr/bin/env fish
# from an Informer export of all course information for a department
# use Python's csvkit to extract lists of faculty, course sections, names, & titles
# usage:
# ./get-columns.fish DEPT data/_informer.csv
# e.g.
# > ./get-columns.fish PNTDR data/pntdr-report.csv

# will fail with an error if either of these args is missing
set dept $argv[1]
set filename $argv[2]

csvcut -c 3 $filename | tail -n +2 | sort | uniq > data/$dept-course-titles.csv
and echo "Wrote $dept course titles CSV…"
# @TODO ideally we'd use case insensitive deletion here
csvcut -c 4 $filename | tail -n +2 | sort | uniq | sed -e '/Standby/d' > data/$dept-faculty-names.csv
and echo "Wrote $dept faculty names CSV…"
csvcut -c 5 $filename | tail -n +2 | sort | uniq > data/$dept-section-names.csv
and echo "Wrote $dept section names CSV…"
csvcut -c 6 $filename | tail -n +2 | sort | uniq > data/$dept-courses.csv
and echo "Wrote $dept courses CSV…"

# first sort file (first column is semester), then process
# --no-inference REQUIRED b/c otherwise it translates "MARCH" to "9999-03-31"
csvsort --no-inference $filename | tail -n +2 > tmp; mv tmp $filename
if [ $dept = 'ARCHT' -o $dept = 'MARCH' -o $dept = 'INTER' -o $dept = 'SYLLABUS' ]
    ./course-csv-to-taxo.py --program $filename > data/$dept-course-list-taxo.csv
else
    ./course-csv-to-taxo.py $filename > data/$dept-course-list-taxo.csv
end
and echo "Created EQUELLA-ready '$dept - COURSE LIST' taxonomy CSV"
