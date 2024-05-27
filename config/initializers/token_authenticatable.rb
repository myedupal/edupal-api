require 'token_authenticatable'

TokenAuthenticatable.configure do |config|
  # default is never expires
  # config.token_expires_in = 1.day

  # mandatory, otherwise no token will be dispatched
  config.creator_requests = [
    ['POST', %r{/api/v1/admin/sign_in$}],
    ['POST', %r{/api/v1/user/sign_in$}],
    ['POST', %r{/api/v1/user$}],
    ['POST', %r{/api/v1/user/oauth/google$}]
  ]

  # mandatory, otherwise sign out will not have any effect
  config.revoker_requests = [
    ['DELETE', '/api/v1/admin/sign_out'],
    ['DELETE', '/api/v1/user/sign_out']
  ]
end
