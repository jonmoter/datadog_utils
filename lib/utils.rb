require 'fileutils'

class Utils
  DATA_DIR = File.expand_path('../data', File.dirname(__FILE__)).freeze

  class << self
    def filepath(name, subdir: '', format: 'json')
      directory = File.expand_path(subdir, DATA_DIR)

      name = name.to_s.downcase.gsub(/\W+/, '_')
      ::Pathname.new("#{directory}/#{name}.#{format}")
    end

    def relative_path(filepath)
      filepath = ::Pathname.new(filepath) unless filepath.is_a? ::Pathname

      filepath.relative_path_from(Pathname.new(ENV['PWD']))
    end

    def save_file(name, data, subdir: '', format: 'json', output: true)
      file = filepath(name, subdir: subdir, format: format)
      FileUtils.mkdir_p(File.dirname(file))

      File.write(file, data)
      puts "Saved #{relative_path(file)}" if output

      file
    end
  end
end
