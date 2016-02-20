# Description:
#   Monitors modifications of web resources.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot watch http[s]://[url] - Adds a web resource to the list of monitored resources.
#   hubot stop watching http[s]://[url] - Removes a web resource from the list.
#   hubot what are you watching? - Returns the list of web resources to monitor.
#
# Author:
#   Paul Chaignon <paul.chaignon@gmail.com>

crypto = require "crypto"

computeHash = (body) ->
    return crypto.createHash("sha256").update(body).digest("base64")

module.exports = (robot) ->
  robot.respond /watch (https?:\/\/[^\s]+)$/, (res) ->
    resource = res.match[1]
    robot.http(resource).get() (err, response, body) ->
      if err
        res.reply "Are you sure about that url?"
        res.send "#{err}"
      else
        hash = computeHash(body)
        resources = robot.brain.get('web_resources') or []
        resources.push(res.match[1])
        robot.brain.set 'web_resources', resources
        robot.brain.set "web_resources:#{resource}", hash
        res.reply "Resource looks good. I'll keep you informed."

  robot.respond /stop watching (https?:\/\/[^\s]+)$/, (res) ->
    resources = robot.brain.get('web_resources') or []
    if res.match[1] in resources
      resources = resources.filter (resource) -> resource isnt res.match[1]
      robot.brain.set 'web_resources', resources
      res.reply "Less work? Aww..."
    else
      res.reply "I'm not :/"

  robot.respond /what are you watching?/, (res) ->
    res.reply robot.brain.get('web_resources')
