ARG DOCKER_OPENSTUDIO_VERSION=3.7.0


FROM canmet/docker-openstudio:3.7.0

MAINTAINER Phylroy Lopez phylroy.lopez@canada.ca and Chris Kirney chris.kirney@nrcan-rncan.gc.ca

ARG DISPLAY=host.docker.internal
ENV DISPLAY ${DISPLAY}

#Repository utilities add on list.
ARG repository_utilities='ca-certificates software-properties-common dpkg-dev debconf-utils'

#Basic software
ARG software='git vim curl zip nano unzip xterm terminator openssh-client openssh-server sqlitebrowser dbus-x11'

#D3 parallel coordinates deps due to canvas deps and OpenStudioApp dependencies
ARG d3_deps='libcairo2-dev libjpeg-dev libpango1.0-dev libgif-dev build-essential g++ libxcb-cursor0'

#set Java ENV
#ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV PATH $JAVA_HOME/bin:$PATH

#Ubuntu install commands
ARG apt_install='apt-get install -y'

#Ubuntu install clean up command
ARG clean='rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /downloads/*'

#Create folder for downloads
RUN mkdir /downloads

# Install software packages
RUN apt-get update \ 
&& apt-get upgrade -y \
&& $apt_install $repository_utilities \
&& add-apt-repository -y ppa:git-core/ppa \
&& add-apt-repository -y ppa:linuxgndu/sqlitebrowser \
&& apt-get update && $apt_install $software $d3_deps  \ 
&& apt-get clean && $clean

# Install JetBrains and regular user and create symbolic links. 
USER  osdev
WORKDIR /home/osdev
ARG ruby_mine_version='RubyMine-2023.3.3'
RUN wget https://download.jetbrains.com/ruby/$ruby_mine_version.tar.gz \
&& tar -xzf $ruby_mine_version.tar.gz \
&& rm $ruby_mine_version.tar.gz
# Install PyCharm
ARG pycharm_loc='pycharm-2023.3.3'
ARG pycharm_version='pycharm-professional-2023.3.3'
RUN wget https://download.jetbrains.com/python/$pycharm_version.tar.gz \
&& tar -xzf $pycharm_version.tar.gz \
&& rm $pycharm_version.tar.gz
USER  root
RUN ln -s /home/osdev/$ruby_mine_version/bin/rubymine.sh /usr/local/sbin/rubymine \
&& ln -s /home/osdev/$pycharm_loc/bin/pycharm.sh /usr/local/sbin/pycharm 

# Install OpenStudioApp and create symbolic links
# Dependencies (OS 3.7.0, OS App 1.7.0):
ARG os_app_deps='freeglut3-dev libxkbfile-dev libc6-dev '
RUN wget https://github.com/openstudiocoalition/OpenStudioApplication/releases/download/v1.7.0/OpenStudioApplication-1.7.0+b070178884-Ubuntu20.04.deb
RUN apt-get update -y
RUN $apt_install $os_app_deps
RUN python3 -m pip install conan
RUN python3 -m pip install setuptools
RUN $apt_install ./OpenStudioApplication-1.7.0+b070178884-Ubuntu20.04.deb
RUN apt-get clean && $clean
RUN rm ./OpenStudioApplication-1.7.0+b070178884-Ubuntu20.04.deb
RUN ln -s /usr/local/bin/OpenStudioApp /usr/local/sbin/OpenStudioApp
RUN apt-get clean && $clean

RUN apt-get update -y
RUN apt-get upgrade -y

USER  osdev
ADD --chown=osdev:osdev btap_utilities /home/osdev/btap_utilities
ADD --chown=osdev:osdev config/terminator/config /home/osdev/.config/terminator/config
ADD --chown=osdev:osdev config/.gitconfig /home/osdev/.gitconfig
RUN echo 'PATH="~/btap_utilities:$PATH"' >> ~/.bashrc \
&& /bin/bash -c "source /etc/user_config_bashrc"
CMD ["/bin/bash"]