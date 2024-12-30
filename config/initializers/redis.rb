require 'redis'
require 'uri'
require 'certifi'

begin
  redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379' # Fallback for local development
  uri = URI.parse(redis_url)

  puts "[Redis Initializer] Initializing Redis with URL: #{redis_url}"
  puts "[Redis Initializer] Parsed URI: #{uri.inspect}"
  puts "[Redis Initializer] Host: #{uri.host}, Port: #{uri.port}, Password: #{uri.password}, Scheme: #{uri.scheme}"

  # Explicitly convert port to integer and validate other values
  host = uri.host
  port = uri.port.to_i
  password = uri.password
  ssl_enabled = uri.scheme == 'rediss'

  $redis = Redis.new(
    host: host,
    port: port,  # Ensures the port is properly cast
    password: password,
    ssl: ssl_enabled,
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_PEER,  # Strict SSL verification
      ca_file: Certifi.where # Use the certifi CA bundle
    }
  )

  puts "[Redis Initializer] Redis initialized successfully at #{host}:#{port} (SSL: #{ssl_enabled})"
rescue URI::InvalidURIError => uri_error
  puts "[Redis Initializer] Invalid REDIS_URL format: #{redis_url}"
  puts "Error: #{uri_error.message}"
  puts uri_error.backtrace.join("\n")
  $redis = nil
rescue => e
  puts "[Redis Initializer] Error initializing Redis: #{e.message}"
  puts e.backtrace.join("\n")
  $redis = nil
end
