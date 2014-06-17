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
      context 'with Metasploit::Credential::Private' do
        #
        # lets
        #

        let(:klass) {
          Metasploit::Credential::Private
        }

        let(:matching_attributes) {
          {}
        }

        let(:non_matching_attributes) {
          {}
        }


        #
        # let!s
        #

        let!(:matching_record) {
          FactoryGirl.create(
              factory,
              matching_attributes
          )
        }

        let!(:non_matching_record) {
          FactoryGirl.create(
              factory,
              non_matching_attributes
          )
        }

        context 'Metasploit::Credential::Private#data' do
          context 'wth Metasploit::Credential::PasswordHash subclass' do
            let(:matching_attributes) {
              {
                  password_data: '123456789'
              }
            }

            let(:non_matching_attributes) {
              {
                  password_data: 'password'
              }
            }

            context 'Metasploit::Credential::NonreplayableHash' do
              let(:factory) {
                :metasploit_credential_nonreplayable_hash
              }

              it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                    attribute: :data
            end

            context 'Metasploit::Credential::NTLMHash' do
              let(:factory) {
                :metasploit_credential_ntlm_hash
              }

              it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                    attribute: :data
            end
          end

          context 'with Metasploit::Credential::Password' do
            let(:factory) {
              :metasploit_credential_password
            }

            let(:matching_attributes) {
              {
                  data: '123456789'
              }
            }

            let(:non_matching_attributes) {
              {
                  # needs to not be a substring alias of matching_attributes[:password_data]
                  data: 'password'
              }
            }

            it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                  attribute: :data
          end

          context 'with Metasploit::Credential::SSHKey' do
            #
            # lets
            #

            let(:factory) {
              :metasploit_credential_ssh_key
            }

            it_should_behave_like 'MetasploitDataModels::Search::Visitor::Relation#visit matching record',
                                  attribute: :data
          end
        end
      end
    end
  end
end