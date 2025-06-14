#!/bin/bash

if [[ -d "${prj_dir}/common/vault" ]]; then
  echo "🔕 Auth setup was already done"
  exit 0
fi
