require 'spec_helper'

describe Metasploit::Credential::Realm::Key do
  context 'CONSTANTS' do
    context 'ACTIVE_DIRECTORY_DOMAIN' do
      subject(:active_directory_domain) do
        described_class::ACTIVE_DIRECTORY_DOMAIN
      end

      it { should == 'Active Directory Domain' }
      it { should be_in described_class::ALL }
    end

    context 'ALL' do
      subject(:all) do
        described_class::ALL
      end

      it { should include described_class::ACTIVE_DIRECTORY_DOMAIN }
      it { should include described_class::ORACLE_SYSTEM_IDENTIFIER }
      it { should include described_class::POSTGRESQL_DATABASE }
    end

    context 'ORACLE_SYSTEM_IDENTIFIER' do
      subject(:oracle_system_identifier) do
        described_class::ORACLE_SYSTEM_IDENTIFIER
      end

      it { should == 'Oracle System Identifier' }
      it { should be_in described_class::ALL }
    end

    context 'POSTGRESQL DATABASE' do
      subject(:postgresql_database) do
        described_class::POSTGRESQL_DATABASE
      end

      it { should == 'PostgreSQL Database' }
      it { should be_in described_class::ALL }
    end
  end
end