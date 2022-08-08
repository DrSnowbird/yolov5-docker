#!/bin/bash

echo "------------------------------------------------"
echo "---- 1. CUSTIMIZED: SCRIPTS: DETECT: setup: ----"
echo "------------------------------------------------"
CUSTOMIZED_DETECT_BASH=${CUSTOMIZED_DETECT_BASH:-./customized/run-detect.sh}
if [ -s ${CUSTOMIZED_DETECT_BASH} ]; then
    echo "Found customized run-detect.sh found, use it instead of this..."
    #cd ./customized
    #./run-detect.sh
    ${CUSTOMIZED_DETECT_BASH} "$@"
    exit 0
else
    echo "... NOT FOUND: './customized/run-detect.sh' script found -- USE Demo script: './run-detect.sh' ..."
fi

echo "-------------------------------------------"
echo "---- 2. INPUT: WEIGHTS: FOLDER: setup: ----"
echo "-------------------------------------------"
echo ">>>> DEMO: using ${WEIGHTS_URL} Weights (trained model) ...."
WEIGHTS_URL=${WEIGHTS_URL:-https://github.com/ultralytics/yolov5/releases/download/v6.1/yolov5s.pt} 
WEIGHTS_DIRECTORY=./weights/
WEIGHTS=${WEIGHTS_DIRECTORY}$(basename $WEIGHTS_URL) # yolov5s.pt
if [ ! -s ${WEIGHTS} ]; then
    echo ">>>> DOWNLOAD: Yolo pre-trained Model weights-and-bias: ${WEIGHTS_URL}"
    wget -c -P ${WEIGHTS_DIRECTORY} ${WEIGHTS_URL}
else
    echo ">>>> FOUND: Yolo pre-trained Model weights-and-bias: ${WEIGHTS}"
fi
echo "INPUT: WEIGHTS: FOLDER: ${WEIGHTS}"

echo "--------------------------------------"
echo "---- 3. INPUT: CONFIDENCE: setup: ----"
echo "--------------------------------------"
CONFIDENCE=${CONFIDENCE:-0.50}
echo "INPUT: OUPUT: CONFIDENCE: ${CONFIDENCE}"

echo "------------------------------------------"
echo "---- 4. INPUT: IMAGES: FOLDER: setup: ----"
echo "------------------------------------------"
echo ">>>> INPUT: IMAGES: FOLDER: ${SOURCE_IMAGES}"
echo ".... INPUT: IMAGES: CHECK: Any files in it? ...."
MY_SOURCE_IMAGES=${SOURCE_IMAGES}
if [ -n "$(ls -A ${SOURCE_IMAGES} 2>/dev/null)" ]; then
   echo ".... INPUT: IMAGES: FOUND: ${SOURCE_IMAGES}: Not empty: OK to use."
else
    # no files in it
    echo ".... INPUT: IMAGES: NOT FOUND: ${SOURCE_IMAGES} ! Use the 1st alternative folder: ./images/ (if not empty)"
    if [ ${SOURCE_IMAGES} != "./image" ] && [ -n "$(ls -A ./images 2>/dev/null)" ]; then
        SOURCE_IMAGES=./images
        echo ">>>> INPUT: IMAGES: FOUND: ${SOURCE_IMAGES}: Not empty: OK to use."
    else
        echo ".... INPUT: IMAGES: NOT FOUND: ./images ! Use the 2nd alternative folder: ./data/images/ (if not empty)" 
        SOURCE_IMAGES=./data/images
        if [ -n "$(ls -A ./data/images 2>/dev/null)" ]; then
            echo ">>>> INPUT: IMAGES: FOUND: ${SOURCE_IMAGES}: Not empty: OK to use."
        else
            echo "**** ERROR: Can't find any images files in: ${MY_SOURCE_IMAGES}, './images', or './data/images' folders! ABORT!"
            exit 1
        fi
    fi
fi
echo "INPUT: IMAGES: FOLDER:: ${SOURCE_IMAGES}"

echo "----------------------------------------"
echo "---- 5. OUTPUT: RUN: FOLDER: setup: ----"
echo "----------------------------------------"
## ---- Output directories setup: ---- ##
# -- outputs in <MY_PROJECT>/<MY_NAME>
MY_PROJECT=${MY_PROJECT:-runs/detect}
MY_NAME=${MY_NAME:-exp}
echo "OUTPUT: RUN: FOLDER: ${MY_PROJECT}/${MY_NAME}"

echo "----------------------------------------"
echo "---- 6. DETECT: IMAGES: RUN: setup: ----"
echo "----------------------------------------"

set -x

# """
# Run inference on images, videos, directories, streams, etc.
#
# Usage - sources:
#     $ python path/to/detect.py --weights yolov5s.pt --source 0              # webcam
#                                                              img.jpg        # image
#                                                              vid.mp4        # video
#                                                              path/          # directory
#                                                              path/*.jpg     # glob
#                                                              'https://youtu.be/Zgi9g1ksQHc'  # YouTube
#                                                              'rtsp://example.com/media.mp4'  # RTSP, RTMP, HTTP stream
# 
# Usage - formats:
#     $ python path/to/detect.py --weights yolov5s.pt                 # PyTorch
#                                          yolov5s.torchscript        # TorchScript
#                                          yolov5s.onnx               # ONNX Runtime or OpenCV DNN with --dnn
#                                          yolov5s.xml                # OpenVINO
#                                          yolov5s.engine             # TensorRT
#                                          yolov5s.mlmodel            # CoreML (macOS-only)
#                                          yolov5s_saved_model        # TensorFlow SavedModel
#                                          yolov5s.pb                 # TensorFlow GraphDef
#                                          yolov5s.tflite             # TensorFlow Lite
#                                          yolov5s_edgetpu.tflite     # TensorFlow Edge TPU
# """
#     parser.add_argument('--weights', nargs='+', type=str, default=ROOT / 'yolov5s.pt', help='model path(s)')
#     parser.add_argument('--source', type=str, default=ROOT / 'data/images', help='file/dir/URL/glob, 0 for webcam')
#     parser.add_argument('--data', type=str, default=ROOT / 'data/coco128.yaml', help='(optional) dataset.yaml path')
#     parser.add_argument('--imgsz', '--img', '--img-size', nargs='+', type=int, default=[640], help='inference size h,w')
#     parser.add_argument('--conf-thres', type=float, default=0.25, help='confidence threshold')
#     parser.add_argument('--iou-thres', type=float, default=0.45, help='NMS IoU threshold')
#     parser.add_argument('--max-det', type=int, default=1000, help='maximum detections per image')
#     parser.add_argument('--device', default='', help='cuda:device, i.e. 0 or 0,1,2,3 or cpu')
#     parser.add_argument('--view-img', action='store_true', help='show results')
#     parser.add_argument('--save-txt', action='store_true', help='save results to *.txt')
#     parser.add_argument('--save-conf', action='store_true', help='save confidences in --save-txt labels')
#     parser.add_argument('--save-crop', action='store_true', help='save cropped prediction boxes')
#     parser.add_argument('--nosave', action='store_true', help='do not save images/videos')
#     parser.add_argument('--classes', nargs='+', type=int, help='filter by class: --classes 0, or --classes 0 2 3')
#     parser.add_argument('--agnostic-nms', action='store_true', help='class-agnostic NMS')
#     parser.add_argument('--augment', action='store_true', help='augmented inference')
#     parser.add_argument('--visualize', action='store_true', help='visualize features')
#     parser.add_argument('--update', action='store_true', help='update all models')
#     parser.add_argument('--project', default=ROOT / 'runs/detect', help='save results to project/name')
#     parser.add_argument('--name', default='exp', help='save results to project/name')
#     parser.add_argument('--exist-ok', action='store_true', help='existing project/name ok, do not increment')
#     parser.add_argument('--line-thickness', default=3, type=int, help='bounding box thickness (pixels)')
#     parser.add_argument('--hide-labels', default=False, action='store_true', help='hide labels')
#     parser.add_argument('--hide-conf', default=False, action='store_true', help='hide confidences')
#     parser.add_argument('--half', action='store_true', help='use FP16 half-precision inference')
#     parser.add_argument('--dnn', action='store_true', help='use OpenCV DNN for ONNX inference')

# Performance: GPU about 10~100 times faster than CPU:
python detect.py --source ${SOURCE_IMAGES} --weights ${WEIGHTS} --conf-thres ${CONFIDENCE} --save-txt --save-conf
# CPU
#python detect.py --source ${SOURCE_IMAGES} --device cpu --weights ${WEIGHTS} --conf-thres ${CONFIDENCE} --save-txt --save-conf

# JSON - not works (to-do: modify detect.py to support JSON)
#python detect.py --source ${SOURCE_IMAGES} --weights ${WEIGHTS} --conf ${CONFIDENCE} --save-json

set +x
