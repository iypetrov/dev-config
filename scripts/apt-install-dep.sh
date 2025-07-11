#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "1 argument is expected, it should be the name of the package to install."
    exit 1
fi

dep="$1"

if dpkg -s "${dep}" &>/dev/null; then
    echo "🔕 Skip installing \"${dep}\" dependency, already available"
else
    echo "🔧 Installing \"${dep}\" dependency"
    if apt install -y "${dep}"; then
        echo "✅ \"${dep}\" dependency installed successfully"
    else
        echo "❌ \"${dep}\" dependency failed to install"
    fi
fi
