
# Implements importation of a zip file containing credentials.  Each well-formed zip should contain one CSV file and a
# subdirectory holding a collection of files, each containing one SSH private key.
class Metasploit::Credential::Importer::Zip
  include Metasploit::Credential::Importer::Base

  #
  # Constants
  #

  # The name of the directory in the zip file's root directory that contains SSH keys
  KEYS_SUBDIRECTORY_NAME = "keys"

  # The name of the file in the zip which is opened and passed as a {File} to an instance of
  # {Metasploit::Credential::Importer::CSV::Core}
  MANIFEST_FILE_NAME = "manifest.csv"

  # An argument to {Dir::mktmpdir}
  TEMP_UNZIP_PATH_PREFIX = "metasploit-imports"

  #
  # Attributes
  #

  # @!attribute manifest_importer
  #   The importer for the zip's manifest file
  #
  #   @return [Metasploit::Credential::Importer::CSV::Manifest]
  attr_accessor :manifest_importer

  #
  # Validations
  #

  validate :data_is_well_formed

  #
  # Instance Methods
  #

  # Extract the zip file and pass the CSV file contained therein to a
  # {Metasploit::Credential::Importer::CSV::Core}, which is in charge of creating new {Metasploit::Credential::Core}
  # objects, creating new {Metasploit::Credential::Public} objects or linking existing ones, and associating them with
  # extracted {Metasploit::Credential::SSHKey} objects read from the files indicated in the manifest.
  #
  # @return [void]
  def import!
    ::Zip::ZipFile.open(data.path)
    csv_path = extracted_zip_path + '/' + MANIFEST_FILE_NAME
    csv_data = File.open(csv_path)
    Metasploit::Credential::Importer::Core.new(data: csv_data, origin: origin).import!
  end

  def extracted_zip_path
    full_path     = Pathname.new data
    path_fragment = full_path.dirname.to_s
    zip_dir_name  = full_path.basename(".*").to_s
    path_fragment + '/' + zip_dir_name
  end


  # Validates that the zip file contains a CSV file and that it
  # can be handled with the {::Zip::ZipFile::open} method.
  #
  # @return [void]
  def data_is_well_formed
    begin
      Zip::ZipFile.open data.path do |archive|
        manifest_file = archive.find_entry(MANIFEST_FILE_NAME)

        if manifest_file
          if archive.find_entry(KEYS_SUBDIRECTORY_NAME)
            true
          else
            errors.add(:data, :missing_keys)
          end
        else
          errors.add(:data, :missing_manifest)
        end
      end
    rescue ::Zip::ZipError
      errors.add(:data, :malformed_archive)
    end
  end

end