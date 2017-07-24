#!/usr/bin/env ruby
require 'json'
require 'pry'

infile = File.dirname(__FILE__) + '/tags.json'
outfile = File.dirname(__FILE__) + '/tag_counts.json'

metrics = JSON.parse(File.read(infile))['tags']
tag_count = 0

counts = metrics.each_with_object({}) do |(tag, host_list), hash|
  tag_count += 1
  tag_parts = tag.split(':')
  tag_value = tag_parts[-1]
  tag_name = tag_parts[0..-2].join(':')

  # binding.pry

  hash[tag_name] ||= {}
  hash[tag_name][tag_value] = host_list.length
end

puts "Found #{counts.keys.length} tag categories, #{tag_count} total tags"
puts "Writing output to #{outfile}"
File.write(outfile, JSON.pretty_generate(counts))
