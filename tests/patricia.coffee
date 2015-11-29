Helper = require('hubot-test-helper')
expect = require('chai').expect

# helper loads a specific script if it's a file
helper = new Helper('./../scripts/patricia.coffee')

describe 'patricia', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  afterEach ->
    room.destroy()

  context 'user enters the room', ->
    beforeEach ->
      room.user.enter 'spoonboy'
      room.user.enter 'ximepa'

    it 'should encourage user to take a bouncer', ->
      expect(room.messages).to.eql [
        ['hubot', '@spoonboy Prend un bouncer s\'il te plait.']
        ['hubot', '@ximepa Prend un bouncer s\'il te plait.']
      ]
