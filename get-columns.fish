#!/usr/bin/env fish
# from an Informer export of all course information for a department
# use Python's csvkit to extract lists of faculty, course sections, names, & titles
# usage:
# ./get-columns.fish informer-export.csv DEPT
# e.g.
# > ./get-columns.fish pntdr-export.csv PNTDR

# will fail with an error if either of these args is missing
set --local filename $argv[1]
set --local dept $argv[2]

csvcut -c 3 $filename | sort | uniq > data/$dept-course-titles.csv
and echo "Wrote $dept course titles CSV…"
csvcut -c 4 $filename | sort | uniq | sed -e '/Standby/d' > data/$dept-faculty-names.csv
and echo "Wrote $dept faculty names CSV…"
csvcut -c 5 $filename | sort | uniq > data/$dept-section-names.csv
and echo "Wrote $dept section names CSV…"
csvcut -c 6 $filename | sort | uniq > data/$dept-courses.csv
and echo "Wrote $dept courses CSV…"

# first sort file (first column is semester), then process
csvsort $filename > tmp; mv tmp $filename
if [ $dept = 'ARCHT' -o $dept = 'MARCH' -o $dept = 'INTER' -o $dept = 'SYLLABUS' ]
    ./course-csv-to-taxo.py --program $filename > data/$dept-course-list-taxo.csv
else
    ./course-csv-to-taxo.py $filename > data/$dept-course-list-taxo.csv
end
and echo "Created EQUELLA-ready '$dept - COURSE LIST' taxonomy CSV"
