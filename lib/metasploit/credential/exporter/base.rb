module Metasploit
  module Credential
    module Exporter
      module Base
        extend ActiveSupport::Concern

        included do
          include ActiveModel::Validations
          # @!attribute output
          #   An {IO} that holds the exported data. {File} in normal usage.
          #   @return [IO]
          attr_accessor :output

          # @!attribute workspace
          #   The {Mdm::Workspace} that the credentials will be exported from
          #   @return[Mdm::Workspace]
          attr_accessor :workspace
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
