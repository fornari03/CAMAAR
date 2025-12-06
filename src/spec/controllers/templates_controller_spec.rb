require 'rails_helper'

RSpec.describe TemplatesController, type: :controller do
  let(:admin) { Usuario.create!(nome: 'Admin', email: 'admin@test.com', matricula: '123', usuario: 'admin', password: 'password', ocupacao: :admin, status: true) }
  
  before do
    session[:usuario_id] = admin.id
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new template and redirects to edit' do
        expect {
          post :create, params: { template: { titulo: 'New Template' } }
        }.to change(Template, :count).by(1)
        
        expect(response).to redirect_to(edit_template_path(Template.last))
      end
    end

    context 'with invalid attributes' do
      it 'does not create a template and renders new' do
        expect {
          post :create, params: { template: { titulo: '' } }
        }.not_to change(Template, :count)
        
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:template) { Template.create!(titulo: 'To Delete', id_criador: admin.id) }

    it 'soft deletes the template (sets hidden to true)' do
      expect {
        delete :destroy, params: { id: template.id }
      }.not_to change(Template, :count)

      template.reload
      expect(template.hidden).to be true
    end
  end
end
