##### Usage:  docker buildx build --target=artifact --output type=local,dest=$(pwd)/out/ .


FROM nvidia/cuda:11.6.0-devel-ubuntu20.04 as build

#ARG DEBIAN_FRONTEND=noninteractive
ARG OPENCV_VERSION=4.5.5
ARG ENABLE_CONTRIB=1
ARG ENABLE_HEADLESS=1

ARG CMAKE_ARGS="-DWITH_CUDA=ON -DWITH_CUDNN=ON -DOPENCV_DNN_CUDA=ON -DWITH_CUBLAS=ON -DWITH_QT=ON -DWITH_GTK=ON"

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt-get upgrade -y &&\
    apt-get install -y \
	python3-pip \
        git \
        libcudnn8 \
        libcudnn8-dev

ARG LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

RUN git clone --recursive https://github.com/opencv/opencv-python.git
WORKDIR /opencv-python
RUN cd /opencv-python
RUN pip wheel /opencv-python --verbose


FROM nvidia/cuda:11.6.0-devel-ubuntu20.04
LABEL org.opencontainers.image.authors="orrious"

COPY --from=build /opencv/*.whl /tmp/.
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt-get upgrade -y &&\
    apt-get install -y \
	python3-pip \
    libcudnn8 \
    libgtk2.0-0 \
    libavcodec-extra \
    ffmpeg

RUN pip3 install /tmp/*.whl
RUN pip3 install torch torchvision --extra-index-url https://download.pytorch.org/whl/cu113
RUN pip3 install matplotlib pandas tqdm
RUN pip3 install --no-deps detecto