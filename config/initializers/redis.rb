# filepath: config/initializers/redis.rb
require 'redis'

Redis.current = Redis.new(
  url: ENV['REDIS_URL'],
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
)
