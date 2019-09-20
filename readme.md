# Course Lists

Scripts to process course information exported from Informer reports into CSVs and text files, which are then uploaded into VAULT as EQUELLA taxonomies.

## Requirements

There's a lot, actually. Builds heavily upon my usual command line setup. The `brew` commands below refer to [Homebrew](http://brew.sh).

- Node & NPM (needed for `eq`), `brew install node`
- Python 2.\*, comes with Mac OS X by default
- Python's csv kit tools, `pip install csvkit`
- Fish shell, `brew install fish` (the Fish scripts could be trivially converted to Bash)
- `jq` command-line JSON processor, `brew install jq`
- `eq`, the [equella-cli](https://github.com/cca/equella_cli) NPM module (`npm i -g equella-cli`) with administrator credentials in an ".equellarc" file located in your user's home directory (used within scripts in calls to `uptaxo`)
- the `uptaxo` script (not included) which puts a light CLI around the EQUELLA taxonomy update script and its dependencies `equellasoap.py` and `util.py` from the [openEQUELLA docs repo](https://github.com/openequella/openequella.github.io/tree/master/example-scripts/SOAP/python)

## Sequencing of Scripts:

First, generate a course information CSV using our other project [cca/libraries_course_lists2](https://github.com/cca/libraries_course_lists2) by downloading the Workday JSON course data and running `python make_informer_csv.py data/data.json 2019FA` where 2019FA is the current semester's short code.

Once you have the course data—expected to be named "\_informer.csv" and in the "data" directory—run the scripts in this order:

```sh
> # create ALL the CSVs
> ./make-all-taxo-csvs.fish data/_informer.csv
> # delete the last semester's taxonomy terms, only run if not the initial upload
> ./delete-all-of-a-semester.fish data/_informer.csv 'Fall 2016'
> # upload everything to VAULT, takes a while
> # stderr shows the "missing" taxonomies we don't need or haven't created yet
> ./upload-taxos-to-vault.fish data/_informer.csv
> # generate LDAP group listings, only the first 1 or 2 runs per semester
> python faculty-ldap-groups.py data/_informer.csv
```

## Files Generated

**CSVs** are placed in a "data" directory under the root of the project. They are named `${DEPARTMENT}-${TYPE}.csv` e.g. `ANIMA-course-titles.csv`. Most are just plain text lists but the "course-list-taxo" ones are more complicated and adhere to the upload format that the EQUELLA taxonomy upload script necessitates.

Faculty LDAP group text files are also placed in the "data" directory.

**Logs** are made automatically for the most part and placed in a "logs" directory under the root of the project. They're of form `YYYY-MM-DD-${TYPE}.txt`, where a lack of a type specifier means it's from the main "upload-taxos-to-vault" script while the syllabus and architecture scripts each have their own logs.

When you're finished with an update, move all the generated data to an archive location with `./move-to-complete.fish` which moves everything in the "data" directory into a directory under "complete" named after the current date.

## LICENSE

[ECL Version 2.0](https://opensource.org/licenses/ECL-2.0)
