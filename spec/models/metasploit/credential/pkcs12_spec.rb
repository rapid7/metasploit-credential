RSpec.describe Metasploit::Credential::Pkcs12, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  it { is_expected.to be_a Metasploit::Credential::Private }

  context 'factories' do
    context 'metasploit_credential_pkcs12' do
      subject(:metasploit_credential_pkcs12) do
        FactoryBot.build(:metasploit_credential_pkcs12)
      end

      it { is_expected.to be_valid }
    end

    context 'metasploit_credential_pkcs12_with_ca' do
      subject(:metasploit_credential_pkcs12_with_ca) do
        FactoryBot.build(:metasploit_credential_pkcs12_with_ca)
      end

      it { is_expected.to be_valid }
    end

    context 'metasploit_credential_pkcs12_with_adcs_template' do
      subject(:metasploit_credential_pkcs12_with_adcs_template) do
        FactoryBot.build(:metasploit_credential_pkcs12_with_adcs_template)
      end

      it { is_expected.to be_valid }
    end

    context 'metasploit_credential_pkcs12_with_ca_and_adcs_template' do
      subject(:metasploit_credential_pkcs12_with_ca_and_adcs_template) do
        FactoryBot.build(:metasploit_credential_pkcs12_with_ca_and_adcs_template)
      end

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :data }

    context 'on #data' do
      subject(:data_errors) do
        pkcs12.errors[:data]
      end

      let(:pkcs12) do
        FactoryBot.build(:metasploit_credential_pkcs12)
      end

      context '#readable' do
        context 'with #data' do
          context 'with error' do
            #
            # Shared Examples
            #

            shared_examples_for 'exception' do
              it 'includes error class' do
                exception_class_name = exception.class.to_s
                expect(
                    data_errors.any? { |error|
                      error.include? exception_class_name
                    }
                ).to be true
              end

              it 'includes error message' do
                exception_message = exception.to_s

                expect(
                    data_errors.any? { |error|
                      error.include? exception_message
                    }
                ).to be true
              end
            end

            #
            # Callbacks
            #

            before(:example) do
              expect(pkcs12).to receive(:openssl_pkcs12).and_raise(exception)

              pkcs12.valid?
            end

            context 'with ArgumentError' do
              let(:exception) do
                ArgumentError.new("Bad Argument")
              end

              it_should_behave_like 'exception'
            end

            context 'with OpenSSL::PKCS12::PKCS12Error' do
              let(:exception) do
                OpenSSL::PKCS12::PKCS12Error.new('mac verify failure')
              end

              it_should_behave_like 'exception'
            end
          end

          context 'without error' do
            before(:example) do
              pkcs12.valid?
            end

            it { is_expected.to be_empty }
          end
        end

        context 'without #data' do
          let(:error) do
            I18n.translate!('errors.messages.blank')
          end

          #
          # Callbacks
          #

          before(:example) do
            pkcs12.data = nil

            pkcs12.valid?
          end

          it { is_expected.to include(error) }
        end
      end

      context '#data_format' do
        subject(:errors) { pkcs12.errors }

        before(:example) do
          allow(pkcs12).to receive(:data).and_return(data)
          pkcs12.valid?
        end

        # Wrong data
        context 'with empty data' do
          let(:data) { '' }
          it { is_expected.to be_added(:data, :format) }
        end

        context 'with an empty pkcs12 cert' do
          let(:data) { 'msf_pkcs12::ca:template' }
          it { is_expected.to be_added(:data, :format) }
        end

        context 'with missing fields separated by :' do
          let(:data) { 'msf_pkcs12:pkcs12_cert:ca' }
          it { is_expected.to be_added(:data, :format) }
        end

        context 'with a wrong header' do
          let(:data) { 'msf_krbenckey:pkcs12_cert:ca' }
          it { is_expected.to be_added(:data, :format) }
        end

        # Good data
        context 'with a correct pkcs12 cert' do
          let(:data) { 'msf_pkcs12:pkcs12_cert::' }
          it { is_expected.to_not be_added(:data, :format) }
        end

        context 'with a CA' do
          let(:data) { 'msf_pkcs12:pkcs12_cert:ca:' }
          it { is_expected.to_not be_added(:data, :format) }
        end

        context 'with an ADCS template' do
          let(:data) { 'msf_pkcs12:pkcs12_cert::adcs_template' }
          it { is_expected.to_not be_added(:data, :format) }
        end

        context 'with both a CA and an ADCS template' do
          let(:data) { 'msf_pkcs12:pkcs12_cert:ca:adcs_template' }
          it { is_expected.to_not be_added(:data, :format) }
        end
      end
    end
  end

  context 'self.build_data' do
    let(:pkcs12_cert) { 'mycert' }
    let(:ca) { 'myca' }
    let(:adcs_template) { 'mytemplate' }

    subject(:serialized_data) { described_class.build_data(**args) }

    context 'with only pkcs12 cert' do
      let(:args) { { pkcs12: pkcs12_cert } }
      it { is_expected.to eq("msf_pkcs12:#{pkcs12_cert}::") }
    end

    context 'with pkcs12 cert and CA' do
      let(:args) { { pkcs12: pkcs12_cert, ca: ca } }
      it { is_expected.to eq("msf_pkcs12:#{pkcs12_cert}:#{ca}:") }
    end

    context 'with pkcs12 cert and ADCS template' do
      let(:args) { { pkcs12: pkcs12_cert, adcs_template: adcs_template } }
      it { is_expected.to eq("msf_pkcs12:#{pkcs12_cert}::#{adcs_template}") }
    end

    context 'with pkcs12 cert, CA and ADCS template' do
      let(:args) { { pkcs12: pkcs12_cert, ca: ca, adcs_template: adcs_template } }
      it { is_expected.to eq("msf_pkcs12:#{pkcs12_cert}:#{ca}:#{adcs_template}") }
    end

    context 'without pkcs12 cert' do
      let(:args) { { ca: ca, adcs_template: adcs_template } }
      it 'raises the expected exception' do
        expect { serialized_data }.to raise_error(ArgumentError)
      end
    end

    context 'with an empty CA' do
      let(:args) { { pkcs12: pkcs12_cert, ca: '' } }
      it 'raises the expected exception' do
        expect { serialized_data }.to raise_error(ArgumentError)
      end
    end

    context 'with an empty ADCS template' do
      let(:args) { { pkcs12: pkcs12_cert, ca: '', adcs_template: '' } }
      it 'raises the expected exception' do
        expect { serialized_data }.to raise_error(ArgumentError)
      end
    end
  end

  context '#pkcs12' do
    it 'returns the base64 encoded pkcs12' do
      cert = 'mycert'
      data = "msf_pkcs12:#{cert}:myca:mytemplate"
      pkcs12 = FactoryBot.build(:metasploit_credential_pkcs12, data: data)
      expect(pkcs12.pkcs12).to eq(cert)
    end
  end

  context '#ca' do
    it 'returns the CA' do
      ca = 'myca'
      data = "msf_pkcs12:mycert:#{ca}:mytemplate"
      pkcs12 = FactoryBot.build(:metasploit_credential_pkcs12, data: data)
      expect(pkcs12.ca).to eq(ca)
    end
  end

  context '#ca' do
    it 'returns the CA' do
      adcs_template = 'mytemplate'
      data = "msf_pkcs12:mycert:ca:#{adcs_template}"
      pkcs12 = FactoryBot.build(:metasploit_credential_pkcs12, data: data)
      expect(pkcs12.adcs_template).to eq(adcs_template)
    end
  end

  context '#openssl_pkcs12' do
    subject { FactoryBot.build(:metasploit_credential_pkcs12).openssl_pkcs12 }

    it { is_expected.to be_a OpenSSL::PKCS12 }

    it 'raises an exception if data is not a base64-encoded certificate' do
      expect {
        FactoryBot.build(:metasploit_credential_pkcs12, data: 'msf_pkcs12:wrong_cert::').openssl_pkcs12
      }.to raise_error(ArgumentError)
    end

    it 'returns the expected OpenSSL::PKCS12' do
      subject = '/C=FR/O=Yeah/OU=Yeah/CN=Yeah'
      issuer = '/C=FR/O=Issuer1/OU=Issuer1/CN=Issuer1'
      pkcs12 = FactoryBot.build(
        :metasploit_credential_pkcs12,
        signing_algorithm: 'SHA512',
        subject: subject,
        issuer: issuer
      )
      openssl_pkcs12 = pkcs12.openssl_pkcs12
      expect(openssl_pkcs12.certificate.signature_algorithm).to eq("sha512WithRSAEncryption")
      expect(openssl_pkcs12.certificate.subject.to_s).to eq(subject)
      expect(openssl_pkcs12.certificate.issuer.to_s).to eq(issuer)
    end
  end

  context '#to_s' do
    let(:subject) { '/C=FR/O=Yeah/OU=Yeah/CN=Yeah' }
    let(:issuer) { '/C=FR/O=Issuer1/OU=Issuer1/CN=Issuer1' }
    let(:ca) { 'myca' }
    let(:adcs_template) { 'mytemplate' }

    context 'with the pkcs21 only' do
      it 'returns the expected string' do
        ca = 'myca'
        adcs_template = 'mytemplate'
        pkcs12 = FactoryBot.build(
          :metasploit_credential_pkcs12,
          subject: subject,
          issuer: issuer
        )
        expect(pkcs12.to_s).to eq("subject:#{subject},issuer:#{issuer}")
      end
    end

    context 'with the pkcs21 and the ca' do
      it 'returns the expected string' do
        pkcs12 = FactoryBot.build(
          :metasploit_credential_pkcs12_with_ca,
          subject: subject,
          issuer: issuer,
          ca: ca
        )
        expect(pkcs12.to_s).to eq("subject:#{subject},issuer:#{issuer},CA:#{ca}")
      end
    end

    context 'with the pkcs21 and the ADCS template' do
      it 'returns the expected string' do
        pkcs12 = FactoryBot.build(
          :metasploit_credential_pkcs12_with_adcs_template,
          subject: subject,
          issuer: issuer,
          adcs_template: adcs_template
        )
        expect(pkcs12.to_s).to eq("subject:#{subject},issuer:#{issuer},ADCS_template:#{adcs_template}")
      end
    end

    context 'with the pkcs21, the CA and the ADCS template' do
      it 'returns the expected string' do
        subject = '/C=FR/O=Yeah/OU=Yeah/CN=Yeah'
        issuer = '/C=FR/O=Issuer1/OU=Issuer1/CN=Issuer1'
        pkcs12 = FactoryBot.build(
          :metasploit_credential_pkcs12_with_ca_and_adcs_template,
          subject: subject,
          issuer: issuer,
          ca: ca,
          adcs_template: adcs_template
        )
        expect(pkcs12.to_s).to eq("subject:#{subject},issuer:#{issuer},CA:#{ca},ADCS_template:#{adcs_template}")
      end
    end

    context 'with no data' do
      it 'returns an empty string' do
        pkcs12 = FactoryBot.build(:metasploit_credential_pkcs12, data: nil)
        expect(pkcs12.to_s).to eq('')
      end
    end
  end

  describe 'human name' do
    it 'properly determines the model\'s human name' do
      expect(described_class.model_name.human).to eq('Pkcs12 (pfx)')
    end
  end
end
