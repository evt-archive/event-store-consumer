ENV['CATEGORY'] ||= 'on'

require_relative '../test_init'

require 'process_host'

def get_stream_name(file: nil)
  file ||= "tmp/stream_name"

  if File.exist? file
    stream_name = File.read file
    stream_name
  else
    if ENV['CATEGORY'] == 'on'
      stream_name = Controls::StreamName::Category.example random: true
    else
      stream_name = Controls::StreamName.example random: true
    end

    File.write file, stream_name

    at_exit do
      File.unlink file
    end

    stream_name
  end
end
