Helper = require('hubot-test-helper')
helper = new Helper('./../scripts/github-trending.js')

Promise = require('bluebird')
co = require('co')
expect = require('chai').expect

describe 'github-trending', ->
  this.timeout(5000)

  beforeEach ->
    @room = helper.createRoom(httpd: false)

  context "user asks for the trending repositories", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "hubot trending"
        yield new Promise.delay(2000)

    it 'gets the trending projects', ->
      expect(@room.messages[0]).to.eql ['john', "hubot trending"]
      expect(@room.messages[1]).to.match /((.+\/.+), ){9}(.+\/.+)/

  context "user asks for the trending repositories in python language", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "hubot trending-python"
        yield new Promise.delay(2000)

    it 'gets the python trending projects', ->
      expect(@room.messages[0]).to.eql ['john', "hubot trending-python"]
      expect(@room.messages[1]).to.match /((.+\/.+), ){9}(.+\/.+)/

  context "user asks for informations on a project", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "hubot trending /santinic/how2"
        yield new Promise.delay(2000)

    it 'gets the python trending projects', ->
      expect(@room.messages).to.eql [
        ['john', "hubot trending /santinic/how2"]
        ['hubot', "stackoverflow from the terminal"]
      ]

  context "user asks for informations on a project that does not exists", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "hubot trending /bad_user/bad_project"
        yield new Promise.delay(2000)

    it 'gets the python trending projects', ->
      expect(@room.messages).to.eql [
        ['john', "hubot trending /bad_user/bad_project"]
      ]
