# Operation for searching for the completeness of {Metasploit::Credential::Core Metasploit::Credential::Cores}.
#
# | Completeness       | Private | Public  | Realm      |
# | ------------------ | ------- | ------- | ---------- |
# | Complete           | Present | Present | Dont' Care |
# | Incomplete Private | Present | Absent  | Don't Care |
# | Incomplete Public  | Absent  | Present | Don't Care |
#
class Metasploit::Credential::Search::Operation::Completeness < Metasploit::Credential::Search::Operation::Set::String

end