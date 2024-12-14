# filepath: /Users/jondedman/code/twenty_four/Jaipur/config/initializers/redis.rb
require 'redis'

$redis = Redis.new(
  url: ENV['REDIS_URL'],
  ssl: true,
  ssl_params: {
    verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
)
