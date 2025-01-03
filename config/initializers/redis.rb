require 'redis'
require 'uri'
require 'certifi'

# Write the certifi CA bundle to a custom CA file
ca_file_path = Rails.root.join('config', 'ca_cert.pem')
File.write(ca_file_path, File.read(Certifi.where))

begin
  $redis = Redis.new(
    host: host,
    port: port,
    password: password,
    ssl: ssl_enabled,
    ssl_params: {
      verify_mode: OpenSSL::SSL::VERIFY_PEER,
      ca_file: ca_file_path.to_s
    }
  )
rescue ArgumentError, TypeError => redis_error
  Rails.logger.error "[Redis Debug] Error during Redis initialization: #{redis_error.message}"
  Rails.logger.error redis_error.backtrace.join("\n")
  Rails.logger.error "[Redis Debug] Host: #{host.inspect} (Type: #{host.class})"
  Rails.logger.error "[Redis Debug] Port: #{port.inspect} (Type: #{port.class})"
  Rails.logger.error "[Redis Debug] Password: #{password.inspect} (Type: #{password.class})"
  Rails.logger.error "[Redis Debug] SSL Enabled: #{ssl_enabled.inspect} (Type: #{ssl_enabled.class})"
  $redis = nil
end
