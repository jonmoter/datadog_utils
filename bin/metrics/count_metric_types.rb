#!/usr/bin/env ruby
#
# Script that reads the metrics found in metrics.json, and does some
# analysis on what kind of metrics they are.

require 'json'

infile = File.dirname(__FILE__) + '/metrics.json'
metrics = JSON.parse(File.read(infile))['metrics']

counts = metrics.each_with_object({}) do |metric, hash|
  parts = metric.split('.')
  value = if parts[0] == 'zendesk'
    parts[0] + '.' + parts[1]
  else
    parts[0]
  end
  hash[value] ||= 0
  hash[value] += 1
end

counts.to_a.sort_by(&:last).reverse.each do |metric, value|
  puts "#{value}\t#{metric}"
end
