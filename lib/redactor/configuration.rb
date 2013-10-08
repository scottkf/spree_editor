require "active_support/hash_with_indifferent_access"

module Redactor
  class Configuration
    class Function < String
      def encode_json(encoder)
        self
      end
    end
    
    def self.defaults
      {
        "folder" => 'uploads',
        "redirect" => "https://#{Spree::Config.get_preference(:site_url)}/admin/s3",
        "uploadFields"=> {
          'key'=> '#key',
          'AWSAccessKeyId'=> '#AWSAccessKeyId',
          'acl'=> '#acl',
          # 'success_action_status'=> '#success_action_status',
          'success_action_redirect'=> '#success_action_redirect',
          'policy'=> '#policy',
          'signature'=> '#signature',
          'Content-Type'=> '#Content-Type'
        }
      }
    end
    
    attr_reader :options
    
    def initialize(options)
      @options = options
    end
    
    def self.new_with_defaults(options={})
      config = new(defaults)
      config = config.merge(options) if options
      config
    end

    def s3_upload_policy_document
      Base64.encode64(
        {
          expiration: 30.minutes.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
          conditions: [
            { bucket: Spree::Config.get_preference(:s3_bucket) },
            ["starts-with", "$key", options["folder"]],
            ["starts-with", "$Content-Type", ''],
            { acl: 'public-read' },
            { success_action_redirect: options["redirect"]}
            # { success_action_status: '201' }
          ]
        }.to_json
      ).gsub(/\n|\r/, '')
    end

    def s3_upload_signature
      Base64.encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest::Digest.new('sha1'),
          Spree::Config.get_preference(:s3_secret),
          s3_upload_policy_document
        )
      ).gsub(/\n/, '')
    end
    
    def merge(options)
      self.class.new(self.options.merge(options))
    end
    
    def self.load(filename)
      return new_with_defaults if !File.exists?(filename)
      
      options = load_yaml(filename)
      options["imageUpload"] = "https://#{Spree::Config.get_preference(:s3_bucket)}.s3.amazonaws.com" if options.has_key?("imageUpload")
      if options.has_key?('default')
        MultipleConfiguration.new(options)
      else
        new_with_defaults(options)
      end
    end
    
    def self.load_yaml(filename)
      YAML::load(ERB.new(IO.read(filename)).result) rescue {}
    end
  end
  
  class MultipleConfiguration < ActiveSupport::HashWithIndifferentAccess
    def initialize(configurations={})
      configurations = configurations.each_with_object({}) { |(name, options), h|
        h[name] = Configuration.new_with_defaults(options)
      }
      
      super(configurations)
    end
  end
end
