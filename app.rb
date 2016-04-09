ENV['RACK_ENV'] ||= 'development'
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'])

class App < Sinatra::Base
  configure :production do
    use Rack::SSL
  end

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
    set :slim, pretty: true, sort_attrs: false
  end

  get '/' do
    slim :index
  end

  post '/linebot/callback' do
    params = JSON.parse(request.body.read)

    params['result'].each do |msg|
      text ||= msg['content']['text']
      request_content = {
        to: [msg['content']['from']],
        toChannel: 1383378250, # Fixed value
        eventType: '138311608800106203', # Fixed value
        content: {
          contentType: 1,
          toType: 1,
          text: text
        }
      }

      endpoint_uri = 'https://trialbot-api.line.me/v1/events'
      content_json = request_content.to_json

      RestClient.proxy = ENV['FIXIE_URL']
      RestClient.post(endpoint_uri, content_json, {
        'Content-Type' => 'application/json; charset=UTF-8',
        'X-Line-ChannelID' => ENV['LINE_CHANNEL_ID'],
        'X-Line-ChannelSecret' => ENV['LINE_CHANNEL_SECRET'],
        'X-Line-Trusted-User-With-ACL' => ENV['LINE_CHANNEL_MID'],
      })
    end

    'OK'
  end
end
