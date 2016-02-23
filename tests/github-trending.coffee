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
        yield @room.user.say 'john', "trending"
        yield new Promise.delay(500)

    it 'get the trending projects', ->
      expect(@room.messages).to.eql [
        ['john', "trending"]
        ['hubot', "/facebook/draft-js - /santinic/how2 - /FreeCodeCamp/FreeCodeCamp - /IBM-Swift/Kitura - /VPenkov/okayNav - /necolt/Swifton - /qutheory/vapor - /ImagicalMine/ImagicalMine - /allenwong/30DaysofSwift - /callmecavs/bricks.js - /vulpino/jolteon - /Freelander/Android_Data - /realm/realm-js - /jaredpalmer/react-production-starter - /gleitz/howdoi - /sqren/fb-sleep-stats - /Thomas101/wmail - /kean/Nuke - /byoutline/kickmaterial - /lmatteis/peer-tweet - /unicodeveloper/laravel-hackathon-starter - /ArnaudValensi/docker-parse-server-git-deploy - /substance/substance - /brrd/Abricotine - /TomWithJerry/CoolAndroidAnim"]
      ]

  context "user asks for the trending repositories in python language", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "trending-python"
        yield new Promise.delay(500)

    it 'get the python trending projects', ->
      expect(@room.messages).to.eql [
        ['john', "trending-python"]
        ['hubot', "/gleitz/howdoi - /timothycrosley/hug - /defaultnamehere/zzzzz - /soimort/you-get - /letsencrypt/letsencrypt - /jflesch/paperwork - /vlall/darksearch - /Urinx/WeixinBot - /dizballanze/do-latency - /rg3/youtube-dl - /pluralsight/guides-cms - /dhruvramani/Terminal-on-FB-Messenger - /p-e-w/maybe - /XX-net/XX-Net - /vinta/awesome-python - /chrissimpkins/codeface - /kennethreitz/requests - /scrapy/scrapy - /lamerman/shellpy - /scikit-learn/scikit-learn - /Valloric/YouCompleteMe - /EliotBerriot/lifter - /praetorian-inc/pentestly - /mitsuhiko/flask - /jkbrzt/httpie"]
      ]

  context "user asks for informations on a project", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "trending /santinic/how2"
        yield new Promise.delay(500)

    it 'get the python trending projects', ->
      expect(@room.messages).to.eql [
        ['john', "trending /santinic/how2"]
        ['hubot', "stackoverflow from the terminal"]
      ]

  context "user asks for informations on a project that does not exists", ->
    beforeEach ->
      co =>
        yield @room.user.say 'john', "trending /bad_user/bad_project"
        yield new Promise.delay(500)

    it 'get the python trending projects', ->
      expect(@room.messages).to.eql [
        ['john', "trending /bad_user/bad_project"]
        ['hubot', ""]
      ]
