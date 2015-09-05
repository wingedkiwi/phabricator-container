#
# Docker image for running https://github.com/phacility/phabricator
#

FROM        phusion/baseimage
MAINTAINER  Chi Vinh Le <cvl@winged.kiwi>

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# Change to different archive
RUN     mv /etc/apt/sources.list /etc/apt/sources.list.save && cat /etc/apt/sources.list.save | sed 's/archive/de.archive/g' > /etc/apt/sources.list

# Add nginx ppa
RUN     add-apt-repository ppa:nginx/stable
# Add nodejs ppa
RUN     curl -sL https://deb.nodesource.com/setup | sudo bash -

# TODO: review this dependency list
RUN     apt-get install -y \
            nodejs \
            build-essential \
            nginx \
            php5-fpm \
            php5-cli \
            php5-mysql \
            php5-curl \
            php5-gd \
            php5-ldap \
            php5-json \
            php-apc \
            php5-apcu \
            python-pygments \
            sendmail \
            mercurial \
            subversion \
            git \
            curl \
            tar \
        && apt-get clean && rm -rf /var/lib/apt/lists/*

# For some reason phabricator doesn't have tagged releases. To support
# repeatable builds use the latest SHA
ADD     download.sh /opt/download.sh
WORKDIR /opt
RUN     bash download.sh phacility phabricator 5125045738
RUN     bash download.sh phacility arcanist    c94e60487a
RUN     bash download.sh phacility libphutil   161e36fdd1
RUN     bash download.sh PHPOffice PHPExcel    372c7cbb69

# Create nginx user and group
RUN echo "nginx:x:497:495:user for nginx:/var/lib/nginx:/bin/false" >> /etc/passwd
RUN echo "nginx:!:495:" >> /etc/group

# Add user
RUN echo "git:x:2000:2000:user for phabricator:/opt/phabricator:/bin/bash" >> /etc/passwd
RUN echo "wwwgrp-phabricator:!:2000:nginx" >> /etc/group

# Setup aphlict

# Add aphlict log
RUN touch /var/log/aphlict.log && chown git:wwwgrp-phabricator /var/log/aphlict.log
# Install aphlict dependencies
RUN cd /opt/phabricator/support/aphlict/server && export HOME=`pwd` && npm install ws
# Copy runit file
RUN mkdir /etc/service/aphlict
COPY services/aphlict/aphlict.runit /etc/service/aphlict/run

# Setup syslog
COPY services/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

# Setup sshd
COPY services/sshd/sshd_config /etc/ssh/sshd_config
COPY services/sshd/phabricator-ssh-hook.sh /etc/ssh/phabricator-ssh-hook.sh
RUN rm -f /etc/service/sshd/down

# Setup nginx
RUN mkdir /etc/service/nginx
COPY services/nginx/nginx.conf /etc/nginx/nginx.conf
COPY services/nginx/fastcgi.conf /etc/nginx/fastcgi.conf
COPY services/nginx/nginx.runit /etc/service/nginx/run

# Setup php5-fpm
RUN mkdir /etc/service/php5-fpm
COPY services/php5-fpm/php.ini /etc/php5/fpm/php.ini
COPY services/php5-fpm/php-fpm.conf /etc/php5/fpm/php-fpm.conf
COPY services/php5-fpm/php5-fpm.runit /etc/service/php5-fpm/run

# Setup phabricator
RUN     mkdir -p /opt/phabricator/conf/local /var/repo

# Copy init scripts
COPY init/ /etc/my_init.d/

EXPOSE  80
ENTRYPOINT ["/sbin/my_init"]
