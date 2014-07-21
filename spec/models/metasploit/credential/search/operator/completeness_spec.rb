require 'spec_helper'

describe Metasploit::Credential::Search::Operator::Completeness do
  subject(:operator) {
    described_class.new
  }

  context '#name' do
    subject(:name) {
      operator.name
    }

    it { should == :completeness }
  end

  context '#operation_class_name' do
    subject(:operation_class_name) {
      operator.operation_class_name
    }

    it { should == 'Metasploit::Credential::Search::Operation::Completeness' }
  end
end