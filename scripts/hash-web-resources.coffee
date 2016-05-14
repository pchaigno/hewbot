crypto = require 'crypto'

module.exports = {
  computeHash: (body, contentType) ->
    return crypto.createHash("sha256").update(body).digest("base64")
}
