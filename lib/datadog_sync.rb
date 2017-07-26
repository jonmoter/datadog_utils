require_relative 'common'
require 'fileutils'
require 'json'
require 'yaml'
require 'pathname'

class DatadogException < StandardError
  attr_reader :code, :result

  def initialize(code, result, message = nil)
    message ||= "Retrieved error code #{code}"
    super(message)
    @code = code
    @result = result
  end
end

class DatadogSync
  #
  # Monitors
  #
  def get_monitor(monitor_id)
    code, result = datadog_client.get_monitor(monitor_id)
    raise DatadogException.new(code, result) if code.to_i != 200
    result
  end

  def save_monitor_to_file(monitor_id, name: nil, output: true)
    monitor = get_monitor(monitor_id)
    name ||= monitor['name'] || monitor_id
    Utils.save_file(name, JSON.pretty_generate(monitor), subdir: 'monitors', output: output)
  end

  def save_all_monitors
    code, result = datadog_client.get_all_monitors
    raise DatadogException.new(code, result) if code.to_i != 200
    Utils.save_file('all_monitors', JSON.pretty_generate(result))

    result.each do |monitor|
      Utils.save_file(monitor['id'].to_s, JSON.pretty_generate(monitor), subdir: 'monitors', output: false)
    end
    puts "Saved #{result.count} monitors to data/monitors subdirectory"
  end

  #
  # Screenboards
  #
  def get_screenboard(board_id)
    code, result = datadog_client.get_screenboard(board_id)
    raise DatadogException.new(code, result) if code.to_i != 200
    result
  end

  def save_screenboard_to_file(board_id, name: nil, output: true)
    board = get_screenboard(board_id)
    name ||= board['board_title'] || board_id
    Utils.save_file(name, JSON.pretty_generate(board), subdir: 'screenboards', output: output)
  end

  def create_screenboard_definition(board_id, name)
    board = get_screenboard(board_id)
    name ||= board['board_title'] || board_id
    defintion = {
      "name" => name,
      "id"  => board_id
    }
    Utils.save_file(name, defintion.to_yaml, subdir: 'screenboards')
  end

  def save_all_screenboards
    code, result = datadog_client.get_all_screenboards
    raise DatadogException.new(code, result) if code.to_i != 200

    Utils.save_file('all_screenboards', JSON.pretty_generate(result))
    download_all_objects(result['screenboards'], 'screenboard')
  end

  #
  # Timeboards
  #
  def get_timeboard(board_id)
    code, result = datadog_client.get_dashboard(board_id)
    raise DatadogException.new(code, result) if code.to_i != 200
    result
  end

  def save_timeboard_to_file(board_id, name: nil, output: true)
    board = get_timeboard(board_id)
    name ||= board['dash']['title'] || board_id
    Utils.save_file(name, JSON.pretty_generate(board), subdir: 'timeboards', output: output)
  end

  def save_all_timeboards
    code, result = datadog_client.get_dashboards
    raise DatadogException.new(code, result) if code.to_i != 200

    Utils.save_file('all_timeboards', JSON.pretty_generate(result))
    download_all_objects(result['dashes'], 'timeboard')
  end

  private

  def datadog_client
    DatadogClient.client
  end

  # When we query for all screenboards or timeboards, we get a JSON document back with
  # a list of the boards, and minimal information about each board. Iterate over the
  # results and download each board into its own file.
  #
  # If a file already exists for that object, skip it.
  def download_all_objects(objects, type)
    subdir = type + 's'
    puts "Found #{objects.count} #{type}s, downloading..."

    count = skip_count = 0
    objects.each do |info|
      id = info['id']
      if File.exist?(Utils.filepath(id, subdir: subdir))
        skip_count += 1
        next
      end

      send("save_#{type}_to_file", id, name: id.to_s, output: false)
      count += 1
      printf("\rDownloaded %d #{type}s, skipped %d, current id = %d", count, skip_count, id)
    end
    puts ''
    puts "Saved #{count} #{type}s to data/#{subdir} subdirectory"
  end
end
