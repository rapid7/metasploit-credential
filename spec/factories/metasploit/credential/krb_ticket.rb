require 'digest/sha1'

FactoryBot.define do
  factory :metasploit_credential_krb_ticket,
          class: Metasploit::Credential::KrbTicket,
          parent: :metasploit_credential_private do

    type { 'Metasploit::Credential::KrbTicket' }

    trait :with_tgt do
      data do
        {
          type: :tgt,
          value: 'opaque_tgt_ticket_blob',
          sname: "krbtgt/#{generate(:metasploit_credential_active_directory_domain_value)}",
          authtime: nil,
          starttime: Time.now.utc,
          endtime: Time.now.utc + 1.days
        }
      end
    end

    trait :with_expired_tgt do
      data do
        {
          type: :tgt,
          value: 'opaque_tgt_ticket_blob',
          sname: "krbtgt/#{generate(:metasploit_credential_active_directory_domain_value)}",
          authtime: nil,
          starttime: Time.now.utc - 2.days,
          endtime: Time.now.utc - 1.days
        }
      end
    end

    trait :with_tgs do
      data do
        {
          type: :tgs,
          value: 'opaque_tgs_ticket_blob',
          sname: generate(:metasploit_credential_krb_ticket_service_name),
          authtime: nil,
          starttime: Time.now.utc,
          endtime: Time.now.utc + 1.days
        }
      end
    end

    trait :with_expired_tgs do
      data do
        {
          type: :tgs,
          value: 'opaque_tgs_ticket_blob',
          sname: generate(:metasploit_credential_krb_ticket_service_name),
          authtime: nil,
          starttime: Time.now.utc - 2.days,
          endtime: Time.now.utc - 1.days
        }
      end
    end
  end

  sequence :metasploit_credential_krb_ticket_service_class, %w[HTTP CIFS LDAP MSSqlSvc].cycle
  sequence :metasploit_credential_krb_ticket_service_name do |n|
    "#{FactoryBot.generate(:metasploit_credential_krb_ticket_service_class)}/host#{n}.domain#{n}.local"
  end
end
