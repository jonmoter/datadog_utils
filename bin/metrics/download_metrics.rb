#!/usr/bin/env ruby
require 'uri'
require 'dotenv'
require 'net/http'
require 'json'

Dotenv.load
outfile = File.dirname(__FILE__) + '/metrics.json'

api_key = ENV.fetch('DATADOG_API_KEY')
app_key = ENV.fetch('DATADOG_APPLICATION_KEY')
from = (Time.now - 60*60*24).to_i

uri = URI.parse("https://app.datadoghq.com/api/v1/metrics?api_key=#{api_key}&application_key=#{app_key}&from=#{from}")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request)

unless response.code == '200'
  puts "ERROR: #{response.body}"
  exit(1)
end

data = JSON.parse(response.body)

File.write(outfile, response.body)
puts "Got #{data['metrics'].count} metrics. Output JSON data to #{outfile}"
