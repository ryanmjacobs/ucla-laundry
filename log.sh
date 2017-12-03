#!/bin/bash

mkdir -p csv

while true; do
    dt="$(date '+%F_%T')"
    ./app.js | tee csv/${dt}.csv
    sleep 60
done
