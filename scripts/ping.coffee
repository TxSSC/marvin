# Description:
#   Utility route for ensuring hubot is up
#
# URLS:
#   /ping

module.exports = (robot) ->
  robot.router.get '/ping', (req, res) ->
    res.send(200, 'pong')
