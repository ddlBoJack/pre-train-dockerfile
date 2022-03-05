FROM aegis1/cuda10.2-cudnn7-devel-ubuntu16.04

LABEL MAINTAINER="matrixzheng01@gmail.com"

USER root

# COPY vimrc /root/.vim_runtime
# COPY ninja-linux.zip / 
# COPY fairseq fairseq
# COPY Miniconda3-latest-Linux-x86_64.sh /root

RUN set -x \
    && cp /etc/apt/sources.list.bak  /etc/apt/sources.list \
    && apt update \
    && apt-get -y install wget curl man git less openssl libssl-dev unzip unar \
    && apt install -y openssh-server 

ENV OPENMPI_VERSION=4.0
ENV OPENMPI_STRING=openmpi-${OPENMPI_VERSION}.0
RUN mkdir /tmp/openmpi \
    && cd /tmp/openmpi \
    && wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.0.tar.gz \
    && tar zxf ${OPENMPI_STRING}.tar.gz \
    && cd ${OPENMPI_STRING} \
    && ./configure --enable-orterun-prefix-by-default --with-openib --prefix /usr/local/mpi \
    && make -j 4 all \
    && make install \
    && ldconfig \
    && rm -rf /tmp/openmpi \
    && test -f /usr/local/mpi/bin/mpic++ # Sanity check

ENV PATH /usr/local/mpi/bin:$PATH


RUN set -x \
    && apt -y install tmux \
    # && git config --global http.proxy http://127.0.0.1:7890 \
    && wget https://github.com/ninja-build/ninja/releases/download/v1.8.2/ninja-linux.zip \
    && unzip ninja-linux.zip -d /usr/local/bin/ \
    && rm -rf ninja-linux.zip \
    && update-alternatives --install /usr/bin/ninja ninja /usr/local/bin/ninja 1 --force \
    && git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime \
    && sh ~/.vim_runtime/install_awesome_vimrc.sh \
    && echo "set number" >> ~/.vimrc

ENV PATH /opt/conda/bin:$PATH

# RUN cd / \
    # && git clone git://github.com/pytorch/fairseq

RUN cd /root \
    && wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && sh Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm -f Miniconda3-latest-Linux-x86_64.sh \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && . /root/.bashrc \
    && conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ \
    && conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ \
    && conda config --set show_channel_urls yes \
    && conda create -n wav2vec python=3.8 -y \
    && conda activate wav2vec \
    && conda install numpy matplotlib scipy -y \
    # install fairseq
    && cd / \
    && git clone git://github.com/pytorch/fairseq \
    && cd fairseq \
    && pip install --editable ./

# install flashlight
RUN apt update \
    && apt install build-essential cmake libboost-system-dev libboost-thread-dev libboost-program-options-dev libboost-test-dev libeigen3-dev zlib1g-dev libbz2-dev liblzma-dev libnss3 libgtk-3-0 libglib2.0 xdg-utils libopenblas-dev -y \
    && cd home \
    && mkdir repo \
    && cd repo \
    && git clone git://github.com/kpu/kenlm.git \
    && cd kenlm \
    && mkdir -p build \
    && cd build \
    && cmake .. && make -j 4 \
    # install fftw3
    && cd /home/repo \
    && wget http://www.fftw.org/fftw-3.3.9.tar.gz \
    && tar zxvf fftw-3.3.9.tar.gz \
    && cd fftw-3.3.9 \
    && mkdir build \
    && cd build \
    && cmake .. && make -j 4 \
    && make install \
    && cd /home/repo \
    && wget https://registrationcenter-download.intel.com/akdlm/irc_nas/17977/l_BaseKit_p_2021.3.0.3219_offline.sh
    # && bash l_BaseKit_p_2021.3.0.3219_offline.sh \
    # # install flashlight
    # && cd /home/repo \
    # && git clone git://github.com/flashlight/flashlight.git \
    # && cd flashlight/bindings/python \
    # && export MKLROOT=/opt/intel/oneapi/mkl/latest \
    # && export KENLM_ROOT=/home/repo/kenlm \
    # && pip3 install packaging cmake \
    # && python setup.py install --user

CMD [ "/bin/bash" ]