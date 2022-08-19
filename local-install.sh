#!/bin/bash -x

PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "#### >>>> $0: PROJ_DIR: ${PROJ_DIR}"

echo "-------------------------------------------"
echo "---- 0.B) APP: GIT: Source code:  setup: ----"
echo "-------------------------------------------"
APP_HOME=${APP_HOME:-${PROJ_DIR}/app}
if [ ! -s ${APP_HOME} ]; then
    mkdir -p ${APP_HOME}
fi

cd ${APP_HOME}

echo "------------------------------------------------"
echo "---- 0.C) Install requirements:             ----"
echo "------------------------------------------------"
DOCKER_RUN=1
if [ "${DOCKER_HOST_IP}" == "" ]; then
    DOCKER_RUN=0
fi

echo
echo "#### >>>> $0: CURR_DIR: `pwd`"
echo

YOLO_GIT=${YOLO_GIT:-https://github.com/DrSnowbird/yolov5.git}
#YOLO_GIT=${YOLO_GIT:-https://github.com/ultralytics/yolov5.git}

if [ ! -s ${APP_HOME}/.git ]; then
    echo -e "#### >>>>  YOLO_GIT= ${YOLO_GIT}"
    git clone ${YOLO_GIT} ${APP_HOME}
    pip install -r ${APP_HOME}/requirements.txt 
fi
if [ ${DOCKER_RUN} -lt 1 ]; then
  
    if [ ! -s ${APP_HOME}/.git ]; then
        echo -e "#### >>>>  YOLO_GIT= ${YOLO_GIT}"
        git clone ${YOLO_GIT} ${APP_HOME}
        pip install -r ${APP_HOME}/requirements.txt
    fi
    echo 
    echo -e ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> Customized Install requirements: >>>>>>>>>>>>>>>>>>>>>>>>>>>>> "
    echo
    if [ -s ${PROJ_DIR}/requirements.txt ]; then
        pip install -r ${PROJ_DIR}/requirements.txt
    fi
    if [ -s ${APP_HOME}/requirements.txt ]; then
        pip install -r ${APP_HOME}/requirements.txt
    fi
    if [ -s ${APP_HOME}/customized/requirements.txt ]; then
        pip install -r ${APP_HOME}/customized/requirements.txt
    fi
fi
