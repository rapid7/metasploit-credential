# @note Must use nested module as `metasploit/credential/version` is used in `metasploit-credential.gemspec` before
#   `metasploit/credential` itself is expected to be loaded.
module Metasploit
  module Credential
    # Holds components of {VERSION} as defined by {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0}.
    module Version
      #
      # CONSTANTS
      #

      # The major version number.
      MAJOR = 1
      # The minor version number, scoped to the {MAJOR} version number.
      MINOR = 0
      # The patch version number, scoped to the {MAJOR} and {MINOR} version numbers.
      PATCH = 0
      # The prerelease version, scoped to the {MAJOR}, {MINOR}, and {PATCH} version numbers.
      PRERELEASE = '1-0-0-plus'

      #
      # Module Methods
      #

      # The full version string, including the {Metasploit::Credential::Version::MAJOR},
      # {Metasploit::Credential::Version::MINOR}, {Metasploit::Credential::Version::PATCH}, and optionally, the
      # `Metasploit::Credential::Version::PRERELEASE` in the
      # {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0} format.
      #
      # @return [String] '{Metasploit::Credential::Version::MAJOR}.{Metasploit::Credential::Version::MINOR}.{Metasploit::Credential::Version::PATCH}'
      #   on master.
      #   '{Metasploit::Credential::Version::MAJOR}.{Metasploit::Credential::Version::MINOR}.{Metasploit::Credential::Version::PATCH}-PRERELEASE'
      #   on any branch other than master.
      def self.full
        version = "#{MAJOR}.#{MINOR}.#{PATCH}"

        if defined? PRERELEASE
          version = "#{version}-#{PRERELEASE}"
        end

        version
      end

      # The full gem version string, including the {Metasploit::Credential::Version::MAJOR},
      # {Metasploit::Credential::Version::MINOR}, {Metasploit::Credential::Version::PATCH}, and optionally, the
      # `Metasploit::Credential::Version::PRERELEASE` in the
      # {http://guides.rubygems.org/specification-reference/#version RubyGems versioning} format.
      #
      # @return [String] '{Metasploit::Credential::Version::MAJOR}.{Metasploit::Credential::Version::MINOR}.{Metasploit::Credential::Version::PATCH}'
      #   on master.  '{Metasploit::Credential::Version::MAJOR}.{Metasploit::Credential::Version::MINOR}.{Metasploit::Credential::Version::PATCH}.PRERELEASE'
      #   on any branch other than master.
      def self.gem
        full.gsub('-', '.pre.')
      end
    end

    # (see Version.gem)
    GEM_VERSION = Version.gem

    # (see Version.full)
    VERSION = Version.full
  end
end
