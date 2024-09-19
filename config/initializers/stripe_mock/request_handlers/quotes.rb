return unless Rails.env.test?
module StripeMock
  module RequestHandlers
    module Quotes

      def Quotes.included(klass)
        klass.add_handler 'post /v1/quotes', :new_quote
        klass.add_handler 'post /v1/quotes/([^/]*)', :update_quote
        klass.add_handler 'get /v1/quotes/([^/]*)/line_items', :get_quote_line_items
        klass.add_handler 'get /v1/quotes/([^/]*)/computed_upfront_line_items', :get_quote_line_items
        klass.add_handler 'get /v1/quotes/([^/]*)', :get_quote
        klass.add_handler 'get /v1/quotes', :get_quotes
        klass.add_handler 'post /v1/quotes/([^/]*)/accept', :accept_quote
        klass.add_handler 'post /v1/quotes/([^/]*)/cancel', :cancel_quote
        klass.add_handler 'get /v1/quotes/([^/]*)/pdf', :quote_pdf
        klass.add_handler 'post /v1/quotes/([^/]*)/finalize', :finalize_quote
      end

      def new_quote(_route, _method_url, params, headers)
        stripe_account = headers && headers[:stripe_account] || Stripe.api_key
        params[:id] ||= new_id('quo')

        quotes[stripe_account] ||= {}
        quotes[stripe_account][params[:id]] = Data.mock_quotes(params)

        quotes[stripe_account][params[:id]][:line_items] = []
        if params[:line_items].present?
          params[:line_items].each do |line_item|
            price = assert_existence :prices, line_item[:price], prices[line_item[:price]]
            quotes[stripe_account][params[:id]][:line_items] << Data.mock_line_item({ price: price })
          end
        else
          quotes[stripe_account][params[:id]][:line_items] << Data.mock_line_item({ price: Data.mock_price })
        end

        quotes[stripe_account][params[:id]]
      end

      def update_quote(route, method_url, params, headers)
        stripe_account = headers && headers[:stripe_account] || Stripe.api_key
        route =~ method_url
        quo = assert_existence :quotes, $1, quotes[stripe_account][$1]

        # get existing and pending metadata
        metadata = quo.delete(:metadata) || {}
        metadata_updates = params.delete(:metadata) || {}

        if params[:line_items].present?
          quotes[stripe_account][quo[:id]]['line_items'] = []
          params[:line_items].each do |line_item|
            price = assert_existence :prices, line_item[:price], prices[line_item[:price]]
            quotes[stripe_account][params[:id]][:line_items] << Data.mock_line_item({ price: price })
          end
        end

        quo.merge!(params.except(:line_items))
        quo[:metadata] = { **metadata, **metadata_updates }

        quo
      end

      def get_quote_line_items(route, method_url, params, headers)
        stripe_account = headers && headers[:stripe_account] || Stripe.api_key
        route =~ method_url
        quo = assert_existence :quotes, $1, quotes[stripe_account][$1]

        Data.mock_list_object(quo[:line_items], params)
      end

      def get_quote(route, method_url, params, headers)
        stripe_account = headers && headers[:stripe_account] || Stripe.api_key
        route =~ method_url
        quo = assert_existence :quotes, $1, quotes[stripe_account][$1]

        result = quo.except(:line_items)

        if params[:expand].present?
          if params[:expand].include?(:invoice)
            result[:invoice] = invoices[result[:invoice]]
          end
          if params[:expand].include?(:subscription)
            result[:subscription] = subscriptions[result[:subscription]]
          end
        end

        result
      end

      def get_quotes(route, method_url, _params, headers)
        stripe_account = headers && headers[:stripe_account] || Stripe.api_key
        route =~ method_url

        quotes[stripe_account]
      end

      def accept_quote(route, method_url, _params, headers)
        stripe_account = headers && headers[:stripe_account] || Stripe.api_key
        route =~ method_url
        quo = assert_existence :quotes, $1, quotes[stripe_account][$1]

        if quo[:status] != 'open'
          raise Stripe::InvalidRequestError.new("Cannot accept a non open quotation", nil, http_status: 400)
        end

        quo[:status] = 'accepted'

        invoice_id = new_id('in')
        invoices[invoice_id] = Data.mock_invoice([Data.mock_line_item], { id: invoice_id, customer: quo[:customer] })
        quo[:invoice] = invoice_id

        subscription = Data.mock_subscription({ id: new_id('su'), customer: quo[:customer], trial_end: (Time.now + 1.day).to_i })
        subscriptions[subscription[:id]] = subscription
        quo[:subscription] = subscription[:id]

        quo
      end

      def cancel_quote(route, method_url, _params, headers)
        stripe_account = headers && headers[:stripe_account] || Stripe.api_key
        route =~ method_url
        quo = assert_existence :quotes, $1, quotes[stripe_account][$1]

        if quo[:status] == 'accepted' || quo[:status] == 'canceled'
          raise Stripe::InvalidRequestError.new("Cannot cancel a quotation in terminal status", nil, http_status: 400)
        end

        quo[:status] = 'canceled'
        quo
      end

      def finalize_quote(route, method_url, _params, headers)
        stripe_account = headers && headers[:stripe_account] || Stripe.api_key
        route =~ method_url
        quo = assert_existence :quotes, $1, quotes[stripe_account][$1]

        if quo[:status] != 'draft'
          raise Stripe::InvalidRequestError.new("Cannot finalize a non draft quotation", nil, http_status: 400)
        end

        quo[:status] = 'open'
        quo
      end

      def quote_pdf(_route, _method_url, _params, _headers) end

    end
  end
end
