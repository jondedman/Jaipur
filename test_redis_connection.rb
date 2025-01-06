# require 'redis'

# # Replace with your Redis URL
# redis_url = 'rediss://:pc78a93b28dde6fa406a1999f04a33a2bf6c5b79f47fd72250d1c5607f95289e3@ec2-54-72-65-59.eu-west-1.compute.amazonaws.com:18200'

# # Establish a connection to Redis
# begin
#   redis = Redis.new(
#     url: redis_url,
#     ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }  # Disable certificate verification
#   )

#   # Try a simple command to check connection
#   response = redis.ping
#   puts "Redis connection successful: #{response}"

# rescue StandardError => e
#   puts "Failed to connect to Redis: #{e.message}"
# end

require 'redis'
Redis.new(url: ENV.fetch("REDIS_URL"), ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }).ping
