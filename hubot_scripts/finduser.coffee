module.exports = (robot) ->
  robot.respond /whoami/i, (msg) ->
    msg.send "#{msg.message.user.name}"
