#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo "3 arguments are expected, <repo_url> <original_url> <path>"
    exit 1
fi

prj_dir="/projects"
repo_url="$1"
original_url="$2"
path="$3"
repo="$(echo "${repo_url}" | cut  -d '@' -f 2)"

if [[ -d "${prj_dir}/${path}" ]]; then
    echo "🔕 ${repo} was already cloned to ${prj_dir}/${path}"
    exit 0
fi

echo "🔧 Cloning ${repo} to ${prj_dir}/${path}"
if git clone "${repo_url}" "${prj_dir}/${path}"; then
    echo "✅ ${repo} cloned successfully to ${prj_dir}/${path}"
    cd "${prj_dir}/${path}"
    chown -R ipetrov:ipetrov .
    git remote add upstream "${original_url}" 
    git fetch upstream main
    git branch --set-upstream-to=upstream/main main
    echo "🔗 Added upstream remote: ${original_url}"
    cd /root
else
    echo "❌ Failed to clone ${repo_url} to ${prj_dir}/${path}"
    exit 1
fi
