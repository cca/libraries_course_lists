## Requirements

There's a lot, actually. Builds heavily upon my usual command line setup. The `brew` commands below refer to [Homebrew](http://brew.sh).

- Node & NPM (needed for `eq`), `brew install node`
- Python 2.\*, comes with Mac OS X by default
- Fish shell, `brew install fish`
- jq, `brew install jq`
- The equella-cli npm module (`npm i -g equella-cli`) with administrator credentials in an .equellarc file located either in your user's home directory (used within scripts in calls to `uptaxo`)
- My `uptaxo` script which puts a light CLI around the EQUELLA taxonomy update script

## Sequencing of commands:

```sh
> # open Informer report, run it for the semester
> # options: *WITH HEADER ROW*, comma-separated multi-value fields
> ./course-csv-to-taxo.py --open-report
> # create ALL the CSVs, they reside in the "data" directory
> ./make-all-taxo-csvs.fish informer.csv
> # upload everything to VAULT, will take a while
> # taxonomy upload status is logged to logs/(today's date).txt
> # some errors & information are still printed to the terminal
> ./upload-taxos-to-vault.fish informer.csv
> # Syllabus Collection is a special snowflake
> ./syllabus-collection.fish informer.csv
> # same for Architecture Division
> ./arch-division.fish  # note: no need to pass file name argument
```

## LICENSE

[Apache Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
