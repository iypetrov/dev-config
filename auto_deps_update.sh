#!/bin/bash

jq -r '.packages[] | split("@")[0]' devbox.json | while IFS= read -r dep; do
    latest_version="$(devbox search "${dep}" | grep -E "^\* ${dep}  " | sed 's/^[^(]*(//' | tr -d , | awk '{print $1}')"
    echo "${dep} -> ${latest_version}"
    sed -i "s#\"${dep}@[^\"]*\"#\"${dep}@${latest_version}\"#g" devbox.json
done
