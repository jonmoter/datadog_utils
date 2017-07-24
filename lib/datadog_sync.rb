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

  MONITORS_DIR = File.expand_path('monitors/generated', ROOT_DIR).freeze
  SCREENBOARD_DIR = File.expand_path('screenboards/generated', ROOT_DIR).freeze
  SCREENBOARD_DEFINITION_DIR = File.expand_path('screenboards', ROOT_DIR).freeze
  TIMEBOARD_DIR = File.expand_path('timeboards/generated', ROOT_DIR).freeze

  #
  # Monitors
  #
  def get_monitor(monitor_id)
    code, result = datadog_client.get_monitor(monitor_id)
    raise DatadogException.new(code, result) if code.to_i != 200
    result
  end

  def save_monitor_to_file(monitor_id, name: nil)
    monitor = get_monitor(monitor_id)
    name ||= monitor['name'] || monitor_id
    save_file(name, JSON.pretty_generate(monitor), MONITORS_DIR)
  end

  #
  # Screenboards
  #
  def get_screenboard(board_id)
    code, result = datadog_client.get_screenboard(board_id)
    raise DatadogException.new(code, result) if code.to_i != 200
    result
  end

  def save_screenboard_to_file(board_id, name: nil)
    board = get_screenboard(board_id)
    name ||= board['board_title'] || board_id
    save_file(name, JSON.pretty_generate(board), SCREENBOARD_DIR)
  end

  def create_screenboard_definition(board_id, name)
    board = get_screenboard(board_id)
    name ||= board['board_title'] || board_id
    defintion = {
      "name" => name,
      "id"  => board_id
    }
    save_file(name, defintion.to_yaml, SCREENBOARD_DEFINITION_DIR, "yml")
  end

  #
  # Timeboards
  #
  def get_timeboard(board_id)
    code, result = datadog_client.get_dashboard(board_id)
    raise DatadogException.new(code, result) if code.to_i != 200
    result
  end

  def save_timeboard_to_file(board_id, name: nil)
    board = get_timeboard(board_id)
    name ||= board['dash']['title'] || board_id
    save_file(name, JSON.pretty_generate(board), TIMEBOARD_DIR)
  end

  private

  def datadog_client
    DatadogClient.client
  end


end
