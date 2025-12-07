# spec/models/usuario_spec.rb
require 'rails_helper'

RSpec.describe Usuario, type: :model do
  it "persiste atributos corretamente" do
    u = Usuario.create!(
      nome: 'usuario',
      email: 'usuario@email.com',
      matricula: '1234',
      usuario: 'usuario',
      password: 'senha123',
      ocupacao: 'discente',
      status: true
    )

    expect(u).to have_attributes(
      nome: 'usuario',
      email: 'usuario@email.com',
      matricula: '1234',
      usuario: 'usuario',
      ocupacao: 'discente',
      status: true
    )

    expect(u.authenticate('senha123')).to be_truthy if u.respond_to?(:authenticate)
  end
end
