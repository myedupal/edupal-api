require 'stripe_mock.rb'
require_relative 'request_handlers/quotes.rb'

module StripeMock
  Instance.class_eval do
    alias_method :original_initialize, :initialize

    include StripeMock::RequestHandlers::Quotes

    attr_reader :quotes

    def initialize
      original_initialize
      @quotes = {}
    end
  end
end
