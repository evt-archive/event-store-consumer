ENV['CATEGORY'] ||= 'on'

require_relative '../test_init'

def get_stream_name(file: nil)
  file ||= "tmp/stream_name"

  __logger.trace "Getting stream name (File: #{file})"

  if File.exist? file
    stream_name = File.read file
    __logger.debug "Read stream name from disk (File: #{file}, StreamName: #{stream_name}"
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
      __logger.debug "Unlinked stream name file (File: #{file}, StreamName: #{stream_name})"
    end

    __logger.debug "Generated stream name (File: #{file}, StreamName: #{stream_name})"

    stream_name
  end
end
