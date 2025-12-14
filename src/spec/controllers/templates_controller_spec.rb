require 'rails_helper'

RSpec.describe TemplatesController, type: :controller do
  let(:admin) { Usuario.create!(nome: 'Admin', email: 'admin@test.com', matricula: '123', usuario: 'admin', password: 'password', ocupacao: :admin, status: true) }
  let!(:template) { Template.create!(titulo: 'Template Teste', id_criador: admin.id) }
  
  before do
    session[:usuario_id] = admin.id
  end

  describe "GET #index" do
    it "retorna sucesso e carrega templates" do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:templates)).not_to be_nil 
    end
  end

  describe "GET #new" do
    it "instancia um novo template" do
      get :new
      expect(response).to have_http_status(:success)
      expect(assigns(:template)).to be_a_new(Template)
    end
  end

  describe "GET #edit" do
    it "carrega o template solicitado" do
      get :edit, params: { id: template.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:template)).to eq(template)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new template and redirects to edit' do
        expect {
          post :create, params: { template: { titulo: 'New Template' } }
        }.to change(Template, :count).by(1)
        
        expect(response).to redirect_to(edit_template_path(Template.last))
        expect(flash[:notice]).to be_present
      end
    end

    context 'with invalid attributes' do
      it 'does not create a template and renders new' do
        expect {
          post :create, params: { template: { titulo: '' } }
        }.not_to change(Template, :count)
        
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_content) 
      end
    end
  end

  describe "PATCH #update" do
    context "com atributos válidos" do
      it "atualiza o template e redireciona" do
        patch :update, params: { id: template.id, template: { titulo: "Título Atualizado" } }
        
        template.reload
        expect(template.titulo).to eq("Título Atualizado")
        expect(response).to redirect_to(edit_template_path(template))
        expect(flash[:notice]).to include("atualizado com sucesso")
      end
    end

    context "com atributos inválidos" do
      it "não atualiza e renderiza edit com erro" do
        old_title = template.titulo
        patch :update, params: { id: template.id, template: { titulo: "" } }
        
        template.reload
        expect(template.titulo).to eq(old_title)
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'soft deletes the template (sets hidden to true)' do
      expect {
        delete :destroy, params: { id: template.id }
      }.not_to change(Template, :count)

      template.reload
      expect(template.hidden).to be true
    end
  end
end