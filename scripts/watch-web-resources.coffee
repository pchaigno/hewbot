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

PERIODIC_CHECKS_INTERVAL = 10000
periodicCheckId = null
firstPeriodicCheck = true

computeHash = (body) ->
  return crypto.createHash("sha256").update(body).digest("base64")

changedWebResources = (robot, room) ->
  resources = robot.brain.get('web_resources') or {}
  for resource, hash of resources
    changedWebResource(robot, room, resource, hash)

changedWebResource = (robot, room, resource, hash) ->
  robot.http(resource).get() (err, response, body) ->
      newHash = null
      if err
        newHash = 0
      else if response.statusCode is 200
        newHash = computeHash body
        if newHash is hash
          newHash = null
      else
        newHash = response.statusCode
      if newHash isnt null
        callbackChangedResource(robot, resource, newHash, room)

callbackChangedResource = (robot, resource, newHash, room) ->
  # There might be concurrent accesses to web_resources here.
  # Need a way to prevent integrity issues.
  resources = robot.brain.get('web_resources') or {}
  resources[resource] = newHash
  robot.brain.set 'web_resources', resources
  robot.messageRoom room, "#{resource} changed"

periodicCheck = (robot, room) ->
  if firstPeriodicCheck
    firstPeriodicCheck = false
  else
    resources = robot.brain.get('web_resources')
    if resources is null
      clearInterval(periodicCheckId)
      firstPeriodicCheck = true
    else
      changedWebResources(robot, room)

init = (robot) ->
  resources = robot.brain.get('web_resources')
  room = robot.brain.get('room_web_resources')
  if resources isnt null and room isnt null
    setInterval(periodicCheck, PERIODIC_CHECKS_INTERVAL, robot, room)

module.exports = (robot) ->
  init(robot)

  robot.respond /watch (https?:\/\/[^\s]+)$/, (res) ->
    resource = res.match[1]
    robot.http(resource).get() (err, response, body) ->
      if err
        res.reply "Are you sure about that url?"
        res.send "#{err}"
      else if response.statusCode is 200
        hash = computeHash(body)
        resources = robot.brain.get('web_resources') or {}
        resources[res.match[1]] = hash
        robot.brain.set 'web_resources', resources
        if firstPeriodicCheck
          room = res.envelope.room
          robot.brain.set 'room_web_resources', room
          periodicCheckId = setInterval(periodicCheck, PERIODIC_CHECKS_INTERVAL, robot, room)
        res.reply "Resource looks good. I'll keep you informed."
      else
        res.reply "The resource seems unavailable: #{response.statusMessage}"

  robot.respond /stop watching (https?:\/\/[^\s]+)$/, (res) ->
    resources = robot.brain.get('web_resources') or {}
    if res.match[1] of resources
      delete resources[res.match[1]]
      robot.brain.set 'web_resources', resources
      res.reply "Less work? Aww..."
    else
      res.reply "I'm not :/"

  robot.respond /what are you watching?/, (res) ->
    resources = Object.keys(robot.brain.get('web_resources')) or []
    res.reply resources.join(', ')

  robot.respond /did any web resource change?/, (res) ->
    changedWebResources(robot, res)
