#!/usr/bin/env bash

RVM_PATH=`rvm env --path -- ruby-version[@gemset-name]`
source $RVM_PATH

CSV_FILE=mauna-loa-co₂.csv

ruby ./noa₂co₂.rb > tmp.csv
mv tmp.csv $CSV_FILE
git add $CSV_FILE
git commit -m "Daily update"
