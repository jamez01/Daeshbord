require 'sinatra/base'
require 'json'
require 'yaml'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'sinatra/flash'
require_relative 'lib/router'
require 'securerandom' 
require 'bcrypt'

API_KEY = ENV['DAESH_API_KEY'] || SecureRandom.alphanumeric(32)

class TraefikDashboardApp < Sinatra::Base
  require 'sinatra/reloader' if development?

  configure :development do
    register Sinatra::Reloader
  end

  configure do
    set :users_file, 'users.yml'
    set :config_file, 'config.yml'
    set :config, {}
  end

  enable :sessions
  register Sinatra::Flash

  # Configuration file path
  DEFAULT_CONFIG= {
    'traefik' => [ { 'url' => 'http://localhost:8080' } ],
    'ignore' => [],
    'ignore_insecure' => true
  }
  

  # Hash to store service logos
  SERVICE_LOGOS = {}

  helpers do
    def load_config
      file_config = YAML.load_file(settings.config_file) rescue {}
      settings.config.merge!(DEFAULT_CONFIG.merge(file_config))
      settings.config['traefik'] = [settings.config['traefik']] if settings.config['traefik'].is_a?(Hash)
    end

    def load_users
      @users = YAML.load_file(settings.users_file, permitted_classes: [BCrypt::Password]) rescue {}
    end

    def save_users
      Mutex.new.synchronize do
        File.open(settings.users_file, 'w') { |f| f.write(@users.to_yaml) }
      end
    end

    def authorized?
      session[:user] && @users[session[:user]]
    end

    def admin?
      authorized? && @users[session[:user]]['role'] == 'admin'
    end

    def auth!
      redirect '/login' unless authorized?
    end

    def admin_auth!
      redirect '/login' unless admin?
    end
  end

  
  # Load configuration
  before do
    content_type :html
    load_config
    load_users
    session['api_key'] = params['api_key'] if params['api_key'] 
    session.clear if params['logout']
    if @users.empty? && request.path_info != '/setup'
      redirect '/setup'
    end
  end


  get '/' do
    @routers = fetch_routers
    erb :dashboard
  end

  get '/setup' do
    puts @users.inspect
    if @users.empty?
      erb :setup
    else
      redirect '/'
    end
  end

  post '/setup' do
    if @users.empty?
      @users[params[:user]] = {
        'password' => BCrypt::Password.create(params[:password]),
        'role' => 'admin'
      }
      save_users
      session[:user] = params[:user]
      redirect '/'
    else
      redirect '/login'
    end
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    user = @users[params[:username]]
    if user && BCrypt::Password.new(user['password']) == params[:password]
      session[:user] = params[:username]
      redirect '/'
    else
      flash[:error] = 'Invalid username or password'
      redirect '/login'
    end
  end

  get '/logout' do
    session.clear
    redirect '/login'
  end

  get '/ignore/:service' do |service|
    admin_auth!
    settings.config['ignore'] << service
    update_config({"ignore" => settings.config['ignore']})
    flash[:success] = "Service #{service} ignored/"
    redirect '/'
  end

  get '/edit/:service' do |service|
    admin_auth!
    # TODO
    redirect '/'
  end
end

require_relative 'lib/helpers'

TraefikDashboardApp.run! if __FILE__ == $0