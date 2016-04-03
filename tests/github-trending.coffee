Helper = require('hubot-test-helper')
helper = new Helper('./../scripts/github-trending.coffee')

Promise = require('bluebird')
co = require('co')
expect = require('chai').expect
nock = require('nock')

describe 'github-trending', ->

  beforeEach ->
    @room = helper.createRoom(httpd: false)

  context "user asks for the trending repositories", ->
    beforeEach ->
      nock('https://github.com').get('/trending').replyWithFile(200, 'tests/test_reponses/trending.html')
      co =>
        @room.user.say 'john', "hubot trending"
        new Promise.delay(100)

    it 'gets the trending projects', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['john', 'hubot trending']
        ['hubot', 'airbnb/caravel, thejameskyle/the-super-tiny-compiler, firehol/netdata, FreeCodeCamp/FreeCodeCamp, kenwheeler/cash, kadirahq/react-storybook, ptmt/react-native-desktop, googlesamples/android-architecture, itsabot/abot, toddmotto/public-apis, dylang/npm-check, jianliaoim/talk-os, Microsoft/BotBuilder, eastlakeside/interpy-zh, forward3d/uphold, rustcc/RustPrimer, typicode/hotel, druid-io/druid, vhf/free-programming-books, mortenjust/cleartext-mac, txusballesteros/welcome-coordinator, Rogero0o/CatLoadingView, amzn/alexa-avs-raspberry-pi, opentok/one-to-one-sample-apps, twbs/bootstrap']
      ]


  context "user asks for the trending repositories in python language", ->
    beforeEach ->
      nock('https://github.com').get('/trending/python').replyWithFile(200, 'tests/test_reponses/trending-python.html')
      co =>
        @room.user.say 'john', "hubot trending-python"
        new Promise.delay(100)

    it 'gets the python trending projects', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['john', 'hubot trending-python']
        ['hubot', 'airbnb/caravel, eastlakeside/interpy-zh, tflearn/tflearn, owocki/pytrader, EntilZha/PyFunctional, tweekmonster/tmux2html, vinta/awesome-python, gongjianhui/AppleDNS, yoavz/music_rnn, azazel75/metapensiero.pj, hardmaru/cppn-gan-vae-tensorflow, YosaiProject/yosai, rg3/youtube-dl, tushar-rishav/code2pdf, joshmaker/python-php, pallets/flask, XX-net/XX-Net, amirouche/AjguDB, ResidentMario/missingno, django/django, yasoob/intermediatePython, scrapy/scrapy, letsencrypt/letsencrypt, scikit-learn/scikit-learn, borgbackup/borg']
      ]


  context "user asks for informations on a project", ->
    beforeEach ->
      nock('https://github.com').get('/pchaigno/hewbot').replyWithFile(200, 'tests/test_reponses/pchaigno-hewbot.html')
      co =>
        @room.user.say 'john', "hubot trending pchaigno/hewbot"
        new Promise.delay(100)

    it 'returns the project title', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['john', 'hubot trending pchaigno/hewbot']
        ['hubot', 'A customized Hubot']
      ]


  context "user asks for informations on a project that does not exists", ->
    beforeEach ->
      nock('https://github.com').get('/bad_user/bad_project').reply(404)
      co =>
        @room.user.say 'john', "hubot trending bad_user/bad_project"
        new Promise.delay(100)

    it 'fails silently', ->
      expect(nock.isDone()).to.be.true
      expect(@room.messages).to.eql [
        ['john', 'hubot trending bad_user/bad_project']
      ]
