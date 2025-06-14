#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "1 argument is expected, it should be the name of the package to install."
    exit 1
fi

dep="$1"

if which "${dep}" > /dev/null 2>&1; then
	echo "🔕 Skip isntalling ${dep} dependency, already available"
else
    echo "🔧 Installing ${dep} dependency"
    if apt install -y "${dep}"; then
        echo "✅ ${cmd} dependency installed successfully"
    else
        echo "❌ ${cmd} dependency failed to install"
    fi
fi
