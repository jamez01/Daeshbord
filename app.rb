require 'sinatra/base'
require 'json'
require 'yaml'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'sinatra/flash'
require_relative 'lib/router'

API_KEY=ENV['TRAEFIK_DASH_API_KEY'] || ['a'..'z'].to_a.shuffle[0,8].join

class TraefikDashboardApp < Sinatra::Base
  require 'sinatra/reloader' if development?

  configure :development do
    register Sinatra::Reloader
  end

  enable :sessions
  register Sinatra::Flash

  # Configuration file path
  DEFAULT_CONFIG= {
    'traefik' => [ { 'url' => 'http://localhost:8080' } ],
    'ignore' => [],
    'ignore_insecure' => true
  }
  
  CONFIG_FILE = 'config.yml'

  # Hash to store service logos
  SERVICE_LOGOS = {}

  helpers do
    def load_config
      file_config = YAML.load_file(CONFIG_FILE) rescue {}
      @config = DEFAULT_CONFIG.merge(file_config)
      @config['traefik'] = [@config['traefik']] if @config['traefik'].is_a?(Hash)
    end
  end

  # Load configuration
  before do
    content_type :html
    load_config
    session['api_key'] = params['api_key'] if params['api_key'] 
    session.clear if params['logout']
  end


  get '/' do
    @routers = fetch_routers
    erb :dashboard
  end

  get '/ignore/:service' do |service|
    auth!
    @config['ignore'] << service
    update_config(ignore: @ignore)
    flash[:success] = "Service #{service} ignored/"
    redirect '/'
  end

  get '/edit/:service' do |service|
    auth!
    # TODO
    redirect '/'
  end
end

require_relative 'lib/helpers'

TraefikDashboardApp.run! if __FILE__ == $0