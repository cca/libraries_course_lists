# Course Lists

Scripts to process course information into sets of departmental CSVs, which are then uploaded into VAULT as openEQUELLA taxonomies.

This project expects us to generate a course information CSV using our other project [cca/libraries_course_lists2](https://github.com/cca/libraries_course_lists2) by downloading the Workday JSON course data and running `pipenv run python make_informer_csv.py`.

## Docker Usage

It is easier to build and run a Docker image than to worry about [the requirements](#requirements) below. The docker-compose project mounts the local complete, data, and logs directories as volumes.

```sh
docker desktop start
# build image & run as container with data volumes
docker-compose up -d
set UN (jq -r '.username' app/.equellarc)
 # pass the "CCA (username)" password to fish shell on container
docker exec -it -e pw=(op item get "CCA ($UN)" --fields password --reveal) course_lists-courselists-1 fish
```

Then perform the "local usage" steps below in the shell. Run `docker-compose down` when finished.

## Local Usage

These steps can be run locally on our host machine if we have the complete setup or on a shell on the Docker container. Docker is recommended. If we're not in the container, `cd app` to enter the code directory. If we place the course data at the path "data/_informer.csv" then it does not have to be passed to the scripts. Run the scripts in this order:

```sh
# create ALL the CSVs
./make-all-taxo-csvs.fish path/to/courses.csv
# delete the last semester's taxonomy terms, only run if not the initial upload
./delete-all-of-a-semester.fish path/to/courses.csv 'Fall 2026'
# upload everything to VAULT, takes a while
./upload-taxos-to-vault.fish path/to/courses.csv
# OR upload only the course list taxonomies to VAULT
./upload-taxos-to-vault.fish path/to/courses.csv --courses
```

## Files Generated

**CSVs** are placed in a "data" directory under the root of the project. They are named `${DEPARTMENT}-${TYPE}.csv` e.g. `ANIMA-course-titles.csv`. Most are just plain text lists but the "course-list-taxo" ones are more complicated and adhere to the upload format that the openEQUELLA taxonomy upload script necessitates. When everything finishes, CSVs are moved to a dated directory under "complete".

**Logs** are made automatically for the most part and placed in a "logs" directory under the root of the project. They are named after the current date.

## Docker build and push

To build and store a new image in Google Artifact Registry, do this:

```sh
# with docker running
docker build .
# switch to the staging project, this assumes a `staging` config
gcloud config configurations activate staging
gcloud auth configure-docker us-west1-docker.pkg.dev
docker tag courselists:latest us-west1-docker.pkg.dev/cca-web-staging/cca-docker-web/courselists:latest
docker push us-west1-docker.pkg.dev/cca-web-staging/cca-docker-web/courselists:latest
```

To use the image later: `gcloud auth configure-docker us-west1-docker.pkg.dev && docker pull us-west1-docker.pkg.dev/cca-web-staging/cca-docker-web/courselists`.

## Requirements

The setup.sh script or using the Docker image should do all this for us.

- `mise` for python and node programming language version management
- Node, python 2.7, and python 3, `mise install`
- Python's csvkit tools, `uv tool install csvkit` or `pipx install csvkit` (they can be in a Python 3 environment)
- Fish shell, `brew install fish`
- `jq` command-line JSON processor, `brew install jq`
- [`eq`](https://github.com/cca/equella_cli), `npm i -g equella-cli`, with an ".equellarc" file either in our home directory or in "app". The account in the .equellarc file needs read/write permissions for Taxonomies.
- (included in this repo) the [`uptaxo` script](https://gist.github.com/phette23/9bec679b7b677af7e396e8a40e7a7047) which wraps a light CLI around the EQUELLA taxonomy update script and its dependencies `equellasoap.py` and `util.py` from the [openEQUELLA docs repo](https://github.com/openequella/openequella.github.io/tree/master/example-scripts/SOAP/python).
- optional: [Dashlane CLI](https://cli.dashlane.com/) or [1Password CLI](https://www.1password.dev/cli)

### Dashlane CLI Setup

Have a login saved in Dashlane with a predictable name like "VAULT (username)" (see ["Docker Usage"](#docker-usage) above.

```sh
# https://cli.dashlane.com/install
brew install dashlane/tap/dashlane-cli # install
dcli sync # login
```

I recommend using only one of biometrics or master password to unlock. The shell commands may need adjusting depending on authentication method; you cannot pipe or `set` a var easily with master password. Despite using CCA's organizational Dashlane subscription, we follow the "Personal" account instructions in their documentation. The ["Accessing your Vault" instructions](https://cli.dashlane.com/personal/vault) detail how to use `dcli` to retrieve credentials.

### Using Python 2.7

The [EQUELLA SOAP API scripts](https://github.com/openequella/openequella.github.io/tree/master/example-scripts/SOAP/python) mentioned under requirements were written for Python 2 and may never be updated to Python 3. TLDR;

```sh
brew install openssl@1.1
mise install python 2.7.18
mise local python 2.7.18 3.12
```

Python 2.7 should install OK from `mise`. I found openssl@1.1 necessary, 1.0.2 will throw errors.

## LICENSE

[ECL Version 2.0](https://opensource.org/licenses/ECL-2.0)
