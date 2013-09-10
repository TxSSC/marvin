# Description:
#   Interface with whatsforlunch api from hubot
#
# Commands:
#   i'm hungry - get the highest rated location for today
#   whats for lunch - get the highest rated location for today
#   hubot lunch-locations - get all lunch locations
#   hubot lunch-locations add <name> - add a location for lunch
#   hubot lunch-locations delete <id> - delete the specific lunch location
#   hubot lunch-locations toggle-weight <id> <weekday> - toggle the weight for a particular day
#   hubot lunch-today - get the current choices for today
#   hubot lunch-vote <id | name> vote on the current locations

LUNCH_SERVER = process.env.HUBOT_LUNCH_URL

module.exports = (robot) ->

  robot.respond /(lunch-today|lunch-locations)$/i, (msg) ->
    if msg.match[1] is 'lunch-locations'
      locationDispatcher msg, 'get'
      return
    else
      todayDispatcher msg

  robot.respond /lunch-locations(?:\s+)(delete|add)(?:\s)([a-z A-Z0-9]+)$/i, (msg) ->
    if msg.match[1] is 'add'
      locationDispatcher msg, 'post'
      return
    else
      locationDispatcher msg, 'delete'
      return

  robot.respond /lunch-locations(?:\s+)toggle-weight(?:\s+)(\d+)(?:\s+)(\w+)/i, (msg) ->
    locationDispatcher msg, 'put'

  robot.respond /lunch-vote(?:\s+)([a-z A-Z0-9]+)/i, (msg) ->
    voteDispatcher msg

  robot.hear /(what'?s?(?:\s*)for(?:\s*)lunch|i'?m hungry)/i, (msg) ->
    todayDispatcher msg, true


#GET/POST/DELETE location
locationDispatcher = (msg, method) ->
  url = LUNCH_SERVER + '/location/'

  if method is 'get'
    msg.http(url)
        .get() (err, res, body) ->
          if res.statusCode isnt 200
            msg.send "Error retrieving locations from #{url}"
          else
            locations = JSON.parse body
            locations = sortLocations locations
            locations = locations.map (location) ->
              if !location.weight || !location.weight.length
                return "#{location.id} - #{location.name}"
              else
                return "#{location.id} - #{location.name} - #{location.weight.join(', ')}"
            msg.send "Locations:\n#{locations.join('\n')}"

  if method is 'post'
    data = JSON.stringify({ name: msg.match[2] })
    msg
      .http(url)
      .headers('Content-Type': 'application/json')
      .post(data) (err, res, body) ->
        if res.statusCode isnt 201
          error = JSON.parse body
          msg.send "Unable to create location: #{error.error}"
        else
          location = JSON.parse body
          msg.send "Created location: #{location.id} - #{location.name}"

  if method is 'put'
    if isNaN msg.match[1]
      msg.send 'Numeric id needed for the location'
    else
      data = JSON.stringify({ weight: msg.match[2] })
      msg
        .http(url + msg.match[1])
        .headers('Content-Type': 'application/json')
        .put(data) (err, res, body) ->
          if res.statusCode isnt 200
            error = JSON.parse body
            msg.send "Unable to update location: #{error.error}"
          else
            location = JSON.parse body
            msg.send "Updated location: #{location.id} - #{location.name} - #{location.weight.join(', ')}"

  if method is 'delete'
    if isNaN msg.match[2]
      msg.send "Numeric id needed for deleting a location"
    else
      msg
        .http(url + msg.match[2])
        .delete() (err, res, body) ->
          if res.statusCode isnt 200
            error = JSON.parse body
            msg.send "Unable to delete location: #{error.error}"
          else
            msg.send "Deleted #{msg.match[2]}"


#POST SERVER/lunch/vote - { id|name, votee }
voteDispatcher = (msg) ->
  url = LUNCH_SERVER + '/day/today'
  obj =
    voter: msg.message.user.name
  if isNaN msg.match[1]
    obj.name = msg.match[1]
  else
    obj.id = msg.match[1]
  msg
    .http(url)
    .headers('Content-Type': 'application/json')
    .put(JSON.stringify(obj)) (err, res, body) ->
      if res.statusCode isnt 200
        error = JSON.parse body
        msg.send "Error voting: #{error.error}"
      else
        msg.send "Vote accepted"


#GET server/lunch/ -> prints all choices from the server
todayDispatcher = (msg, highest=false) ->
  url = LUNCH_SERVER + '/day/today'
  msg
    .http(url)
    .headers(Accept: 'application/json')
    .get() (err, res, body) ->
      if res.statusCode isnt 200
        error = JSON.parse body
        msg.send "Error: #{error.error}"
      else
        locations = JSON.parse(body).locations
        locations = sortLocations locations
        if not highest
          locations = locations.map (location) ->
            return "#{location.id} - #{location.name}, Rating: #{location.rating}"
          msg.send "Todays Locations:\n#{locations.join('\n')}"
        else
          ratings = (location.rating for location in locations)
          highest = ratings.indexOf(Math.max.apply Math, ratings)
          location = locations[highest]
          msg.send "Top location: #{location.id} - #{location.name}, Rating: #{location.rating}"


#Sort the given array by id
sortLocations = (locations) ->
  bound = locations.length - 1

  for i in [0..bound]
    for j in [0..bound]
      if parseInt(locations[j].id) > parseInt(locations[i].id)
        temp = locations[i]
        locations[i] = locations[j]
        locations[j] = temp

  return locations