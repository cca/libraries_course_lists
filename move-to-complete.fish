#!/usr/bin/env fish
# move all files in "data" dir to "complete/${date}" where date is today's date
set today (date "+%Y-%m-%d")
mkdir -p "complete/$today"
mv data/* "complete/$today/"
