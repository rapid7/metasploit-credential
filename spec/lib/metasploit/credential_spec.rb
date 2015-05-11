require 'spec_helper'

RSpec.describe Metasploit::Credential do
  context 'CONSTANTS' do
    context 'VERSION' do
      subject(:version) do
        described_class::VERSION
      end

      it 'is Metasploit::Credential::Version.full' do
        expect(version).to eq(Metasploit::Credential::Version.full)
      end
    end
  end
end