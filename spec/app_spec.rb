require 'rspec'
require 'rack/test'
require_relative 'spec_helper'
require_relative '../app'

RSpec.describe 'Traefik Dashboard App' do
  include Rack::Test::Methods

  def app
    TraefikDashboardApp
  end

  before(:each) do
    allow(YAML).to receive(:load_file).and_return({
      'traefik' => { 'url' => 'http://localhost:8080', 'username' => 'user', 'password' => 'pass' },
      'ignore' => []
    })
    allow(Router).to receive(:all).and_return([
      Router.new('service' => 'router1', 'name' => 'router1', 'status' => 'enabled', 'tls' => {}, 'rule' => 'Host(`example.com`)'),
      Router.new('service' => 'router2', 'name' => 'router2', 'status' => 'disabled', 'tls' => nil, 'rule' => 'Host(`example.org`)')
    ])
  end

  describe 'GET /' do
    it 'loads the dashboard' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to include('router1')
    end
  end

  describe 'helpers' do
    let(:app_instance) { app.new! }

    describe '#fetch_routers' do
      it 'fetches and filters routers' do
        routers = app_instance.fetch_routers
        expect(routers.map(&:name)).to eq(['router1'])
      end
    end

    describe '#get_icon' do
      it 'returns a default icon if no icon is found' do
        icon_url = app_instance.get_icon('service', 'example.com', 'https')
        expect(icon_url).to include('fakeimg.pl')
      end
    end
  end
end
