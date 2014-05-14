
# Allows importation of a zip file of a specially structured directory containing a file called
# +manifest.csv+ (conforming to {Metasploit::Credential::Importer::CSV::Manifest}) and a collection
# of files which each contain one private key.
class Metasploit::Credential::Importer::Zip
  include Metasploit::Credential::Importer::Base

  #
  # Constants
  #

  # The name of the file in the zip which is opened and passed as a {File} to an instance of
  # {Metasploit::Credential::Importer::CSV::Manifest}
  MANIFEST_FILE_NAME = "manifest.csv"

  # An argument to {Dir::mktmpdir}
  TEMP_UNZIP_PATH_PREFIX = "metasploit-imports"

  #
  # Attributes
  #

  # @!attribute zip_file
  #   The zip file
  #
  #   @return [File]
  attr_accessor :zip_file

  #
  # Validations
  #

  validate :zip_file_is_well_formed, :zip_contains_manifest

  #
  # Instance Methods
  #

  # Extract the zip file and pass the +manifest.csv+ contained therein to a
  # {Metasploit::Credential::Importer::CSV::Manifest}, which is in charge of creating new {Metasploit::Credential::Core}
  # objects, creating new {Metasploit::Credential::Public} objects or linking existing ones, and associating them with
  # extracted {Metasploit::Credential::SSHKey} objects read from the files indicated in the manifest.
  #
  # @return [void]
  def import!
    # do the unzip
    #
    csv_data = nil
    Zip.open(zip_file.path) do |archive|
      # csv_data = archive.glob(MANIFEST_FILE_NAME).first
      # fins the file above and extract it, setting csv_data to the resultant {File} object
      # extract all the files in the zip to a tmp directory (platform-specific!)
    end
    Metasploit::Credential::Importer::CSV::Manifest.new(data: csv_data).import!
  end


  # Validates that the zip file can be opened by the rubyzip gem
  #
  # @return [void]
  def zip_file_is_archive
    begin
      Zip::File.open zip_file.path
      true
    rescue Zip::Error
      errors.add(:zip_file, :malformed_archive)
    end
  end

  # Validates that the zip file contains a file called +manifest.csv+
  #
  # @return [void]
  def zip_contains_manifest
    Zip::File.open zip_file.path do |archive|
      manifest_file = archive.glob(MANIFEST_FILE_NAME).first
      if manifest_file.present?
        true
      else
        errors.add(:zip_file, :missing_manifest)
      end
    end
  end

end