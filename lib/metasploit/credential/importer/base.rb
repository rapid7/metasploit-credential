module Metasploit
  module Credential
    module Importer
      module Base
        extend ActiveSupport::Concern

        included do
          include ActiveModel::Validations
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