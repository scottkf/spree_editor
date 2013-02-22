module Redactor
  class Engine < ::Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    initializer "precompile", :group => :all do |app|
      app.config.assets.precompile << "redactor.js"
    end


    def self.base
      File.join(Rails.application.config.relative_url_root || "", Rails.application.config.assets.prefix || "/", "redactor")
    end

  end
end