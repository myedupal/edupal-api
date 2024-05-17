class ZkloginSaltGenerator
  HASH_ALGORITHM = 'SHA256'
  LENGTH = 16

  def initialize(master_seed: ENV['ZKLOGIN_MASTER_SEED'], client_id: ENV['GOOGLE_OAUTH_CLIENT_ID'])
    @master_seed = master_seed
    @client_id = client_id
  end

  def generate(sub)
    salt = OpenSSL::KDF.hkdf(@master_seed, salt: @client_id, info: sub, length: LENGTH, hash: HASH_ALGORITHM)
    Base64.encode64(salt).strip
  end
end
