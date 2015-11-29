# Description:
#   Changes Hubot's name.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot ... change your name - Changes Hubot's name.
#
# Author:
#   Paul Chaignon <paul.chaignon@gmail.com>

module.exports = (robot) ->
  robot.respond /.*change your name(?: to (.*))?$/, (res) ->
    if res.message.user.name is 'pchaigno'
      if res.match[1] is undefined
        robot.name = 'hewbot'
        robot.alias = 'hewbot'
      else
        robot.name = res.match[1]
        robot.alias = res.match[1]
      res.reply 'done!'
    else
      res.send 'pchaigno?'
