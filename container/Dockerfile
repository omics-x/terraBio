FROM ubuntu:latest

# Update and upgrade the system
RUN apt-get update && apt-get upgrade -yq

# Install required dependencies
RUN apt-get install unzip curl build-essential zlib1g-dev libbz2-dev liblzma-dev \
    libcurl4-openssl-dev libssl-dev libncurses5-dev libncursesw5-dev liblapacke.so.3 libz-dev -yq

# Set the working directory
WORKDIR /tools

# Download and install BCFtools
RUN curl -LO https://github.com/samtools/bcftools/releases/download/1.20/bcftools-1.20.tar.bz2 \
    && tar -xjf bcftools-1.20.tar.bz2 \
    && cd bcftools-1.20 \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf bcftools-1.20 bcftools-1.20.tar.bz2

# Download and install QCTool
RUN curl -LO https://www.well.ox.ac.uk/~gav/resources/qctool_v2.2.0-CentOS_Linux7.8.2003-x86_64.tgz \
    && tar --strip-components=1 -xzf qctool_v2.2.0-CentOS_Linux7.8.2003-x86_64.tgz -C /tools \
    && rm qctool_v2.2.0-CentOS_Linux7.8.2003-x86_64.tgz

# Download and install HTSlib (which includes bgzip)
RUN curl -LO https://github.com/samtools/htslib/releases/download/1.20/htslib-1.20.tar.bz2 \
    && tar -xjf htslib-1.20.tar.bz2 \
    && cd htslib-1.20 \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf htslib-1.20 htslib-1.20.tar.bz2

# Add QCTool and HTSlib to the PATH
ENV PATH="/tools/qctool:/tools/qctool/bin:/usr/local/bin:$PATH"
