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
end
