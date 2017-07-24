require_relative '../lib/datadog_sync'

monitor_id = ARGV[0].to_i
bail "You must specify a monitor_id" if monitor_id == 0

filepath = DatadogSync.new.save_monitor_to_file(monitor_id)

cwd = Pathname.new(ENV['PWD'])
puts "Definition for monitor #{monitor_id} written to #{filepath.relative_path_from(cwd)}"
