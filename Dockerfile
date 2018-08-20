FROM maciresearch/core_worker-gui

### Install serval requirements
RUN apt-get update \
    && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    grep \
    sed \
    gawk \
    jq \
    curl \
    git \
    python-pip \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*
    
### Build and install serval 
RUN git clone https://github.com/servalproject/serval-dna.git /serval-dna \
    && cd /serval-dna \
    && autoreconf -f -i -I m4 \
    && ./configure \
    && make -j 8 servald \
    && make install \
    && rm -rf /serval-dna

### Install pyserval for python 2 and 3
RUN python -m pip install https://github.com/umr-ds/pyserval/archive/master.zip \
    && python3 -m pip install https://github.com/umr-ds/pyserval/archive/master.zip

### install core-serval integration
COPY dotcore /root/.core/
ENV BASH_ENV /root/.serval
RUN echo "custom_services_dir = /root/.core/myservices" >> /etc/core/core.conf \
    && echo "export SERVALINSTANCE_PATH=\$PWD" >> /root/.serval \
    && echo "export SERVALINSTANCE_PATH=\$PWD" >> /root/.bashrc
