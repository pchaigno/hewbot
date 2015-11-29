# Description:
#   Advertises the current Hubot version.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot what ... version - Returns the Hubot version
#
# Author:
#   Paul Chaignon <paul.chaignon@gmail.com>

module.exports = (robot) ->
  robot.respond /what.*version/, (res) ->
    res.reply "I'm at version #{robot.version}"
