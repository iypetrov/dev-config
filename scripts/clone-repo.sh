#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "2 arguments are expected, <repo_url> <path>"
    exit 1
fi

prj_dir="/root/projects"
repo_url="$1"
path="$2"

if [[ -d "${prj_dir}/${path}" ]]; then
  echo "🔕 ${repo_url} was already cloned to ${prj_dir}/${path}"
  exit 0
fi

echo "🔧 Cloning ${repo_url} to ${prj_dir}/${path}"
if git clone "${repo_url}" "${prj_dir}/${path}"; then
    echo "✅ ${repo_url} cloned successfully to ${prj_dir}/${path}"
else
    echo "❌ Failed to clone ${repo_url} to ${prj_dir}/${path}"
    exit 1
fi
