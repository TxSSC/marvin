# Description:
#   Get a random koan
#
# Dependencies:
#   "coffee-script": ">=1.7.0"
#
# Commands:
#   hubot enlighten me - Generate a zen koan

ZEN = [
  """A monk asked Joshu, a Chinese Zen master: \"Has a dog Buddha-nature or not?\"
  Joshu answered: \"Mu.\""""

  """Gutei raised his finger whenever he was asked a question about Zen. A boy attendant began to imitate him in this way. When anyone asked the boy what his master had preached about, the boy would raise his finger.
  Gutei heard about the boy's mischief. He seized him and cut off his finger. The boy cried and ran away. Gutei called and stopped him. When the boy turned his head to Gutei, Gutei raised up his own finger. In that instant the boy was enlightened.
  When Gutei was about to pass from this world he gathered his monks around him. \"I attained my finger-Zen,\" he said, \"from my teacher Tenryu, and in my whole life I could not exhaust it.\" Then he passed away."""

  """Wakuan complained when he saw a picture of bearded Bodhidharma: \"Why hasn't that fellow a beard?\""""

  """Kyogen said: \"Zen is like a man hanging in a tree by his teeth over a precipice. His hands grasp no branch, his feet rest on no limb, and under the tree another person asks him: 'Why did Bodhidharma come to China from India?'\"
  If the man in the tree does not answer, he fails; and if he does answer, he falls and loses his life. Now what shall he do?\""""

  """When Buddha was in Grdhrakuta mountain he turned a flower in his fingers and held it before his listeners. Every one was silent. Only Maha-Kashapa smiled at this revelation, although he tried to control the lines of his face.
  Buddha said: \"I have the eye of the true teaching, the heart of Nirvana, the true aspect of non-form, and the ineffable stride of Dharma. It is not expressed by words, but especially transmitted beyond teaching. This teaching I have given to Maha-Kashapa.\""""

  """A monk told Joshu: \"I have just entered the monastery. Please teach me.\"
  Joshu asked: \"Have you eaten your rice porridge?\"
  The monk replied: \"I have eaten.\"
  Joshu said: \"Then you had better wash your bowl.\"
  At that moment the monk was enlightened."""

  """Getsuan said to his students: \"Keichu, the first wheel-maker of China, made two wheels of fifty spokes each. Now, suppose you removed the nave uniting the spokes. What would become of the wheel? And had Keichu done this, could he be called the master wheel-maker?\""""

  """A monk asked Seijo: \"I understand that a Buddha who lived before recorded history sat in meditation for ten cycles of existence and could not realize the highest truth, and so could not become fully emancipated. Why was this so?\"
  Seijo replied: \"Your question is self-explanatory.\"
  The monk asked: \"Since the Buddha was meditating, why could he not fulfill Buddhahood?\"
  Seijo said: \"He was not a Buddha.\""""

  """A monk named Seizei asked of Sozan: \"Seizei is alone and poor. Will you give him support?\"
  Sozan asked: \"Seizei?\"
  Seizei responded: \"Yes, sir.\"
  Sozan said: \"You have Zen, the best wine in China, and already have finished three cups, and still you are saying that they did not even wet your lips.\""""

  """Joshu went to a place where a monk had retired to meditate and asked him: \"What is, is what?\"
  The monk raised his fist.
  Joshu replied: \"Ships cannot remain where the water is too shallow.\" And he left.
  A few days later Joshu went again to visit the monk and asked the same question.
  The monk answered the same way.
  Joshu said: \"Well given, well taken, well killed, well saved.\" And he bowed to the monk."""

  """Zuigan called out to himself every day: \"Master.\"
  Then he answered himself: \"Yes, sir.\"
  And after that he added: \"Become sober.\"
  Again he answered: \"Yes, sir.\"
  \"And after that,\" he continued, \"do not be deceived by others.\"
  \"Yes, sir; yes, sir,\" he answered."""
]

module.exports = (robot) ->

  robot.respond /enlighten( me)?/i, (msg) ->
    msg.reply msg.random(ZEN)
