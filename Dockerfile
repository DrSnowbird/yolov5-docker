# Start FROM Nvidia PyTorch image https://ngc.nvidia.com/catalog/containers/nvidia:pytorch
#FROM nvcr.io/nvidia/pytorch:22.10-py3
#FROM openkbs/python-nonroot-docker
#FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-runtime
#FROM nvidia/cuda:11.5.1-base-ubuntu20.04
#FROM nvidia/cuda:11.5.1-devel-ubuntu20.04
FROM pytorch/pytorch:latest

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

#### ---
ENV DEBIAN_FRONTEND noninteractive

##############################################
#### ---- Installation Directories   ---- ####
##############################################
ENV INSTALL_DIR=${INSTALL_DIR:-/usr}
ENV SCRIPT_DIR=${SCRIPT_DIR:-$INSTALL_DIR/scripts}

############################################
##### ---- System: certificates : ---- #####
##### ---- Corporate Proxy      : ---- #####
############################################
COPY ./scripts ${SCRIPT_DIR}
COPY certificates /certificates
RUN ${SCRIPT_DIR}/setup_system_certificates.sh
RUN ${SCRIPT_DIR}/setup_system_proxy.sh

######################################
#### ---- CERT setup: (ENV)  ---- ####
######################################
#CERT-trust-apt-install.sh
#CERT-trust-git-install.sh
#CERT-trust-pip-install.sh
RUN ${SCRIPT_DIR}/CERT-trust-apt-install.sh
ENV GIT_SSL_NO_VERIFY=${GIT_SSL_NO_VERIFY:-true}

###################################
#### ---- Utility:        ---- ####
###################################
RUN apt-get update -y && \
    apt-get -y install --no-install-recommends sudo curl vim git ack wget libglib2.0-0 libgl1-mesa-glx

###################################
#### ---- Python3:        ---- ####
###################################
RUN apt install python3 -y && apt install -y python3-pip

# TO copy and run add-user-sudo.sh

###################################
#### ---- user: developer ---- ####
###################################
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}
ENV USER=${USER:-developer}
ENV HOME=/home/${USER}
ENV WORKSPACE=${HOME}/workspace

ENV LANG C.UTF-8
RUN useradd -ms /bin/bash ${USER} && \
    mkdir -p /home/${USER} && \
    echo "${USER}:x:${USER_ID}:${GROUP_ID}:${USER},,,:/home/${USER}:/bin/bash" >> /etc/passwd && \
    echo "${USER}:x:${USER_ID}:" >> /etc/group && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && \
    chown -R ${USER}:${USER} /home/${USER} && \
    apt-get autoremove &&  \
    rm -rf /var/lib/apt/lists/* && \
    echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf

############################################
##### ---- System: certificates : ---- #####
##### ---- Corporate Proxy      : ---- #####
############################################
#COPY ./scripts ${SCRIPT_DIR}
#COPY certificates /certificates
#RUN ${SCRIPT_DIR}/setup_system_certificates.sh
#RUN ${SCRIPT_DIR}/setup_system_proxy.sh

###############################
#### ---- App: (ENV)  ---- ####
###############################
USER ${USER:-developer}

ENV APP_HOME=${APP_HOME:-$HOME/app}
ENV APP_MAIN=${APP_MAIN:-$HOME/setup.sh}
ENV PATH=${HOME}/.local/bin:${PATH}

#################################
#### ---- App: (common) ---- ####
#################################
RUN mkdir -p ${APP_HOME} && \
    sudo chown -R $USER:$USER ${APP_HOME} && \
    ls -al ${HOME} ${APP_HOME}

WORKDIR ${APP_HOME}

## ----------------------------
## Option-1: static yolov5 code
## ----------------------------
#COPY --chown=$USER:$USER app ${APP_HOME}

## ----------------------------
## Option-2: on-demain yolov5 code
## ----------------------------
## (optional-not safe: disable GIT SSL VERIFY)
RUN GIT_SSL_NO_VERIFY=true git clone https://github.com/DrSnowbird/yolov5.git ${APP_HOME} && ls -al ${APP_HOME}
#RUN GIT_SSL_NO_VERIFY=true git clone https://github.com/ultralytics/yolov5.git ${APP_HOME} && ls -al ${APP_HOME}

RUN if [ -s ${APP_HOME}/requirements.txt ]; then \
        pip install -r ${APP_HOME}/requirements.txt ; \
    fi; 
#pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu116 ; \

###############################
#### ---- App Setup:  ---- ####
###############################
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
#ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64
#VOLUMES_LIST="/usr/local/cuda/lib64:/usr/local/cuda/lib64 /usr/local/cudnn/lib64:/usr/local/cudnn/lib64 

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
        pip install -r ${HOME}/requirements.txt ; \
    fi; 


# Default run-detect.sh (It will detect the existence of ./customized/run-detect.sh, then run it instead)
#CMD ["/usr/src/app/run-detect.sh"]
CMD ["/home/developer/app/run-detect.sh"]
