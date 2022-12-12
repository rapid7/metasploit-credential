RSpec.shared_examples_for 'a KrbEncKey' do |expected:|
  describe '#enctype' do
    it 'has an enctype' do
      expect(subject.enctype).to eq(expected[:enctype])
    end
  end

  describe '#key' do
    it 'has a key' do
      expect(subject.key.length).to eq(expected[:key_length])
    end
  end

  describe '#salt' do
    it 'has a salt' do
      expect(subject.salt).to match(expected[:salt])
    end
  end

  describe '#to_s' do
    it 'has a human readable to_s' do
      expect(subject.to_s).to match expected[:to_s]
    end
  end
end

RSpec.describe Metasploit::Credential::KrbEncKey, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  it { is_expected.to be_a Metasploit::Credential::PasswordHash }

  context 'factories' do
    context 'metasploit_credential_krb_enc_key' do
      subject(:metasploit_credential_krb_enc_key) do
        FactoryBot.build(:metasploit_credential_krb_enc_key)
      end

      it { is_expected.to be_valid }
    end

    FactoryBot.factories[:metasploit_credential_krb_enc_key].defined_traits.each do |trait|
      context "with #{trait}" do
        subject(:metasploit_credential_krb_enc_key) do
          FactoryBot.build(:metasploit_credential_krb_enc_key, trait.name)
        end

        it { is_expected.to be_valid }
        it { expect(subject.data).to be_a(String) }
      end
    end
  end

  context 'when the krb enc key is rc4' do
    subject :krb_enc_key_rc4 do
      FactoryBot.build(:metasploit_credential_krb_enc_key, :with_rc4)
    end

    it_behaves_like 'a KrbEncKey',
                    expected: {
                      enctype: 23,
                      key_length: 16,
                      salt: nil,
                      to_s: /rc4-hmac:\w{32}/
                    }
  end

  context 'when the krb enc key is aes128' do
    subject :krb_enc_key_aes256 do
      FactoryBot.build(:metasploit_credential_krb_enc_key, :with_aes128)
    end

    it_behaves_like 'a KrbEncKey',
                    expected: {
                      enctype: 17,
                      key_length: 16,
                      salt: /DOMAIN.LOCALUserAccount\d+/,
                      to_s: /aes128-cts-hmac-sha1-96:\w{32}/
                    }
  end

  context 'when the krb enc key is aes128' do
    subject :krb_enc_key_aes256 do
      FactoryBot.build(:metasploit_credential_krb_enc_key, :with_aes256)
    end

    it_behaves_like 'a KrbEncKey',
                    expected: {
                      enctype: 18,
                      key_length: 32,
                      salt: /DOMAIN.LOCALUserAccount\d+/,
                      to_s: /aes256-cts-hmac-sha1-96:\w{64}/
                    }
  end

  context 'when the krb enc key is not a known enctype' do
    subject :krb_enc_key_aes256 do
      FactoryBot.build(:metasploit_credential_krb_enc_key, data: described_class.build_data(enctype: 1024, key: "abc"))
    end

    it_behaves_like 'a KrbEncKey',
                    expected: {
                      enctype: 1024,
                      key_length: 3,
                      salt: nil,
                      to_s: 'unassigned-1024:616263'
                    }
  end

  context 'validations' do
    context '#data' do
      subject(:data_errors) do
        krb_enc_key.errors[:data]
      end

      #
      # lets
      #

      let(:data) do
        FactoryBot.generate(:metasploit_credential_krb_enc_key_aes256)
      end

      let(:krb_enc_key) do
        FactoryBot.build(
          :metasploit_credential_krb_enc_key,
          data: data
        )
      end

      #
      # Callbacks
      #

      before(:example) do
        krb_enc_key.valid?
      end

      context 'when the data is valid' do
        it { is_expected.to be_empty }
      end

      context "when the data is invalid" do
        let(:data) do
          "foo"
        end

        it { is_expected.to include("is not in the KrbEncKey data format of 'msf_krbenckey:<ENCTYPE>:<KEY>:<SALT>', where the key and salt are in hexadecimal characters") }
      end
    end
  end
end
