# Description:
#   Encourages users to take an IRC bouncer.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot [user] does not seem to have a bouncer - Saves [user] in memory
#
# Author:
#   Paul Chaignon <paul.chaignon@gmail.com>

String::startsWith ?= (s) -> @slice(0, s.length) == s

module.exports = (robot) ->
  robot.enter (res) ->
    for user in robot.brain.users_without_bouncer
      if res.message.user.name.startsWith user
        res.reply "Prend un bouncer s'il te plait."

  robot.respond /([^\s]+) does not seem to have a bouncer/, (res) ->
    if res.message.user.name is 'pchaigno'
      users = robot.brain.users_without_bouncer or []
      users.push(res.match[1])
      robot.brain.users_without_bouncer = users
      res.reply "I'll keep that in mind"
    else
      res.send 'pchaigno?'

  robot.respond /who does not have a bouncer\?/, (res) ->
    users = robot.brain.users_without_bouncer or []
    users_text = users.join(', ')
    res.reply users_text

  robot.respond /([^\s]+) (now )?has a bouncer/, (res) ->
    if res.message.user.name is 'pchaigno'
      users = robot.brain.users_without_bouncer or []
      robot.brain.users_without_bouncer = users.filter (user) -> user isnt res.match[1]
      res.reply "Glad to hear that!"
    else
      res.send 'pchaigno?'
