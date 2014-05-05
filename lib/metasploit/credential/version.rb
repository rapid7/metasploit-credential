module Metasploit
  module Credential
    # Holds components of {VERSION} as defined by {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0}.
    module Version
      # The major version number.
      MAJOR = 0
      # The minor version number, scoped to the {MAJOR} version number.
      MINOR = 1
      # The patch number, scoped to the {MINOR} version number.
      PATCH = 1
      # The prerelease name of the given {MAJOR}.{MINOR}.{PATCH} version number. Will not be defined on master.
      PRERELEASE = 'MSP-9896-metasploit-concern-run'

      # The full version string, including the {MAJOR}, {MINOR}, {PATCH}, and optionally, the {PRERELEASE} in the
      # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
      #
      # @return [String] '{MAJOR}.{MINOR}.{PATCH}' on master.  '{MAJOR}.{MINOR}.{PATCH}-{PRERELEASE}' on any branch
      #   other than master.
      def self.full
        version = "#{MAJOR}.#{MINOR}.#{PATCH}"

        if defined? PRERELEASE
          version = "#{version}-#{PRERELEASE}"
        end

        version
      end
    end

    # @see Version.full
    VERSION = Version.full
  end
end
