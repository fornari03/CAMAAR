require 'rails_helper'

RSpec.describe Resposta, type: :model do
  describe 'associations' do
    it 'belongs to formulario' do
      expect(Resposta.reflect_on_association(:formulario).macro).to eq :belongs_to
    end
    it 'belongs to participante' do
      expect(Resposta.reflect_on_association(:participante).macro).to eq :belongs_to
    end
  end

  describe 'defaults' do
    it 'sets respondido to false by default' do
      resposta = Resposta.new
      expect(resposta.respondido).to be_falsey
    end
  end
end
