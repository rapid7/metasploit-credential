require 'spec_helper'

describe Metasploit::Credential::Login::Status do
  context 'CONSTANTS' do
    context 'ALL' do
      subject(:all) do
        described_class::ALL
      end

      it { should include described_class::DENIED_ACCESS }
      it { should include described_class::DISABLED }
      it { should include described_class::LOCKED_OUT }
      it { should include described_class::SUCCESSFUL }
      it { should include described_class::UNABLE_TO_CONNECT }
      it { should include described_class::UNTRIED }
    end

    context 'DENIED_ACCESS' do
      subject(:denied_access) do
        described_class::DENIED_ACCESS
      end

      it { should == 'Denied Access' }
      it { should be_in described_class::ALL }
    end

    context 'DISABLED' do
      subject(:disabled) do
        described_class::DISABLED
      end

      it { should == 'Disabled' }
      it { should be_in described_class::ALL }
    end

    context 'LOCKED_OUT' do
      subject(:locked_out) do
        described_class::LOCKED_OUT
      end

      it { should == 'Locked Out' }
      it { should be_in described_class::ALL }
    end

    context 'SUCCESSFUL' do
      subject(:successful) do
        described_class::SUCCESSFUL
      end

      it { should == 'Successful' }
      it { should be_in described_class::ALL }
    end

    context 'UNABLE_TO_CONNECT' do
      subject(:unabled_to_connect) do
        described_class::UNABLE_TO_CONNECT
      end

      it { should == 'Unable to Connect' }
      it { should be_in described_class::ALL }
    end

    context 'UNTRIED' do
      subject(:untried) do
        described_class::UNTRIED
      end

      it { should == 'Untried' }
      it { should be_in described_class::ALL }
    end
  end
end