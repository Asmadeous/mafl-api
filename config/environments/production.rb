require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot to improve performance.
  config.eager_load = true

  # Do not show full error reports.
  config.consider_all_requests_local = false

  # Enable caching with memory store.
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store

  # Require master key for encrypted credentials.
  config.require_master_key = true

  # Disable public file server (API apps typically don't serve static assets).
  config.public_file_server.enabled = false

  # Active Storage configuration (adjust if using a different storage like Amazon S3).
  config.active_storage.service = :local

  # Use a real queuing backend for Active Job (adjust as needed).
  # config.active_job.queue_adapter = :sidekiq

  # Mailer configuration using Resend
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :resend
  config.action_mailer.resend_settings = {
    api_key: Rails.application.credentials.resend_api_key
  }
  config.action_mailer.default_url_options = {
    host: "mafl-api-production.up.railway.app",
    protocol: "https"
  }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.hosts << "mafl-api-production.up.railway.app:8080"
  # Action Cable config
  config.action_cable.mount_path = "/cable"
  config.action_cable.url = "wss://mafl-api-production.up.railway.app/cable"
  config.action_cable.allowed_request_origins = [ "https://mafl-api-production.up.railway.app" ]

  # Force SSL for all access.
  config.force_ssl = true

  # Use default logging formatter and tagged logging.
  config.log_level = :info
  config.log_tags = [ :request_id ]
  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump the schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Default host for route helpers
  Rails.application.routes.default_url_options[:host] = "mafl-api-production.up.railway.app"
end
