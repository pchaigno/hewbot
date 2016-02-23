Helper = require('hubot-test-helper')
helper = new Helper('./../node_modules/hubot-url-title/src/scripts/hubot-url-title.coffee')

Promise = require('bluebird')
co = require('co')
expect = require('chai').expect

describe 'hubot-url-title', ->
  beforeEach ->
    @room = helper.createRoom(httpd: false)

  context "user posts youtube video", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "https://www.youtube.com/watch?v=u-mRU44Q5u4"
        yield new Promise.delay(500)

    it 'posts the title of the video', ->
      expect(@room.messages).to.eql [
        ['john', "https://www.youtube.com/watch?v=u-mRU44Q5u4"]
        ['hubot', "AWS re:Invent 2015 | (SEC316) Harden Your Architecture w/ Security Incident Response Simulations - YouTube"]
      ]

  context "user posts a link to a PDF file", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "http://www.intel.fr/content/dam/doc/application-note/pci-sig-sr-iov-primer-sr-iov-technology-paper.pdf"
        yield new Promise.delay(500)

    it 'posts the title of the video', ->
      expect(@room.messages).to.eql [
        ['john', "http://www.intel.fr/content/dam/doc/application-note/pci-sig-sr-iov-primer-sr-iov-technology-paper.pdf"]
        ['hubot', "PCI-SIG SR-IOV Primer"]
      ]
