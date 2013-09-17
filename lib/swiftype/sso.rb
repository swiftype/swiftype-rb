require 'digest/sha1'

module Swiftype
  # Single sign-on for the Swiftype Dashboard.
  module SSO
    BASE_URL = 'https://swiftype.com/sso'

    # Generate a URL that a user can click on to be logged into the Swiftype Dashboard.
    # This requires the +platform_client_id+ and +platform_client_secret+ configuration options be set.
    def self.url(user_id)
      timestamp = Time.now.to_i

      "#{BASE_URL}?user_id=#{user_id}&client_id=#{Swiftype.platform_client_id}&timestamp=#{timestamp}&token=#{token(user_id, timestamp)}"
    end

    def self.token(user_id, timestamp)
      Digest::SHA1.hexdigest("#{user_id}:#{Swiftype.platform_client_secret}:#{timestamp}")
    end
  end
end
