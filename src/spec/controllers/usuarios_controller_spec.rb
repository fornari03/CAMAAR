require 'rails_helper'

RSpec.describe UsuariosController, type: :controller do
  let(:valid_attributes) do
    {
      nome: 'Usuario Teste',
      email: 'usuario@email.com',
      matricula: '12345',
      usuario: 'user_teste',
      password: 'senha123',
      ocupacao: 'discente',
      status: true
    }
  end

  let(:invalid_attributes) do
    {
      nome: nil,
      email: nil,
      matricula: nil,
      usuario: nil,
      password: nil,
      ocupacao: nil,
      status: true
    }
  end

  before(:each) do
    allow_any_instance_of(described_class).to receive(:authenticate_admin).and_return(true)
    Usuario.delete_all 
  end

  describe "GET #index" do
    it "retorna uma lista vazia quando não há usuários" do
      get :index
      expect(assigns(:usuarios)).to be_empty
      expect(response).to be_successful
    end

    it "mostra todos usuarios" do
      usuario = Usuario.create!(valid_attributes)
      get :index
      expect(assigns(:usuarios)).to include(usuario)
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "retorna sucesso e atribui o usuário correto" do
      usuario = Usuario.create!(valid_attributes)
      get :show, params: { id: usuario.id }
      expect(assigns(:usuario)).to eq(usuario)
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "atribui um novo usuário a @usuario" do
      get :new
      expect(assigns(:usuario)).to be_a_new(Usuario)
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "atribui o usuário requisitado a @usuario" do
      usuario = Usuario.create!(valid_attributes)
      get :edit, params: { id: usuario.id }
      expect(assigns(:usuario)).to eq(usuario)
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "com parâmetros válidos" do
      it "cria um novo Usuario" do
        expect {
          post :create, params: { usuario: valid_attributes }
        }.to change(Usuario, :count).by(1)
      end

      it "redireciona para o usuário criado (ou index)" do
        post :create, params: { usuario: valid_attributes }
        expect(response).to redirect_to(Usuario.last) 
      end
    end

    context "com parâmetros inválidos" do
      it "não cria um novo usuário e renderiza o template new" do
        expect {
          post :create, params: { usuario: invalid_attributes }
        }.not_to change(Usuario, :count)
        
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH #update" do
    let(:usuario) { Usuario.create!(valid_attributes) }
    
    context "com parâmetros válidos" do
      let(:new_attributes) { { nome: 'Nome Atualizado' } }

      it "atualiza o usuário solicitado" do
        patch :update, params: { id: usuario.id, usuario: new_attributes }
        usuario.reload
        expect(usuario.nome).to eq('Nome Atualizado')
      end

      it "redireciona para o usuário" do
        patch :update, params: { id: usuario.id, usuario: new_attributes }
        expect(response).to redirect_to(usuario)
      end
    end

    context "com parâmetros inválidos" do
      it "não atualiza o usuário e renderiza edit" do
        patch :update, params: { id: usuario.id, usuario: invalid_attributes }
        usuario.reload
        expect(usuario.nome).to eq(valid_attributes[:nome])
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destrói o usuário solicitado" do
      usuario = Usuario.create!(valid_attributes)
      expect {
        delete :destroy, params: { id: usuario.id }
      }.to change(Usuario, :count).by(-1)
    end

    it "redireciona para a lista de usuários" do
      usuario = Usuario.create!(valid_attributes)
      delete :destroy, params: { id: usuario.id }
      expect(response).to redirect_to(usuarios_url)
    end
  end
end