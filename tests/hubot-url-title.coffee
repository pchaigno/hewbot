Helper = require('hubot-test-helper')
helper = new Helper('./../node_modules/hubot-url-title/src/scripts/hubot-url-title.coffee')

Promise = require('bluebird')
co = require('co')
expect = require('chai').expect
nock = require('nock')

describe 'hubot-url-title', ->
  beforeEach ->
    @room = helper.createRoom(httpd: false)

  context "user posts youtube video", ->
    beforeEach ->
      nock('https://www.youtube.com').get('/watch?v=u-mRU44Q5u4').replyWithFile(200, 'tests/test_reponses/youtube.html')
      co =>
        @room.user.say 'john', 'https://www.youtube.com/watch?v=u-mRU44Q5u4'
        new Promise.delay(100)

    it 'posts the title of the video', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['john', "https://www.youtube.com/watch?v=u-mRU44Q5u4"]
        ['hubot', "AWS re:Invent 2015 | (SEC316) Harden Your Architecture w/ Security Incident Response Simulations - YouTube"]
      ]
