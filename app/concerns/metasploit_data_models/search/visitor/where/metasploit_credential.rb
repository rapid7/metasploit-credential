module MetasploitDataModels::Search::Visitor::Where::MetasploitCredential
  extend ActiveSupport::Concern

  included do
    visit 'Metasploit::Credential::Search::Operation::Type' do |operation|
      attribute = attribute_visitor.visit operation.operator

      attribute.eq(operation.value)
    end
  end
end