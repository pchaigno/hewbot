ssdeep = require 'ssdeep'
htmlToText = require 'html-to-text'
fs = require 'fs'

extractText = (body) ->
  return htmlToText.fromString body

module.exports = {
  computeHash: (body, contentType) ->
    if contentType and /text\/html/.test(contentType)
      body = extractText(body)
    return ssdeep.hash(body)
}
