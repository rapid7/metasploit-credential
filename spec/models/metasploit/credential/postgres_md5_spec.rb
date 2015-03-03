require 'spec_helper'

describe Metasploit::Credential::PostgresMD5 do
  it_should_behave_like 'Metasploit::Concern.run'

  it { should be_a Metasploit::Credential::ReplayableHash }

  context 'CONSTANTS' do
    context 'DATA_REGEXP' do
      subject(:data_regexp) do
        described_class::DATA_REGEXP
      end

      it 'is valid if the string is md5 and 32 hex chars' do
        hash = "md5#{SecureRandom.hex(16)}"
        expect(data_regexp).to match(hash)
      end

      it 'is not valid if it does not start with md5' do
        expect(data_regexp).not_to match(SecureRandom.hex(16))
      end

      it 'is not valid for an invalid length' do
        expect(data_regexp).not_to match(SecureRandom.hex(6))
      end

      it 'is not valid if it is not hex chars after the md5 tag' do
        bogus = "md5#{SecureRandom.hex(15)}jk"
        expect(data_regexp).not_to match(bogus)
      end

    end
  end


end
