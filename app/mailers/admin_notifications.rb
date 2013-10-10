class AdminNotifications < ActionMailer::Base
  include Resque::Mailer
  default :from => "do_not_reply@mynew.tv"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.admin_notifications.problem.subject
  #
  def problem(subject, text)
    @text = text
    mail :to => "tute@mynew.tv", :subject => "MyNewTv problem: #{subject}"
  end
end

