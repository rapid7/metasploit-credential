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

  #
  # Attributes
  #

  # @!attribute export_data
  #   Holds the raw information from the database before it is formatted into the {#data} attribute
  #   @return [Array]
  attr_accessor :export_data

  # @!attribute mode
  #   One of `:login` or `:core`
  #   @return [Symbol]
  attr_accessor :mode

  # @!attribute output_file_path
  #   The platform-independent location of the export file on disk
  #   @return [String]
  attr_accessor :output_file_path

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
  def rendered_csv
    CSV.open(output) do |csv|
      csv << header_line
      export_data.each do |datum|
        line = self.send("line_for_#{mode}", datum)
        csv << line.values
      end
    end
  end

  # The IO object that contains the exported data
  # @return [IO]
  def output
    @output ||= File.open(output_file_path, 'w')
  end

  # The platform-independent location of the export file on disk, set in `Dir.tmpdir` by default
  # @return [String]
  def output_file_path
    @output_file_path ||= File.join(Dir.tmpdir, "creds-#{mode.to_s}-#{Time.now.to_s}")
  end

  # Returns the header line, which is dependent on mode
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