RSpec.shared_examples_for 'a KrbTicket' do
  let(:expected) { {} }

  describe '#data' do
    it 'has a data hash' do
      expect(subject.data.keys - %i[ type value starttime authtime endtime sname ]).to be_empty
      expect(subject.data[:type]).to eq(expected[:type])
      expect(subject.data[:value]).to match(expected[:value])
      expect(subject.data[:sname]).to match(expected[:sname])
      require 'pry'; binding.pry
      expect(subject.data[:starttime]).to match(expected[:starttime])
      expect(subject.data[:authtime]).to match(expected[:authtime])
      expect(subject.data[:endtime]).to match(expected[:endtime])
    end
  end

  describe '#type' do
    it 'has a type' do
      expect(subject.type).to eq(subject.data[:type])
    end
  end

  describe '#value' do
    it 'has a value' do
      expect(subject.value).to eq(subject.data[:value])
    end
  end

  describe '#authtime' do
    it 'has an authtime' do
      expect(subject.authtime).to eq(subject.data[:authtime])
    end
  end

  describe '#starttime' do
    it 'has an starttime' do
      expect(subject.starttime).to eq(subject.data[:starttime])
    end
  end

  describe '#endtime' do
    it 'has an endtime' do
      expect(subject.endtime).to eq(subject.data[:endtime])
    end
  end

  describe '#to_s' do
    it 'has a human readable to_s' do
      expect(subject.to_s).to match expected[:to_s]
    end
  end
end

RSpec.describe Metasploit::Credential::KrbTicket, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  it { is_expected.to be_a Metasploit::Credential::Private }

  context 'factories' do
    FactoryBot.factories[:metasploit_credential_krb_ticket].defined_traits.each do |trait|
      context "with #{trait}" do
        subject(:metasploit_credential_krb_ticket) do
          FactoryBot.build(:metasploit_credential_krb_ticket, trait.name)
        end

        it { is_expected.to be_valid }
        it { expect(subject.data).to be_a(Hash) }
      end
    end
  end

  before do
    Timecop.freeze(Time.local(1990).utc)
  end

  after do
    Timecop.return
  end

  context 'when the krb ticket is a tgt' do
    subject :krb_ticket do
      FactoryBot.build(:metasploit_credential_krb_ticket, :with_tgt)
    end

    it_behaves_like 'a KrbTicket' do
      let(:expected) do
        {
          type: :tgt,
          value: /\w+/,
          sname: /krbtgt\/.*/,
          authtime: nil,
          starttime: Time.now.utc,
          endtime: Time.now.utc + 1.days,
          to_s: /tgt:(?<sname>[\w.\/]+):ccache:(?<ticket_value>[\w.\/]+)/
        }
      end
    end
  end

  context 'when the krb ticket is a tgs' do
    subject :krb_ticket do
      FactoryBot.build(:metasploit_credential_krb_ticket, :with_tgs)
    end

    it_behaves_like 'a KrbTicket' do
      let(:expected) do
        {
          type: :tgs,
          value: /\w+/,
          sname: /.*\/.*/,
          authtime: nil,
          starttime: Time.now.utc,
          endtime: Time.now.utc + 1.days,
          to_s: /tgs:(?<sname>[\w.\/]+):ccache:(?<ticket_value>[\w.\/]+)/
        }
      end
    end
  end

  context 'validations' do
    context '#data' do
      subject(:data_errors) do
        krb_ticket.errors[:data]
      end

      #
      # lets
      #

      let(:data) do
        FactoryBot.build(:metasploit_credential_krb_ticket, :with_tgs).data
      end

      let(:krb_ticket) do
        FactoryBot.build(
          :metasploit_credential_krb_ticket,
          data: data
        )
      end

      #
      # Callbacks
      #

      before(:example) do
        krb_ticket.valid?
      end

      context 'when the data is valid' do
        it { is_expected.to be_empty }
      end

      context "when the type is missing" do
        let(:data) do
          super().without(:type)
        end

        it { is_expected.to include('is missing type') }
      end

      context "when the value is missing" do
        let(:data) do
          super().without(:value)
        end

        it { is_expected.to include('is missing value') }
      end

      context "when the sname is missing" do
        let(:data) do
          super().without(:sname)
        end

        it { is_expected.to include('is missing sname') }
      end

      context 'when invalid keys are present' do
        let(:data) do
          super().merge({ typ: 123, end_time: 'abc' })
        end

        it { is_expected.to include('has invalid attribute typ', 'has invalid attribute end_time') }
      end
    end
  end
end
