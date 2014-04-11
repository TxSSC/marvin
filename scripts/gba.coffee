# Description:
#   Commands to remotely control gameboy instance
#
# Commands:
#   hubot load <file> - Load the rom <file>.gba
#   hubot up <#> - Press the up button <#> times
#   hubot down <#> - Press the down button <#> times
#   hubot left <#> - Press the left button <#> times
#   hubot right <#> - Press the right button <#> times
#   hubot A <#> - Press the A button <#> times
#   hubot B <#> - Press the B button <#> times
#   hubot START <#> - Press the START button <#> times
#   hubot SELECT <#> - Press the SELECT button <#> times

GBA_URL = process.env.HUBOT_GBA_URL

module.exports = (robot) ->
  push_req = (req, msg) ->
    n = 1
    if msg.match[1]?
      n = msg.match[1]
    robot.http(GBA_URL+'/events')
      .query({
        push: req
        times: n
      })
      .post() (err, res, body) ->
        response = body
        msg.reply "Pushing "+req+" "+n+" times"

  robot.respond /LOAD (.*)$/i, (msg) ->
    query = msg.match[1]
    robot.http(GBA_URL+'/events')
      .query({
        load: query
      })
      .post() (err, res, body) ->
        response = body
        msg.reply "Loading "+response+".gba"

  robot.respond /UP\s*(\d+)?$/i, (msg) ->
    push_req('UP', msg)

  robot.respond /DOWN\s*(\d+)?$/i, (msg) ->
    push_req('DOWN', msg)

  robot.respond /LEFT\s*(\d+)?$/i, (msg) ->
    push_req('LEFT', msg)

  robot.respond /RIGHT\s*(\d+)?$/i, (msg) ->
    push_req('RIGHT', msg)

  robot.respond /A\s*(\d+)?$/i, (msg) ->
    push_req('A', msg)

  robot.respond /B\s*(\d+)?$/i, (msg) ->
    push_req('B', msg)

  robot.respond /L\s*(\d+)?$/i, (msg) ->
    push_req('L', msg)

  robot.respond /R\s*(\d+)?$/i, (msg) ->
    push_req('R', msg)

  robot.respond /START\s*(\d+)?$/i, (msg) ->
    push_req('START', msg)

  robot.respond /SELECT\s*(\d+)?$/i, (msg) ->
    push_req('SELECT', msg)
