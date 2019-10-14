class LinebotController < ApplicationController
  require "line/bot"

  def callback
    body = request.body.read
    signature = request.env["HTTP_X_LINE_SIGNATURE"]
    unless client.validate_signature(body, signature)
      error 400 do "Bad Request" end
    end
    events = client.parse_events_from(body)

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case events.type
        when Line::Bot::Event::MessageType::Type
          message = {
            type: "text",
            text: event.message["text"]
          }
        end
      end
      client.reply_message(event["reqlyToken"], message)
    end
    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new {
      config.channel_secret = Env["LINE_CHANNEL_SECRET"]
      config.channel_secret = Env["LINE_CHANNEL_TOKEN"]
    }
  end
end
