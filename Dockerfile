# hewbot
#
# VERSION               1.0
FROM ubuntu:14.04
MAINTAINER Paul Chaignon <paul.chaignon@gmail.com>

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install base dependencies
RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential ca-certificates curl libssl-dev

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 0.11.16

# Install NVM with NodeJS and NPM
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.20.0/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/v$NODE_VERSION/bin:$PATH

ADD . /hewbot
WORKDIR /hewbot

ENTRYPOINT bin/hubot --name hewbot
