Helper = require('hubot-test-helper')
expect = require('chai').expect
helper = new Helper('./../scripts/torrents.coffee')

Promise = require('bluebird')
co = require('co')

describe 'torrents', ->

  beforeEach ->
    @room = helper.createRoom(httpd: false)

  context "user ask torrent list", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "hubot: check torrents"
        yield new Promise.delay(1500)

    it 'encourage user to take a bouncer', ->
      expect(@room.messages).to.eql [
        ['john', "hubot: check torrents"]
        ['hubot', "@john "]
      ]
