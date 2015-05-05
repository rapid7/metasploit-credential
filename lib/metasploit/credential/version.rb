# @note Must use nested module as `metasploit/credential/version` is used in `metasploit-credential.gemspec` before
#   `metasploit/credential` itself is expected to be loaded.
module Metasploit
  module Credential
    # Holds components of {VERSION} as defined by {http://semver.org/spec/v2.0.0.html semantic versioning v2.0.0}.
    module Version
      # The major version number.
      MAJOR = 1
      # The minor version number, scoped to the {MAJOR} version number.
      MINOR = 0
      # The patch number, scoped to the {MINOR} version number.
      PATCH = 0
      # the prerelease identifier
      PRERELEASE = 'rails-4.0c'

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
