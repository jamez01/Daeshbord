require 'net/http'
require 'json'
class Router
  ROUTE_PATH='/api/http/routers'
  SINGLE_ROUTE_PATH='/api/http/router/'
  @@api_url = 'http://localhost:8080'
  @@api_user = false
  @@api_pass = false
  def self.api_url=(url)
    @@api_url = url&.chomp('/') 
  end

  def self.find(name)
    response = api_get("#{SINGLE_ROUTE_PATH}#{name}")
    router = JSON.parse(response) rescue {}
    Router.new(router)
  end

  def self.all
    response = api_get(ROUTE_PATH)
    JSON.parse(response).map {|router| Router.new(router)}
  end

  def self.auth
    @@api_user && @@api_pass ? "#{@@api_user}:#{@@api_pass}@" : ""
  end

  def self.user=(user)
    @@api_user = user
  end

  def self.password=(pass)
    @@api_pass = pass
  end
  attr_reader :entrypoints, :service, :rule, :name, :priority, :status, :tls  
  alias_method :entry_points, :entrypoints
  def initialize(traefik_router)
    @traefik_router = traefik_router
    @entrypoints = @traefik_router['entryPoints']
    @service = @traefik_router['service']
    @name = @traefik_router['name']
    @priority = @traefik_router['priority']
    @rule = @traefik_router['rule']
    @status = @traefik_router['status']
    @tls = @traefik_router['tls']
  end

  def enabled?
    @status == 'enabled'
  end

  def ssl?
    @tls.nil? ? false : true
  end

  def scheme
    @tls.nil? ? 'http' : 'https'
  end

  def hostnames
    hosts = @rule.match(/Host\(`([^`]+)`\)/i)
    hosts.nil? ? [] : hosts[1..-1]
  end

  private

  def self.api_get(path)
    puts "Fetching #{path}..."
    uri = URI("#{auth}#{@@api_url}#{path}")
    Net::HTTP.start(uri.host, uri.port, read_timeout: 5) do |http|
      request = Net::HTTP::Get.new(uri)
      http.request(request).body
    end
  end

end