# Based on https://github.com/aibooster0/curaengine-dockerfile/blob/master/Dockerfile
FROM --platform=i386 i386/ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get clean && apt-get update && apt-get -y upgrade
RUN apt-get -y install git wget nano \
  autoconf automake libtool curl make \
  g++ unzip cmake python3 python3-dev \
  python3-sip-dev

RUN useradd -m user && echo "user:password" | chpasswd
COPY --chown=user:user ./dockerfiles/assets/cheerp_online /home/user/

#RUN mkdir -p /home/user/sources && cd /home/user/sources && \
#  wget https://github.com/google/protobuf/releases/download/v3.5.0/protobuf-all-3.5.0.zip && \
#  unzip protobuf-all-3.5.0.zip && cd protobuf-3.5.0 && \
#  chmod +x ./autogen.sh ./configure && cd ../ && \
#  git clone https://github.com/Ultimaker/libArcus.git && \
#  cd libArcus && git pull && git checkout 4.4 && cd ../ && \
#  git clone https://github.com/Ultimaker/CuraEngine.git && \
#  cd CuraEngine && git pull && git checkout 4.4 && cd ../../ && \
#  chmod -R 777 /home/user

RUN mkdir -p /tmp/sources && cd /tmp/sources/ && \
  wget https://github.com/google/protobuf/releases/download/v3.5.0/protobuf-all-3.5.0.zip && \
  unzip protobuf-all-3.5.0.zip && rm protobuf-all-3.5.0.zip && \
  git clone https://github.com/Ultimaker/libArcus.git && \
  git clone https://github.com/Ultimaker/CuraEngine.git

# install protobuf
#RUN unzip protobuf-all-3.5.0.zip
#WORKDIR "/tmp/sources/protobuf-3.5.0"
RUN cd /tmp/sources/protobuf-3.5.0 && \
 ./autogen.sh && ./configure && make && \
  make install && ldconfig && \
  rm -rf /tmp/sources/protobuf-3.5.0

# install libArcus
#WORKDIR "/tmp/sources/libArcus"
RUN cd /tmp/sources/libArcus && \
  git pull && git checkout 4.4 && \
  mkdir build && cd build && 
  cmake .. && make && make install && \
  rm -rf /tmp/sources/libArcus

# install curaengine
#WORKDIR "/tmp/sources/CuraEngine"
RUN cd /tmp/sources/CuraEngine && \
  git pull && git checkout 4.4 && \
  mkdir build && cd build && cmake .. && make

# We set WORKDIR, as this gets extracted by Webvm to be used as the cwd. This is optional.
WORKDIR /home/user/
# We set env, as this gets extracted by Webvm. This is optional.
ENV HOME="/home/user" TERM="xterm" USER="user" SHELL="/bin/bash" EDITOR="nano" LANG="en_US.UTF-8" LC_ALL="C"
RUN echo 'root:password' | chpasswd && \
  chmod -R 777 /home/user /tmp/
CMD [ "/bin/bash", "-i" ]
