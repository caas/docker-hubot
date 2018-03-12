#   Auth should be in the "user:password" format.
# Commands:
#   hubot jenkins build <job> - builds the specified Jenkins job
#   hubot jenkins last <job> - Details about the last build for the specified Jenkins job

querystring = require 'querystring'

auth_users = ["amjadhubot489", "amjad.syed", "amjadhussain3751"]

jenkinsBuild = (msg, buildWithEmptyParameters) ->
    url = process.env.HUBOT_JENKINS_URL
    #url = "http://192.168.43.112:8010"
    job = querystring.escape msg.match[1]
    params = msg.match[3]
    command = if buildWithEmptyParameters then "buildWithParameters" else "build"
    path = if params then "#{url}/job/#{job}/buildWithParameters?#{params}" else "#{url}/job/#{job}/#{command}?token=test"
    #HUBOT_JENKINS_AUTH = "amjad:hussain"
    req = msg.http(path)

    if process.env.HUBOT_JENKINS_AUTH
      auth = new Buffer(process.env.HUBOT_JENKINS_AUTH).toString('base64')
      req.headers Authorization: "Basic #{auth}"

    req.header('Content-Length', 0)
    req.header('Jenkins-Crumb', process.env.HUBOT_JENKINS_CRUMB)
    req.post() (err, res, body) ->
        if err
          msg.reply "Jenkins says: #{err}"
        else if 200 <= res.statusCode < 400 # Or, not an error code.
          msg.reply "(#{res.statusCode}) Build started for #{job} #{url}/job/#{job}"
        else if 400 == res.statusCode
          jenkinsBuild(msg, true)
        else if 404 == res.statusCode
          msg.reply "Build not found, double check that it exists and is spelt correctly."
        else
          msg.reply "Jenkins says: Status #{res.statusCode} #{body}"

jenkinsLast = (msg) ->
    url = process.env.HUBOT_JENKINS_URL
    #url = "http://192.168.43.112:8010"
    job = msg.match[1]

    path = "#{url}/job/#{job}/lastBuild/api/json"
    #HUBOT_JENKINS_AUTH = "amjad:hussain"
    req = msg.http(path)

    if process.env.HUBOT_JENKINS_AUTH
      auth = new Buffer(process.env.HUBOT_JENKINS_AUTH).toString('base64')
      req.headers Authorization: "Basic #{auth}"

    req.header('Content-Length', 0)
    req.header('Jenkins-Crumb', process.env.HUBOT_JENKINS_CRUMB)
    req.get() (err, res, body) ->
        if err
          msg.send "Jenkins says: #{err}"
        else
          response = ""
          try
            content = JSON.parse(body)
            response += "NAME: #{content.fullDisplayName}\n"
            response += "URL: #{content.url}\n"

            if content.description
              response += "DESCRIPTION: #{content.description}\n"

            response += "BUILDING: #{content.building}\n"
            response += "RESULT: #{content.result}\n"

            msg.send response


module.exports = (robot) ->
  robot.respond /j(?:enkins)? build ([\w\.\-_ ]+)(, (.+))?/i, (msg) ->
    if "#{msg.message.user.name}" in auth_users
       msg.send "Hi, Triggering the jenkins build. You can later check the status of the build."
       jenkinsBuild(msg, false)
    else
      msg.send "Error: your are not authorized to perform build"

  robot.respond /j(?:enkins)? last (.*)/i, (msg) ->
    jenkinsLast(msg)

  robot.jenkins = {
    build: jenkinsBuild,
    last: jenkinsLast
  }