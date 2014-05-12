# Provides common behavior that is used in CSV-based imports for credentials.
require 'csv'
class Metasploit::Credential::Importer::CSV::Base
  include Metasploit::Credential::Importer::Base

  #
  # Attributes
  #

  # @!attribute csv_object
  #   The {CSV} instance created from {#data}
  #   @return [CSV]
  attr_reader :csv_object

  # @!attribute data
  #   An {IO} that holds the CSV data. {File} in normal usage, {StringIO} in testing
  #   @return [IO]
  attr_accessor :data

  # @!attribute origin_import
  #   An {Metasploit::Credential::Origin::Import} that represents the discrete
  #   importation of this set of credential objects
  #   @return [Metasploit::Credential::Origin::Import]
  attr_accessor :origin_import

  # @!attribute private_credential_type
  #   The name of one of the subclasses of {Metasploit::Credential::Private}.  This will be the same for all the
  #   {Metasploit::Credential::Private} objects created during the import.
  #   @return[String]
  attr_accessor :private_credential_type

  #
  # Method Validations
  #
  validate :header_format_and_csv_wellformedness

  #
  # Instance Methods
  #

  def csv_object
    @csv_object ||= CSV.new(data, headers:true, return_headers: true)
  end

  # Parse the {#csv_object} and create new data model objects (overridden in subclasses)
  #
  # @return[void]
  def import!
    raise NotImplementedError, "this method must be defined in the subclas"
  end

  private

  # Invalid if CSV is malformed, headers are not in compliance, or CSV contains no data
  #
  # @return [void]
  # TODO: add new i18n stuff for the error strings below
  # TODO: only rescue the malformed CSV exception here
  def header_format_and_csv_wellformedness
    begin
      if csv_object.present?
        if csv_object.header_row?
          csv_headers = csv_object.first.fields
          if csv_headers.map(&:to_sym) == self.class.const_get(:VALID_CSV_HEADERS)
            csv_object.rewind
            true
          else
            errors.add(:data, :incorrect_csv_headers)
          end
        else
          fail "CSV has already been accessed past index 0"
        end
      else
        errors.add(:data, :empty_csv)
      end
    rescue ::CSV::MalformedCSVError
      errors.add(:data, :malformed_csv)
    end
  end

end