ssdeep = require 'ssdeep'
htmlToText = require 'html-to-text'
fs = require 'fs'

extractText = (body) ->
  return htmlToText.fromString body

removeSpaces = (body) ->
  return body.replace(/\s+/g, ' ')

module.exports = {
  computeHash: (body, contentType) ->
    if contentType and /text\/html/.test(contentType)
      body = extractText(body)
      body = removeSpaces(body)
    return ssdeep.hash(body)
}
