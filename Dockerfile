### Build serval in seperate container
FROM maciresearch/core_worker:0.3 as builder

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

RUN git clone https://github.com/umr-ds/serval-dna.git /serval-dna
WORKDIR /serval-dna
ENV CFLAGS -Wno-error=deprecated-declarations -O1
ENV CC gcc-5
RUN git fetch && git checkout -b build 66c2853690b7448a96134aded392978db5b1eeef
RUN autoreconf -f -i -I m4
RUN ./configure
RUN make -j 8 servald


### Setup core worker container
FROM maciresearch/core_worker:0.3
LABEL maintainer="hoechst@mathematik.uni-marburg.de"
LABEL name="umrds/serval_core_worker"
LABEL version="0.3.1"

COPY --from=builder /serval-dna/servald  /usr/local/sbin/servald

### Install pyserval for python 2 and 3
RUN apt-get update \
    && apt-get install -y \
    bwm-ng \
    python-pip \
    python3-pip \
    && apt-get clean
RUN python -m pip install https://github.com/umr-ds/pyserval/archive/e794df6a9963904f167ef6ddc835c73e147e43b9.zip \
    && python3 -m pip install https://github.com/umr-ds/pyserval/archive/e794df6a9963904f167ef6ddc835c73e147e43b9.zip \
    && python -m pip install pynacl \
    && python3 -m pip install pynacl \
    && rm -rf /root/.cache/pip/*

RUN apt-get update \
    && apt-get install -y \
    bwm-ng \
    sysstat \
    tcpdump \
    && apt-get clean

### install core-serval integration
COPY dotcore /root/.core/
ENV BASH_ENV /root/.serval
RUN echo "custom_services_dir = /root/.core/myservices" >> /etc/core/core.conf \
    && echo 'export SERVALINSTANCE_PATH=$SESSION_DIR/`hostname`.conf' >> /root/.serval \
    && echo 'export SERVALINSTANCE_PATH=$SESSION_DIR/`hostname`.conf' >> /root/.bashrc
