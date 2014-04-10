require 'spec_helper'

describe Metasploit::Credential::Realm::Key do
  context 'CONSTANTS' do
    context 'ACTIVE_DIRECTORY_DOMAIN' do
      subject(:active_directory_domain) do
        described_class::ACTIVE_DIRECTORY_DOMAIN
      end

      it { should == 'Active Directory Domain' }
    end

    context 'POSTGRESQL DATABASE' do
      subject(:postgresql_database) do
        described_class::POSTGRESQL_DATABASE
      end

      it { should == 'PostgreSQL Database' }
    end
  end
end