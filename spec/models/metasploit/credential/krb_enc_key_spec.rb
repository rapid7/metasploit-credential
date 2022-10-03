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

    [
      :with_rc4,
      :with_aes128,
      :with_aes256,
    ].each do |trait|
      context "with #{trait}" do
        subject(:metasploit_credential_krb_enc_key) do
          FactoryBot.build(:metasploit_credential_krb_enc_key, trait)
        end

        it { is_expected.to be_valid }
        it { expect(subject.data).to be_a(Hash) }
      end
    end
  end

  context 'when the krb enc key is aes256' do
    subject :krb_enc_key_aes256 do
      FactoryBot.build(:metasploit_credential_krb_enc_key, :with_aes256)
    end

    describe '#data' do
      it 'has a data hash' do
        expect(subject.data.keys).to match_array(%i[ enctype key salt ])
        expect(subject.data[:enctype]).to eq(18)
        expect(subject.data[:key].bytes.length).to eq(32)
        expect(subject.data[:salt]).to match(/DOMAIN.LOCALUserAccount\d+/)
      end
    end

    describe '#enctype' do
      it 'has an enctype' do
        expect(subject.enctype).to eq(subject.data[:enctype])
      end
    end

    describe '#key' do
      it 'has an key' do
        expect(subject.key).to eq(subject.data[:key])
      end
    end

    describe '#salt' do
      it 'has a salt' do
        expect(subject.salt).to eq(subject.data[:salt])
      end
    end

    describe '#to_s' do
      it 'has a human readable to_s' do
        expect(subject.to_s).to match /18:\w{64}/
      end
    end
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

      context "when the enctype is missing" do
        let(:data) do
          super().without(:enctype)
        end

        it { is_expected.to include('is missing enctype.') }
      end

      context "when the key is missing" do
        let(:data) do
          super().without(:key)
        end

        it { is_expected.to include('is missing key.') }
      end

      context 'when invalid keys are present' do
        let(:data) do
          super().merge({ ky: 123, slt: 'abc' })
        end

        it { is_expected.to include('has invalid attribute ky.', 'has invalid attribute slt.') }
      end
    end
  end
end
