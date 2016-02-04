# Course Lists

Scripts to process course information exported from Informer reports into CSVs and text files, which are then uploaded into VAULT as EQUELLA taxonomies.

## Requirements

There's a lot, actually. Builds heavily upon my usual command line setup. The `brew` commands below refer to [Homebrew](http://brew.sh).

- Node & NPM (needed for `eq`), `brew install node`
- Python 2.\*, comes with Mac OS X by default
- Fish shell, `brew install fish` (the Fish scripts could be trivially converted to Bash)
- `jq` command-line JSON processor, `brew install jq`
- My [equella-cli](https://github.com/cca/equella_cli) NPM module (`npm i -g equella-cli`) with administrator credentials in an ".equellarc" file located in your user's home directory (used within scripts in calls to `uptaxo`)
- My `uptaxo` script (not included) which puts a light CLI around the EQUELLA taxonomy update script

## Sequencing of Scripts:

First, generate an Informer report of the current semester's courses. You can open the report URL with `./course-csv-to-taxo.py --open-report`. If you want to refresh just a single department's course list, you can simply specify that department in the report query and follow the same steps here.

Download the report as a CSV, with the following settings:

- _with header row_ because the csvkit tools we use will assume one anyways, otherwise first row will get cut off everywhere
- _comma-separated multivalue fields_ needed so facultyID is handled appropriately

Once you have a report downloaded, say named "\_informer.csv" and in the "data" directory as in the examples below, run the scripts in this order:

```sh
> # create ALL the CSVs
> ./make-all-taxo-csvs.fish data/_informer.csv
> # delete the last semester's taxonomy terms, only run if not the initial upload
> # NOTE: DOES NOT delete ARCH DIV or Syllabus Collection semesters, that's manual
> ./delete-all-of-a-semester.fish data/_informer.csv 'Spring 2016'
> # upload everything to VAULT, takes a while
> # stderr shows the "missing" taxonomies we don't need or haven't created yet
> ./upload-taxos-to-vault.fish data/_informer.csv
> # Syllabus Collection is a special snowflake
> ./syllabus-collection.fish data/_informer.csv
> # Architecture Division is also special
> ./arch-division.fish  # note: no need to pass file name argument
> # generate LDAP group listings, only the first 1 or 2 runs per semester
> python faculty-ldap-groups.py data/_informer.csv
```

## Files Generated

**CSVs** are placed in a "data" directory under the root of the project. They are named `${DEPARTMENT}-${TYPE}.csv` e.g. `ANIMA-course-titles.csv`. Most are just plain text lists but the "course-list-taxo" ones are more complicated and adhere to the upload format that the EQUELLA taxonomy upload script necessitates.

Faculty LDAP group text files are also placed in the "data" directory.

**Logs** are made automatically for the most part and placed in a "logs" directory under the root of the project. They're of form `YYYY-MM-DD-${TYPE}.txt` for the most part, where a lack of a type specifier means it's from the main "upload-taxos-to-vault" script while the syllabus and architecture scripts each have their own logs.

When you're finished with an update, you can move all the generated data to an archive location with `./move-to-complete.fish` which moves everything in the "data" directory into a directory under "complete" named after the current date.

## LICENSE

[Apache Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
