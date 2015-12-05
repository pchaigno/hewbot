# Hewbot

Hewbot is a chat bot built on the [Hubot][hubot] framework.

[hubot]: http://hubot.github.com

### Running Hewbot Locally

If you don't have a Node.js environment set up, you can use the provided Dockerfile:
```
$ docker build .
$ docker run -it [container_id]
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
docker build .
docker run -e "ADAPTER=irc" -e "NAME=[hewbot_nickname]" -e "HUBOT_IRC_ROOMS=#[channel]" -it [container_id]
```
Or, with a registered nickname:
```
docker run -e "ADAPTER=irc" -e "HUBOT_IRC_NICKSERV_PASSWORD=[password]" -e "NAME=[hewbot_nickname]" -e "HUBOT_IRC_ROOMS=#[channel]" -it [container_id]
```
See [Dockerfile](Dockerfile) for other possible environment variables.


### Contributing

Please check out our [contribution guidelines](CONTRIBUTING.md).


### License

This projet is under [MIT license](LICENSE).
