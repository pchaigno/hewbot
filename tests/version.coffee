Helper = require('hubot-test-helper')
expect = require('chai').expect

# helper loads a specific script if it's a file
helper = new Helper('./../scripts/version.coffee')

describe 'version', ->

  beforeEach ->
    @room = helper.createRoom(httpd: false)

  context "user ask for the Hubot version", ->
    beforeEach ->
      @room.user.say 'john', "hubot: what's your current version?"

    it 'encourage user to take a bouncer', ->
      expect(@room.messages).to.eql [
        ['john', "hubot: what's your current version?"]
        ['hubot', "@john I'm at version #{@room.robot.version}"]
      ]
