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

  describe '#respondido?' do
    it 'returns true if data_submissao is present' do
      r = Resposta.new(data_submissao: Time.now)
      expect(r.respondido?).to be true
    end

    it 'returns false if data_submissao is nil' do
      r = Resposta.new(data_submissao: nil)
      expect(r.respondido?).to be false
    end
  end
end
