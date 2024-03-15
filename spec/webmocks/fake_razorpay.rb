require 'sinatra/base'

class FakeRazorpay < Sinatra::Base
  post '/v1/payment_links' do
    content_type :json
    status 200
    {
      accept_partial: true,
      amount: 1000,
      amount_paid: 0,
      callback_method: "get",
      callback_url: "https://example-callback-url.com/",
      cancelled_at: 0,
      created_at: 1_591_097_057,
      currency: "INR",
      customer: {
        contact: "+919000090000",
        email: "gaurav.kumar@example.com",
        name: "Gaurav Kumar"
      },
      description: "Payment for policy no #23456",
      expire_by: 1_691_097_057,
      expired_at: 0,
      first_min_partial_amount: 100,
      id: "plink_ExjpAUN3gVHrPJ",
      notes: {
        policy_name: "Jeevan Bima"
      },
      notify: {
        email: true,
        sms: true
      },
      payments: nil,
      reference_id: "TS1989",
      reminder_enable: true,
      reminders: [],
      short_url: "https://rzp.io/i/nxrHnLJ",
      status: "created",
      updated_at: 1_591_097_057,
      user_id: ""
    }.to_json
  end

  post '/v1/plans' do
    content_type :json
    status 200
    {
      id: SecureRandom.uuid,
      entity: "plan",
      interval: 1,
      period: "yearly",
      item: {
        id: "item_00000000000001",
        active: true,
        name: "Test plan - Yearly",
        description: "Description for the test plan - Yearly",
        amount: 6990,
        unit_amount: 6990,
        currency: "MYR",
        type: "plan",
        unit: nil,
        tax_inclusive: false,
        hsn_code: nil,
        sac_code: nil,
        tax_rate: nil,
        tax_id: nil,
        tax_group_id: nil,
        created_at: 1_580_219_935,
        updated_at: 1_580_219_935
      },
      created_at: 1_580_219_935
    }.to_json
  end

  get '/v1/plans/:id' do
    content_type :json
    status 200
    {
      id: "plan_00000000000001",
      entity: "plan",
      interval: 1,
      period: "weekly",
      item: {
        id: "item_00000000000001",
        active: true,
        name: "Test plan - Weekly",
        description: "Description for the test plan - Weekly",
        amount: 69_900,
        unit_amount: 69_900,
        currency: "MYR",
        type: "plan",
        unit: nil,
        tax_inclusive: false,
        hsn_code: nil,
        sac_code: nil,
        tax_rate: nil,
        tax_id: nil,
        tax_group_id: nil,
        created_at: 1_580_220_492,
        updated_at: 1_580_220_492
      },
      notes: {
        notes_key_1: "Tea, Earl Grey, Hot",
        notes_key_2: "Tea, Earl Grey… decaf."
      },
      created_at: 1_580_220_492
    }.to_json
  end

  post '/v1/subscriptions' do
    content_type :json
    status 200
    {
      id: "sub_00000000000001",
      entity: "subscription",
      plan_id: "plan_00000000000001",
      status: "created",
      current_start: nil,
      current_end: nil,
      ended_at: nil,
      quantity: 1,
      notes: {
        notes_key_1: "Tea, Earl Grey, Hot",
        notes_key_2: "Tea, Earl Grey… decaf."
      },
      charge_at: 1_580_453_311,
      start_at: 1_580_626_111,
      end_at: 1_583_433_000,
      auth_attempts: 0,
      total_count: 6,
      paid_count: 0,
      customer_notify: true,
      created_at: 1_580_280_581,
      expire_by: 1_580_626_111,
      short_url: "https://rzp.io/i/z3b1R61A9",
      has_scheduled_changes: false,
      change_scheduled_at: nil,
      source: "api",
      offer_id: "offer_JHD834hjbxzhd38d",
      remaining_count: 5
    }.to_json
  end

  get '/v1/subscriptions/:id' do
    content_type :json
    status 200
    {
      id: "sub_00000000000001",
      entity: "subscription",
      plan_id: "plan_00000000000001",
      status: "active",
      current_start: nil,
      current_end: nil,
      ended_at: nil,
      quantity: 1,
      notes: {
        notes_key_1: "Tea, Earl Grey, Hot",
        notes_key_2: "Tea, Earl Grey… decaf."
      },
      charge_at: 1_580_453_311,
      start_at: 1.minute.ago.to_i,
      end_at: 1.month.from_now.to_i,
      auth_attempts: 0,
      total_count: 6,
      paid_count: 0,
      customer_notify: true,
      created_at: 1_580_280_581,
      expire_by: 1_580_626_111,
      short_url: "https://rzp.io/i/z3b1R61A9",
      has_scheduled_changes: false,
      change_scheduled_at: nil,
      source: "api",
      offer_id: "offer_JHD834hjbxzhd38d",
      remaining_count: 5
    }.to_json
  end

  patch '/v1/subscriptions/:id' do
    content_type :json
    status 200
    {
      id: "sub_00000000000001",
      entity: "subscription",
      plan_id: "plan_00000000000001",
      status: "paused",
      current_start: nil,
      current_end: nil,
      ended_at: nil,
      quantity: 1,
      notes: {
        notes_key_1: "Tea, Earl Grey, Hot",
        notes_key_2: "Tea, Earl Grey… decaf."
      },
      charge_at: 1_580_453_311,
      start_at: 1_580_626_111,
      end_at: 1_583_433_000,
      auth_attempts: 0,
      total_count: 6,
      paid_count: 0,
      customer_notify: true,
      created_at: 1_580_280_581,
      expire_by: 1_580_626_111,
      short_url: "https://rzp.io/i/z3b1R61A9",
      has_scheduled_changes: false,
      change_scheduled_at: nil,
      source: "api",
      offer_id: "offer_JHD834hjbxzhd38d",
      remaining_count: 5
    }.to_json
  end

  post '/v1/subscriptions/:id/cancel' do
    content_type :json
    status 200
    {
      id: "sub_00000000000001",
      entity: "subscription",
      plan_id: "plan_00000000000001",
      status: params['cancel_at_cycle_end'] == "1" ? "active" : "cancelled",
      current_start: nil,
      current_end: nil,
      ended_at: nil,
      quantity: 1,
      notes: {
        notes_key_1: "Tea, Earl Grey, Hot",
        notes_key_2: "Tea, Earl Grey… decaf."
      },
      charge_at: 1_580_453_311,
      start_at: 1_580_626_111,
      end_at: 1_583_433_000,
      auth_attempts: 0,
      total_count: 6,
      paid_count: 0,
      customer_notify: true,
      created_at: 1_580_280_581,
      expire_by: 1_580_626_111,
      short_url: "https://rzp.io/i/z3b1R61A9",
      has_scheduled_changes: false,
      change_scheduled_at: nil,
      source: "api",
      offer_id: "offer_JHD834hjbxzhd38d",
      remaining_count: 5
    }.to_json
  end
end
