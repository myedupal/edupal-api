module CallbackLoggable
  extend ActiveSupport::Concern

  private

    def log_callback
      request_headers = request.env.select { |k, _v| k =~ /^HTTP_/ }
      @callback = CallbackLog.create(
        request_headers: request_headers,
        request_body: request.body.read,
        callback_from: @callback_from
      )
    end
end
