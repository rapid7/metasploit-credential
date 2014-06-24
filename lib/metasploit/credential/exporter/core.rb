class Metasploit::Credential::Exporter::Core
  include Metasploit::Credential::Exporter::Base
  include Metasploit::Credential::Creation

  #
  # Constants
  #

  # Valid modes
  ALLOWED_MODES  = [:login, :core]

  # The downcased and Symbolized name of the default object type to export
  DEFAULT_MODE  = :login

  # An argument to {Dir::mktmpdir}
  TEMP_ZIP_PATH_PREFIX = "metasploit-exports"


  #
  # Attributes
  #

  # @!attribute export_data
  #   Holds the raw information from the database before it is formatted into the {#data} attribute
  #   @return [Array]
  attr_accessor :export_data

  # @!attribute finalized_zip_file
  #   The final output artifacts, zipped
  #   @return [Zip::File]
  attr_accessor :finalized_zip_file

  # @!attribute mode
  #   One of `:login` or `:core`
  #   @return [Symbol]
  attr_accessor :mode

  # @!attribute output_directory_path
  #   The platform-independent location of the export file on disk
  #   @return [String]
  attr_accessor :output_directory_path


  #
  # Instance Methods
  #

  def initialize(args)
    @mode = args[:mode].present? ? args.fetch(:mode) : DEFAULT_MODE
    fail "Invalid mode" unless ALLOWED_MODES.include?(mode)
    super args
  end

  # Iterate over the {#export_data} and write lines to the CSV, returning the completed
  # CSV file.
  # @return [CSV]
  def render_csv_and_keys_to_output_directory
    CSV.open(output) do |csv|
      csv << header_line
      export_data.each do |datum|
        line = self.send("line_for_#{mode}", datum)

        # Special-case any SSHKeys in the import
        if line[:private_type] == "SSHKey"
          key_path = path_for_key(line, datum)
          write_key_file(key_path, line[:private_data])
          line[:private_data] = key_path
        end

        csv << line.values
      end
    end
  end


  # Returns a platform-agnostic filesystem path where the key data will be saved as a file
  # @param [Hash] line the result of {#line_for_login} or #{line_for_core}
  # @return [String]
  def key_path(datum)
    core = datum.is_a? Metasploit::Credential::Core ? datum : datum.core
    dir_path = File.join(output_directory_path, Metasploit::Credential::Importer::Zip::KEYS_SUBDIRECTORY_NAME)
    FileUtils.mkdir_p(dir_path)
    File.join(dir_path,"#{core.public.username}-#{core.private.id}")
  end

  # @param [String] path the filesystem path where the +data+ will be written
  # @param [String] data the key data that will be written out at +path+
  # @return [void]
  def write_key_file(path, data)

  end

  # The IO object that contains the exported data
  # @return [IO]
  def output
    @output ||= File.open(File.join(output_directory_path, Metasploit::Credential::Importer::Zip::MANIFEST_FILE_NAME), 'w')
  end

  # The platform-independent location of the export directory on disk, set in `Dir.tmpdir` by default
  # @return [String]
  def output_directory_path
    @output_directory_path ||= Dir.mktmpdir(TEMP_ZIP_PATH_PREFIX)
  end

  # Returns the CSV header line, which is dependent on mode
  # @return [Array<Symbol>]
  def header_line
    case mode
      when :login
        Metasploit::Credential::Importer::Core::VALID_LONG_CSV_HEADERS.push(:host_address, :service_port, :service_name, :service_protocol)
      when :core
        Metasploit::Credential::Importer::Core::VALID_LONG_CSV_HEADERS
    end
  end

  # Take a login and return a [Hash] that will be used for a CSV row.
  # The hashes returned by this method will contain credentials for
  # networked devices which may or may not successfully authenticate to those
  # devices.
  # @param [Metasploit::Credential::Login]
  # @return [Hash]
  def line_for_login(login)
    result = line_for_core(login.core)
    result.merge({
      host_address: login.service.host.address,
      service_port: login.service.port,
      service_name: login.service.name,
      service_protocol: login.service.proto
    })
  end

  # Returns a lookup for cores containing data from the given {Metasploit::Credential::Core} object's
  # component types in order that it can be used as a CSV row.
  # @return [Hash]
  def line_for_core(core)
    {
      username: core.public.username,
      private_type: core.private.type.demodulize,
      private_data: core.private.data,
      realm_key: core.realm.key,
      realm_value: core.realm.value,
    }
  end
end