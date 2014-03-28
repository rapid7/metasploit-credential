module Metasploit
  module Credential
    module Version
      MAJOR = 0
      MINOR = 0
      PATCH = 1
      PRERELEASE = 'gem-skeleton'

      def self.full
        version = "#{MAJOR}.#{MINOR}.#{PATCH}"

        if defined? PRERELEASE
          version = "#{version}-#{PRERELEASE}"
        end

        version
      end
    end

    VERSION = Version.full
  end
end
