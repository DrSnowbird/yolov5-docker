# Start FROM Nvidia PyTorch image https://ngc.nvidia.com/catalog/containers/nvidia:pytorch
#FROM nvcr.io/nvidia/pytorch:22.06-py3
#FROM python:3.8.8
#FROM openkbs/python-nonroot-docker
FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-runtime

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

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

###################################
#### ---- user: developer ---- ####
###################################
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}
ENV USER=${USER:-developer}
ENV HOME=/home/${USER}
ENV WORKSPACE=${HOME}/workspace

ENV LANG C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends sudo curl vim git ack wget unzip ca-certificates && \
    useradd -ms /bin/bash ${USER} && \
    export uid=${USER_ID} gid=${GROUP_ID} && \
    mkdir -p /home/${USER} && \
    mkdir -p /home/${USER}/workspace && \
    mkdir -p /etc/sudoers.d && \
    echo "${USER}:x:${USER_ID}:${GROUP_ID}:${USER},,,:/home/${USER}:/bin/bash" >> /etc/passwd && \
    echo "${USER}:x:${USER_ID}:" >> /etc/group && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    chown -R ${USER}:${USER} /home/${USER} && \
    apt-get autoremove; \
    rm -rf /var/lib/apt/lists/* && \
    echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf

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
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
#ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64
#VOLUMES_LIST="/usr/local/cuda/lib64:/usr/local/cuda/lib64 /usr/local/cudnn/lib64:/usr/local/cudnn/lib64 

COPY --chown=$USER:$USER ./requirements.txt ${HOME}
RUN if [ -s ${HOME}/requirements.txt ]; then \
        pip install --no-cache-dir --user -r ${HOME}/requirements.txt ; \
    fi; 

COPY --chown=$USER:$USER app ${APP_HOME}
#RUN git clone https://github.com/DrSnowbird/yolov5.git ${APP_HOME} && ls -al ${APP_HOME}
#RUN git clone https://github.com/ultralytics/yolov5.git ${APP_HOME} && ls -al ${APP_HOME}
RUN if [ -s ${APP_HOME}/requirements.txt ]; then \
        python -m pip install --upgrade pip ; \
        pip3 install --no-cache-dir --user -r ${APP_HOME}/requirements.txt ; \
        pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu116 ; \
    fi; 

#### ---
RUN sudo apt-get update -y && sudo apt-get -y install libglib2.0-0 libgl1-mesa-glx
# PyTorch+cuda: https://pytorch.org/get-started/locally/

# Install linux packages
#RUN sudo apt update -y && sudo apt install -y vim zip htop screen libgl1-mesa-glx
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
#COPY --chown=$USER:$USER ./requirements.txt ${HOME}
#RUN if [ -s ${HOME}/requirements.txt ]; then \
#        pip install --no-cache-dir --user -r ${HOME}/requirements.txt ; \
#    fi; 


# Default run-detect.sh (It will detect the existence of ./customized/run-detect.sh, then run it instead)
#CMD ["/usr/src/app/run-detect.sh"]
CMD ["/home/developer/app/run-detect.sh"]
