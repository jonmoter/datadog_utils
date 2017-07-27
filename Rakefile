require 'bundler/setup'
require 'digest'
require 'json'
require 'pry'

$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'common'
require 'datadog_sync'

namespace :metrics do
  desc "Download metrics to data subdirectory"
  task :download do |_t|
    data = DatadogClient.get('metrics', from: (Time.now - 60*60*24).to_i)
    json = JSON.parse(data)

    outfile = Utils.save_file('metrics', JSON.pretty_generate(json))
    puts "Got #{json['metrics'].count} metrics. Output JSON data to #{outfile}"
  end

  desc "Count up information about metrics [MATCH, LIMIT, MIN_SIZE]"
  task :count do |_t|
    infile = Utils.filepath('metrics')
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

    i = 0
    counts.to_a.sort_by(&:last).reverse.each do |metric, value|
      break if ENV['MIN_SIZE'] && value < ENV['MIN_SIZE'].to_i
      next if ENV['MATCH'] && !metric.include?(ENV['MATCH'])

      puts "#{value}\t#{metric}"
      i += 1
      break if ENV['LIMIT'] && i >= ENV['LIMIT'].to_i
    end
  end
end

namespace :tags do
  desc "Download tag data to temp files"
  task :download do |_t|
    data = DatadogClient.get('tags/hosts')
    outfile = Utils.save_file('tags_by_host', data)

    json = JSON.parse(data)
    puts "Got #{json['tags'].count} unique tags. Output JSON data to #{outfile}"
  end

  desc "Count up the number of tags used"
  task :count do |t|
    infile = Utils.filepath('tags_by_host')
    metrics = JSON.parse(File.read(infile))['tags']
    tag_count = 0

    counts = metrics.each_with_object({}) do |(tag, host_list), hash|
      tag_count += 1
      tag_parts = tag.split(':')
      tag_value = tag_parts[-1]
      tag_name = tag_parts[0..-2].join(':')

      hash[tag_name] ||= {}
      hash[tag_name][tag_value] = host_list.length
    end

    puts "Found #{counts.keys.length} tag categories, #{tag_count} total tags"

    Utils.save_file('tag_counts', JSON.pretty_generate(counts))
  end
end

["monitor", "screenboard", "timeboard"].each do |resource|
  namespace resource do
    desc "Download #{resource} from datadog (by id)"
    task :get, :id do |_t, args|
      DatadogSync.new.send("save_#{resource}_to_file", args.id, name: args.id)
    end

    desc "Download all #{resource}s from datadog."
    task :get_all do |_t|
      puts "Getting all #{resource} definitions from datadog..."
      DatadogSync.new.send("save_all_#{resource}s")
    end

    desc "Download #{resource} from datadog (by filename)"
    task :refresh, :name do |_t, args|
      begin
        id = JSON.parse(File.read("#{resource}s/generated/#{args.name}.json"))["id"]
        DatadogSync.new.send("save_#{resource}_to_file", id, name: id.to_s)
      rescue SystemCallError
        fail "Unable to locate a saved dashboard with that name"
      end
    end

    desc "Update datadog #{resource} (by filename)"
    task :update, :name do |_t, args|
      definition = DefinitionReader.find_dashboard(args.name)
      board = DashboardBuilder.build(definition)
      board.send_to_datadog!
    end
  end
end
