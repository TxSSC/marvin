# Description:
#   stalker.coffee uses Stalker, an open source API to see where your coworkers are:
#     https://github.com/TxSSC/Stalker
#   Make sure you set up your HUBOT_STALKER_URL environment variable with the URL to
#   your company's stalker server.
#
# Commands:
#   hubot i - Set your status to In
#   hubot o - Set your status to Out
#   hubot l - Set your status to Lunch
#   hubot b <date|time> - Set your status to Back and return date/time to <date|time>
#   hubot stalker <name> - Link your hubot user and stalker user accounts
#   hubot stalker clear - Clear your cached stalker data from hubot
#   hubot at <location> back <date> - Set your location to <location> and return date to <date>
#   hubot stalker info - Show your currently set stalker data

STALKER_URL = process.env.HUBOT_STALKER_URL
STALKER_API_TOKEN = process.env.HUBOT_STALKER_TOKEN

module.exports = (robot) ->

  # Simple status
  robot.respond /(i(?:n)?|l(?:unch)?|o(?:ut)?)$/i, (msg) ->
    location = switch msg.match[1].toLowerCase()
      when 'i', 'in' then 'In'
      when 'l', 'lunch' then 'Lunch'
      when 'o', 'out' then 'Out'

    data =
      location: location
      back: null

    setStatus(msg, data)

  # Custom messages, location optional
  robot.respond /a(?:t)?\s+(.+)\s+b(?:ack)?\s+(.+)|b(?:ack)?\s+(.+)/i, (msg) ->
    back = msg.match[3] || msg.match[2]
    valid = validate(back)

    unless !valid
      msg.send(valid)
      return

    data =
      location: msg.match[1] || 'Back'
      back: strToDate(back)

    setStatus(msg, data)

  # Stalker settings based commands, tell|show, clear, set
  robot.respond /s(?:talker)?\s+(\w+)/i, (msg) ->
    switch msg.match[1]
      when 'clear' then clearUser(msg)
      when 'tell', 'show' then getLocation(msg)
      else setUser(msg, msg.match[1])

# Clear a User
clearUser = (msg) ->
  if msg.message.hip_user.stalker?
    delete msg.message.hip_user.stalker
    msg.send("I have already forgotten who you are.")
  else
    msg.send("Oh well, I knew nothing about you anyways.")

# Set or Create User
setUser = (msg, name) ->
  if msg.message.hip_user.stalker?
    # Already has a Stalker ID set
    msg.send("I already know you by #{capitalize(msg.message.hip_user.stalker.name)}")
  else
    msg
      .http("#{STALKER_URL}/api/users")
      .headers('Content-Type': 'application/json')
      .headers('Authorization': STALKER_API_TOKEN)
      .get() (err, res, body) ->
        if res.statusCode != 200
          msg.send("Something went wrong linking your stalker account.")
        else
          users = JSON.parse(body).users

          for u in users
            hip_user = u if u.name.toLowerCase().indexOf(name.toLowerCase()) > -1

          if hip_user
            msg.message.hip_user.stalker =
              id: hip_user.id
              name: hip_user.name

            msg.send("You're good to go!")
          else
            msg.send("You should probably create your account over at #{STALKER_URL} first.")

# PUT /users/:id
setStatus = (msg, data) ->
  hip_user = msg.message.hip_user

  unless hip_user.stalker?
    msg.send("You must tell me who you are mystery person, try asking for some help.")
    return

  msg
    .http("#{STALKER_URL}/api/users/#{hip_user.stalker.id}")
    .headers('Content-Type': 'application/json')
    .headers('Authorization': STALKER_API_TOKEN)
    .put(JSON.stringify(hip_user: data)) (err, res, body) ->
      if res.statusCode != 200
        msg.send("Whoops looks like there was an error setting your status")
      else
        hip_user = JSON.parse(body).user

        if hip_user.location? && hip_user.location != '' && hip_user.back? && hip_user.back != ''
          back = new Date(hip_user.back)
          msg.send("You're now #{hip_user.location} and will be back at #{back.toLocaleDateString()} #{back.toLocaleTimeString()}.")
        else
          msg.send("You're now #{hip_user.location}")

# GET /users/:id
getLocation = (msg) ->
  hip_user = msg.message.hip_user

  unless hip_user.stalker?
    msg.send("You must tell me who you are mystery person, try asking for some help.")
    return

  msg
    .http("#{STALKER_URL}/api/users/#{hip_user.stalker.id}")
    .headers('Content-Type': 'application/json')
    .headers('Authorization': STALKER_API_TOKEN)
    .get() (err, res, body) ->
      if res.statusCode != 200
        msg.send("Something has run amuck!")
      else
        hip_user = JSON.parse(body).user

        if !hip_user.location? || hip_user.location == ''
          msg.send("I'm afraid I know nothing about where you are.")
        else if hip_user.back? && hip_user.back != ''
          back = new Date(hip_user.back)
          msg.send("I heard you were at #{hip_user.location} and will be back at #{back.toLocaleDateString()} #{back.toLocaleTimeString()}.")
        else
          msg.send("The last I heard you were #{hip_user.location}")

# Return a capitalized name
capitalize = (name) ->
  name.charAt(0).toUpperCase() + name.slice(1)

# Validate a date/time
validate = (str) ->
  time = /^\d{1,2}:\d{2}\s*(am|pm)$/i
  datetime = /^\d{1,2}(\/|-)\d{1,2}(\/|-)\d{2,4}\s+\d{1,2}:\d{2}\s*(am|pm)$/i

  unless time.test(str) || datetime.test(str)
    "I would like an actual date and time in the format mm/dd/yyyy hh:mm am/pm"

# Convert human time string to valid date object
strToDate = (str) ->
  time = /(\d{1,2}):(\d{2})\s*(am|pm)$/i
  match = str.match(time)

  str = str.slice(0, str.length - match[0].length)
  hours = parseInt(match[1], 10)
  minutes = parseInt(match[2], 10)
  meridian = match[3]

  if str.length == 0
     str = new Date().toLocaleDateString() + " "

  if meridian == "am"
    str += hours + ":" + minutes
  else
    str += ((hours + 12) % 24) + ":" + minutes

  new Date(str)
