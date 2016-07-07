#!/usr/bin/env bash

CSV_FILE=mauna-loa-co₂.csv
JSON_FILE=mauna-loa-co₂-latest.json

ruby ./noa₂co₂.rb > tmp.csv
mv tmp.csv $CSV_FILE
git add $CSV_FILE $JSON_FILE
git commit -m "Daily update"
git push
