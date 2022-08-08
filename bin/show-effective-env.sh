#!/bin/bash

################################ Usage #######################################

## ---------- ##
## -- main -- ##
## ---------- ##

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

PROJ_DIR=$(dirname $DIR)

cd ${PROJ_DIR}

ENV_FILES=".env .env.template"
for f in $ENV_FILES; do
    echo "------------------ $f : --------------------"
    cat $f |grep -v "^##\|^# " |grep -v "^$"
done
