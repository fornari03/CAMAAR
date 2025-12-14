class RespostasController < ApplicationController
  before_action :require_login 
  
  before_action :set_formulario
  before_action :verifica_participacao

  def new
    @questions = @formulario.template.questoes.includes(:opcoes).order(:id)
    @resposta = Resposta.new
  end

  def create
    @resposta = Resposta.find_or_initialize_by(
      formulario: @formulario, 
      participante: current_usuario
    )
    
    saved_successfully = true
    
    ActiveRecord::Base.transaction do
      unless @resposta.save
        saved_successfully = false
        raise ActiveRecord::Rollback
      end

      if params[:respostas].present?
        params[:respostas].each do |questao_id, valor_enviado|
          questao = Questao.find(questao_id)
          
          item = RespostaItem.find_or_initialize_by(resposta: @resposta, questao: questao)
          
          if questao.multipla_escolha?
            opcao_encontrada = questao.opcoes.find_by(texto_opcao: valor_enviado)
            
            if opcao_encontrada
              item.opcao_escolhida = opcao_encontrada
            else
              item.errors.add(:base, "Opção inválida selecionada.")
            end
          else
            item.texto_resposta = valor_enviado
            item.opcao_escolhida = nil
          end
          
          unless item.save
             @resposta.errors.add(:base, "Questão '#{questao.enunciado}': #{item.errors.full_messages.join(', ')}")
             saved_successfully = false
             raise ActiveRecord::Rollback
          end
        end
      end
      
      @resposta.update!(data_submissao: Time.current)
    end

    if saved_successfully
      redirect_to root_path, notice: "Avaliação enviada com sucesso. Obrigado!"
    else
      @questions = @formulario.template.questoes.includes(:opcoes).order(:id)
      flash.now[:alert] = "Houve um erro ao enviar suas respostas. Verifique os campos abaixo."
      render :new, status: :unprocessable_content  
    end
  end

  private

  def set_formulario
    @formulario = Formulario.find(params[:formulario_id])
  end

  def verifica_participacao
    unless current_usuario && current_usuario.discente?
      redirect_to root_path, alert: "Acesso negado."
      return
    end
    
    if @formulario.data_encerramento.present? && @formulario.data_encerramento < Time.current
      redirect_to root_path, alert: "Este formulário não está mais aceitando respostas."
      return
    end

    resposta_existente = Resposta.find_by(formulario: @formulario, participante: current_usuario)
    if resposta_existente&.data_submissao.present?
       redirect_to root_path, alert: "Você já respondeu este formulário."
    end
  end
end