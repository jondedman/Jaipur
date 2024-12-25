# filepath: /Users/jondedman/code/twenty_four/Jaipur/config/initializers/redis.rb
require 'redis'
require 'certifi'

begin
  redis_url = ENV['REDIS_URL']
  puts "Initializing Redis with URL: #{redis_url}"
  $redis = Redis.new(
    url: redis_url,
    ssl: true,
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_NONE  # Skip SSL certificate verification
    }
  )
  puts "Redis initialized successfully"
rescue => e
  puts "Error initializing Redis: #{e.message}"
  puts e.backtrace.join("\n")
  $redis = nil
end
