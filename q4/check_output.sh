#!/usr/bin/env bash

# n = 1
ruby main.rb 1 3 10 > check_output.csv

if cmp -s check_output.csv output.csv; then
    echo 'n=1 success'
else
    echo 'n=1 failed'
fi

rm check_output.csv

# n = 2
ruby main.rb 2 3 10 > check_output2.csv

if cmp -s check_output2.csv output2.csv; then
    echo 'n=2 success'
else
    echo 'n=2 failed'
fi

rm check_output2.csv
