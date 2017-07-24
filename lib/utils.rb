require 'fileutils'

class Utils
  DATA_DIR = File.expand_path('../data', File.dirname(__FILE__)).freeze

  class << self
    def filepath(name, subdir: '', format: 'json')
      directory = File.expand_path(subdir, DATA_DIR)

      name = name.downcase.gsub(/\W+/, '_')
      ::Pathname.new("#{directory}/#{name}.#{format}")
    end

    def save_file(name, data, subdir: '', format: "json")
      file = filepath(name, subdir: subdir, format: format)
      FileUtils.mkdir_p(File.dirname(file))

      File.write(file, data)
      puts "Saved #{file}"

      file
    end
  end
end
