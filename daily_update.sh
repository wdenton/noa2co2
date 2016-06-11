#!/usr/bin/env bash

CSV_FILE=mauna-loa-co₂.csv

ruby ./noa₂co₂.rb > tmp.csv
mv tmp.csv $CSV_FILE
git add $CSV_FILE
git commit -m "Daily update"
