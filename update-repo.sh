#!/usr/bin/env bash

CSV_FILE=mauna-loa.csv
JSON_FILE=mauna-loa-latest.json

git add $CSV_FILE $JSON_FILE
git commit -m "Daily update"
git push
