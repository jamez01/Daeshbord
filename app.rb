require 'sinatra'
require 'json'
require 'yaml'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'sinatra/reloader' if development?
require_relative 'lib/router'
# Configuration file path
CONFIG_FILE = 'config.yml'

# Hash to store service logos
SERVICE_LOGOS = {}

# Load configuration
before do
  content_type :html
  @config = YAML.load_file(CONFIG_FILE) rescue {}
  @user = @config['traefik']['username']
  @password = @config['traefik']['password']
  @auth = @user && @password ? "#{@user}:#{@password}@" : ""
  @ignore = @config['ignore'] || []
end

helpers do
  # Fetch data from the Traefik API
  def fetch_routers
    Router.api_url = @config['traefik']['url']
    Router.user = @user
    Router.password = @password
    Router.all.reject {|router| @ignore.include?(router.name) || !router.enabled? || !router.ssl? || router.hostnames.empty? || router.hostnames.first.nil?}
  end

  def get_icon(service,hostname,scheme)
    puts service,hostname,scheme
    SERVICE_LOGOS[service] ||= find_icon_url(service, hostname,scheme)
    SERVICE_LOGOS[service]
  end

  # Find icon URL
  def find_icon_url(service, hostname, scheme)
    url = "#{scheme}://#{hostname}"
    puts "Finding icon for #{url}..."
    response = Net::HTTP.get_response(URI(url))
    redirect_limit = 5
    redirect_count = 0
    while response.is_a?(Net::HTTPRedirection)
      redirect_count += 1
      url = response['location']
      url = URI.join("#{scheme}://#{hostname}", url).to_s unless url.start_with?('http')
      puts "Following redirect to #{url}..."
      response = Net::HTTP.get_response(URI(url))
      break if redirect_count >= redirect_limit
    end

    return "https://fakeimg.pl/100x100/575757/54e3ff?text=#{service}" unless response.is_a?(Net::HTTPOK) 

    doc = Nokogiri::HTML(response.body)
    icon_urls = doc.css('link[rel~="icon"], link[rel~="shortcut icon"], link[rel~="apple-touch-icon"]').map { |link| link['href'] }
    icon_urls += doc.css('img').map { |img| img['src'] }
    icon_urls.each do |icon_url|
      icon_url = URI.join(url, icon_url).to_s unless icon_url.start_with?('http')
      response = Net::HTTP.get_response(URI(icon_url))
      puts "Using #{icon_url}..." if response.is_a?(Net::HTTPOK) && response.content_type.start_with?('image/')
      return icon_url if response.is_a?(Net::HTTPOK) && response.content_type.start_with?('image/')
    end
    "https://fakeimg.pl/100x100/575757/54e3ff?text=#{service}"
  end
end

get '/' do
  @routers = fetch_routers
  erb :dashboard
end