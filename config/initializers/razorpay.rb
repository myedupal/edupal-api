Razorpay.setup(
  ENV.fetch('RAZORPAY_KEY_ID', 'replace_with_your_key_id'),
  ENV.fetch('RAZORPAY_KEY_SECRET', 'replace_with_your_key_secret')
)

# DO NOT ENABLE THIS, NOT ALL API ENDPOINTS SUPPORT JSON
# Razorpay.headers = { "Content-type" => "application/json" }
