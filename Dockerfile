ARG DOCKER_OPENSTUDIO_VERSION=3.0.0-beta
FROM canmet/docker-openstudio:$DOCKER_OPENSTUDIO_VERSION

MAINTAINER Phylroy Lopez phylroy.lopez@canada.ca

ARG DISPLAY=local
ENV DISPLAY ${DISPLAY}

#Repository utilities add on list.
ARG repository_utilities='ca-certificates software-properties-common dpkg-dev debconf-utils'

#Basic software
ARG software='git vim curl zip lynx xemacs21 nano unzip xterm terminator diffuse silversearcher-ag openssh-client openssh-server sqlitebrowser dbus-x11 python3 python3-pip code'

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
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV PATH $JAVA_HOME/bin:$PATH

#Ubuntu install commands
ARG apt_install='apt-get install -y --no-install-recommends --force-yes'

#Ubuntu install clean up command
ARG clean='rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /downloads/*'

#Create folder for downloads
RUN mkdir /downloads

#Install software packages
RUN apt-get update && \ 
	$apt_install $repository_utilities \
	&& add-apt-repository -y ppa:linuxgndu/sqlitebrowser \
	&& wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add - \
	&& add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" \
	&& apt-get update && $apt_install $software $d3_deps $r_deps \ 
	&& apt-get clean && $clean


#### Build sqlite with json support
RUN curl -fSL -o sqlite.tar.gz https://www.sqlite.org/2017/sqlite-autoconf-3160200.tar.gz \ 
    && mkdir /usr/src/sqlite3 \
    && tar -xzf sqlite.tar.gz -C /usr/src/sqlite3 \
    && rm sqlite.tar.gz \
    && cd /usr/src/sqlite3/sqlite-autoconf-3160200 \
    && ./configure --prefix=/usr/local --enable-json1 --enable-readline \
    && make  \ 
    && make install \
    && make clean
	
	
#install Amazon AWS CLI and packer
RUN wget https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_linux_amd64.zip \
&& unzip packer_1.0.0_linux_amd64.zip -d /usr/bin/ \
&& rm packer_1.0.0_linux_amd64.zip
RUN curl -O http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip \
&& mkdir /usr/local/ec2 \
&& unzip ec2-api-tools.zip -d /usr/local/ec2 \
&& mv  `find  /usr/local/ec2/ec2-api-tools-* -maxdepth 0` /usr/local/ec2/ec2-api-tools \
&& rm ec2-api-tools.zip  
ENV EC2_HOME=/usr/local/ec2/ec2-api-tools

# Install aws cli2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
&& unzip awscliv2.zip \
&& ./aws/install \
&& rm awscliv2.zip

# Install Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
&& apt-get update \
&& $apt_install ./google-chrome-stable_current_amd64.deb \
&& apt-get clean && $clean \
&& rm google-chrome-stable_current_amd64.deb

USER  osdev
WORKDIR /home/osdev

# Install RubyMine
ARG ruby_mine_version='RubyMine-2019.3.3'
RUN wget https://download.jetbrains.com/ruby/$ruby_mine_version.tar.gz \
&& tar -xzf $ruby_mine_version.tar.gz \
&& rm $ruby_mine_version.tar.gz

# Install PyCharm
ARG pycharm_version='pycharm-professional-2019.3.4'
RUN wget https://download.jetbrains.com/python/$pycharm_version.tar.gz \
&& tar -xzf $pycharm_version.tar.gz \
&& rm $pycharm_version.tar.gz
#create symbolic link to rubymine and pycharm and set midori to default browser

ARG pycharm_loc='pycharm-2019.3.4'
USER  root
RUN ln -s /home/osdev/$ruby_mine_version/bin/rubymine.sh /usr/local/sbin/rubymine \
&& ln -s /home/osdev/$pycharm_loc/bin/pycharm.sh /usr/local/sbin/pycharm \
&& ln -s /usr/bin/midori /bin/xdg-open




USER  osdev
ADD --chown=osdev:osdev btap_utilities /home/osdev/btap_utilities
ADD --chown=osdev:osdev config/terminator/config /home/osdev/.config/terminator/config
ADD --chown=osdev:osdev config/.gitconfig /home/osdev/.gitconfig
RUN echo 'PATH="~/btap_utilities:$PATH"' >> ~/.bashrc \
&& /bin/bash -c "source /etc/user_config_bashrc"
CMD ["/bin/bash"]
