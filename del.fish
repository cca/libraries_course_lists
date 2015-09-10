#!/usr/bin/env fish
set --local depts (csvcut -c 2 data/2015-09-09-informer.csv | tail -n +2 | sort | uniq)

for dept in $depts
    # course titles
    set uuid (eq tax --name "$dept - course titles" | jq -r '.uuid')
    set term (eq tax "$uuid/term" | grep -C 4 'Animation 1' | tail -n 7 | sed -e 's/\},/}/' | jq -r '.uuid')
    if [ -z $term ]
        echo "deleting ANIMA-100 from $dept taxo"
        eq tax --method del "$uuid/term/$term"
    end

    # faculty names
    set uuid (eq tax --name "$dept - faculty" | jq -r '.uuid')
    set term (eq tax "$uuid/term" | grep -C 4 'Edward Gutierrez' | tail -n 7 | sed -e 's/\},/}/' | jq -r '.uuid')
    if [ -z $term ]
        echo "deleting ANIMA-100 from $dept taxo"
        eq tax --method del "$uuid/term/$term"
    end

    # course names e.g. INDIV-101
    set uuid (eq tax --name "$dept - course names" | jq -r '.uuid')
    set term (eq tax "$uuid/term" | grep -C 4 'ANIMA-100' | tail -n 7 | sed -e 's/\},/}/' | jq -r '.uuid')
    if [ -z $term ]
        echo "deleting ANIMA-100 from $dept taxo"
        eq tax --method del "$uuid/term/$term"
    end

    # course sections
    set uuid (eq tax --name "$dept - course sections" | jq -r '.uuid')
    set term (eq tax "$uuid/term" | grep -C 4 'ANIMA-100-01' | tail -n 7 | sed -e 's/\},/}/' | jq -r '.uuid')
    if [ -z $term ]
        echo "deleting ANIMA-100 from $dept taxo"
        eq tax --method del "$uuid/term/$term"
    end
end
