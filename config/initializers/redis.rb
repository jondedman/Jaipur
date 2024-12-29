# filepath: /Users/jondedman/code/twenty_four/Jaipur/config/initializers/redis.rb
require 'redis'
require 'uri'
require 'certifi'

begin
  redis_url = ENV['REDIS_URL']
  uri = URI.parse(redis_url)
  puts "Initializing Redis with URL: #{redis_url}"
  puts "Parsed URI: #{uri.inspect}"
  puts "Host: #{uri.host}, Port: #{uri.port}, Password: #{uri.password}, Scheme: #{uri.scheme}"
  puts "redis_url is a #{redis_url.class}"
  puts "uri is a #{uri.class}"
  puts "host is a #{uri.host.class}"
  puts "port is a #{uri.port.class}"
  puts "password is a #{uri.password.class}"
  puts "scheme is a #{uri.scheme.class}"

  $redis = Redis.new(
    host: uri.host,
    port: uri.port,  # Ensure port is an integer
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
