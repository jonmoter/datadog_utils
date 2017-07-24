require 'dotenv'
require 'datadog_client'
require 'utils'

Dotenv.load
OUTPUT_ROOT = File.expand_path(File.dirname(__FILE__), '../data')

def bail(error, code: 1)
  puts "ERROR: #{error}" if error
  exit(code)
end
