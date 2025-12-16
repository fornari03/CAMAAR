Usuario.find_or_create_by!(email: 'admin@test.com') do |user|
  user.nome = 'Administrador Default'
  user.usuario = 'admin'
  user.matricula = '000000'
  user.ocupacao = :admin
  user.status = true
  user.password = 'password'
end