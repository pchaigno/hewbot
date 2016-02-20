Helper = require('hubot-test-helper')
helper = new Helper('./../scripts/watch-web-resources.coffee')

Promise = require('bluebird')
co = require('co')
expect = require('chai').expect

describe 'watch-web-resources', ->
  beforeEach ->
    @room = helper.createRoom(httpd: false)

  context 'pchaigno wants to monitor a new web resource', ->
    beforeEach ->
      co =>
        yield @room.user.say 'pchaigno', 'hubot: watch https://github.com'
        yield new Promise.delay(1000)

    it 'saves the resource in memory after checking it', ->
      expect(@room.messages).to.eql [
        ['pchaigno', 'hubot: watch https://github.com']
        ['hubot', "@pchaigno Resource looks good. I'll keep you informed."]
      ]
      expect(@room.robot.brain.get('web_resources')).to.eql ['https://github.com']

  context 'pchaigno wants to monitor an inexistant web resource', ->
    beforeEach ->
      co =>
        yield @room.user.say 'pchaigno', 'hubot: watch https://orangesummerofcode.com'
        yield new Promise.delay(1000)

    it 'returns the error message', ->
      expect(@room.messages).to.eql [
        ['pchaigno', 'hubot: watch https://orangesummerofcode.com']
        ['hubot', "@pchaigno Are you sure about that url?"]
        ['hubot', 'Error: getaddrinfo ENOTFOUND orangesummerofcode.com orangesummerofcode.com:443']
      ]
      expect(@room.robot.brain.get('web_resources')).to.eql null

  context 'someone asks for the list of monitored web resources', ->
    beforeEach ->
      @room.robot.brain.set 'web_resources', ['https://github.com']
      @room.user.say 'bob', 'hubot: what are you watching?'

    it "answers with the list of monitored web resources", ->
      expect(@room.messages).to.eql [
        ['bob', 'hubot: what are you watching?']
        ['hubot', "@bob https://github.com"]
      ]

  context 'pchaigno does not care for github.com anymore', ->
    beforeEach ->
      @room.robot.brain.set 'web_resources', ['https://github.com']
      @room.user.say 'pchaigno', 'hubot: stop watching https://github.com'

    it 'removes github.com from the web resources to monitor', ->
      expect(@room.messages).to.eql [
        ['pchaigno', 'hubot: stop watching https://github.com']
        ['hubot', "@pchaigno Less work? Aww..."]
      ]
      expect(@room.robot.brain.get('web_resources')).to.eql []
