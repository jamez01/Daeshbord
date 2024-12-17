class TraefikDashboardApp 
  helpers do
    def auth!
      puts "API_KEY: #{session['api_key']}"
      puts "APY_KEY: #{API_KEY}"
      unless session['api_key'] == API_KEY
        flash[:error] = "Unauthorized"
        redirect '/' 
      end
    end
    # Fetch data from the Traefik API
    def fetch_routers
      routers = []
      @config['traefik']&.each do |traefik|
        Router.api_url = traefik['url']
        Router.user = traefik['usr']
        Router.password = traefik['password']
        routers << Router.all.reject {|router| 
          @config['ignore'].include?(router.service) || 
          !router.enabled? || 
          (!router.ssl? && @config['ignore_insecure'] ) || 
          router.hostnames.empty? || 
          router.hostnames.first.nil?
        }
      end
      routers.flatten
    rescue Errno::ECONNREFUSED => e
      flash[:error] = "Traefik is not available: #{e.message}"
      routers.flatten
    end

    def get_icon(router)
      SERVICE_LOGOS[router.service] ||= find_icon_url(router.service, router.hostnames.first, router.scheme)
      SERVICE_LOGOS[router.service]
    end

    # Find icon URL
    def find_icon_url(service, hostname, scheme)
      url = "#{scheme}://#{hostname}"
      puts "Finding icon for #{url}..."
      begin
        response = Net::HTTP.get_response(URI(url))
      rescue Errno::ECONNREFUSED, SocketError => e
        puts "Error fetching #{url}: #{e.message}"
      end
      redirect_limit = 5
      redirect_count = 0
      while response.is_a?(Net::HTTPRedirection)
        redirect_count += 1
        url = response['location']
        url = URI.join("#{scheme}://#{hostname}", url).to_s unless url.start_with?('http')
        begin
          response = Net::HTTP.get_response(URI(url))
        rescue Errno::ECONNREFUSED, SocketError => e
          puts "Error fetching #{url}: #{e.message}"
        end
        break if redirect_count >= redirect_limit
      end

      return nil unless response.is_a?(Net::HTTPOK)

      doc = Nokogiri::HTML(response.body)
      icon_urls = doc.css('link[rel~="icon"], link[rel~="shortcut icon"], link[rel~="apple-touch-icon"]').map { |link| link['href'] }
      icon_urls += doc.css('img').map { |img| img['src'] }
      icon_urls.each do |icon_url|
        icon_url = URI.join(url, icon_url).to_s unless icon_url.start_with?('http')
        response = Net::HTTP.get_response(URI(icon_url))
        return icon_url if response.is_a?(Net::HTTPOK) && response.content_type.start_with?('image/')
      end
      nil
    end


    def update_config(new_config)
      @config.merge!(new_config)
      Mutex.new.synchronize do
        File.open(CONFIG_FILE, 'w') { |file| file.write(@config.to_yaml) }
      end
    end
  end
end