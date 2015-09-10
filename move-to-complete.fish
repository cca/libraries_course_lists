#!/usr/bin/env fish

set today (date "+%Y-%m-%d")
mkdir -p "complete/$today"
mv data/* "complete/$today/"
