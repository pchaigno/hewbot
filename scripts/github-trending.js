// Description:
//   get the latest trending repositories on github
//
// Dependencies:
//   cheerio
//   request
//
// Configuration:
//   None
//
// Commands:
//   trending          : list trending repositories (all languages)
//   trending-language : list trending repositories for the given language
//   trending project  : get general information for the given project
//

var cheerio = require('cheerio');
var request = require('request')

function extractRepositories(error, response, body, msg) {
  if (!error && response.statusCode == 200) {
    $ = cheerio.load(body);

    var results = [];

    $('h3').each(function(i, elem) {
      var link = $(this).children('a').attr("href");
      results.push(link.substring(1));
    });

    msg.send(results.join(', '));
  }
}

module.exports = function(robot) {

  robot.respond(/trending$/i, function(msg){
    request('https://github.com/trending', function(error, response, body) {
      extractRepositories(error, response, body, msg);
    });
  });

  robot.respond(/trending-(.*)$/i, function(msg){
    var language = msg.match[1];
    request('https://github.com/trending/'+language, function(error, response, body) {
      extractRepositories(error, response, body, msg);
    });
  });

  robot.respond(/trending (.*)$/i, function(msg){
    var project = msg.match[1];
    request('https://github.com/'+project, function(error, response, body){
      if (!error && response.statusCode == 200) {
        $ = cheerio.load(body);

        msg.send( $('.repository-meta-content').text().trim() );
      }
    });
  });

}
