
# Implements importation of a zip file containing credentials.  Each well-formed zip should contain one CSV file and a
# subdirectory holding a collection of files, each containing one SSH private key.
class Metasploit::Credential::Importer::Zip
  include Metasploit::Credential::Importer::Base

  #
  # Constants
  #

  # The name of the directory in the zip file's root directory that contains SSH keys
  KEYS_SUBDIRECTORY_NAME = "keys"

  # The name of the file in the zip which is opened and passed as a `File` to an instance of
  # {Metasploit::Credential::Importer::CSV::Core}
  MANIFEST_FILE_NAME = "manifest.csv"

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

  validate :input_is_well_formed

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
    ::Zip::File.open(input.path)
    csv_path = extracted_zip_path + '/' + MANIFEST_FILE_NAME
    csv_input = File.open(csv_path)
    Metasploit::Credential::Importer::Core.new(input: csv_input, origin: origin, workspace: workspace).import!
  end

  # Returns the path to the directory where the zip was extracted.
  #
  # @return [String]
  def extracted_zip_path
    full_path     = Pathname.new input
    path_fragment = full_path.dirname.to_s
    zip_dir_name  = full_path.basename(".*").to_s
    path_fragment + '/' + zip_dir_name
  end


  # Validates that the zip file contains a CSV file and that it
  # can be handled with the {::Zip::File::open} method.
  #
  # @return [void]
  def input_is_well_formed
    begin
      Zip::File.open input.path do |archive|
        manifest_file = archive.find_entry(MANIFEST_FILE_NAME)

        if manifest_file
          if archive.find_entry(KEYS_SUBDIRECTORY_NAME)
            true
          else
            errors.add(:input, :missing_keys)
          end
        else
          errors.add(:input, :missing_manifest)
        end
      end
    rescue ::Zip::Error
      errors.add(:input, :malformed_archive)
    end
  end

end