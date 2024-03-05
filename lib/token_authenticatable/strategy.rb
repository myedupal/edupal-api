require 'devise'

module TokenAuthenticatable
  class Strategy < Devise::Strategies::Authenticatable
    def valid?
      env['HTTP_AUTHORIZATION'].present? && authenticate_request?(request)
    end

    def authenticate!
      return success!(warden_user)   if warden_user # check if user already set by another strategy
      return fail!(:unauthenticated) unless (session = Session.find_by(token: bearer_token, scope: scope.to_s))
      return fail!(:timeout)         if session.revoked? or session.expired?
      return fail!(:inactive)        unless session.account.active_for_authentication?

      success!(session.account)
    end

    def store?
      false
    end

    private

      def bearer_token
        pattern = /^Bearer /
        header  = env['HTTP_AUTHORIZATION']
        return unless header && header.match(pattern)

        header.gsub(pattern, '')
      end

      def warden_user
        env['warden'].user
      end

      def authenticate_request?(request)
        self.class.module_parent.configuration.creator_requests.each do |matcher|
          request_method, pattern = matcher
          if pattern.is_a?(Regexp)
            return false if request_method == request.method && request.path.match(pattern)
          elsif request_method == request.method && request.path == pattern
            return false
          end
        end
        true
      end
  end
end

Warden::Strategies.add(:token_authenticatable, TokenAuthenticatable::Strategy)
