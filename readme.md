# Course Lists

Scripts to process course information into sets of departmental CSVs, which are then uploaded into VAULT as openEQUELLA taxonomies.

## Usage

First, generate a course information CSV using our other project [cca/libraries_course_lists2](https://github.com/cca/libraries_course_lists2) by downloading the Workday JSON course data and running `python make_informer_csv.py data/data.json 2021FA` where 2021FA is the current semester's short code.

**Note:** if you're off campus, connect to the VPN before running these scripts, they will run much quicker.

Once you have the course data—expected to be named "\_informer.csv" and in the "data" directory—run the scripts in this order:

```sh
> # create ALL the CSVs
> ./make-all-taxo-csvs.fish data/_informer.csv
> # delete the last semester's taxonomy terms, only run if not the initial upload
> ./delete-all-of-a-semester.fish data/_informer.csv 'Fall 2021'
> # upload everything to VAULT, takes a while
> # stderr shows the "missing" taxonomies we don't need or haven't created yet
> ./upload-taxos-to-vault.fish data/_informer.csv
> # files are archived in the /complete/$date directory afterwards
```

## Requirements

The setup.sh script should get us most of the way there.

- Node & NPM (needed for `eq`), `brew install node`
- Python 2.7 (see section below)
- Python's csv kit tools, `pip install csvkit` (they can be in a Python 3 environment)
- Fish shell, `brew install fish` (the Fish scripts could be trivially converted to Bash)
- `jq` command-line JSON processor, `brew install jq`
- `eq`, the [equella-cli](https://github.com/cca/equella_cli) NPM module (`npm i -g equella-cli`) with administrator credentials in an ".equellarc" file located in your user's home directory (used within scripts in calls to `uptaxo`)
- (included in this repo) the [`uptaxo` script](https://gist.github.com/phette23/9bec679b7b677af7e396e8a40e7a7047) which puts a light CLI around the EQUELLA taxonomy update script and its dependencies `equellasoap.py` and `util.py` from the [openEQUELLA docs repo](https://github.com/openequella/openequella.github.io/tree/master/example-scripts/SOAP/python). These may need to be on your PATH, e.g. in a ~/bin directory

## Files Generated

**CSVs** are placed in a "data" directory under the root of the project. They are named `${DEPARTMENT}-${TYPE}.csv` e.g. `ANIMA-course-titles.csv`. Most are just plain text lists but the "course-list-taxo" ones are more complicated and adhere to the upload format that the openEQUELLA taxonomy upload script necessitates.

**Logs** are made automatically for the most part and placed in a "logs" directory under the root of the project. They're of form `YYYY-MM-DD-${TYPE}.txt`, where a lack of a type specifier means it's from the main "upload-taxos-to-vault" script while the Syllabus and Architecture Division collections each have their own logs.

## Using Python 2.7

The [EQUELLA SOAP API scripts](https://github.com/openequella/openequella.github.io/tree/master/example-scripts/SOAP/python) mentioned under requirements were written for Python 2 and probably will never be updated to Python 3. Python 2 no longer ships with MacOS and is not in homebrew. We can still install a 2.7.x version from the Python website's [Downloads](https://www.python.org/downloads/) page, however.

If we try to run the project without addressing SSL certs, we'll run into an error:

```sh
Traceback (most recent call last):
  File "/Users/ephetteplace/bin/uptaxo", line 132, in <module>
    equella = equellasoap.EquellaSoap(institutionUrl, username, password, proxyUrl)
  File "/Users/ephetteplace/bin/equellasoap.py", line 54, in __init__
    self.login(username, password)
  File "/Users/ephetteplace/bin/equellasoap.py", line 126, in login
    ('password', STRING, password),
  File "/Users/ephetteplace/bin/equellasoap.py", line 89, in _call
    raise Exception, errMsg
Exception: Connection error:
*******************
 [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed (_ssl.c:727)
*******************
```

There is an "Install Certificates.command" script included under /Applications/Python2.7 but it does not work. I resolved the SSL verification error by linking my system certs into one of the path's where Python's `ssl` library is looking: `ln -s /etc/ssl/cert.pem /Library/Frameworks/Python.framework/Versions/2.7/etc/openssl/`. There may be a better solution—there are Stack Overflow posts that talk about modifying the `urllib` calls to avoid verification in the code, which seems much worse—but this one worked.

## LICENSE

[ECL Version 2.0](https://opensource.org/licenses/ECL-2.0)
