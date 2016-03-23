class MessagesController < ApplicationController
  include ActionController::Live

  def index
    @messages = Message.all
  end

  def create
    @message = Message.create!(message_params)
    $redis.publish('message.create', @message.to_json)
  end

  def events
    response.headers["Content-Type"] = "text/event-stream"
    start = Time.zone.now
    redis = Redis.new
    redis.subscribe('message.create') do |on|
      on.message do |event, data|
        response.stream.write("data: #{data}\n\n")
      end
    end
  rescue IOError
    logger.info "Stream closed"
  ensure
    redis.quit
    response.stream.close
  end

  private

  def message_params
    params.require(:message).permit(:name, :content)
  end
end
