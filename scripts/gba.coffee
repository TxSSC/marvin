# Description:
#   Commands to remotely control gameboy instance
#
# Commands:
#   hubot gba load <file> - Load the rom <file>.gba
#   hubot gba <button> <number> - Emulate a button press <button> <number> times

GBA_URL = process.env.HUBOT_GBA_URL

module.exports = (robot) ->

  robot.respond /load\s+(.*)$/i, (msg) ->
    rom = msg.match[1]

    robot
      .http(GBA_URL)
      .query({
        load: rom
      })
      .post() (err, res, body) ->
        if res.statusCode == 200
          msg.send("Loading #{rom}.gba")
        else
          msg.send("There was a problem loading #{rom}.gba")

  robot.respond /gba\s+(\w+)\s*(\d+)?/i, (msg) ->
    c = msg.match[1]
    n = msg.match[2] || 1

    msg
      .http(GBA_URL)
      .query({ push: c, times: n })
      .post() (err, res, body) ->
        if res.statusCode == 200
          msg.send("Pushing #{c} #{n} times")
        else
          msg.send("There was a problem executing that")
