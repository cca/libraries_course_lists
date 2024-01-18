#!/usr/bin/env python3
import argparse
import csv


def convert_semester(str) -> str:
    """
    Convert the abbreviated semester form "2015fa" from an Informer report
    into a more readable, human-friendly form "2015 Fall"
    """
    year = str[:4]
    season = str.lower()[-2:]
    if season == "fa":
        return "Fall " + year
    elif season == "sp":
        return "Spring " + year
    elif season == "su":
        return "Summer " + year
    # something's gone wrong if we get this far, so throw an error
    else:
        raise Exception("invalid semester season string %s" % season)


def main(args) -> None:
    # the columns in the department-specific Informer CSV, in order
    columns = [
        "semester",
        "dept",
        "title",
        "faculty",
        "section",
        "course",
        "xlist",
        "usernames",
    ]
    with open(args.file, "r") as fh:
        reader = csv.DictReader(fh, columns, delimiter=",")
        for row in reader:
            # skip Standby rows, don't want them in our taxonomies
            if not row["faculty"].lower() == "standby":
                # construct output row string, first few elements are slash-separated path
                # ex. "Fall 2015\ANIMA\Animation 1\Daria Morgendorffer\ANIMA-100-01"
                out = '"' + convert_semester(row["semester"]) + "\\"
                # only add program if told to on the command line
                if args.program:
                    out += row["dept"] + "\\"
                # see my normalize-course-titles project which slots right in here
                out += "\\".join([row["title"], row["faculty"], row["section"]]) + '",'
                # path is over, these are taxonomy data keys
                # format is "key,value"
                out += '"CrsName","%s",' % row["course"]
                out += '"XList","%s",' % row["xlist"]
                out += '"facultyID","%s",' % row["usernames"]
                print(out)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file", nargs="?", help="CSV of the Informer report")
    parser.add_argument(
        "-p",
        "--program",
        help="retain the program code in the taxonomy",
        action="store_true",
    )
    args = parser.parse_args()
    main(args)
