return unless Rails.env.test?
module StripeMock
  Data.module_eval do
    def self.mock_quotes(params = {})
      id = params[:id] || 'test_quo_defaults'
      now = Time.now.to_i
      expires_at = params[:expires_at] || now + 1.days

      {
        "id": id,
        "object": "quote",
        "amount_subtotal": 2198,
        "amount_total": 2198,
        "application": nil,
        "application_fee_amount": nil,
        "application_fee_percent": nil,
        "automatic_tax": {
          "enabled": false,
          "liability": nil,
          "status": nil
        },
        "collection_method": "charge_automatically",
        "computed": {
          "recurring": nil,
          "upfront": {
            "amount_subtotal": 2198,
            "amount_total": 2198,
            "total_details": {
              "amount_discount": 0,
              "amount_shipping": 0,
              "amount_tax": 0
            }
          }
        },
        "created": now,
        "currency": "usd",
        "customer": "test_cus_default",
        "default_tax_rates": [],
        "description": nil,
        "discounts": [],
        "expires_at": expires_at,
        "footer": nil,
        "from_quote": nil,
        "header": nil,
        "invoice": nil,
        "invoice_settings": {
          "days_until_due": nil,
          "issuer": {
            "type": "self"
          }
        },
        "livemode": false,
        "metadata": {},
        "number": nil,
        "on_behalf_of": nil,
        "status": "draft",
        "status_transitions": {
          "accepted_at": nil,
          "canceled_at": nil,
          "finalized_at": nil
        },
        "subscription": nil,
        "subscription_data": {
          "description": nil,
          "effective_date": nil,
          "trial_period_days": nil
        },
        "subscription_schedule": nil,
        "test_clock": nil,
        "total_details": {
          "amount_discount": 0,
          "amount_shipping": 0,
          "amount_tax": 0
        },
        "transfer_data": nil
      }.merge(params)
    end
  end
end
