ARG DOCKER_OPENSTUDIO_VERSION=3.5.1


FROM canmet/docker-openstudio:3.5.1

MAINTAINER Phylroy Lopez phylroy.lopez@canada.ca

ARG DISPLAY=host.docker.internal
ENV DISPLAY ${DISPLAY}

#Repository utilities add on list.
ARG repository_utilities='ca-certificates software-properties-common dpkg-dev debconf-utils'

#Basic software
ARG software='git vim curl zip nano unzip xterm terminator openssh-client openssh-server sqlitebrowser dbus-x11'

#Netbeans Dependancies (requires $java_repositories to be set)
ARG netbeans_deps='oracle-java8-installer libxext-dev libxrender-dev libxtst-dev oracle-java8-set-default'

#VCCode Dependancies
ARG vscode_deps='curl libc6-dev  libasound2 libgconf-2-4 libgnome-keyring-dev libgtk2.0-0 libnss3 libpci3  libxtst6 libcanberra-gtk-module libnotify4 libxss1 wget'
#Java repositories needed for Netbeans

#D3 parallel coordinates deps due to canvas deps
ARG d3_deps='libcairo2-dev libjpeg-dev libpango1.0-dev libgif-dev build-essential g++'

#Purge software 
ARG intial_purge_software='openjdk*'

#set Java ENV
#ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV PATH $JAVA_HOME/bin:$PATH

#Ubuntu install commands
ARG apt_install='apt-get install -y --no-install-recommends'

#Ubuntu install clean up command
ARG clean='rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /downloads/*'

#Create folder for downloads
RUN mkdir /downloads

# Install software packages
RUN apt-get update \ 
&& $apt_install $repository_utilities \
&& add-apt-repository -y ppa:linuxgndu/sqlitebrowser \
&& apt-get update && $apt_install $software $d3_deps $r_deps  \ 
&& apt-get clean && $clean

# Update Git
RUN add-apt-repository -y ppa:git-core/ppa \
&& apt-get update \
&& apt-get install git -y

# Install JetBrains and regular user and create symbolic links. 
USER  osdev
WORKDIR /home/osdev
ARG ruby_mine_version='RubyMine-2022.3.3'
RUN wget https://download.jetbrains.com/ruby/$ruby_mine_version.tar.gz \
&& tar -xzf $ruby_mine_version.tar.gz \
&& rm $ruby_mine_version.tar.gz
# Install PyCharm
ARG pycharm_loc='pycharm-2022.3.3'
ARG pycharm_version='pycharm-professional-2022.3.3'
RUN wget https://download.jetbrains.com/python/$pycharm_version.tar.gz \
&& tar -xzf $pycharm_version.tar.gz \
&& rm $pycharm_version.tar.gz
USER  root
RUN ln -s /home/osdev/$ruby_mine_version/bin/rubymine.sh /usr/local/sbin/rubymine \
&& ln -s /home/osdev/$pycharm_loc/bin/pycharm.sh /usr/local/sbin/pycharm 

# Install OpenStudio App and create symbolic links.
# old ependencies:  ARG os_app_deps='build-essential git cmake-curses-gui cmake-gui libssl-dev libxt-dev libncurses5-dev libgl1-mesa-dev autoconf libexpat1-dev libpng-dev libfreetype6-dev libdbus-glib-1-dev libglib2.0-dev libfontconfig1-dev libxi-dev libxrender-dev libgeographic-dev libicu-dev chrpath bison libffi-dev libgdbm-dev libqdbm-dev libreadline-dev libyaml-dev libharfbuzz-dev libgmp-dev patchelf python-pip libgconf-2-4 libxss1 python-setuptools ' 
# New dependencies (3.5.1):
ARG os_app_deps='freeglut3-dev libxkbfile-dev '
RUN wget -O osa.deb https://github.com/openstudiocoalition/OpenStudioApplication/releases/download/v1.5.0/OpenStudioApplication-1.5.0+2a9ad1764a-Ubuntu20.04.deb \
&& apt-get update \
&& $apt_install $os_app_deps \
&& python3 -m pip install conan \
&& python3 -m pip install setuptools \
&& $apt_install ./osa.deb  \
&& apt-get clean && $clean \
&& rm ./osa.deb \
&& ln -s /usr/local/bin/OpenStudioApp /usr/local/sbin/OpenStudioApp \
&& apt-get clean && $clean

USER  osdev
ADD --chown=osdev:osdev btap_utilities /home/osdev/btap_utilities
ADD --chown=osdev:osdev config/terminator/config /home/osdev/.config/terminator/config
ADD --chown=osdev:osdev config/.gitconfig /home/osdev/.gitconfig
RUN echo 'PATH="~/btap_utilities:$PATH"' >> ~/.bashrc \
&& /bin/bash -c "source /etc/user_config_bashrc"
CMD ["/bin/bash"]