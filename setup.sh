#!/bin/bash

####################################################################
#### ---- setup.sh: for application                        ---- ####
####################################################################

set -e
env

#### ---------------------------------------------
#### --- APP: Type: python, java, nodejs, etc. --- 
#### ---------------------------------------------
#### MANDATORY: ONLY choose one here
PROGRAM_TYPE="py"
#PROGRAM_TYPE="java"
#PROGRAM_TYPE="js"

# -- debug use only --
verify=1

# -------------------------------
# ----------- Usage -------------
# -------------------------------
# To test on host machine:
# Run the Application:
#   ./setup.sh
# -------------------------------
echo ">>> PWD=$PWD"
echo ">>> APP_HOME=${APP_HOME}"

#### ---------------------
#### --- APP: LOCATION ---
#### ---------------------
if [ ! -s ${APP_HOME} ]; then
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    if [[ "$DIR" =~ "/app$" ]]; then
        APP_HOME=${DIR}
    else
        # - find possilbe app directory:
        if [ -s ${HOME}/app ]; then
            APP_HOME=${HOME}/app
	else
            APP_HOME=`realpath $(find ./ -name app)`
	    if [ "$APP_HOME" != "" ] && [ -s $APP_HOME ]; then
                echo ">>> Found APP_HOME=${APP_HOME}"
	    else
		echo "*** ERROR: Can't find APP_HOME: Abort!"
		exit 9
	    fi
	fi
    fi
fi

#### ---------------------------
#### --- APP: UTILITY        --- 
#### ---------------------------
function verifyDirectory() {
    if [ $verify -eq 0 ]; then
        return
    fi
    if [ "$1" = "" ] || [ ! -d "$1" ]; then
        echo "*** ERROR ***: NOT_EXISTING: App's mandatory directory: $1: Can't continue! Abort!"
        exit 1
    fi
}

function verifyFile() {
    if [ $verify -eq 0 ]; then
        return
    fi
    if [ "$1" != "" ] && [ ! -s "$1" ]; then
        echo "*** ERROR ***: NOT_FOUND: App's mandatory file: $1: Can't continue! Abort!"
        exit 1
    fi
}

function verifyCommand() {
    if [ $verify -eq 0 ]; then
        return
    fi
    if [ "$1" == "" ]; then
        return
    fi
    if [ "$1" == "cmd" ] || [ "$1" == "exec" ]; then
        return
    fi
    if [ ! `which $1` ]; then
        echo "*** ERROR ***: NOT_FOUND: App's mandatory tool: $1: Can't continue! Abort!"
        exit 1
    fi
}

function runCommands() {
    if [ $verify -eq 0 ]; then
        return
    fi
    CD_CMD=$1
    EXE_CMD=$2
    if [ "$1" != "" ] && [ -d "$1" ]; then
        cd $1
        shift
    fi
    if [ "$2" != "" ]; then
        /bin/bash -c "$*"
    fi
}

APP_RUN_EXE="node"
function setRunnerExe() {
    case "${PROGRAM_TYPE}" in 
        *java)
            APP_RUN_EXE=java
            ;;
        *js)
            APP_RUN_EXE=node
            ;;
        *py)
            APP_RUN_EXE=python
            ;;
    esac
}
setRunnerExe
echo ">>>>>>>APP_RUN_EXE=$APP_RUN_EXE"
echo ">>>>>>>APP_RUN_CMD=$APP_RUN_CMD"
verifyCommand ${APP_RUN_CMD%% *}

# -------------------------------------------------------------------------------------

### --- APP: SETUP ---
#APP_HOME=${APP_HOME:-$HOME/app}
APP_HOME=${APP_HOME:-${DIR}}

### --- APP: RUN ---
APP_RUN_DIR=${APP_RUN_DIR:-$APP_HOME}
if [ "$PP_RUN_MAIN" != "" ]; then
    APP_RUN_MAIN_base=$(basename $APP_RUN_MAIN)
    APP_RUN_MAIN_dir=$(dirname $APP_RUN_MAIN)
    if [ ${APP_RUN_MAIN_dir} = "." ] || [ ${APP_RUN_MAIN_dir} = "" ]; then
        APP_RUN_MAIN_dir=${APP_RUN_DIR}
        echo "    >>>> APP_RUN_DIR=${APP_RUN_DIR}"
        echo "    >>>> APP_RUN_MAIN_dir=${APP_RUN_MAIN_dir}"
        echo "    >>>> APP_RUN_MAIN_base=${APP_RUN_MAIN_base}"
    fi
fi
echo "(final)>>> APP_RUN_DIR=$APP_RUN_DIR"

if [ "$APP_RUN_CMD" = "" ]; then
    # Need to check APP_RUN_MAIN defined or not
    if [ "$APP_RUN_MAIN_base" = "" ]; then
        ## AUTO-detection/finding of runnable main program Need to detect main python as best efforts or error out
        #echo "*** ERROR: Neither APP_RUN_CMD nor APP_RUN_MAIN defined! Abort!"
        #exit 1
        # --- Auto detection and pick the first Python with main() to run --
        ABS_APP_DIR="${APP_RUN_DIR%app*}app" 
        echo "ABS_APP_DIR=$ABS_APP_DIR"
        FOUND_PROGRAM=`ls ${ABS_APP_DIR}/*.${PROGRAM_TYPE} | head -n 1 | awk '{print $1}' `
        if [ "$FOUND_PROGRAM" != "" ]; then
            APP_RUN_DIR=$(dirname $FOUND_PROGRAM)
            APP_RUN_MAIN=$FOUND_PROGRAM
            APP_RUN_CMD="${APP_RUN_EXE} ${APP_RUN_MAIN}"
            echo ">>> Auto detect (in app/) APP_RUN_DIR : $APP_RUN_DIR"
            echo ">>> Auto detect (in app/) APP_RUN_MAIN: $APP_RUN_MAIN"
            echo ">>> Auto detect (in app/) APP_RUN_CMD : $APP_RUN_CMD"
        else
            echo "*** ERROR ***: FAIL: Can't find any Python to run! Abort"
            exit 1
        fi
    else
        echo "--> APP_RUN_MAIN_base: ${APP_RUN_MAIN_base} will be used to launch Python as main."
        echo ">>> Given (in .env) APP_RUN_DIR : $APP_RUN_DIR"
        echo ">>> Given (in .env) APP_RUN_MAIN: $APP_RUN_MAIN"
        echo ">>> Given (in .env) APP_RUN_CMD : $APP_RUN_CMD"
        APP_RUN_CMD="python3 ${APP_RUN_MAIN}"
    fi
else
    echo "--> APP_RUN_CMD: ${APP_RUN_CMD} will be used to launch Python as main."
    echo ">>> Given (in .env) APP_RUN_DIR : $APP_RUN_DIR"
    echo ">>> Given (in .env) APP_RUN_MAIN: $APP_RUN_MAIN"
    echo ">>> Given (in .env) APP_RUN_CMD : $APP_RUN_CMD"
fi

verifyDirectory $APP_HOME
verifyDirectory $APP_RUN_DIR
verifyFile $APP_RUN_MAIN

#### ---- Application ----
cd ${APP_RUN_DIR} 
ls -al 

function run_2nd__cmd() {
    #### ---- RUN Flask REST Server: ----
    # APP_RUN_2nd_CMD=FLASK_OR_GRADIO=flask python3 flask_server.py
    #  APP_RUN_2nd_CMD="FLASK_OR_GRADIO=flask && python3 text-summary-gradio.py"
    runCommands ${APP_RUN_DIR} ${APP_RUN_2nd_CMD}
    sleep 5
}
if [[ -v APP_RUN_2nd_CMD ]] ; then
    run_2nd__cmd &
fi

# FLASK_OR_GRADIO=flask && python3 text-summary-gradio.py
# FLASK_OR_GRADIO=gradio && python3 text-summary-gradio.py

#### ---- RUN Application ----
## e.g. Java Jar file
## cd ${APP_HOME}/dist && java -jar my_jar.jar
runCommands ${APP_RUN_DIR} ${APP_RUN_CMD}

#
## Wait for any process to exit
#wait -n
#
## Exit with status of process that exited first
#exit $?
