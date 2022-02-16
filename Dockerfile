FROM aegis1/cuda10.2-cudnn7-devel-ubuntu16.04
USER root
RUN cp /etc/apt/sources.list.bak  /etc/apt/sources.list
RUN apt update
RUN apt-get -y install wget curl man git less openssl libssl-dev unzip
RUN apt install -y openssh-server

# (optional) install git-lfs for pcl gpu cluster
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt-get install git-lfs

# (optional) install rclone for pcl gpu cluster
RUN sed -i "s/mozilla\/DST_Root_CA_X3.crt/!mozilla\/DST_Root_CA_X3.crt/g" /etc/ca-certificates.conf
RUN update-ca-certificates
RUN curl https://rclone.org/install.sh | bash

# install openmpi
ENV OPENMPI_VERSION=4.0
ENV OPENMPI_STRING=openmpi-${OPENMPI_VERSION}.0
RUN mkdir /tmp/openmpi && \
        cd /tmp/openmpi && \
        wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.0.tar.gz && \
        tar zxf ${OPENMPI_STRING}.tar.gz && \
        cd ${OPENMPI_STRING} && \
        ./configure --enable-orterun-prefix-by-default --with-openib --prefix /usr/local/mpi && \
        make -j 4 all && \
        make install && \
        ldconfig && \
        rm -rf /tmp/openmpi && \
        test -f /usr/local/mpi/bin/mpic++  # Sanity check
ENV PATH /usr/local/mpi/bin:$PATH

# install miniconda
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
#RUN `wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh --no-check-certificate` as an alternative
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh &&\
	bash Miniconda3-latest-Linux-x86_64.sh -b &&\
        rm -rf Miniconda3-latest-Linux-x86_64.sh
        # conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free &&\
        # conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main &&\
        # conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge &&\
        # conda config --set show_channel_urls yes

RUN git clone https://github.com/espnet/espnet.git
WORKDIR espnet
RUN ./ci/install_kaldi.sh
WORKDIR tools
ENV CONDA_EXE="/root/miniconda3/bin/conda"
ENV CONDA_TOOLS_DIR="/root/miniconda3"
RUN ./setup_anaconda.sh ${CONDA_TOOLS_DIR} espnet 3.8
# make TH_VERSION=xxx, pytorch=1.10.0 if empty
RUN make

# install boost
RUN apt -y install libboost-all-dev
RUN apt -y install aptitude && aptitude search boost
# install some dependencies
RUN apt -y install bc
RUN . ./activate_python.sh && pip install gpustat && pip install mpi4py

# FairSeq Commit id when making this PR: `commit 313ff0581561c7725ea9430321d6af2901573dfb`
RUN . ./activate_python.sh && ./installers/install_fairseq.sh

WORKDIR /
RUN ln -s espnet/tools/kaldi . && ln -s espnet/tools/fairseq .

# install tmux
RUN apt -y install tmux

# ninja for C++ build in pytorch
RUN wget https://github.com/ninja-build/ninja/releases/download/v1.8.2/ninja-linux.zip && \
        unzip ninja-linux.zip -d /usr/local/bin/ && \
        update-alternatives --install /usr/bin/ninja ninja /usr/local/bin/ninja 1 --force
# install vim
RUN git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime && sh ~/.vim_runtime/install_awesome_vimrc.sh
RUN echo "set number" >> ~/.vimrc

# use conda env "espnet" once entering the container
RUN echo ". /espnet/tools/activate_python.sh" >> ~/.bashrc
# ENTRYPOINT ["bash"]
ENV SHELL=/bin/bash
CMD ["/bin/bash"]