#!/usr/bin/env bash

exists () {
    command -v "$1" 2&>/dev/null
}

# https://brew.sh/
exists brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
exists mise || brew install mise
mise install

exists fish || brew install fish
exists jq || brew install jq
# csvkit doesn't install a utility named csvkit, pick a random one to test
exists csvjoin || brew install csvkit

exists eq || npm i -g equella-cli

# python scripts
echo "Installing Python scripts to ~/bin — ensure that directory is on your PATH"
mkdir -p ~/bin

if ! test -e ~/bin/uptaxo; then
    wget -O ~/bin/uptaxo https://gist.githubusercontent.com/phette23/9bec679b7b677af7e396e8a40e7a7047/raw/171af0a5dcaefff5bc3d0281faf3ed4183674495/uptaxo.py
    chmod +x ~/bin/uptaxo
fi
if ! test -e ~/bin/equellasoap.py; then
    wget -O ~/bin/equellasoap.py https://raw.githubusercontent.com/openequella/openequella.github.io/master/example-scripts/SOAP/python/equellasoap.py
fi
if ! test -e ~/bin/util.py; then
    wget -O ~/bin/util.py https://raw.githubusercontent.com/openequella/openequella.github.io/master/example-scripts/SOAP/python/util.py
fi

exists python2 || echo "You might need to install Python 2.7 yourself: https://www.python.org/downloads/"
