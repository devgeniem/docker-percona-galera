# This file creates a container that runs Database (Percona) with Galera Replication.
#
# Author: Paul Czarkowski
# Date: 08/16/2014

FROM debian:jessie
MAINTAINER Onni Hakala "onni.hakala@geniem.com"

ENV PERCONA_VERSION=5.6 DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

# Base Deps
RUN \
  apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A && \
  echo "deb http://repo.percona.com/apt jessie main" > /etc/apt/sources.list.d/percona.list && \
  echo "deb-src http://repo.percona.com/apt jessie main" >> /etc/apt/sources.list.d/percona.list && \
  ln -fs /bin/true /usr/bin/chfn && \
  apt-get -yqq update && \
  apt-get install -yqq \
  ca-certificates \
  curl \
  vim-tiny \
  locales \
  runit \
  percona-xtradb-cluster-client-${PERCONA_VERSION} \
  percona-xtradb-cluster-server-${PERCONA_VERSION}  \
  percona-xtrabackup \
  percona-xtradb-cluster-garbd-3.x \
  --no-install-recommends && \
  locale-gen en_US.UTF-8 && \
  rm -rf /var/lib/apt/lists/* && \
  sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
  rm -rf /var/lib/mysql/*

# Define mountable directories.
VOLUME ["/var/lib/mysql"]

ADD root-files /

# Define working directory.
WORKDIR /app

RUN chmod +x /app/bin/* /etc/service/*/run

# Define default command.
CMD ["/app/bin/boot"]

# Expose ports.
EXPOSE 3306 4444 4567 4568

# Name ports for registrator
ENV SERVICE_3306_NAME=database_port SERVICE_4444_NAME=database_sst SERVICE_4567_NAME=database_mon SERVICE_4568_NAME=database_ssi
