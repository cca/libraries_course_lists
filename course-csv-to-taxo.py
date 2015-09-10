#!/usr/bin/env python
from __future__ import print_function
import argparse
import webbrowser
import csv

# CLI arguments
parser = argparse.ArgumentParser()
parser.add_argument('file', nargs='?', help='CSV of the Informer report')
parser.add_argument('-o', '--open-report',
                    help='open the appropriate Informer report',
                    action='store_true')
parser.add_argument('-p', '--program',
                    help='retain the program code in the taxonomy',
                    action='store_true')
args = parser.parse_args()

if args.open_report:
    webbrowser.open('https://vm-informer-01.cca.edu/informer/?locale=en_US\
                    #action=ReportRun&reportId=25428063&launch=false')
    exit()


def skip_header(fp):
    """
    given a file pointer, check if the CSV has a header row
    if so, skip to the next row so DictReader starts with content
    """
    # check for header row
    if csv.Sniffer().has_header(fp.read(1024)):
        # return to beginning of file & skip first line
        fp.seek(0)
        next(fp)


report = open(args.file, 'rb')
# skip header row
skip_header(report)
# the columns in the department-specific Informer CSV, in order
columns = [
    'semester',
    'dept',
    'title',
    'faculty',
    'section',
    'course',
    'xlist',
    'usernames'
]  # we leave off last "student count" column because it's unused
reader = csv.DictReader(report, columns)


def convert_semester(str):
    """
    Convert the abbreviated semester form "2015fa" from an Informer report
    into a more readable, human-friendly form "2015 Fall"
    """
    year = str[:4]
    season = str.lower()[-2:]
    if season == 'fa':
        return 'Fall ' + year
    elif season == 'sp':
        return 'Spring ' + year
    elif season == 'su':
        return 'Summer ' + year
    # something's gone wrong if we get this far, so throw an error
    else:
        raise Exception('invalid semester season string %s' % season)


for row in reader:
    # skip Standby rows, don't want them in our taxonomies
    if not row['faculty'].lower() == 'standby':
        # construct output row string, first few elements are slash-separated path
        # ex. "Fall 2015\ANIMA\Animation 1\Daria Morgendorffer\ANIMA-100-01"
        out = '"' + convert_semester(row['semester']) + '\\'
        # only add program if told to on the command line
        if args.program:
            out += row['dept'] + '\\'
        # @TODO: is this the place to normalize course names?
        # see my normalize-course-titles project which slots right in here
        out += '\\'.join([row['title'], row['faculty'], row['section']]) + '",'
        # path is over, these are taxonomy data keys
        # format is "key,value"
        out += '"CrsName","%s",' % row['course']
        out += '"Xlist","%s",' % row['xlist']
        out += '"facultyID","%s",' % row['usernames']
        print(out)
