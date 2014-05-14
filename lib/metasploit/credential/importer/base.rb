module Metasploit
  module Credential
    module Importer
      module Base
        extend ActiveSupport::Concern

        #
        # Constants
        #

        # Whitelist of the {Metasploit::Credential::Private} subclass names allowed
        # in importers.  Used to designate the names of classes that can be exported
        # and are therefore allowed in imports.
        ALLOWED_PRIVATE_TYPE_NAMES = [
                                      Metasploit::Credential::NonreplayableHash,
                                      Metasploit::Credential::NTLMHash,
                                      Metasploit::Credential::Password,
                                      Metasploit::Credential::SSHKey].map(&:name)


        included do
          include ActiveModel::Validations

          # @!attribute data
          #   An {IO} that holds the CSV data. {File} in normal usage, {StringIO} in testing
          #   @return [IO]
          attr_accessor :data
        end

          #
          # Instance Methods
          #

          # @param attributes [Hash{Symbol => String,nil}]
        def initialize(attributes={})
          attributes.each do |attribute, value|
            public_send("#{attribute}=", value)
          end
        end


      end
    end
  end
end