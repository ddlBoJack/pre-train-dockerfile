FROM aegis1/cuda11.1-cudnn8-devel-ubuntu20.04

LABEL MAINTAINER="matrixzheng01@gmail.com"

USER root

# COPY vimrc /root/.vim_runtime
# COPY ninja-linux.zip / 
# COPY fairseq fairseq
# COPY Miniconda3-latest-Linux-x86_64.sh /root

RUN set -x \
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
    && wget https://github.com/ninja-build/ninja/releases/download/v1.10.2/ninja-linux.zip\
    && unzip ninja-linux.zip -d /usr/local/bin/ \
    && rm -rf ninja-linux.zip \
    && update-alternatives --install /usr/bin/ninja ninja /usr/local/bin/ninja 1 --force \
    # && git clone https://github.com/chxuan/vimplus.git ~/.vimplus \
    # && cd ~/.vimplus \
    # && ./install.sh
    && git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime \
    && sh ~/.vim_runtime/install_awesome_vimrc.sh \
    && echo "set number" >> ~/.vimrc

ENV PATH /opt/conda/bin:$PATH

# RUN cd / \
    # && git clone git://github.com/pytorch/fairseq

# install conda and fairseq
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
    && echo "conda activate wav2vec" >> ~/.bashrc \
    # (optional) only for cloudbrain
    && pip install --upgrade numpy \ 
    # install fairseq
    && pip install soundfile \
    && apt-get install -y libsndfile1-dev \
    && cd / \
    && git clone https://github.com/pytorch/fairseq.git \
    && cd fairseq \
    && pip install --editable ./

# install flash light
# step 1
RUN apt-get install -y sudo && sudo apt update

# step 2:  install boost, blas
RUN apt search openlas && sudo apt install build-essential cmake libboost-system-dev libboost-thread-dev libboost-program-options-dev libboost-test-dev libeigen3-dev zlib1g-dev libbz2-dev liblzma-dev libnss3 libgtk-3-0 xdg-utils libopenblas-dev -y

# step 3: install KENLM
RUN git clone https://github.com/kpu/kenlm.git && cd kenlm && mkdir -p build && cd build && cmake .. && make -j 4

# step 4: install FFTW3
RUN wget http://www.fftw.org/fftw-3.3.9.tar.gz && tar zxvf fftw-3.3.9.tar.gz && cd fftw-3.3.9 && mkdir build && cd build && cmake .. && make -j 4 && sudo make install

# step 5: install intel MKL
# ref: https://github.com/eddelbuettel/mkl4deb
RUN cd /tmp && wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && sh -c 'echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list' && apt-get update && apt-get install -y intel-mkl-64bit-2018.2-046
RUN pip install packaging && apt-get install -y vim &&  pip install editdistance && pip install gpustat

# step 6: install flashlight/binding/python
RUN git clone https://github.com/flashlight/flashlight.git && cd flashlight/bindings/python && export MKLROOT=/opt/intel/mkl/ && export KENLM_ROOT=/kenlm && python setup.py install --user

# some patches
RUN apt-get install -y vim && pip install editdistance && pip install gpustat


ENV SHELL=/bin/bash
CMD [ "/bin/bash" ]



