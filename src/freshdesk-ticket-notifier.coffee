# Description
#   A hubot script for tracking any webhook events from the Freskdesk support tool.
#
# Configuration:
#   HUBOT_FRESHDESK_NOTIFIER_TEMPLATE - Custom template from payload data. (optional)
#   HUBOT_FRESHDESK_NOTIFIER_ROOM - Default room to drop messages into.
#
# Commands:
#   None.
#
# URLS:
#   POST /hubot/freshdesk-hook/<action>[?room=<room>]
#
# Notes:
#   * Docs for creating webhook via Observer and Dispatch'r:
#     https://support.freshdesk.com/support/articles/132589-using-webhooks-in-the
#   * Use RequestBin to find out the names payload keys for generating custom templates:
#     http://requestb.in
#   * Two template variables are added to the data from the payload:
#     - `ticket_priority_stars` - priority converted to stars
#     - `action` - verb from endpoint url
#   * The "action" can be any endpoint, with one Freshdesk rule expected to
#     hit each. Hyphens/underscores in the action are converted into spaces in
#     the `action` template variable.
#   * The following are action suggestions for the default template:
#     - created
#     - closed
#     - updated-by-customer
#
# Author:
#   patcon@gittip

config =
  template:      process.env.HUBOT_FRESHDESK_NOTIFIER_TEMPLATE
  room:          process.env.HUBOT_FRESHDESK_NOTIFIER_ROOM

defaults =
  template: '[Freshdesk] #{{ticket_id}} ({{ticket_priority_stars}}) - Ticket {{action}}. {{{ticket_url}}}'
  room:     config.room

url      = require('url')
qs       = require('querystring')
Mustache = require('mustache')

module.exports = (robot) ->
  robot.router.post "/hubot/freshdesk-hook/:action", (req, res) ->
    uri = url.parse(req.url)
    query = qs.parse(uri.query)

    room = query.room or defaults.room
    template = config.template or defaults.template
    data = req.body.freshdesk_webhook

    # Augment the data object
    data.action = req.params.action.replace(/-_/g, " ")
    data.ticket_priority_stars = switch data.ticket_priority
      when "Low"
        "☆☆☆"
      when "Medium"
        "★☆☆"
      when "High"
        "★★☆"
      when "Urgent"
        "★★★"
      else
        console.log "No ticket_priority available in webhook payload. Add it via the Freshdesk UI."
        "Priority N/A"

    message = Mustache.render template, data

    robot.messageRoom room, message

    # End the response? Not doc'd.
    res.end()
