require 'spec_helper'

describe MetasploitDataModels::Search::Visitor::Relation do
  subject(:visitor) {
    described_class.new(
        query: query
    )
  }

  let(:query) {
    Metasploit::Model::Search::Query.new(
        formatted: formatted,
        klass: klass
    )
  }

  context '#visit' do
    subject(:visit) {
      visitor.visit
    }

    context 'MetasploitDataModels::Search::Visitor::Relation#query Metasploit::Model::Search::Query#klass' do
      context 'with Metasploit::Credential::Public' do
        let(:klass) {
          Metasploit::Credential::Public
        }

        let(:matching_username) {
          'alice'
        }

        let(:non_matching_username) {
          # must not LIKE match matching_username
          'bob'
        }

        #
        # let!s
        #

        let!(:matching_record) {
          FactoryGirl.create(
              :metasploit_credential_public,
              username: matching_username
          )
        }

        let!(:non_matching_record) {
          FactoryGirl.create(
              :metasploit_credential_public,
              username: non_matching_username
          )
        }

        it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                              attribute: :username
      end
    end
  end
end