# Classe base abstrata para todos os modelos da aplicação.
# Herda de ActiveRecord::Base e define que esta é uma classe abstrata primária.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
