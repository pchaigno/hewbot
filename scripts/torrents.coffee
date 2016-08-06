# Description:
#   Monitors new torrents.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot check torrents - Returns a list of new torrents (since the last check).
#
# Author:
#   Paul Chaignon <paul.chaignon@gmail.com>
request = require "request"
BloomFilter = require("bloomfilter").BloomFilter

RARBG_API_ENDPOINT = 'https://torrentapi.org/pubapi_v2.php?'
OMDB_API_ENDPOINT = 'https://www.omdbapi.com?'
PERIODIC_CHECKS_INTERVAL = 5 * 60 * 1000
DAY_INTERVAL = 24 * 60 * 60 * 1000
NB_HASH_FUNCTIONS = 7
SIZE_BLOOM_FILTERS = 1000

periodicCheckId = null
lastSwitchBloomFilters = 0
bfPreviousDay = null
bfCurrentDay = null


currentTime = () ->
  return new Date().getTime() 


humanFileSize = (bytes, threshold) ->
  if Math.abs(bytes) < threshold
    return bytes + 'B'
  units =  ['KiB','MiB','GiB','TiB','PiB','EiB','ZiB','YiB']
  if threshold is 1000
    units = ['kB','MB','GB','TB','PB','EB','ZB','YB']
  u = -1
  while Math.abs(bytes) >= threshold && u < units.length - 1
    bytes /= threshold
    u++
  return bytes.toFixed(1) + units[u]


newBloomFilter = () ->
  return 


stringifyBloomFilter = (bf) ->
  if bf is null
    return null
  array = [].slice.call(bf.buckets)
  return JSON.stringify array


loadBloomFilter = (bfString) ->
  console.log bfString
  if bfString is null
    return null
  return new BloomFilter JSON.parse bfString, NB_HASH_FUNCTIONS


switchBloomFilters = (robot) ->
  lastSwitchBloomFilters = currentTime()
  bfPreviousDay = bfCurrentDay
  bfCurrentDay = new BloomFilter SIZE_BLOOM_FILTERS, NB_HASH_FUNCTIONS
  robot.brain.set 'current_bf_torrents', stringifyBloomFilter bfCurrentDay
  robot.brain.set 'previous_bf_torrents', stringifyBloomFilter bfPreviousDay


addTorrent = (robot, torrentName) ->
  console.log "torrent added: #{torrentName}"
  bfCurrentDay.add torrentName
  robot.brain.set 'current_bf_torrents', stringifyBloomFilter bfCurrentDay


addTorrents = (robot, torrents) ->
  for torrent in torrents
    console.log "torrent added: #{torrent.title}"
    bfCurrentDay.add torrent.title
  robot.brain.set 'current_bf_torrents', stringifyBloomFilter bfCurrentDay


torrentUnseenBefore = (torrentName) ->
  if bfCurrentDay.test torrentName
    return false
  if bfPreviousDay isnt null and bfPreviousDay.test torrentName
    return false
  return true


getIMDBRating = (torrent) ->
  imdbid = torrent.episode_info.imdb
  imdbApiURL = "#{OMDB_API_ENDPOINT}i=#{imdbid}"
  console.log("Request {imdbApiURL}")
  request.get { uri: imdbApiURL, json: true }, (err, response, body) ->
    if err
      console.log err
    else
      filesize = humanFileSize torrent.size, 1024
      console.log "#{torrent.title}: #{filesize} #{body.imdbRating}"


initializeBFCurrentDay = (robot, torrents) ->
  console.log "nb_torrents: #{torrents.length}"
  bfCurrentDay = new BloomFilter SIZE_BLOOM_FILTERS, NB_HASH_FUNCTIONS
  addTorrents robot torrents


getListTorrents = (robot, token) ->
  listURL = "#{RARBG_API_ENDPOINT}limit=100&format=json_extended&mode=list&token=#{token}&category=14;17;42;44;45;46;47;48&sort=leechers&by=DESC"
  console.log("Request #{listURL}")
  request.get { uri: listURL, json: true }, (err, response, body) ->
    if err
      console.log(err)
    else
      if bfCurrentDay is null
        initializeBFCurrentDay(robot, body.torrent_results)
      else
        console.log("nb_torrents = #{body.torrent_results.length}")
        for torrent in body.torrent_results
          if torrentUnseenBefore(torrent.title)
            addTorrent robot, torrent.title
            getIMDBRating torrent


checkTorrents = (robot, room) ->
  console.log("Checking torrents...")
  if lastSwitchBloomFilters < currentTime() - DAY_INTERVAL
    switchBloomFilters robot
  tokenURL = "#{RARBG_API_ENDPOINT}get_token=get_token"
  console.log("Request #{tokenURL}")
  request.get { uri: tokenURL, json: true }, (err, response, body) ->
    if err
      console.log(err)
    else
      getListTorrents(robot, body.token)


init = (robot) ->
  console.log("Initializing...")
  if periodicCheckId is null
    room = process.env.HUBOT_IRC_ROOMS.split(',')[0]
    console.log(robot.brain.get 'current_bf_torrents')
    bfCurrentDay = loadBloomFilter(robot.brain.get 'current_bf_torrents' or null)
    bfPreviousDay = loadBloomFilter(robot.brain.get 'previous_bf_torrents' or null)
    console.log bfCurrentDay
    periodicCheckId = setInterval(checkTorrents, PERIODIC_CHECKS_INTERVAL, robot, room)


module.exports = (robot) ->
  robot.brain.on 'loaded', (_) ->
    init(robot)

  robot.respond /check torrents/, (res) ->
    checkTorrents robot, res.envelope.room
