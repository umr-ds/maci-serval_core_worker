FROM maciresearch/core_worker

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
    git
    
### Build and install serval 
RUN git clone https://github.com/servalproject/serval-dna.git /serval-dna
WORKDIR /serval-dna

RUN autoreconf -f -i -I m4
RUN ./configure
RUN make
RUN make install

### install core-serval integration
WORKDIR /root/.core/
RUN echo "custom_services_dir = /root/.core/myservices" >> /etc/core/core.conf
COPY dotcore /root/.core/