crypto = require 'crypto'
htmlToText = require 'html-to-text'
fs = require 'fs'

extractText = (body) ->
  return htmlToText.fromString body

module.exports = {
  computeHash: (body, contentType) ->
    if contentType and /text\/html/.test(contentType)
      body = extractText(body)
    return crypto.createHash("sha256").update(body).digest("base64")
}
