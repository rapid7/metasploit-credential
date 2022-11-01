require 'digest/sha1'

FactoryBot.define do
  factory :metasploit_credential_krb_ticket,
          class: Metasploit::Credential::KrbTicket,
          parent: :metasploit_credential_private do

    trait :with_tgt do
      data do
        {
          type: :tgt,
          value: 'opaque_tgt_ticket_blob',
          endtime: Time.now.utc + 1.days
        }
      end
    end

    trait :with_tgs do
      data do
        {
          type: :tgs,
          value: 'opaque_tgs_ticket_blob',
          endtime: Time.now.utc + 1.days
        }
      end
    end
  end
end
