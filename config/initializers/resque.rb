require 'logger'

$logger = Logger.new('log/resque.log', 'monthly')
$logger.datetime_format = "%Y-%m-%d %H:%M:%S"

if ENV['RAILS_ENV'] == 'production'
  Resque.redis = Redis.new(:db => 1)
end

require "mail"
require "resque"
require "resque/failure/multiple"
require "resque/failure/redis"

# # Configure Resque connection from config/redis.yml.  This file should look
# # something like:
# #   development: localhost:6379
# #   test: localhost:6379:15
# #   production: localhost:6379
# Resque.redis = YAML.load_file(Rails.root + 'config/redis.yml')[Rails.env]

Mail.defaults do
  delivery_method :smtp, { :address              => ActionMailer::Base.smtp_settings[:address],
    :port                 => ActionMailer::Base.smtp_settings[:port],
    :domain               => ActionMailer::Base.smtp_settings[:domain],
    :user_name            => ActionMailer::Base.smtp_settings[:user_name],
    :password             => ActionMailer::Base.smtp_settings[:password],
    :authentication       => ActionMailer::Base.smtp_settings[:authentication],
  :enable_starttls_auto => true  }
end


module Resque
  module Failure
    # Logs failure messages.
    class Logger < Base
      def save
        #Rails.logger.error exception
        $logger.info "#{Time.now} #{detailed}"
      end

      

      def detailed
        <<-EOF
        #{worker} failed processing #{queue}:
        Payload:
        #{payload.inspect.split("\n").map { |l| "  " + l }.join("\n")}
        Exception:
        #{exception}
        
        EOF
      end
    end
# #{exception.backtrace.map { |l| "  " + l }.join("\n")} unless exception.backtrace.nil?


    # Emails failure messages.
    # Note: uses Mail (default in Rails 3.0) not TMail (Rails 2.x).
    class Notifier < Logger
      def save
        text, subject = "[Error] #{queue}: #{exception}, \n Payload: #{payload}, \n Worker: #{worker}", "Resque Error: #{queue}"
        #$logger.info "#{Time.now} #{backtrace(exception)}"
        Mail.deliver do
          from "resque@mynew.tv"
          to "tute@mynew.tv"
          subject subject
          text_part do
            body text
          end
        end
      rescue
        puts $!
      end
    end
  end
end


Resque::Failure::Multiple.configure do |multi|
  # Always stores failure in Redis and writes to log
  multi.classes = Resque::Failure::Redis, Resque::Failure::Logger
  # Production/staging only: also email us a notification
  multi.classes << Resque::Failure::Notifier if Rails.env.production? || Rails.env.staging?
end

