require 'redis'
require 'openssl'

begin
  redis_url = ENV['REDIS_URL']
  puts "Initializing Redis with URL: #{redis_url}"

  # Initialize Redis with SSL enabled and certificate verification
  $redis = Redis.new(
    url: redis_url,
    ssl: true,
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_PEER,
      # Optionally, you can specify the path to your CA certificates here if needed
      # ca_file: '/path/to/ca.crt'
    }
  )
  puts "Redis initialized successfully"
rescue => e
  puts "Error initializing Redis: #{e.message}"
  puts e.backtrace.join("\n")
  $redis = nil
end
