require 'rails_helper'

RSpec.describe ZkloginSaltGenerator do
  let(:master_seed) { 'master_seed' }
  let(:client_id) { 'client_id' }
  let(:generator) { ZkloginSaltGenerator.new(master_seed: master_seed, client_id: client_id) }

  describe '.generate' do
    it 'generates a salt' do
      expect(OpenSSL::KDF).to receive(:hkdf).with(master_seed, salt: client_id, info: 'sub', length: 16, hash: 'SHA256').and_return('salt')
      expect(Base64).to receive(:encode64).with('salt').and_return('encoded_salt')

      expect(generator.generate('sub')).to eq('encoded_salt')
    end
  end
end
