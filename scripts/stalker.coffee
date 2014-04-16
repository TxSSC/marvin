# Description:
#   stalker.coffee uses Stalker, an open source API to see where your coworker are:
#     https://github.com/TxSSC/Stalker
#   Make sure you set up your HUBOT_STALKER_URL environment variable with the URL to
#   your company's stalker server.
#
# Commands:
#   hubot s <name> - An alias for `stalker <name>`
#   hubot s clear - An alias for `stalker clear`
#   hubot stalker <name> - Link your hubot user and stalker user accounts
#   hubot stalker clear - Clear your cached stalker data from hubot
#   hubot c <location> - Set your location to <location>
#   hubot c <location> b <time> - An alias for `custom <location> back <time>`
#   hubot custom <location> back <time> - Set your location to <location> and return time to <time>
#   hubot s info - An alias for `stalker info`
#   hubot stalker info - Show your currently set stalker data

STALKER_URL = process.env.HUBOT_STALKER_URL

module.exports = (robot) ->

  # Simple status
  robot.respond /(i(?:n)?|l(?:unch)?|o(?:ut)?)$/i, (msg) ->
    location = switch msg.match[1]
      when 'i', 'in' then 'In'
      when 'l', 'lunch' then 'Lunch'
      when 'o', 'out' then 'Out'

    data =
      location: location
      returning: ''

    setStatus(msg, data)

  # Custom messages, return time optional
  robot.respond /c(?:ustom)?\s+(.+)\s+b(?:ack)?\s+(.+)|c(?:ustom)?\s+(.+)/i, (msg) ->
    data =
      location: msg.match[1] || msg.match[3]
      returning: msg.match[2] || ''

    setStatus(msg, data)

  # Stalker settings based commands, tell|show, clear, set
  robot.respond /s(?:talker)?\s+(\w+)/i, (msg) ->
    switch msg.match[1]
      when 'clear' then clearUser(msg)
      when 'tell', 'show' then getLocation(msg)
      else setUser(msg, msg.match[1])

# Clear a User
clearUser = (msg) ->
  if msg.message.user.stalker?
    delete msg.message.user.stalker
    msg.send("I have already forgotten who you are.")
  else
    msg.send("Oh well, I knew nothing about you anyways.")

# Set or Create User
setUser = (msg, user) ->
  data = JSON.stringify({ name: user })

  if msg.message.user.stalker?
    # Already has a Stalker ID set
    msg.send("I already know you by #{capitalize(msg.message.user.stalker.name)}")
  else
    msg
      .http("#{STALKER_URL}/users")
      .headers('Content-Type': 'application/json')
      .get() (err, res, body) ->
        if res.statusCode != 200
          msg.send("Something went wrong linking your stalker account.")
        else
          users = JSON.parse(body)

          for u in users
            user = u if u.name.toLowerCase().indexOf(msg.match[1].toLowerCase()) > -1

          if user
            msg.message.user.stalker =
              id: user.id
              name: user.name

            msg.send("You're good to go!")
          else
            msg
              .http("#{STALKER_URL}/users")
              .headers('Content-Type': 'application/json')
              .post(data) (err, res, body) ->
                if res.statusCode != 201
                  error = JSON.parse(body)
                  msg.send("Something went wrong while creating your account. #{error.error}")
                else
                  user = JSON.parse(body)
                  msg.message.user.stalker =
                    id: user.id
                    name: user.name

                  msg.send("Ok you can stalk now!")

# PUT /users/:id
setStatus = (msg, data) ->
  user = msg.message.user

  unless user.stalker?
    msg.send("You must tell me who you are mystery person, try asking for some help.")
    return

  msg
    .http("#{STALKER_URL}/users/#{user.stalker.id}")
    .headers('Content-Type': 'application/json')
    .put(JSON.stringify(data)) (err, res, body) ->
      if res.statusCode != 200
        error = JSON.parse(body)
        msg.send("Whoops looks like there was an error setting your status: #{error.error}")
      else
        user = JSON.parse(body)

        if user.location? && user.location != '' &&
            user.returning? && user.returning != ''
          msg.send("You're now at #{user.location} and returning at #{user.returning}.")
        else
          msg.send("You're now #{user.location}")

# GET /users/:id
getLocation = (msg) ->
  user = msg.message.user

  unless user.stalker?
    msg.send("You must tell me who you are mystery person, try asking for some help.")
    return

  msg
    .http("#{STALKER_URL}/users/#{user.stalker.id}")
    .headers('Content-Type': 'application/json')
    .get() (err, res, body) ->
      if res.statusCode != 200
        error = JSON.parse(body)
        msg.send("Something has run amuck! #{error.error}")
      else
        user = JSON.parse(body)

        if !user.location? || user.location == ''
          msg.send("I'm afraid I know nothing about where you are.")
        else if user.returning? && user.returning != ''
          msg.send("I heard you were at #{user.location} and returning at #{user.returning}.")
        else
          msg.send("The last I heard you were #{user.location}")

# Return a capitalized name
capitalize = (name) ->
  name.charAt(0).toUpperCase() + name.slice(1)
