
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

  # @!attribute manifest_importer
  #   The importer for the zip's manifest file
  #
  #   @return [Metasploit::Credential::Importer::CSV::Manifest]
  attr_accessor :manifest_importer

  # @!attribute zip_file
  #   The zip file
  #
  #   @return [File]
  attr_accessor :zip_file

  #
  # Validations
  #

  validate :zip_file_is_well_formed

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
    ::Zip::File.open(zip_file.path)
    csv_path = extracted_zip_path + '/' + MANIFEST_FILE_NAME
    csv_data = File.open(csv_path)
    Metasploit::Credential::Importer::CSV::Manifest.new(data: csv_data, origin: origin).import!
  end

  def extracted_zip_path
    full_path     = Pathname.new zip_file
    path_fragment = full_path.dirname.to_s
    zip_dir_name  = full_path.basename(".*").to_s
    path_fragment + '/' + zip_dir_name
  end


  # Validates that the zip file contains a file called +manifest.csv+ and that it
  # can be handled with the {::Zip::File::open} method.
  #
  # @return [void]
  def zip_file_is_well_formed
    begin
      Zip::File.open zip_file.path do |archive|
        manifest_file = archive.glob(MANIFEST_FILE_NAME).first
        if manifest_file.present?
          true
        else
          errors.add(:zip_file, :missing_manifest)
        end
      end
    rescue ::Zip::Error
      errors.add(:zip_file, :malformed_archive)
    end
  end

end