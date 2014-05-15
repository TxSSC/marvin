# Description:
#   Get a random koan
#
# Dependencies:
#   "coffee-script": ">=1.7.0"
#
# Commands:
#   hubot enlighten me - Generate a zen koan

ZEN = [
  """What is the straight within the bend?"""

  """You are at the top of the 100 foot high pole.
  How will you make a step further?"""

  """If you have the staff, I will give it to you.
  If you have no staff, I will take it away from you!"""

  """What is the straight within the bent?"""

  """Two hands clap and there is a sound;
  what is the sound of one hand?"""

  """Those who know don't talk.
  Those who talk don't know."""

  """Give evil nothing to oppose
  and it will disappear by itself."""

  """All streams flow to the sea
  because it is lower than they are.
  Humility gives it its power."""

  """Rather than make the first move
  it is better to wait and see.
  Rather than advance an inch
  it is better to retreat a yard."""

  """Thirty spokes join in one hub
  In its emptiness, there is the function of a vehicle."""

  """Mix clay to create a container
  In its emptiness, there is the function of a container."""

  """That which exists is used to create benefit
  That which is empty is used to create functionality."""

  """End sagacity; abandon knowledge
  The people benefit a hundred times."""

  """End benevolence; abandon righteousness
  The people return to piety and charity."""

  """End cunning; discard profit
  Bandits and thieves no longer exist."""

  """Those who understand others are intelligent
  Those who understand themselves are enlightened"""

  """Those who overcome others have strength
  Those who overcome themselves are powerful"""

  """Those who know contentment are wealthy
  Those who proceed vigorously have willpower"""

  """Those who do not lose their base endure
  Those who die but do not perish have longevity"""

  """The softest things of the world
  Override the hardest things of the world"""

  """That which has no substance
  Enters into that which has no openings"""

  """Fame or the self, which is dearer?
  The self or wealth, which is greater?
  Gain or loss, which is more painful?"""

  """Knowing contentment avoids disgrace
  Knowing when to stop avoids danger
  Thus one can endure indefinitely"""

  """What is your original face before you were born?"""

  """When you can do nothing, what can you do?"""

  """When the many are reduced to one, to what is the one reduced?"""

  """A monk saw a turtle in the garden of Daizui’s monastery and asked the teacher,
  “All beings cover their bones with flesh and skin.
  Why does this being cover its flesh and skin with bones?”
  Master Daizui took off one of his sandals and covered the turtle with it."""

  """What is the color of wind?"""
]

module.exports = (robot) ->

  robot.respond /enlighten( me)?/i, (msg) ->
    msg.reply msg.random(ZEN)
