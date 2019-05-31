# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'
require 'json'
require 'faraday'
require 'faraday_middleware'

require 'help_scout/version'

require 'help_scout/base'
require 'help_scout/modules/getable'

require 'help_scout/api'
require 'help_scout/api/access_token'
require 'help_scout/api/client'
require 'help_scout/attachment'
require 'help_scout/configuration'
require 'help_scout/conversation'
require 'help_scout/customer'
require 'help_scout/folder'
require 'help_scout/mailbox'
require 'help_scout/mailbox_ref'
require 'help_scout/person'
require 'help_scout/response'
require 'help_scout/source'
require 'help_scout/thread'
require 'help_scout/user'
require 'help_scout/util'

module HelpScout
  class << self
    attr_writer :configuration
  end

  def self.access_token
    api.access_token
  end

  def self.api
    @api ||= HelpScout::API.new
  end

  def self.api_key
    configuration.api_key
  end

  def self.app_id
    configuration.app_id
  end

  def self.app_secret
    configuration.app_secret
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
    api.access_token = HelpScout.configuration.access_token
  end

  def self.default_mailbox
    configuration.default_mailbox
  end
end
