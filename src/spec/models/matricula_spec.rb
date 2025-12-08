require 'rails_helper'

RSpec.describe Matricula, type: :model do
  describe 'associations' do
    it 'belongs to usuario' do
      expect(Matricula.reflect_on_association(:usuario).macro).to eq :belongs_to
    end
    it 'belongs to turma' do
      expect(Matricula.reflect_on_association(:turma).macro).to eq :belongs_to
    end
  end
end
