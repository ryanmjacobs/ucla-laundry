#!/bin/bash

while true; do
    if ./app.js | grep ^7, | grep available; then
        smass do laundry boiii
    else
        smass do NOT laundry boiii
    fi
    sleep 60
done
