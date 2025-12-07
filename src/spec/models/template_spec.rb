require 'rails_helper'

RSpec.describe Template, type: :model do
  describe 'scopes' do
    describe '.all_visible' do
      it 'returns only templates that are not hidden' do
        user = Usuario.create!(nome: 'User', email: 'user@test.com', matricula: '123', usuario: 'user', password: 'password', ocupacao: :admin, status: true)
        # Create a visible template (hidden: false by default)
        visible_template = Template.create!(titulo: 'Visible Template', id_criador: user.id)
        
        # Create a hidden template
        hidden_template = Template.create!(titulo: 'Hidden Template', hidden: true, id_criador: user.id)

        expect(Template.all_visible).to include(visible_template)
        expect(Template.all_visible).not_to include(hidden_template)
      end
    end
  end
end
