Helper = require('hubot-test-helper')
helper = new Helper('./../scripts/watch-web-resources.coffee')

Promise = require('bluebird')
co = require('co')
expect = require('chai').expect
nock = require('nock')

describe 'watch-web-resources', ->

  beforeEach ->
    @room = helper.createRoom(httpd: false)

  context 'pchaigno wants to monitor a new web resource', ->
    beforeEach ->
      nock('https://github.com').get('/').reply(200, 'github page')
      co =>
        @room.user.say 'pchaigno', 'hubot: watch https://github.com'
        new Promise.delay(100)

    it 'saves the resource in memory after checking it', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['pchaigno', 'hubot: watch https://github.com']
        ['hubot', "@pchaigno Resource looks good. I'll keep you informed."]
      ]
      expect(Object.keys(@room.robot.brain.get('web_resources'))).to.eql ['github.com']
      expect(@room.robot.brain.get('room_web_resources')).to.eql 'room1'


  context "pchaigno wants to monitor a new web resource, but doesn't specify the protocol", ->
    beforeEach ->
      nock('http://travis-ci.org').get('/').reply(200, 'travis page')
      co =>
        @room.user.say 'pchaigno', 'hubot: watch travis-ci.org'
        new Promise.delay(100)

    it 'saves the resource in memory after checking it', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['pchaigno', 'hubot: watch travis-ci.org']
        ['hubot', "@pchaigno Resource looks good. I'll keep you informed."]
      ]
      expect(Object.keys(@room.robot.brain.get('web_resources'))).to.eql ['travis-ci.org']
      expect(@room.robot.brain.get('room_web_resources')).to.eql 'room1'


  context 'pchaigno wants to monitor an inexistant web resource', ->
    beforeEach ->
      nock('https://google.com').get('/').replyWithError('getaddrinfo ENOTFOUND orangesummerofcode.com orangesummerofcode.com:443')
      co =>
        @room.user.say('pchaigno', 'hubot: watch https://google.com')
        new Promise.delay(100)

    it 'returns the error message', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['pchaigno', 'hubot: watch https://google.com']
        ['hubot', "@pchaigno Are you sure about that url?"]
        ['hubot', 'Error: getaddrinfo ENOTFOUND orangesummerofcode.com orangesummerofcode.com:443']
      ]
      expect(@room.robot.brain.get('web_resources')).to.eql null


  context 'pchaigno wants to monitor a large file', ->
    beforeEach ->
      long_string = (new Array(10*1024*1024)).join("x")
      nock(/cdimage\.debian\.org/).get(/debian-8.3.0-amd64-CD-1\.iso$/).reply(200, long_string)
      co =>
        @room.user.say 'pchaigno', 'hubot: watch http://cdimage.debian.org/debian-cd/8.3.0/amd64/iso-cd/debian-8.3.0-amd64-CD-1.iso'
        new Promise.delay 100

    it 'returns the error message', ->
      expect(@room.messages).to.eql [
        ['pchaigno', 'hubot: watch http://cdimage.debian.org/debian-cd/8.3.0/amd64/iso-cd/debian-8.3.0-amd64-CD-1.iso']
        ['hubot', "@pchaigno That's too big for me..."]
      ]
      expect(@room.robot.brain.get('web_resources')).to.eql null


  context 'someone asks for the list of monitored web resources', ->
    beforeEach ->
      @room.robot.brain.set 'web_resources', {'github.com': ''}
      @room.user.say 'bob', 'hubot: what are you watching?'

    it "answers with the list of monitored web resources", ->
      expect(@room.messages).to.eql [
        ['bob', 'hubot: what are you watching?']
        ['hubot', "@bob github.com"]
      ]


  context 'someone asks for the list of monitored web resources', ->
    beforeEach ->
      @room.user.say 'bob', 'hubot: what are you watching?'

    it "answers that it's not watching anything", ->
      expect(@room.messages).to.eql [
        ['bob', 'hubot: what are you watching?']
        ['hubot', "@bob Nothing :'("]
      ]


  context 'pchaigno does not care for github.com anymore', ->
    beforeEach ->
      @room.robot.brain.set 'web_resources', {'github.com': ''}
      @room.user.say 'pchaigno', 'hubot: stop watching https://github.com'

    it 'removes github.com from the web resources to monitor', ->
      expect(@room.messages).to.eql [
        ['pchaigno', 'hubot: stop watching https://github.com']
        ['hubot', "@pchaigno Less work? Aww..."]
      ]
      expect(@room.robot.brain.get('web_resources')).to.eql {}


  context 'pchaigno asks if any web resource changed', ->
    beforeEach ->
      @room.robot.brain.set 'web_resources', {'github.com': '', 'twitter.com': ''}
      nock('http://twitter.com').get('/').reply(200, 'twitter page')
      nock('http://github.com').get('/').reply(200, 'github page')
      co =>
        @room.user.say 'pchaigno', 'hubot: did any web resource change?'
        new Promise.delay 100

    it 'answers with the url of the changed resources', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['pchaigno', 'hubot: did any web resource change?']
        ['hubot', "github.com changed"]
        ['hubot', "twitter.com changed"]
      ]
      expect(@room.robot.brain.get('web_resources')['github.com']).to.not.eql ''


  context 'pchaigno asks if any web resource changed', ->
    beforeEach ->
      nock(/.*/).get(/.*/).reply(404)
      @room.user.say 'pchaigno', 'hubot: did any web resource change?'

    it 'answers that nothing changed', ->
      expect(nock.isDone()).to.be.false
      expect(nock.pendingMocks()).to.eql ['GET /.*///.*/']
      expect(@room.messages).to.eql [
        ['pchaigno', 'hubot: did any web resource change?']
      ]


  context 'pchaigno asks if any web resource changed', ->
    beforeEach ->
      long_string = (new Array(10*1024*1024)).join("x")
      nock(/cdimage\.debian\.org/).get(/debian-8.3.0-amd64-CD-1\.iso$/).reply(200, long_string)
      @room.robot.brain.set 'web_resources', {'cdimage.debian.org/debian-cd/8.3.0/amd64/iso-cd/debian-8.3.0-amd64-CD-1.iso': ''}
      co =>
        @room.user.say 'pchaigno', 'hubot: did any web resource change?'
        new Promise.delay 100

    it 'answers that one of the resources became too big and was eliminated', ->
      expect(@room.messages).to.eql [
        ['pchaigno', 'hubot: did any web resource change?']
        ['hubot', 'cdimage.debian.org/debian-cd/8.3.0/amd64/iso-cd/debian-8.3.0-amd64-CD-1.iso is becoming too big for me...']
      ]
      expect(@room.robot.brain.get('web_resources')).to.eql {}
