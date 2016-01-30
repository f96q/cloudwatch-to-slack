# /usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'
require 'erb'
require 'zip'

def kms_policy(arn)
  ERB.new(File.read('./kms_policy.json.erb')).result(binding)
end

def create_role(role_name, arn)
  client = Aws::IAM::Client.new
  response = client.create_role({
    role_name: role_name,
    assume_role_policy_document: File.read('./lambda_policy.json'),
  })
  client.attach_role_policy({
    role_name: role_name,
    policy_arn: 'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole',
  })
  client.put_role_policy({
    role_name: role_name,
    policy_name: 'kms',
    policy_document: kms_policy(arn),
  })
  response
end

def create_function(function_name, role, zip_file)
  client = Aws::Lambda::Client.new
  options = {
    function_name: function_name,
    runtime: 'nodejs',
    role: role,
    handler: 'index.handler',
    code: {
      zip_file: zip_file
    },
    timeout: 3,
    memory_size: 128,
    publish: true,
  }
  client.create_function(options)
end

def create_zip_file(kms_encypted_hook_url, slack_channel)
  source = ERB.new(File.read('./index.js.erb')).result(binding)
  Zip::OutputStream.write_buffer do |f|
    f.put_next_entry('index.js')
    f.write(source)
  end.string
end

def create_kms_key(alias_name)
  client = Aws::KMS::Client.new
  response = client.create_key
  client.create_alias({
    alias_name: "alias/#{alias_name}",
    target_key_id: response.key_metadata.key_id
  })
  response
end

def kms_encrypt(key_id, plaintext)
  ciphertext_blob = Aws::KMS::Client.new.encrypt(key_id: key_id, plaintext: plaintext).ciphertext_blob
  Base64::strict_encode64(ciphertext_blob)
end

def main(name, web_hook_url, slack_channel)
  kms = create_kms_key(name)

  iam = create_role(name, kms.key_metadata.arn)
  kms_encypted_hook_url = kms_encrypt(kms.key_metadata.key_id, web_hook_url)

  zip_file = create_zip_file(kms_encypted_hook_url, slack_channel)

  sleep(25)

  create_function(name, iam.role.arn, zip_file)
end

Aws.config[:region] = 'ap-northeast-1'

main(ARGV[0], ARGV[1], ARGV[2])
