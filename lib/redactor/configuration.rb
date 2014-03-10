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
        # s3: '/admin/s3encrypt'
        imageUpload: '/admin/redactor_upload'
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

    def merge(options)
      self.class.new(self.options.merge(options))
    end
    
    def self.load(filename)
      return new_with_defaults if !File.exists?(filename)
      
      options = load_yaml(filename)
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
