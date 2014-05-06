# Description:
#   Get a random programmer's excuse
#
# Commands:
#   hubot give me an excuse - Generate a programmer excuse

EXCUSES = [
  "It works on my machine..."
  "Where were you when the program blew up?"
  "Why do you want to do it that way?"
  "You can't use that version on your system."
  "Did you try refreshing?"
  "Even though it doesn't work, how does it feel?"
  "Somebody must have changed my code."
  "It works, but it hasn't been tested."
  "This can't be the source of that!"
  "I can't test everything..."
  "It's just some unlucky coincidence."
  "You must have the wrong version"
  "I haven't touched that module in weeks!"
  "There has to be something funky in your data."
  "What did you type in wrong to get it to crash?"
  "It must be your computer."
  "How is that possible?"
  "It worked yesterday"
  "I've never seen that before."
  "That's weird..."
]

module.exports = (robot) ->

  robot.respond /give me an excuse/i, (msg) ->
    msg.reply msg.random(EXCUSES)
