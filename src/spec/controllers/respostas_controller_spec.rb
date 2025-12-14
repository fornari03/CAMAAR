require 'rails_helper'

RSpec.describe RespostasController, type: :controller do
  # Configuração dos dados de teste
  let(:aluno) { Usuario.create!(nome: 'Aluno', email: 'aluno@test.com', usuario: 'aluno', password: 'p', ocupacao: :discente, status: true, matricula: '1234') }
  let(:docente) { Usuario.create!(nome: 'Doc', email: 'doc@test.com', usuario: 'doc', password: 'p', ocupacao: :docente, status: true, matricula: '5678') }
  
  let(:materia) { Materia.create!(nome: 'Mat', codigo: 'M1') }
  let(:turma) { Turma.create!(codigo: 'T1', semestre: '2025.1', horario: '10h', materia: materia, docente: docente) }
  let(:template) { Template.create!(titulo: 'T', participantes: 'alunos', criador: docente, name: 'Template Teste') }
  let(:formulario) { Formulario.create!(titulo_envio: 'F1', data_criacao: Time.now, template: template, turma: turma) }
  
  # Questões
  let!(:questao_texto) { Questao.create!(enunciado: 'Q Texto', tipo: 0, template: template) }
  let!(:questao_multipla) { Questao.create!(enunciado: 'Q Multipla', tipo: 1, template: template) }
  let!(:opcao_valida) { Opcao.create!(texto_opcao: 'Opcao A', questao: questao_multipla) }

  before do
    session[:usuario_id] = aluno.id
  end

  describe "Restrições de Acesso (before_actions)" do
    it "redireciona se o usuário não for discente" do
      session[:usuario_id] = docente.id
      get :new, params: { formulario_id: formulario.id }
      
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Acesso negado.")
    end

    it "redireciona se o prazo do formulário expirou" do
      formulario.update!(data_encerramento: 1.day.ago)
      get :new, params: { formulario_id: formulario.id }
      
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Este formulário não está mais aceitando respostas.")
    end

    it "redireciona se o aluno já respondeu" do
      Resposta.create!(formulario: formulario, participante: aluno, data_submissao: Time.current)
      
      get :new, params: { formulario_id: formulario.id }
      
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Você já respondeu este formulário.")
    end
  end

  describe "GET #new" do
    it "retorna sucesso para aluno elegível" do
      get :new, params: { formulario_id: formulario.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:questions)).to include(questao_texto)
    end
  end

  describe "POST #create" do
    
    context "Caminho Feliz" do
      it "cria resposta com texto simples" do
        expect {
          post :create, params: { 
            formulario_id: formulario.id, 
            respostas: { questao_texto.id => "Minha resposta" } 
          }
        }.to change(Resposta, :count).by(1)
        
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Avaliação enviada com sucesso. Obrigado!")
      end

      it "cria resposta com múltipla escolha válida" do
        post :create, params: { 
          formulario_id: formulario.id, 
          respostas: { questao_multipla.id => "Opcao A" } 
        }
        
        resposta = Resposta.last
        item = resposta.resposta_items.find_by(questao: questao_multipla)
        expect(item.opcao_escolhida).to eq(opcao_valida)
      end
    end

    context "Caminhos de Erro (Cobre as imagens image_c081db.png)" do
      
      it "faz rollback e renderiza new se falhar ao salvar o cabeçalho da Resposta" do
        allow_any_instance_of(Resposta).to receive(:save).and_return(false)

        expect {
          post :create, params: { 
            formulario_id: formulario.id, 
            respostas: { questao_texto.id => "Teste" } 
          }
        }.not_to change(Resposta, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:new)
        expect(flash[:alert]).to include("Houve um erro")
      end

      it "gera erro ao enviar opção inválida para questão de múltipla escolha" do
        expect {
          post :create, params: { 
            formulario_id: formulario.id, 
            respostas: { questao_multipla.id => "Opcao Hackeada Inexistente" } 
          }
        }.not_to change(Resposta, :count)

        expect(flash[:alert]).to include("Houve um erro")
      end

      it "faz rollback se um item individual falhar ao salvar" do
        allow_any_instance_of(RespostaItem).to receive(:save).and_return(false)

        expect {
          post :create, params: { 
            formulario_id: formulario.id, 
            respostas: { questao_texto.id => "Texto Válido" } 
          }
        }.not_to change(Resposta, :count)

        expect(response).to render_template(:new)
        expect(flash[:alert]).to include("Houve um erro")
      end
    end
  end
end