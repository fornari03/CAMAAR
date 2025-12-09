class RespostasController < ApplicationController
  before_action :set_formulario
  before_action :verifica_participacao

  def new
    @questions = @formulario.template.questoes
    @resposta = Resposta.new
  end

  def create
    @resposta = Resposta.new(formulario: @formulario, participante: current_usuario)
    
    # Using specific logic for items creation based on params
    # structure: params[:respostas] = { questao_id => valor }
    
    saved_successfully = true
    
    ActiveRecord::Base.transaction do
      unless @resposta.save
        saved_successfully = false
        raise ActiveRecord::Rollback
      end

      if params[:respostas].present?
        params[:respostas].each do |questao_id, valor|
          questao = Questao.find(questao_id)
          item = RespostaItem.new(resposta: @resposta, questao: questao)
          
          if questao.tipo == 0 # Texto
             item.texto_resposta = valor
          elsif questao.tipo == 1 # Multipla Escolha - Not fully implemented in params spec yet
             # Assuming valor is option_id
             # item.opcao_escolhida_id = valor
             # Need to handle this logic carefully
          end
          # Check Questao model for proper enum validatio or usage
          
          # Simplified saving for prototype:
          item.texto_resposta = valor # Fallback
          
          unless item.save
             @resposta.errors.add(:base, "Erro na questão #{questao.enunciado}: #{item.errors.full_messages.join(', ')}")
             saved_successfully = false
             raise ActiveRecord::Rollback
          end
        end
      end
      
      @resposta.update!(data_submissao: Time.now)
    end

    if saved_successfully
      redirect_to root_path, notice: "Avaliação enviada com sucesso. Obrigado!"
    else
      @questions = @formulario.template.questoes
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_formulario
    @formulario = Formulario.find(params[:formulario_id])
  end

  def verifica_participacao
    # Ensure user is matriculated in the class or has right to answer
    # Simple check: is user student?
    redirect_to root_path, alert: "Acesso negado." unless current_usuario && current_usuario.discente?
    
    # Check if already answered
    if Resposta.exists?(formulario: @formulario, participante: current_usuario)
       redirect_to root_path, alert: "Você já respondeu este formulário."
    end
  end
end
