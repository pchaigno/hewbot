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

  context 'user without a bouncer enters the room', ->
    beforeEach ->
      room.robot.brain.users_without_bouncer = ['alice', 'bob']
      room.user.enter 'alice_'
      room.user.enter 'bob'

    it 'encourage user to take a bouncer', ->
      expect(room.messages).to.eql [
        ['hubot', "@alice_ Prend un bouncer s'il te plait."]
        ['hubot', "@bob Prend un bouncer s'il te plait."]
      ]

  context 'pchaigno points out an user without a bouncer', ->
    beforeEach ->
      room.user.say 'pchaigno', 'hubot: alice does not seem to have a bouncer'

    it 'saves the user without a bouncer in memory', ->
      expect(room.messages).to.eql [
        ['pchaigno', 'hubot: alice does not seem to have a bouncer']
        ['hubot', "@pchaigno I'll keep that in mind"]
      ]
      expect(room.robot.brain.users_without_bouncer).to.eql ['alice']

  context 'someone points out an user without a bouncer', ->
    beforeEach ->
      room.user.say 'joe', 'hubot: alice does not seem to have a bouncer'

    it 'asks pchaigno for confirmation', ->
      expect(room.messages).to.eql [
        ['joe', 'hubot: alice does not seem to have a bouncer']
        ['hubot', "pchaigno?"]
      ]
      expect(room.robot.brain.users_without_bouncer).to.eql undefined
