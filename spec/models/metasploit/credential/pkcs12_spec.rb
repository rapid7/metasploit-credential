RSpec.describe Metasploit::Credential::Pkcs12, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factories' do
    context 'metasploit_credential_pkcs12' do
      subject(:metasploit_credential_pkcs12) do
        FactoryBot.build(:metasploit_credential_pkcs12)
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

  describe 'human name' do
    it 'properly determines the model\'s human name' do
      expect(described_class.model_name.human).to eq('Pkcs12 (pfx)')
    end
  end
end
