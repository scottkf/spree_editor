module Redactor
  require 'redactor/configuration'
  require 'redactor/engine'

  def self.configuration
    @configuration ||= Configuration.load(::Rails.root.join("config/redactor.yml"))
  end

  def self.configuration=(configuration)
    @configuration = configuration
  end

end