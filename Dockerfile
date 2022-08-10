# Start FROM Nvidia PyTorch image https://ngc.nvidia.com/catalog/containers/nvidia:pytorch
#FROM nvcr.io/nvidia/pytorch:22.06-py3
#FROM python:3.8.8
FROM openkbs/python-nonroot-docker

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

###############################
#### ---- App: (ENV)  ---- ####
###############################
USER ${USER:-developer}
WORKDIR ${HOME:-/home/developer}

ENV APP_HOME=${APP_HOME:-$HOME/app}
ENV APP_MAIN=${APP_MAIN:-setup.sh}
ENV PATH=${HOME}/.local/bin:${PATH}

#################################
#### ---- App: (common) ---- ####
#################################
WORKDIR ${APP_HOME}
RUN python -u -m pip install --upgrade pip

###############################
#### ---- App Setup:  ---- ####
###############################
RUN sudo chown -R $USER:$USER ${APP_HOME}
RUN git clone https://github.com/ultralytics/yolov5.git ${APP_HOME} && ls -al ${APP_HOME}
RUN if [ -s ${APP_HOME}/requirements.txt ]; then \
        python -m pip install --upgrade pip ; \
        pip install --no-cache-dir --user -r ${APP_HOME}/requirements.txt ; \
    fi; 

# Install linux packages
RUN sudo apt update && sudo apt install -y vim zip htop screen libgl1-mesa-glx
#RUN pip uninstall -y nvidia-tensorboard nvidia-tensorboard-plugin-dlprof

#####################################
##### ---- user: developer ---- #####
#####################################
WORKDIR ${APP_HOME}
USER ${USER}

#############################################
#############################################
#### ---- App: (Customization here) ---- ####
#############################################
#############################################
#### (you customization code here!) #########
COPY --chown=$USER:$USER run-detect.sh ${APP_HOME}
COPY --chown=$USER:$USER ./requirements.txt ${HOME}
RUN if [ -s ${HOME}/requirements.txt ]; then \
        pip install --no-cache-dir --user -r ${HOME}/requirements.txt ; \
    fi; 


# Default run-detect.sh (It will detect the existence of ./customized/run-detect.sh, then run it instead)
#CMD ["/usr/src/app/run-detect.sh"]
CMD ["/home/developer/app/run-detect.sh"]
