#!/bin/bash

temp="$(mktemp -d)"
trap "rm -rf '$temp'" EXIT
>&2 echo "temp directory: $temp"

>&2 echo -n "extracting csv.tar.gz..."
tar zxf csv.tar.gz -C "$temp"
>&2 echo " done"

>&2 echo -n "consolidating raw .csv files..."
rdmd consolidate.d "$temp"
>&2 echo " done"
