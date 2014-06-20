require 'spec_helper'

require 'securerandom'

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

        context 'Metasploit::Credential::Private#data' do
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

        context 'Metasploit::Credential::Private#type' do
          #
          # lets
          #

          let(:matching_record) {
            metasploit_credential_private_by_class.fetch(matching_class)
          }

          let(:metasploit_private_factories) {
            [
                :metasploit_credential_nonreplayable_hash,
                :metasploit_credential_ntlm_hash,
                :metasploit_credential_password,
                :metasploit_credential_ssh_key
            ]
          }

          #
          # let!s
          #

          let!(:metasploit_credential_private_by_class) {
            metasploit_private_factories.each_with_object({}) { |factory, instance_by_class|
              instance = FactoryGirl.create(factory)
              instance_by_class[instance.class] = instance
            }
          }

          it_should_behave_like 'Metasploit::Credential::Search::Operation::Type',
                                matching_class: Metasploit::Credential::NonreplayableHash

          it_should_behave_like 'Metasploit::Credential::Search::Operation::Type',
                                matching_class: Metasploit::Credential::NTLMHash

          it_should_behave_like 'Metasploit::Credential::Search::Operation::Type',
                                matching_class: Metasploit::Credential::Password

          it_should_behave_like 'Metasploit::Credential::Search::Operation::Type',
                                matching_class: Metasploit::Credential::SSHKey
        end

        context 'with all operators' do
          #
          # shared examples
          #

          shared_examples_for 'matching class' do |matching_class|
            context "with #{matching_class}" do
              let(:matching_class) {
                matching_class
              }

              context 'with Class#name' do
                let(:matching_type) {
                  matching_class.name
                }

                it 'should find only matching record' do
                  expect(visit).to match_array([matching_record])
                end
              end

              context 'with Class#model_name.human' do
                let(:matching_type) {
                  matching_class.model_name.human
                }

                it 'should find only matching record' do
                  expect(visit).to match_array([matching_record])
                end
              end
            end
          end

          #
          # lets
          #

          let(:formatted) {
            %Q{data:"#{matching_data}" type:"#{matching_type}"}
          }

          let(:metasploit_credential_privates_by_class) {
            {
                Metasploit::Credential::NonreplayableHash => FactoryGirl.create_list(
                    :metasploit_credential_nonreplayable_hash,
                    2
                ),
                Metasploit::Credential::NTLMHash => FactoryGirl.create_list(
                    :metasploit_credential_ntlm_hash,
                    2
                ),
                Metasploit::Credential::Password => [
                    FactoryGirl.create(
                        :metasploit_credential_password,
                        data: 'alices_password'
                    ),
                    FactoryGirl.create(
                        :metasploit_credential_password,
                        data: 'bobs_password'
                    )
                ],
                Metasploit::Credential::SSHKey => FactoryGirl.create_list(
                    :metasploit_credential_ssh_key,
                    2
                )
            }
          }

          let(:matching_class_records) {
            metasploit_credential_privates_by_class.fetch(matching_class)
          }

          let(:matching_data) {
            matching_record.data
          }

          let(:matching_record) {
            matching_class_records.sample
          }

          it_should_behave_like 'matching class', Metasploit::Credential::NonreplayableHash
          it_should_behave_like 'matching class', Metasploit::Credential::NTLMHash
        end
      end
    end
  end
end