class Metasploit::Credential::CaseInsensitiveSerializer
    def self.load(value)
        value
    end

    def self.dump(value)
        value.downcase
    end
end
