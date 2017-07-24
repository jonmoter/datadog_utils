require 'dogapi'
require 'dotenv'

Dotenv.load

def bail(error, code: 1)
  puts "ERROR: #{error}" if error
  exit(code)
end

module DatadogClient
  def datadog_client
    $datadog_client ||= begin
      %w(DATADOG_API_KEY DATADOG_APPLICATION_KEY).each do |var|
        bail("You must specify #{var}") unless ENV[var]
      end

      Dogapi::Client.new(
        ENV.fetch('DATADOG_API_KEY'),
        ENV.fetch('DATADOG_APPLICATION_KEY')
      )
    end
  end
end
