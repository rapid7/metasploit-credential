#
# Standard Library
#

require 'pathname'

# {Metasploit::Credential::Importer::Multi} allows a single class to pass off a file to the correct importer as
# long as the file meets certain basic requirements.  Each file type is identified, and if supported, another class
# in the {Metasploit::Credential::Importer} namespace is instantiated with the {#data} attribute passed in there.
class Metasploit::Credential::Importer::Multi
  include Metasploit::Credential::Importer::Base

  #
  # Attributes
  #

  # @!attribute selected_importer
  #   An instance of the importer class which will handle the processing of data into the system.
  #   @return [IO]
  attr_accessor :selected_importer

  #
  # Validations
  #

  validate :is_supported_format

  #
  # Instance Methods
  #

  def initialize(file)
    @data = file
    @selected_importer = nil

    if zip?
      @selected_importer = Metasploit::Credential::Importer::Zip.new(data: data)
    elsif csv?
      @selected_importer =Metasploit::Credential::Importer::CSV::Core.new(data: data)
    end
  end

  # Perform the import
  #
  # @return [void]
  def import!
    selected_importer.import!
  end


  # True if the file can be opened with {Zip::File::open}, false otherwise
  #
  # @return [Boolean]
  def zip?
    begin
      ::Zip::ZipFile.open data.path
      true
    rescue ::Zip::ZipError
      false
    end
  end

  # True if the file has a ".csv" extension
  #
  # @return [Boolean]
  def csv?
    ::Pathname.new(data.path).extname == '.csv'
  end

  private

  # True if the format of {#data} is supported for import
  #
  # @return [Boolean]
  def is_supported_format
    if zip? || csv?
      true
    else
      errors.add(:data, :unsupported_file_format)
    end
  end
end