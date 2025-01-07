# require 'redis'
# require 'uri'
# require 'certifi'

# # Write the certifi CA bundle to a custom CA file
# ca_file_path = Rails.root.join('config', 'ca_cert.pem')
# File.write(ca_file_path, File.read(Certifi.where))

# begin
#   redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379' # Fallback for local development
#   uri = URI.parse(redis_url)

#   Rails.logger.info "[Redis Initializer] Initializing Redis with URL: #{redis_url}"
#   Rails.logger.info "[Redis Initializer] Parsed URI: #{uri.inspect}"
#   Rails.logger.info "[Redis Initializer] Host: #{uri.host}, Port: #{uri.port}, Password: #{uri.password}, Scheme: #{uri.scheme}"

#   # Explicitly convert port to integer and validate other values
#   host = uri.host
#   port = uri.port.to_i
#   password = uri.password
#   ssl_enabled = uri.scheme == 'rediss'

#   $redis = Redis.new(
#     host: host,
#     port: port,  # Use the parsed port
#     password: password,
#     ssl: ssl_enabled,
#     ssl_params: {
#       verify_mode: OpenSSL::SSL::VERIFY_PEER,  # Strict SSL verification
#       ca_file: ca_file_path.to_s
#     }
#   )

#   Rails.logger.info "[Redis Initializer] Redis initialized successfully at #{host}:#{port} (SSL: #{ssl_enabled})"
# rescue URI::InvalidURIError => uri_error
#   Rails.logger.error "[Redis Initializer] Invalid REDIS_URL format: #{redis_url}"
#   Rails.logger.error "Error: #{uri_error.message}"
#   Rails.logger.error uri_error.backtrace.join("\n")
#   $redis = nil
# rescue ArgumentError, TypeError => redis_error
#   Rails.logger.error "[Redis Debug] Error during Redis initialization: #{redis_error.message}"
#   Rails.logger.error redis_error.backtrace.join("\n")
#   Rails.logger.error "[Redis Debug] Host: #{host.inspect} (Type: #{host.class})"
#   Rails.logger.error "[Redis Debug] Port: #{port.inspect} (Type: #{port.class})"
#   Rails.logger.error "[Redis Debug] Password: #{password.inspect} (Type: #{password.class})"
#   Rails.logger.error "[Redis Debug] SSL Enabled: #{ssl_enabled.inspect} (Type: #{ssl_enabled.class})"
#   $redis = nil
# rescue => e
#   Rails.logger.error "[Redis Initializer] Error initializing Redis: #{e.message}"
#   Rails.logger.error e.backtrace.join("\n")
#   $redis = nil
# end

#

# $redis = Redis.new(url: ENV["REDIS_URL"], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
