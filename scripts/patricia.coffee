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
#   hubot [user] does not have a bouncer - Saves [user] in memory
#   hubot who does not have a bouncer? - List users without a bouncer from memory
#   hubot [user] (now)? has a bouncer - Remove [user] from memory
#
# Author:
#   Paul Chaignon <paul.chaignon@gmail.com>

String::startsWith ?= (s) -> @slice(0, s.length) == s

module.exports = (robot) ->
  robot.enter (res) ->
    users_without_bouncer = robot.brain.get('users_without_bouncer') or {}
    for user in users_without_bouncer
      if res.message.user.name.startsWith user
        res.reply "Prend un bouncer s'il te plait."

  robot.respond /([^\s]+) does not have a bouncer$/, (res) ->
    if res.message.user.name is 'pchaigno'
      users = robot.brain.get('users_without_bouncer') or []
      users.push(res.match[1])
      robot.brain.set 'users_without_bouncer', users
      res.reply "I'll keep that in mind"
    else
      res.send 'pchaigno?'

  robot.respond /who does not have a bouncer\?/, (res) ->
    users = robot.brain.get('users_without_bouncer') or []
    users_text = users.join(', ')
    res.reply users_text

  robot.respond /([^\s]+) (now )?has a bouncer/, (res) ->
    if res.message.user.name is 'pchaigno'
      users = robot.brain.get('users_without_bouncer') or []
      users_without_bouncer = users.filter (user) -> user isnt res.match[1]
      robot.brain.set 'users_without_bouncer', users_without_bouncer
      res.reply "Glad to hear that!"
    else
      res.send 'pchaigno?'
