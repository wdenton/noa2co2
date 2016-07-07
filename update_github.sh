#!/usr/bin/env bash

CSV_FILE=mauna-loa-co₂.csv
JSON_FILE=mauna-loa-co₂-latest.json

git add $CSV_FILE $JSON_FILE
git commit -m "Daily update"
git push
