require 'bundler/setup'
require 'digest'
require 'json'
# require 'byebug'
require 'pry'

$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'datadog_sync'

namespace :metrics do
  desc "Download metrics to temp dir"
  task :download do |t|
    ruby "bin/metrics/download_metrics.rb"
  end

  desc "Count up information about metrics"
  task :count do |t|
    ruby "bin/metrics/count_metric_types.rb"
  end
end

namespace :tags do
  desc "Download tag data to temp files"
  task :download do |t|
    ruby "bin/metrics/download_tags.rb"
  end

  desc "Count up the number of tags used"
  task :count do |t|
    ruby "bin/metrics/count_tags.rb"
  end
end

["monitor", "screenboard", "timeboard"].each do |resource|
  namespace resource do
    desc "Download #{resource} from datadog (by id)"
    task :get, :id do |_t, args|
      ruby "bin/get_#{resource}.rb #{args.id}"
    end

    desc "Download #{resource} from datadog (by filename)"
    task :refresh, :name do |_t, args|
      begin
        id = JSON.parse(File.read("#{resource}s/generated/#{args.name}.json"))["id"]
        ruby "bin/get_#{resource}.rb #{id}"
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
