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

    context 'metasploit_credential_pkcs12_with_pkcs12_password' do
      subject(:metasploit_credential_pkcs12_with_pkcs12_password) do
        FactoryBot.build(:metasploit_credential_pkcs12_with_pkcs12_password)
      end

      it { is_expected.to be_valid }
    end

    context 'metasploit_credential_pkcs12_with_ca_and_adcs_template' do
      subject(:metasploit_credential_pkcs12_with_ca_and_adcs_template) do
        FactoryBot.build(:metasploit_credential_pkcs12_with_ca_and_adcs_template)
      end

      it { is_expected.to be_valid }
    end

    context 'metasploit_credential_pkcs12_with_ca_and_adcs_template_and_pkcs12_password' do
      subject(:metasploit_credential_pkcs12_with_ca_and_adcs_template_and_pkcs12_password) do
        FactoryBot.build(:metasploit_credential_pkcs12_with_ca_and_adcs_template_and_pkcs12_password)
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

    end
  end

  context '#data' do
    it 'returns the base64 encoded pkcs12' do
      cert = 'mycert'
      data = Base64.strict_encode64(cert)
      pkcs12 = FactoryBot.build(:metasploit_credential_pkcs12, data: data)
      expect(pkcs12.data).to eq(data)
    end
  end

  context '#metadata' do
    let(:cert) { 'mycert' }
    let(:data) { Base64.strict_encode64(cert) }

    context 'with the CA' do
      it 'returns the CA in the metadata' do
        ca = 'myca'
        pkcs12 = FactoryBot.build(:metasploit_credential_pkcs12, data: data, metadata: { ca: ca })
        expect(pkcs12.metadata).to eq( { 'ca' => ca } )
      end
    end

    context 'with the Certififate Template' do
      it 'returns the certificate template in the metadata' do
        adcs_template = 'mytemplate'
        pkcs12 = FactoryBot.build(:metasploit_credential_pkcs12, data: data, metadata: { adcs_template: adcs_template })
        expect(pkcs12.metadata).to eq( { 'adcs_template' => adcs_template } )
      end
    end

    context 'with both the CA and the Certififate Template' do
      it 'returns the CA and the certificate template in the metadata' do
        ca = 'myca'
        adcs_template = 'mytemplate'
        pkcs12 = FactoryBot.build(:metasploit_credential_pkcs12, data: data, metadata: { ca: ca, adcs_template: adcs_template })
        expect(pkcs12.metadata).to eq( { 'ca' => ca, 'adcs_template' => adcs_template } )
      end
    end

    context 'with both the CA, the Certififate Template and the cert password' do
      it 'returns the CA and the certificate template in the metadata' do
        ca = 'myca'
        adcs_template = 'mytemplate'
        pkcs12_password = 'mypassword'
        pkcs12 = FactoryBot.build(:metasploit_credential_pkcs12, data: data, metadata: { ca: ca, adcs_template: adcs_template, pkcs12_password: pkcs12_password })
        expect(pkcs12.metadata).to eq( { 'ca' => ca, 'adcs_template' => adcs_template, 'pkcs12_password' => pkcs12_password } )
      end
    end
  end

  context '#ca' do
    it 'returns the CA' do
      cert = 'mycert'
      data = Base64.strict_encode64(cert)
      ca = 'myca'
      pkcs12 = FactoryBot.build(:metasploit_credential_pkcs12, data: data, metadata: { ca: ca })
      expect(pkcs12.ca).to eq(ca)
    end
  end

  context '#adcs_template' do
    it 'returns the certificate template' do
      cert = 'mycert'
      data = Base64.strict_encode64(cert)
      adcs_template = 'mytemplate'
      pkcs12 = FactoryBot.build(:metasploit_credential_pkcs12, data: data, metadata: { adcs_template: adcs_template })
      expect(pkcs12.adcs_template).to eq(adcs_template)
    end
  end

  context '#pkcs12_password' do
    it 'returns the Pkcs12 password' do
      cert = 'mycert'
      data = Base64.strict_encode64(cert)
      pkcs12_password = 'mypassword'
      pkcs12 = FactoryBot.build(:metasploit_credential_pkcs12, data: data, metadata: { pkcs12_password: pkcs12_password })
      expect(pkcs12.pkcs12_password).to eq(pkcs12_password)
    end
  end

  context '#openssl_pkcs12' do
    subject { FactoryBot.build(:metasploit_credential_pkcs12).openssl_pkcs12 }

    it { is_expected.to be_a OpenSSL::PKCS12 }

    it 'raises an exception if data is not a base64-encoded certificate' do
      expect {
        FactoryBot.build(:metasploit_credential_pkcs12, data: 'wrong_cert').openssl_pkcs12
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
    let(:pkcs12_password) { 'mypassword' }

    context 'with the pkcs21 only' do
      it 'returns the expected string' do
        pkcs12 = FactoryBot.build(
          :metasploit_credential_pkcs12,
          subject: subject,
          issuer: issuer
        )
        expect(pkcs12.to_s).to eq("subject:#{subject},issuer:#{issuer}")
      end
    end

    context 'with the pkcs21 and the CA' do
      it 'returns the expected string' do
        pkcs12 = FactoryBot.build(
          :metasploit_credential_pkcs12_with_ca,
          subject: subject,
          issuer: issuer,
          metadata: { ca: ca }
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
          metadata: { adcs_template: adcs_template }
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
          metadata: { ca: ca, adcs_template: adcs_template }
        )
        expect(pkcs12.to_s).to eq("subject:#{subject},issuer:#{issuer},CA:#{ca},ADCS_template:#{adcs_template}")
      end
    end

    context 'with the pkcs21, the CA, the ADCS template and the pkcs12 password' do
      it 'returns the expected string' do
        subject = '/C=FR/O=Yeah/OU=Yeah/CN=Yeah'
        issuer = '/C=FR/O=Issuer1/OU=Issuer1/CN=Issuer1'
        pkcs12_password = 'mypassword'
        pkcs12 = FactoryBot.build(
          :metasploit_credential_pkcs12_with_ca_and_adcs_template_and_pkcs12_password,
          subject: subject,
          issuer: issuer,
          pkcs12_password: pkcs12_password,
          metadata: { ca: ca, adcs_template: adcs_template, pkcs12_password: pkcs12_password }
        )
        # The Pkcs12 password is voluntarily not included
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
