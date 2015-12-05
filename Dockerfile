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
RUN apt-get install -y --no-install-recommends python build-essential ca-certificates curl libssl-dev

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

# Default adapter and name
ENV ADAPTER shell
ENV NAME hewbot

# Default environment variables in case IRC adapter is used
# User needs to define ADAPTER, NAME, HUBOT_IRC_ROOMS
# and eventually HUBOT_IRC_NICKSERV_PASSWORD
ENV HUBOT_IRC_SERVER "irc.freenode.net"
ENV HUBOT_IRC_PORT 6697
ENV HUBOT_IRC_DEBUG "true"
ENV HUBOT_IRC_USESSL "true"
ENV HUBOT_IRC_UNFLOOD "true"

ENTRYPOINT bin/hubot --adapter $ADAPTER --name $NAME
