environment ENV['RACK_ENV'] || 'development'
port ENV['PORT'] || 3000
puma_threads = ENV['PUMA_THREADS'] || 5
threads puma_threads, puma_threads
workers ENV['PUMA_WORKERS'] || 2

preload_app!

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end