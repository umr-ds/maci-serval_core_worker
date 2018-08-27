### Build serval in seperate container
FROM maciresearch/core_worker as builder

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
    && apt-get clean

RUN git clone https://github.com/servalproject/serval-dna.git /serval-dna
WORKDIR /serval-dna
RUN autoreconf -f -i -I m4
RUN ./configure
RUN make -j 8 servald


### Setup core worker container
FROM maciresearch/core_worker
COPY --from=builder /serval-dna/servald  /usr/local/sbin/servald

### Install pyserval for python 2 and 3
RUN apt-get update \
    && apt-get install -y \
    python-pip \
    python3-pip \
    && apt-get clean
RUN python -m pip install https://github.com/umr-ds/pyserval/archive/master.zip \
    && python3 -m pip install https://github.com/umr-ds/pyserval/archive/master.zip \
    && rm -rf /root/.cache/pip/*

### install core-serval integration
COPY dotcore /root/.core/
ENV BASH_ENV /root/.serval
RUN echo "custom_services_dir = /root/.core/myservices" >> /etc/core/core.conf \
    && echo "export SERVALINSTANCE_PATH=\$PWD" >> /root/.serval \
    && echo "export SERVALINSTANCE_PATH=\$PWD" >> /root/.bashrc
