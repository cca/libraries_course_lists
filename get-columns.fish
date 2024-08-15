#!/usr/bin/env fish
# from an Informer export of all course information for a department
# use Python's csvkit to extract lists of faculty, course sections, names, & titles
# usage:
# ./get-columns.fish DEPT data/_informer.csv
# e.g.
# > ./get-columns.fish PNTDR data/pntdr-report.csv

source log.fish

# will fail with an error if either of these args is missing
set dept $argv[1]
set filename $argv[2]

csvcut -c 3 $filename | tail -n +2 | sort | uniq > data/$dept-course-titles.csv
csvcut -c 4 $filename | tail -n +2 | sort | uniq | gsed -E /Standby/Id > data/$dept-faculty-names.csv
csvcut -c 5 $filename | tail -n +2 | sort | uniq > data/$dept-section-names.csv
csvcut -c 6 $filename | tail -n +2 | sort | uniq > data/$dept-courses.csv
log "Wrote $dept course titles, faculty, sections, and courses CSVs…"

# first sort file (first column is semester), then process
# --no-inference REQUIRED b/c otherwise it translates "MARCH" to "9999-03-31"
csvsort --snifflimit 0 --no-inference $filename > tmp
mv tmp $filename
if [ $dept = ARCHT -o $dept = BARCH -o $dept = INTER -o $dept = MARCH -o $dept = SYLLABUS ]
    ./course-csv-to-taxo.py --program $filename > data/$dept-course-list-taxo.csv
else
    ./course-csv-to-taxo.py $filename > data/$dept-course-list-taxo.csv
end
log "Created EQUELLA-ready '$dept - COURSE LIST' taxonomy CSV"
