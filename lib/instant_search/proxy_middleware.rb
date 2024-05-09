# frozen_string_literal: true

# Proxies requests to the Typesense server via the Rails app transparently
class InstantSearch::ProxyMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if true || SiteSetting.instant_search_enabled
      if env["PATH_INFO"].start_with?("/typesense/")
        proxy(env)
      else
        @app.call(env)
      end
    else
      @app.call(env)
    end
  end

  def proxy(env)
    request = Rack::Request.new(env)
    server = JSON.parse(SiteSetting.typesense_nodes, symbolize_names: true).first

    uri =
      URI(
        "#{server[:protocol]}://#{server[:host]}:#{server[:port]}#{request.fullpath.sub("/typesense", "")}",
      )
    req = Net::HTTP::Post.new(uri.request_uri)
    req.body = request.body.read
    req["Content-Type"] = "application/json"
    # Not needed as users have their scoped API keys
    #req["X-TYPESENSE-API-KEY"] = SiteSetting.instant_search_api_key
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    res = http.request(req)

    # tell me why
    headers = res.to_hash.transform_values(&:first)
    headers.delete("transfer-encoding")

    [res.code.to_i, headers, [res.body]]
  end
end
