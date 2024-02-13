class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
end

# the above is a security measure that we will not be using for this project, so it has been skipped
