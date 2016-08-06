# Hewbot

[![Build Status](https://travis-ci.org/pchaigno/hewbot.svg?branch=master)](https://travis-ci.org/pchaigno/hewbot)
[![Coverage Status](https://coveralls.io/repos/github/pchaigno/hewbot/badge.svg?branch=master)](https://coveralls.io/github/pchaigno/hewbot?branch=master)

Hewbot is a chat bot built on the [Hubot][hubot] framework.

[hubot]: http://hubot.github.com

### Running Hewbot Locally

If you don't have a Node.js environment set up, you can use the provided Dockerfile:
```
$ docker-compose up
```
Alternatively, if you already have Node.js installed:
```
$ bin/hubot --adapter shell --name hewbot
```
You'll see some start up output and a prompt:
```
[Sat Feb 28 2015 12:38:27 GMT+0000 (GMT)] INFO Using default redis on localhost:6379
hewbot>
```
Then you can interact with hewbot by typing `hewbot help`.
```
hewbot> hewbot help
hewbot animate me <query> - The same thing as `image me`, except adds [snip]
hewbot help - Displays all of the help commands that hewbot knows about.
...
```

### Running Hewbot on IRC

The Dockerfile allows you to send Hewbot on IRC:
```
HUBOT_ADAPTER=irc HUBOT_NAME=[hewbot_nickname] HUBOT_IRC_ROOMS='#[channel]' docker-compose up
```
Or, with a registered nickname:
```
HUBOT_ADAPTER=irc HUBOT_NAME=[hewbot_nickname] HUBOT_IRC_NICKSERV_PASSWORD=[password] HUBOT_IRC_ROOMS='#[channel]' docker-compose up
```
See [Dockerfile](Dockerfile) for other possible environment variables.


### Contributing

Please check out our [contribution guidelines](CONTRIBUTING.md).


### License

This projet is under [MIT license](LICENSE).
