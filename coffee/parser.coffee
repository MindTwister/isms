sqlite3 = require 'sqlite3'
class Message
  constructor: (data) ->
    @address = data.id
    @date = data.date * 1000 + 978307201 * 1000
    @body = data.text
    @type = if data.is_from_me? then 2 else 1
    @service_center = data.service_center
  toString : ->
    return "<sms protocol='0' address='#{@address}' date='#{@date}' type='#{@type}' subject='null' body='#{@body}' toa='null' sc_toa='null' service_center='#{@service_center}' read='1' status='-1' locked='0' />"
class Parser
  parse : (callBack) ->
    @messages = []
    @db.each "SELECT * FROM message
	LEFT JOIN chat_message_join on chat_message_join.message_id = message.ROWID
	LEFT JOIN chat_handle_join on chat_handle_join.chat_id = chat_message_join.chat_id
	LEFT JOIN handle on chat_handle_join.handle_id = handle.ROWID", (err, row) =>
      @messages.push new Message row
    , =>
      strOut = "<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>"
      strOut += "<smses count='#{@messages.length}'>"
      strOut += m.toString() for m in @messages
      strOut += "</smses>"
      callBack strOut
  constructor: (file) ->
    @db = new sqlite3.Database file

module.exports = Parser


