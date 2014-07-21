# Operator for searching for the completeness of {Metasploit::Credential::Core Metasploit::Credential::Cores}.
#
# | Completeness       | Private | Public  | Realm      |
# | ------------------ | ------- | ------- | ---------- |
# | Complete           | Present | Present | Dont' Care |
# | Incomplete Private | Present | Absent  | Don't Care |
# | Incomplete Public  | Absent  | Present | Don't Care |
#
class Metasploit::Credential::Search::Operator::Completeness < Metasploit::Model::Search::Operator::Single
  # The name of this operator.
  #
  # @return [Symbol] `:completeness`
  def name
    @name ||= :completeness
  end

  # The `Class#name` of the `Metasploit::Model::Search::Operator::Single#operation_class`.
  #
  # @return [String] `'Metasploit::Credential::Search::Operation::Completeness'`
  def operation_class_name
    @operation_class_name ||= 'Metasploit::Credential::Search::Operation::Completeness'
  end
end