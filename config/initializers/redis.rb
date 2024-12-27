# filepath: /Users/jondedman/code/twenty_four/Jaipur/config/initializers/redis.rb
require 'redis'
require 'uri'
require 'certifi'

begin
  redis_url = ENV['REDIS_URL']
  uri = URI.parse(redis_url)
  puts "Initializing Redis with URL: #{redis_url}"
  $redis = Redis.new(
    host: uri.host,
    port: uri.port,
    password: uri.password,
    ssl: uri.scheme == 'rediss',
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_PEER,  # Verify SSL certificate
      ca_file: Certifi.where  # Use the certifi CA bundle
    }
  )
  puts "Redis initialized successfully"
rescue => e
  puts "Error initializing Redis: #{e.message}"
  puts e.backtrace.join("\n")
  $redis = nil
end
