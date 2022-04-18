FROM aegis1/cuda11.1-cudnn8-devel-ubuntu20.04
# (recommend) FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04 
# if you use this image in high cuda envs like 11.3

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
    && pip install packaging \
    && pip install editdistance \
    && pip install gpustat \
    && pip install tensorboard \
    # install fairseq
    && pip install soundfile \
    && apt-get install -y libsndfile1-dev \
    && cd / \
    && git clone https://github.com/pytorch/fairseq.git \
    && cd fairseq \
    && pip install --editable ./ \
    && conda install -c conda-forge npy-append-array -y \
    && pip install librosa pandas sentencepiece

RUN apt-get install -y ffmpeg

RUN apt-get install -y vim \
    && pip install packaging

# install rclone
RUN curl https://rclone.org/install.sh | bash
RUN sed -i 's/shopt/# shopt/' ~/.bashrc


ENV SHELL=/bin/bash
CMD [ "/bin/bash" ]



