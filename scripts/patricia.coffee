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
#   None
#
# Author:
#   Paul Chaignon <paul.chaignon@gmail.com>

module.exports = (robot) ->
  robot.enter (res) ->
    if res.message.user.name.match "^(spoonboy|ximepa)"
      res.reply "Prend un bouncer s'il te plait."
