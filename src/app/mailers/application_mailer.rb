# Classe base para Mailers, configurando defaults e layout.
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
end
