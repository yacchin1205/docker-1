FROM ubuntu:18.04
MAINTAINER ffdixon@bigbluebutton.org

ENV DEBIAN_FRONTEND noninteractive
ENV container docker

RUN apt-get update && apt-get install  -y netcat

# -- Test if we have apt cache running on docker host, if yes, use it.
# RUN nc -zv host.docker.internal 3142 &> /dev/null && echo 'Acquire::http::Proxy "http://host.docker.internal:3142";'  > /etc/apt/apt.conf.d/01proxy

# -- Install utils
RUN apt-get update && apt-get install -y wget apt-transport-https

RUN apt-get install -y language-pack-en
RUN update-locale LANG=en_US.UTF-8

# -- Install system utils
RUN apt-get update 
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y wget software-properties-common

# -- Install yq 
RUN LC_CTYPE=C.UTF-8 add-apt-repository ppa:rmescandon/yq
RUN apt update
RUN LC_CTYPE=C.UTF-8 apt install yq -y

RUN apt-get install -y \
  haveged    \
  net-tools  \
  sudo

# -- Modify systemd to be able to run inside container
RUN apt-get update \
    && apt-get install -y systemd

# -- Install Dependencies
RUN apt-get install -y mlocate strace iputils-ping telnet tcpdump vim htop

RUN apt-get install -y tomcat8 

# -- Disable unneeded services
RUN systemctl disable systemd-journal-flush
RUN systemctl disable systemd-update-utmp.service

# -- Finish startup 
#    Add a number there to force update files
RUN echo "Finishing ... @1"
RUN mkdir /opt/docker-bbb/
RUN wget https://raw.githubusercontent.com/bigbluebutton/bbb-install/master/bbb-install.sh -O- | sed 's|https://\$PACKAGE_REPOSITORY|http://\$PACKAGE_REPOSITORY|g' | sed 's|node_8|node_12|g' > /opt/docker-bbb/bbb-install.sh
RUN chmod 755 /opt/docker-bbb/bbb-install.sh
ADD setup.sh /opt/docker-bbb/setup.sh

RUN useradd bbb --uid 1000 -s /bin/bash
RUN mkdir /home/bbb
RUN chown bbb /home/bbb
RUN sh -c 'echo "bbb ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/bbb'
RUN sh -c 'echo "bbb:bbb" | chpasswd'

ADD rc.local /etc/
RUN chmod 755 /etc/rc.local

ADD haveged.service /etc/systemd/system/default.target.wants/haveged.service

ENTRYPOINT ["/bin/systemd", "--system", "--unit=multi-user.target"]
CMD []

