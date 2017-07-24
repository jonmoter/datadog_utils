require_relative '../lib/datadog_sync'

board_id = ARGV[0].to_i
bail "You must specify a board_id" if board_id == 0

filepath = DatadogSync.new.save_screenboard_to_file(board_id)

cwd = Pathname.new(ENV['PWD'])
puts "Definition for board #{board_id} written to #{filepath.relative_path_from(cwd)}"
