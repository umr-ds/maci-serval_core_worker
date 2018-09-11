### Build serval in seperate container
FROM maciresearch/core_worker:0.1 as builder

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
    libsodium-dev \
    gcc-5 \
    && apt-get clean

RUN git clone https://github.com/servalproject/serval-dna.git /serval-dna
WORKDIR /serval-dna
ENV CFLAGS -Wno-error=deprecated-declarations -O1
ENV CC gcc-5
RUN git checkout batphone-release-0.93
RUN autoreconf -f -i -I m4
RUN ./configure
RUN make -j 8 servald


### Setup core worker container
FROM maciresearch/core_worker:0.1
COPY --from=builder /serval-dna/servald  /usr/local/sbin/servald

### Install pyserval for python 2 and 3
RUN apt-get update \
    && apt-get install -y \
    python-pip \
    python3-pip \
    && apt-get clean
RUN python -m pip install https://github.com/umr-ds/pyserval/archive/master.zip \
    && python3 -m pip install https://github.com/umr-ds/pyserval/archive/master.zip \
    && python -m pip install pynacl \
    && python3 -m pip install pynacl \
    && rm -rf /root/.cache/pip/*

### install core-serval integration
COPY dotcore /root/.core/
ENV BASH_ENV /root/.serval
RUN echo "custom_services_dir = /root/.core/myservices" >> /etc/core/core.conf \
    && echo 'export SERVALINSTANCE_PATH=$SESSION_DIR/`hostname`.conf' >> /root/.serval \
    && echo 'export SERVALINSTANCE_PATH=$SESSION_DIR/`hostname`.conf' >> /root/.bashrc
