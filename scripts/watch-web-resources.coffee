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
#   hubot watch [url] - Adds a web resource to the list of monitored resources.
#   hubot stop watching [url] - Removes a web resource from the list.
#   hubot what are you watching? - Returns the list of web resources to monitor.
#
# Author:
#   Paul Chaignon <paul.chaignon@gmail.com>

request = require "request"
hasher = require './hash-web-resources.coffee'

PERIODIC_CHECKS_INTERVAL = 60000
MAX_SIZE_DOWNLOADED_FILES = 1000000
periodicCheckId = null
firstPeriodicCheck = true

changedWebResources = (robot, room) ->
  resources = robot.brain.get('web_resources') or {}
  for resource, hash of resources
    changedWebResource(robot, room, resource, hash)

changedWebResource = (robot, room, resource, hash) ->
  size = 0
  request "http://#{resource}", (err, response, body) ->
      newHash = null
      if err
        newHash = 0
      else if response.statusCode is 200
        newHash = hasher.computeHash body, response.headers['content-type']
        if newHash is hash
          newHash = null
      else
        newHash = response.statusCode
      if newHash isnt null
        callbackChangedResource(robot, resource, newHash, room)
  .on 'data', (chunk) ->
    size += chunk.length
    if size > MAX_SIZE_DOWNLOADED_FILES
      this.abort()
      resources = robot.brain.get('web_resources') or {}
      delete resources[resource]
      robot.brain.set 'web_resources', resources
      robot.messageRoom room, "#{resource} is becoming too big for me..."


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
    periodicCheckId = setInterval(periodicCheck, PERIODIC_CHECKS_INTERVAL, robot, room)

module.exports = (robot) ->
  robot.brain.on 'loaded', (_) ->
    if periodicCheckId is null
      init(robot)

  robot.respond /watch ((?:https?:\/\/)?([^\s]+))$/, (res) ->
    resource = res.match[1]
    if not /^https?:\/\//.test(resource)
      resource = "http://#{resource}"
    size = 0
    request resource, (err, response, body) ->
      if err
        res.reply "Are you sure about that url?"
        res.send "#{err}"
      else if response.statusCode is 200
        hash = hasher.computeHash body, response.headers['content-type']
        resources = robot.brain.get('web_resources') or {}
        resources[res.match[2]] = hash
        robot.brain.set 'web_resources', resources
        if firstPeriodicCheck
          room = res.envelope.room
          if typeof room is "undefined"
          # Direct message, we need to find the room where we last saw the user.
            room = robot.brain.userForName(res.message.user.name).room
          robot.brain.set 'room_web_resources', room
          periodicCheckId = setInterval(periodicCheck, PERIODIC_CHECKS_INTERVAL, robot, room)
        res.reply "Resource looks good. I'll keep you informed."
      else
        res.reply "The resource seems unavailable: #{response.statusMessage}"
    .on 'data', (chunk) ->
      size += chunk.length
      if size > MAX_SIZE_DOWNLOADED_FILES
        this.abort()
        res.reply "That's too big for me..."

  robot.respond /stop watching ((?:https?:\/\/)?([^\s]+))$/, (res) ->
    resources = robot.brain.get('web_resources') or {}
    if res.match[1] of resources
      delete resources[res.match[1]]
    else if res.match[2] of resources
      delete resources[res.match[2]]
    else
      res.reply "I'm not :/"
      return
    robot.brain.set 'web_resources', resources
    res.reply "Less work? Aww..."

  robot.respond /what are you watching?/, (res) ->
    resources = robot.brain.get('web_resources')
    if resources is null
      res.reply "Nothing :'("
    else
      resources = Object.keys(resources)
      if resources is 0
        res.reply "Nothing :'("
      else
        res.reply resources.join(', ')

  robot.respond /did any web resource change?/, (res) ->
    changedWebResources(robot, res)
