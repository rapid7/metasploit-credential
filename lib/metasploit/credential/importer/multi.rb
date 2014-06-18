#
# Standard Library
#

require 'pathname'

# {Metasploit::Credential::Importer::Multi} allows a single class to pass off a file to the correct importer as
# long as the file meets certain basic requirements.  Each file type is identified, and if supported, another class
# in the {Metasploit::Credential::Importer} namespace is instantiated with the {#input} attribute passed in there.
class Metasploit::Credential::Importer::Multi
  include Metasploit::Credential::Importer::Base

  #
  # Attributes
  #

  # @!attribute selected_importer
  #   An instance of the importer class which will handle the processing of input into the system.
  #   @return [IO]
  attr_accessor :selected_importer

  #
  # Validations
  #

  validate :is_supported_format

  #
  # Instance Methods
  #

  def initialize(args={})
    @input   = args.fetch(:input)
    @origin = args.fetch(:origin)
    @selected_importer = nil

    if zip?
      @selected_importer = Metasploit::Credential::Importer::Zip.new(input: input, origin: origin)
    elsif csv?
      @selected_importer =Metasploit::Credential::Importer::Core.new(input: input, origin: origin)
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
      ::Zip::File.open input.path
      true
    rescue ::Zip::Error
      false
    end
  end

  # True if the file has a ".csv" extension
  #
  # @return [Boolean]
  def csv?
    ::Pathname.new(input.path).extname == '.csv'
  end

  private

  # True if the format of {#input} is supported for import
  #
  # @return [Boolean]
  def is_supported_format
    if zip? || csv?
      true
    else
      errors.add(:input, :unsupported_file_format)
    end
  end
end