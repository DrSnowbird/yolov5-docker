# Instruction - Run without Container
This mode of running is for running without Container
# pre-requsits
1. Python 3.8
2. GPU access: You need to setup proper Nvidia Driver and CUDA libraries. Please see Nvidia website for guides.
# Steps - to Run
1. 'make install': to install Python3 modules needed by this yolov5-docker
2. Copy you images, videos to the folder './images'
3. './run-detect.sh': to run the detection
4. Output will be in "./runs" folder.
