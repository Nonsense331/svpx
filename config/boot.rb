# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require 'rails/commands/server'

module Rails
  class Server
    alias :custom_default_options :default_options
    def default_options
      custom_default_options.merge!(Host: '0.0.0.0')
    end
  end
end
