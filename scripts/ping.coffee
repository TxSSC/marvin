# Description:
#   Utility route for ensuring hubot is up

module.exports = (robot) ->
  robot.router.get '/ping', (req, res) ->
    res.send(200, 'pong')
