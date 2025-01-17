FROM --platform=i386 i386/debian:buster
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get clean && apt-get update && apt-get -y upgrade
RUN apt-get -y install apt-utils gcc nodejs \
	python3 python3-pip unzip git nano cmake \
	software-properties-common fakeroot \
	dbus base whiptail hexedit patch clang \
	wamerican ucf manpages file make ninja-build \
	dialog curl less cowsay netcat-openbsd
RUN echo 'deb http://ppa.launchpad.net/leaningtech-dev/cheerp-ppa/ubuntu focal main' > /etc/apt/sources.list && \
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 84540D4B9BF457D5 && \
    sudo apt-get update && apt-get -y install \ 
    cheerp-core && mkdir /data
RUN python3 -m pip install conan==1.56 && \
  conan config install https://github.com/ultimaker/conan-config.git && \
  conan profile new default --detect --force && \
  mkdir /home/user/CuraEngine/ && \
  curl https://github.com/Ultimaker/CuraEngine/archive/refs/tags/5.4.0.tar.gz | tar -xz -C /home/user/CuraEngine/ && \
  

RUN useradd -m user && echo "user:password" | chpasswd
COPY --chown=user:user ./dockerfiles/assets/cheerp_online /home/user/

# We set WORKDIR, as this gets extracted by Webvm to be used as the cwd. This is optional.
WORKDIR /home/user/
# We set env, as this gets extracted by Webvm. This is optional.
ENV HOME="/home/user" TERM="xterm" USER="user" SHELL="/bin/bash" EDITOR="nano" LANG="en_US.UTF-8" LC_ALL="C"
RUN echo 'root:password' | chpasswd
CMD [ "/bin/bash" ]
