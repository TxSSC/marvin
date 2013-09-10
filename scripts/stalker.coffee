# Description:
#   stalker.coffee uses Stalker, an open source API to see where your coworker are:
#     https://github.com/TxSSC/Stalker
#   Make sure you set up your HUBOT_STALKER_URL environment variable with the URL to
#   your company's stalker server.
#
# Commands:
#   I am stalker <name> - Link your hubot user and stalker user
#   I want to stop stalking - Clear your stalker data from hubot
#   hubot I'm at <location> - Set your current location and clear your return time
#   hubot <name> is at <location>
#   hubot Back at <time or date> - Set the time you will be back
#   hubot Going to <location> back at <time> - Set your current location and return time
#   hubot Im going <location> back <time> - Set your current location and return time
#   hubot Clear my location - Clear your set location
#   hubot Clear my return time - Clear your back time status
#   hubot Where am I? - List your current location
#   hubot Where is <name>? - Show the location of the user, for stalking
#   hubot Where is everyone? - Shows everyone's location

STALKER_URL = process.env.HUBOT_STALKER_URL

module.exports = (robot) ->

  robot.respond /(?:i'?m\s+)?at\s+([a-z A-Z0-9]+)/i, (msg) ->
    data =
      location: msg.match[1]
      returning: ''
    setStatus msg, robot, data

  robot.respond /(?:i'?m\s+)?going(?: to )?(.+) back (?:at )?(.+)/i, (msg) ->
    data =
      location: msg.match[1]
      returning: msg.match[2]
    setStatus msg, robot, data

  robot.respond /(.+)\s+is at\s+(.+)/i, (msg) ->
    data =
      user: msg.match[1]
      location: msg.match[2]
      returning: ''
    setStatus msg, robot, data

  robot.respond /back\s+(?:at\s+)?(.+)/i, (msg) ->
    data =
      returning: msg.match[1]
    setStatus msg, robot, data

  robot.respond /clear\s+(?:my\s+)?return(?:\s+time)?/i, (msg) ->
    data =
      returning: ''
    setStatus msg, robot, data

  robot.respond /clear\s+(?:my\s+)?location/i, (msg) ->
    data =
      location: ''
    setStatus msg, robot, data

  robot.respond /Where am I?/i, (msg) ->
    if !robot.brain.data.users[msg.message.user.id].stalker
      msg.send "You must become a stalker first young padawan"
      return

    id = msg.message.user.stalker
    getLocation id, msg, robot

  robot.respond /Where is(?:\s+)([[a-z A-Z0-9]+)/i, (msg) ->
    if msg.match[1] is "everyone"
      getEveryone msg, robot
    else
      getLocation msg, robot

  robot.hear /I am stalker(?:\s+)([a-z A-Z0-9]+)/i, (msg) ->
    setUser msg, robot

  robot.hear /I want to stop stalking/i, (msg) ->
    clearUser msg, robot

# Clear a User
clearUser = (msg, robot) ->
  if msg.message.user.stalker
    msg.message.user.stalker = null
    msg.send "I have cleared your stalker name"

# Set or Create User
setUser = (msg, robot) ->
  url = STALKER_URL + '/users'
  data = JSON.stringify({ name: msg.match[1] })

  if robot.brain.data.users[msg.message.user.id].stalker
    # Already has a Stalker ID set
    msg.send "It looks like you are already a stalker " + msg.match[1]
  else
    msg
      .http(url)
      .headers('Content-Type': 'application/json')
      .post(data) (err, res, body) ->
        if res.statusCode isnt 201
          error = JSON.parse body
          msg.send "Whoops looks like there was an error adding you: #{error.error}"
          return
        else
          user = JSON.parse body
          robot.brain.data.users[msg.message.user.id].stalker = user._id
          msg.send "Ok you can stalk now!"
          return

# PUT /users/:id
setStatus = (msg, robot, obj) ->
  user = msg.message.user

  if obj.user?
    users = robot.brain.usersForFuzzyName(obj.user)
    user = users[0] if users.length

    unless users.length is 1 and user.stalker?
      msg.send "I must know about #{obj.user} in order to stalk them"
      return

  url = STALKER_URL + '/users/' + user.stalker
  data = JSON.stringify(obj)
  msg
    .http(url)
    .headers('Content-Type': 'application/json')
    .put(data) (err, res, body) ->
      if res.statusCode isnt 200
        error = JSON.parse body
        msg.send "Whoops looks like there was an error setting your status: #{error.error}"
        return
      else
        user = JSON.parse body
        if Object.keys(obj).length is 1 and (obj.location? and
          user.location is '' or obj.returning? and user.returning is '')
            msg.send "I cleared that status."
            return
        else
          if obj.location? and obj.location isnt '' and obj.returning? and obj.returning isnt ''
            msg.send "#{user.name} is now at #{user.location} and will return #{user.returning}."
          else if obj.location? and obj.location isnt ''
            msg.send "#{user.name} is now at #{user.location}."
          else
            msg.send "#{user.name} will return #{user.returning}."
          return

# GET /users/:id OR Get a single user's location
getLocation = () ->
  args = Array.prototype.slice.call(arguments)
  robot = args.pop()
  msg = args.pop()
  id = args.pop()

  if id
    url = STALKER_URL + '/users/' + id
    msg
      .http(url)
      .headers('Content-Type': 'application/json')
      .get() (err, res, body) ->
        if res.statusCode isnt 200
          error = JSON.parse body
          msg.send "Whoops looks like there was an error getting your location: #{error.error}"
          return
        else
          user = JSON.parse body
          if user.location == ''
            msg.send "You don't have a location set"
            return
          else
            msg.send "Your at " + user.location
            return
  else
    url = STALKER_URL + '/users'
    msg
      .http(url)
      .headers('Content-Type': 'application/json')
      .get() (err, res, body) ->
        if res.statusCode isnt 200
          error = JSON.parse body
          msg.send "Whoops looks like there was an error...Oh long johnson!: #{error.error}"
          return
        else
          users = JSON.parse body
          user = (user for user in users when user.name == msg.match[1].toLowerCase())

          if user.length < 1
            msg.send msg.match[1].charAt(0).toUpperCase() + msg.match[1].slice(1) + " doesn't have a location set"
            return
          else
            msg.send msg.match[1].charAt(0).toUpperCase() + msg.match[1].slice(1) + " is at " + user[0].location
            return

# GET /users
getEveryone = () ->
  args = Array.prototype.slice.call(arguments)
  robot = args.pop()
  msg = args.pop()

  url = STALKER_URL + '/users'
  msg
    .http(url)
    .headers('Content-Type': 'application/json')
    .get() (err, res, body) ->
      if res.statusCode isnt 200
        error = JSON.parse body
        msg.send "Whoops looks like there was an error...Oh long johnson!: #{error.error}"
        return
      else
        users = JSON.parse body

        for user in users
          msg.send user.name.charAt(0).toUpperCase() + user.name.slice(1) + " is at " + user.location

        return