#! /usr/local/bin/ruby

Customer = Struct.new(:key, :bucket, :access_key, :secret_key)

class Backups
  require 'fileutils'
  require 'aws-sdk-s3'

  CUSTOMERS = %w[tomc roofer ultramix].freeze

  class NoAWSKeysError < StandardError; end

  attr_reader :customer

  class << self
    def customers
      CUSTOMERS.map { |key| Customer.new(key) }
    end
  end

  def initialize(customer)
    @customer = customer
    puts "Initializing backup for #{customer.key.upcase}"
    configure_customer
    validate_aws_keys
    configure_aws
    puts "Looking in bucket #{customer.bucket}"
  end

  def download_latest
    ensure_backup_folder
    puts "Downloading latest file #{latest_backup_file.key}"
    begin
      s3_client.get_object(bucket: customer.bucket, key: latest_backup_file.key, response_target: backup_path)
      puts 'Success'
    rescue StandardError
      puts 'Error downloading file'
    end
  end

  private

  def ensure_backup_folder
    puts 'Ensuring folder exists'
    FileUtils.mkdir_p backup_folder
  end

  def backup_folder
    "backup_files/#{customer.key}/"
  end

  def backup_path
    "#{backup_folder}/#{latest_backup_file.key}"
  end

  def latest_backup_file
    @latest_backup_file ||= list_bucket.max_by(&:last_modified)
  end

  def list_bucket
    files = nil
    s3_client.list_objects(bucket: customer.bucket).each do |response|
      files = response.contents
    end
    files
  end

  def configure_aws
    Aws.config.update(
      access_key_id: customer.access_key,
      secret_access_key: customer.secret_key,
      force_path_style: true,
      region: 'us-east-1'
    )
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new
  end

  def configure_customer
    %w[bucket access_key secret_key].each do |fld|
      customer.send("#{fld}=", ENV["#{customer.key.upcase}_AWS_#{fld.upcase}"])
    end
  end

  def validate_aws_keys
    return if customer.access_key && customer.secret_key

    puts "Error with #{customer.key}"
    raise NoAWSKeysError
  end
end

Backups.customers.each do |customer|
  backups = Backups.new(customer)
  backups.download_latest
end
