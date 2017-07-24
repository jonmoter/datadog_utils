#!/usr/bin/env ruby
require 'uri'
require 'dotenv'
require 'net/http'
require 'json'

Dotenv.load
outfile = File.dirname(__FILE__) + '/tags.json'

api_key = ENV.fetch('DATADOG_API_KEY')
app_key = ENV.fetch('DATADOG_APPLICATION_KEY')

uri = URI.parse("https://app.datadoghq.com/api/v1/tags/hosts?api_key=#{api_key}&application_key=#{app_key}")

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
puts "Got #{data['tags'].count} unique tags. Output JSON data to #{outfile}"
