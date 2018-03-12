# hubot-jenkins

Docker-compose.yml creates the following containers.
* redis
* hubot
* jenkins

Install hubot app in slack and get the required username and api token.


Pass the following environment values to hobot to connect to slack and jenkins.
* HUBOT_NAME: jenkinbot - slack username
* HUBOT_SLACK_TOKEN: slack_api_token
* HUBOT_JENKINS_URL: http://192.168.43.112:8010 - jenkins url
* HUBOT_JENKINS_AUTH: amjad:hussain - jenkins credentials
* HUBOT_JENKINS_CRUMB: 85440a3f1fd3222b379e3c113eaf4712 - jenkins crumb.

