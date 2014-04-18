FactoryGirl.define do
  factory :metasploit_credential_login,
          class: Metasploit::Credential::Login do
    ignore do
      host {
        FactoryGirl.build(
          :mdm_host, workspace: workspace
        )
      }
      workspace { core.workspace }
    end

    access_level { generate :metasploit_credential_login_access_level }

    association :core, factory: :metasploit_credential_core

    last_attempted_at { DateTime.now.utc }
    service {
      FactoryGirl.build(
          :mdm_service,
          host: host
      )
    }

    status { generate :metasploit_credential_login_status }
  end

  sequence :metasploit_credential_login_access_level do |n|
    "metasploit_credential_login_access_level#{n}"
  end

  sequence :metasploit_credential_login_status, Metasploit::Credential::Login::Status::ALL.cycle
end
