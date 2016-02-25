Helper = require('hubot-test-helper')
helper = new Helper('./../scripts/github-trending.js')

Promise = require('bluebird')
co = require('co')
expect = require('chai').expect

describe 'github-trending', ->
  beforeEach ->
    @room = helper.createRoom(httpd: false)

  context "user asks for the trending repositories", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "hubot trending"
        yield new Promise.delay(500)

    it 'gets the trending projects', ->
      expect(@room.messages).to.eql [
        ['john', "hubot trending"]
        ['hubot', "/dthree/cash - /FreeCodeCamp/FreeCodeCamp - /facebook/draft-js - /santinic/how2 - /copy/v86 - /ryanflorence/react-project - /ImagicalMine/ImagicalMine - /VPenkov/okayNav - /IBM-Swift/Kitura - /allenwong/30DaysofSwift - /dustturtle/RealReachability - /dthree/vorpal - /ampproject/amphtml - /legomushroom/mojs - /callmecavs/bricks.js - /xiepeijie/SwipeCardView - /gabrielrcouto/php-terminal-gameboy-emulator - /codrops/Animocons - /substance/substance - /Freelander/Android_Data - /Ramotion/circle-menu - /Zepo/MLeaksFinder - /veniversum/git-visualizer - /AllThingsSmitty/css-protips - /RFStorm/mousejack"]
      ]

  context "user asks for the trending repositories in python language", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "hubot trending-python"
        yield new Promise.delay(500)

    it 'gets the python trending projects', ->
      expect(@room.messages).to.eql [
        ['john', "hubot trending-python"]
        ['hubot', "/deepgram/sidomo - /snipsco/ntm-lasagne - /Zephrys/monica - /zero-db/zerodb - /timothycrosley/hug - /gleitz/howdoi - /ansible/ansible - /NathanEpstein/Dora - /mitsuhiko/flask - /letsencrypt/letsencrypt - /fchollet/keras - /rg3/youtube-dl - /soimort/you-get - /django/django - /openstack/bandit - /vinta/awesome-python - /XX-net/XX-Net - /tariqdaouda/pyGeno - /jflesch/paperwork - /donnemartin/data-science-ipython-notebooks - /p-e-w/maybe - /scikit-learn/scikit-learn - /kennethreitz/requests - /scrapy/scrapy - /jkbrzt/httpie"]
      ]

  context "user asks for informations on a project", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "hubot trending /santinic/how2"
        yield new Promise.delay(500)

    it 'gets the python trending projects', ->
      expect(@room.messages).to.eql [
        ['john', "hubot trending /santinic/how2"]
        ['hubot', "stackoverflow from the terminal"]
      ]

  context "user asks for informations on a project that does not exists", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "hubot trending /bad_user/bad_project"
        yield new Promise.delay(500)

    it 'gets the python trending projects', ->
      expect(@room.messages).to.eql [
        ['john', "hubot trending /bad_user/bad_project"]
      ]
