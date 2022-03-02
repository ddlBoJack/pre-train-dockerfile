FROM aegis1/cuda10.2-cudnn7-devel-ubuntu16.04

LABEL MAINTAINER="matrixzheng01@gmail.com"

USER root

COPY vimrc /root/.vim_runtime
COPY ninja-linux.zip / 
COPY fairseq fairseq 
COPY Miniconda3-latest-Linux-x86_64.sh /root

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
    # && wget https://github.com/ninja-build/ninja/releases/download/v1.8.2/ninja-linux.zip \
    && unzip ninja-linux.zip -d /usr/local/bin/ \
    && rm -rf ninja-linux.zip \
    && update-alternatives --install /usr/bin/ninja ninja /usr/local/bin/ninja 1 --force \
    && sh ~/.vim_runtime/install_awesome_vimrc.sh \
    && echo "set number" >> ~/.vimrc

ENV PATH /opt/conda/bin:$PATH

RUN cd /root \
    # && wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh \
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
    && cd /root/fairseq \
    && pip install --editable ./

    # && conda create -n wav2vec python=3.8 -y
    # && conda activate wav2vec \
    # && conda deactivate
    # && git clone https://github.com/pytorch/fairseq \
    # && cd fairseq \
    # && pip install --editable ./
# ENV SHELL=/bin/bash
# SHELL ["conda", "run", "-n", "wav2vec", "/bin/bash", "-c"]
# RUN . activate \
#     && conda activate wav2vec \ 
#     && cd fairseq \
#     && pip install --editable ./

CMD [ "/bin/bash" ]