#!/usr/bin/env bash

ruby main.rb > check_output.csv

if cmp -s check_output.csv output.csv; then
    echo 'success'
else
    echo 'failed'
fi

rm check_output.csv
