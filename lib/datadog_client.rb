require 'dogapi'

module DatadogClient
  class << self
    def client
      assert_env!

      @datadog_client ||= Dogapi::Client.new(api_key, application_key)
    end

    def get(endpoint, extra_params = {})
      assert_env!

      params = URI.encode_www_form(extra_params.merge(api_key: api_key, application_key: application_key))
      uri = URI.parse("https://app.datadoghq.com/api/v1/#{endpoint}?#{params}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      bail(response.body) unless response.code.to_i == 200
      response.body
    end

    private

    def api_key
      ENV.fetch('DATADOG_API_KEY')
    end

    def application_key
      ENV.fetch('DATADOG_APPLICATION_KEY')
    end

    def assert_env!
      %w(DATADOG_API_KEY DATADOG_APPLICATION_KEY).each do |var|
        bail("You must specify #{var}") unless ENV[var]
      end
    end
  end
end
