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

  #
  # Method Validations
  #
  validate :header_format_and_csv_wellformedness

  #
  # Instance Methods
  #

  def csv_object
    @csv_object ||= CSV.new(data, headers:true)
  end

  # (overridden in subclasses)
  # Parse the {#csv_object} and create new data model objects
  # @return[void]
  def import!
    raise NotImplementedError, "this method must be defined in the subclas"
  end

  private

  # Invalid if CSV is malformed, headers are not in compliance, or CSV contains no data
  #
  # @return [void]
  # TODO: add new i18n stuff for the error strings below
  def header_format_and_csv_wellformedness
    begin
      if csv_object.present?
        first_row = csv_object.first
        if first_row.present?
          if first_row.map(&:to_sym) == self.class.const_get(:VALID_CSV_HEADERS)
            return true
          else
            errors.add(:data, :incorrect_csv_headers)
          end
        end
      else
        errors.add(:data, :empty_csv)
      end
    rescue
      errors.add(:data, :malformed_csv)
    end
  end

end