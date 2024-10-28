# Course Lists

Scripts to process course information into sets of departmental CSVs, which are then uploaded into VAULT as openEQUELLA taxonomies.

This project expects us to generate a course information CSV using our other project [cca/libraries_course_lists2](https://github.com/cca/libraries_course_lists2) by downloading the Workday JSON course data and running `pipenv run python make_informer_csv.py`.

## Docker Usage

It is easier to build and run a Docker image than to worry about [the requirements](#requirements) enumerated below. The docker-compose project mounts the local complete, data, and logs directories as volumes.

```sh
# build image & run as container with data volumes
docker-compose up -d
# get user password (example using 1Password CLI)
set UN (jq -r '.username' app/.equellarc)
set PW (op item get "VAULT ($UN)" --reveal --fields password --reveal)
# run bash on container with "pw" env var
docker exec -it -e pw=$PW course_lists-courselists-1 bash
```

Then perform the "local usage" steps below. Run `docker-compose down` when finished.

We may want to run `docker image prune` on occasion to clean up "dangling" old images. They tend to not take up much disk space but clutter the `docker images` list.

## Local Usage

These steps can be run locally on our host machine if we have the complete setup or on a shell on the Docker container. Docker container is recommended. If we're not in the container, `cd app` to enter the code directory.

Once we have the course data—named "_informer.csv" in these examples and in the "data" directory—run the scripts in this order:

```sh
# create ALL the CSVs
./make-all-taxo-csvs.fish data/_informer.csv
# delete the last semester's taxonomy terms, only run if not the initial upload
./delete-all-of-a-semester.fish data/_informer.csv 'Fall 2023'
# upload everything to VAULT, takes a while
./upload-taxos-to-vault.fish data/_informer.csv
# upload only the course list taxonomies to VAULT
./upload-taxos-to-vault.fish data/_informer.csv --courses
# files are archived in the /complete/$date directory afterwards
```

## Files Generated

**CSVs** are placed in a "data" directory under the root of the project. They are named `${DEPARTMENT}-${TYPE}.csv` e.g. `ANIMA-course-titles.csv`. Most are just plain text lists but the "course-list-taxo" ones are more complicated and adhere to the upload format that the openEQUELLA taxonomy upload script necessitates.

**Logs** are made automatically for the most part and placed in a "logs" directory under the root of the project. They're of form `YYYY-MM-DD-${TYPE}.txt`, where a lack of a type specifier means it's from the main "upload-taxos-to-vault" script while the Syllabus and Architecture Division collections each have their own logs.

## Requirements

The setup.sh script gets us most of the way there.

- `mise` for python and node programming language version management
- Node, python 2.7, and python 3, `mise install`
- Python's csvkit tools, e.g. `uv tool install csvkit` or `pipx install csvkit` (they can be in a Python 3 environment)
- Fish shell, `brew install fish` (the Fish scripts could be trivially converted to Bash)
- `jq` command-line JSON processor, `brew install jq`
- `eq`, the [equella-cli](https://github.com/cca/equella_cli) NPM module (`npm i -g equella-cli`) with administrator credentials in an ".equellarc" file located in your user's home directory (used within scripts in calls to `uptaxo`)
- (included in this repo) the [`uptaxo` script](https://gist.github.com/phette23/9bec679b7b677af7e396e8a40e7a7047) which puts a light CLI around the EQUELLA taxonomy update script and its dependencies `equellasoap.py` and `util.py` from the [openEQUELLA docs repo](https://github.com/openequella/openequella.github.io/tree/master/example-scripts/SOAP/python). These may need to be on your PATH, e.g. in a ~/bin directory

## Using Python 2.7

The [EQUELLA SOAP API scripts](https://github.com/openequella/openequella.github.io/tree/master/example-scripts/SOAP/python) mentioned under requirements were written for Python 2 and will probably never be updated to Python 3. TLDR;

```sh
brew install openssl@1.1
mise install python 2.7.18
mise local python 2.7.18 3.12
```

Python 2.7 should install OK from `mise`. I've found that openssl@1.1 is necessary, 1.0.2 will throw errors.

## LICENSE

[ECL Version 2.0](https://opensource.org/licenses/ECL-2.0)
