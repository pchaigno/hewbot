Helper = require('hubot-test-helper')
expect = require('chai').expect

# helper loads a specific script if it's a file
helper = new Helper('./../scripts/rename.coffee')

describe 'rename', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  afterEach ->
    room.destroy()

  context 'pchaigno asks Hubot to change its name', ->
    beforeEach ->
      room.user.say 'pchaigno', 'hubot: please change your name to patrick'

    it 'changes it name accordingly', ->
      expect(room.messages).to.eql [
        ['pchaigno', "hubot: please change your name to patrick"]
        ['patrick', "@pchaigno done!"]
      ]

  context 'pchaigno asks Hubot to take back its default name', ->
    beforeEach ->
      room.user.say 'pchaigno', 'hubot: please change your name'

    it 'changes it name accordingly', ->
      expect(room.messages).to.eql [
        ['pchaigno', "hubot: please change your name"]
        ['hewbot', "@pchaigno done!"]
      ]

  context 'someone asks Hubot to change its name', ->
    beforeEach ->
      room.user.say 'georges', 'hubot: please change your name'

    it 'asks pchaigno for confirmation', ->
      expect(room.messages).to.eql [
        ['georges', "hubot: please change your name"]
        ['hubot', "pchaigno?"]
      ]
