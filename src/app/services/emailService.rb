# app/services/email_service.rb

class EmailService
  def self.send_password_reset_email(usuario)
    raise ArgumentError, "Usuário não pode ser nulo" if usuario.nil?

    begin
      if Rails.env.development? || Rails.env.test?
        Rails.logger.info "[FAKE EMAIL] Redefinição de senha para #{usuario.email}"
        Rails.logger.info "[FAKE EMAIL] Link: http://localhost:3000/definir_senha?email=#{usuario.email}"
        return { success: true, fake: true }
      end

      UserMailer.with(user: usuario).definicao_senha.deliver_now

      { success: true }
    rescue => e
      Rails.logger.error "[EmailService] Falha ao enviar email de redefinição para #{usuario.email}: #{e.class} - #{e.message}"
      { success: false, error: e.message }
    end
  end
end
