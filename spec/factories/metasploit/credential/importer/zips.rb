#
# Gems
#

require 'zip/zip'

FactoryGirl.define do
  factory :metasploit_credential_importer_zip,
          class: Metasploit::Credential::Importer::Zip do
    data { generate :metasploit_credential_importer_zip_file }
    origin {FactoryGirl.build :metasploit_credential_origin_import }
  end



  # NB: There is not a very easy and time-effective way to DRY the below code.  These sequences define
  # zip files which represent valid and error-condition cases.

  #
  # Create a zip with keys and manifest,
  #
  sequence :metasploit_credential_importer_zip_file do |n|
    path = "/tmp/#{Metasploit::Credential::Importer::Zip::TEMP_UNZIP_PATH_PREFIX}-#{Time.now.to_i}-#{n}"
    keys_path = "#{path}/#{Metasploit::Credential::Importer::Zip::KEYS_SUBDIRECTORY_NAME}"
    FileUtils.mkdir_p(keys_path)

    # Create keys
    key_data = 5.times.collect do
      FactoryGirl.build(:metasploit_credential_ssh_key).data
    end

    # associate keys with usernames
    csv_hash = key_data.inject({}) do |hash, data|
      username = FactoryGirl.generate(:metasploit_credential_public_username)
      hash[username] = data
      hash
    end

    # write out each key into a file in the intended zip directory
    csv_hash.each do |name, ssh_key_data|
      File.open("#{keys_path}/#{name}", 'w') do |file|
        file << ssh_key_data
      end
    end

    # write out manifest CSV into the zip directory
    # 'key' used twice because we are using usernames for filenames
    CSV.open("#{path}/#{Metasploit::Credential::Importer::Zip::MANIFEST_FILE_NAME}", 'wb') do |csv|
      csv << Metasploit::Credential::Importer::CSV::Core::VALID_CSV_HEADERS
      csv_hash.keys.each do |key|
        csv << [key, Metasploit::Credential::SSHKey.name, key, Metasploit::Credential::Realm::Key::ACTIVE_DIRECTORY_DOMAIN, 'Rebels']
      end
    end

    # Write out zip file
    zip_location = "#{path}.zip"
    ::Zip::ZipFile.open(zip_location, ::Zip::ZipFile::CREATE) do |zipfile|
      Dir.entries(path).each do |entry|
        next if entry.first == '.'
        zipfile.add(entry, path + '/' + entry)
      end
    end

    File.open(zip_location, 'rb')
  end


  #
  # Create a zip without keys and WITH a manifest
  #
  sequence :metasploit_credential_importer_zip_file_invalid_no_keys do |n|
    path = "/tmp/#{Metasploit::Credential::Importer::Zip::TEMP_UNZIP_PATH_PREFIX}-#{Time.now.to_i}-#{n}"
    FileUtils.mkdir_p(path)

    # Create keys
    key_data = 5.times.collect do
      FactoryGirl.build(:metasploit_credential_ssh_key).data
    end

    # associate keys with usernames
    csv_hash = key_data.inject({}) do |hash, data|
      username = FactoryGirl.generate(:metasploit_credential_public_username)
      hash[username] = data
      hash
    end

    # write out manifest CSV into the zip directory
    # 'key' used twice because we are using usernames for filenames
    CSV.open("#{path}/#{Metasploit::Credential::Importer::Zip::MANIFEST_FILE_NAME}", 'wb') do |csv|
      csv << Metasploit::Credential::Importer::CSV::Core::VALID_CSV_HEADERS
      csv_hash.keys.each do |key|
        csv << [key, Metasploit::Credential::SSHKey.name, key, Metasploit::Credential::Realm::Key::ACTIVE_DIRECTORY_DOMAIN, 'Rebels']
      end
    end

    # Write out zip file
    zip_location = "#{path}.zip"
    ::Zip::ZipFile.open(zip_location, ::Zip::ZipFile::CREATE) do |zipfile|
      Dir.entries(path).each do |entry|
        next if entry.first == '.'
        zipfile.add(entry, path + '/' + entry)
      end
    end

    File.open(zip_location, 'rb')
  end


  #
  # Create a zip with keys and WITHOUT a manifest,
  #
  sequence :metasploit_credential_importer_zip_file_without_manifest do |n|
    path = "/tmp/#{Metasploit::Credential::Importer::Zip::TEMP_UNZIP_PATH_PREFIX}-#{Time.now.to_i}-#{n}"
    keys_path = "#{path}/#{Metasploit::Credential::Importer::Zip::KEYS_SUBDIRECTORY_NAME}"
    FileUtils.mkdir_p(keys_path)

    # Create keys
    key_data = 5.times.collect do
      FactoryGirl.build(:metasploit_credential_ssh_key).data
    end

    # associate keys with usernames
    csv_hash = key_data.inject({}) do |hash, data|
      username = FactoryGirl.generate(:metasploit_credential_public_username)
      hash[username] = data
      hash
    end

    # write out each key into a file in the intended zip directory
    csv_hash.each do |name, ssh_key_data|
      File.open("#{keys_path}/#{name}", 'w') do |file|
        file << ssh_key_data
      end
    end

    # Write out zip file
    zip_location = "#{path}.zip"
    ::Zip::ZipFile.open(zip_location, Zip::ZipFile::CREATE) do |zipfile|
      Dir.entries(path).each do |entry|
        next if entry.first == '.'
        zipfile.add(entry, path + '/' + entry)
      end
    end

    File.open(zip_location, 'rb')
  end
end

