#!/usr/bin/env python
from __future__ import print_function
import argparse
import csv

# CLI arguments
parser = argparse.ArgumentParser()
parser.add_argument('file', help='CSV of the Informer report')
args = parser.parse_args()


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
# output data structure, will end up looking like
# {'ANIMA': set(['asmith', 'bsmith', 'csmith']), 'ARCHT': set([...])}
depts = {}


# iterate over CSV to populate our data structure
for row in reader:
    # converts comma-separated usernames string into a set
    # we use a set instead of list to get built-in deduping
    uns = set(row['usernames'].replace(' ', '').split(','))

    if row['dept'] not in depts:
        depts[row['dept']] = uns
    else:
        depts[row['dept']].update(uns)

# interate over data structure, writing out sorted lists of usernames to files
for dept in depts:
    # convert to list from set just so we can sort alphabetically
    uns = list(depts[dept])
    uns.sort()

    textfile = open('data/' + dept + '-faculty-ldap.txt', 'w')
    for user in uns:
        textfile.write(user + '\n')
    textfile.close()
