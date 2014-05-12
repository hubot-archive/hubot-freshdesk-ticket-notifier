# Description
#   A hubot script for tracking any webhook events from the Freskdesk support tool.
#
# Configuration:
#   None
#
# Commands:
#   HUBOT_FRESHDESK_NOTIFIER_TEMPLATE - Custom template from payload data. (optional)
#   HUBOT_FRESHDESK_NOTIFIER_ROOM - Default room to drop messages into.
#
# URLS:
#   POST /hubot/freshdesk-hook[?room=<room>]
#
# Notes:
#   * Docs for creating webhook via Observer and Dispatch'r:
#     https://support.freshdesk.com/support/articles/132589-using-webhooks-in-the
#   * Use RequestBin to find out the names payload keys for generating custom templates:
#     http://requestb.in
#
# Author:
#   patcon@gittip

config =
  template:      process.env.HUBOT_FRESHDESK_NOTIFIER_TEMPLATE
  room:          process.env.HUBOT_FRESHDESK_NOTIFIER_ROOM

defaults =
  template: "[Freshdesk] New {{ticket_priority}}-priority support ticket {{{ticket_url}}}"
  room:     config.room

url      = require('url')
qs       = require('querystring')
Mustache = require('mustache')

module.exports = (robot) ->
  robot.router.post "/hubot/freshdesk-hook/new", (req, res) ->
    uri = url.parse(req.url)
    query = qs.parse(uri.query)

    room = query.room or defaults.room
    template = config.template or defaults.template
    data = req.body.freshdesk_webhook

    message = Mustache.render template, data

    robot.messageRoom room, message

    # End the response? Not doc'd.
    res.end()
