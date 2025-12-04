# spec/controllers/usuarios_controller_spec.rb
require 'rails_helper'

RSpec.describe UsuariosController, type: :controller do
  let(:valid_attributes) do
    {
      nome: 'usuario',
      email: 'usuario@email.com',
      matricula: '1234',
      usuario: 'usuario',
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

  describe "GET #index" do
    before do
      # cria pelo menos um usuário para a view consumir
      Usuario.create!(valid_attributes)
      get :index
    end
    it "retorna uma lista vazia quando não há usuários (apenas criados no teste)" do
      # Primeiro limpar todos os usuários criados por factories
      Usuario.delete_all
      get :index
      expect(assigns(:usuarios)).to be_empty
    end

    it "renderiza a view index" do
      expect(response).to be_successful
      expect(response.content_type).to eq("text/html; charset=utf-8")
      expect(response).to render_template(:index)
      expect(assigns(:usuarios)).to be_present
    end


    it "mostra todos usuarios" do
      initial_count = Usuario.count
      #exite validação de e-mail e usuario unico
      usuario1 = Usuario.create!(valid_attributes.merge(email: 'u1@example.com', usuario: 'u1'))
      usuario2 = Usuario.create!(valid_attributes.merge(email: 'u2@example.com', usuario: 'u2'))

      #faz a requisição
      get :index

      #verifica que usuarios tem novos registros
      expect(assigns(:usuarios).count).to eq(initial_count + 2)
      expect(assigns(:usuarios)).to include(usuario1, usuario2)
    end

  end


  describe "GET #show" do
    it "retorna uma resposta de sucesso" do
      usuario = Usuario.create! (valid_attributes)
      get :show, params: { id: usuario.id }
      expect(response).to be_successful
    end 
     it "retorna o usuário solicitado" do
      usuario = Usuario.create!(valid_attributes)
      get :show, params: { id: usuario.id }
      expect(assigns(:usuario)).to eq(usuario)  # mais direto
    end
  end

  describe "POST #create" do
    it "cria usuario com dados validos" do
      post :create,params: {usuario: valid_attributes}
      usuario = assigns(:usuario)
      expect(usuario).to be_persisted
      expect(usuario.nome).to eq(valid_attributes[:nome])
      expect(usuario.email).to eq(valid_attributes[:email])
      expect(usuario.matricula).to eq(valid_attributes[:matricula])
      expect(usuario.usuario).to eq(valid_attributes[:usuario])
      expect(usuario.ocupacao).to eq(valid_attributes[:ocupacao])
      expect(usuario.status).to eq(valid_attributes[:status])
    end
    it "retorna erros ao tentar criar usuário com dados inválidos" do
      post :create, params: { usuario: invalid_attributes }
      usuario = assigns(:usuario)
      expect(usuario).not_to be_persisted
      expect(usuario.errors).not_to be_empty
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:unprocessable_entity)
    end
   it "rejeita e-mail duplicado" do
    usuario1 = Usuario.create!(
    valid_attributes.merge(email: "usuario1@example.com", usuario: "user1"))
    post :create, params: { usuario: valid_attributes.merge(
      email: "usuario1@example.com",
      usuario: "user2" )}

    usuario = assigns(:usuario)
    expect(usuario).not_to be_persisted
    expect(usuario.errors[:email]).to be_present
    expect(response).to render_template(:new)
    expect(response).to have_http_status(:unprocessable_entity)

    end

    it "rejeita usuario duplicado" do
      usuario1 = Usuario.create!(
      valid_attributes.merge(email: "usuario1@example.com", usuario: "user1"))
      post :create, params: { usuario: valid_attributes.merge(email: "usuario2@example.com",usuario: "user1" )}
      usuario = assigns(:usuario)
      expect(usuario).not_to be_persisted
      expect(usuario.errors[:usuario]).to be_present
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "rejeita senha inválida (vazia)" do
      invalid = valid_attributes.merge(password: "")
      post :create, params: { usuario: invalid }
      usuario = assigns(:usuario)
      expect(usuario).not_to be_persisted
      expect(usuario.errors[:password]).to include("a senha não pode ser vazia")
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it "valida o tamanho da senha maior ou igual a 6 " do
    end
  end
end 
