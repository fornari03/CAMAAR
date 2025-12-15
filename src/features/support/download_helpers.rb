def verify_csv_download_response(filename)
  # Captura headers uma vez
  headers = page.response_headers
  
  # Delega as validações
  validate_csv_content_type(headers)
  validate_attachment_disposition(headers, filename)
end

# --- Métodos Auxiliares ---

def validate_csv_content_type(headers)
  expect(headers['Content-Type']).to include('text/csv')
end

def validate_attachment_disposition(headers, filename)
  disposition = headers['Content-Disposition']
  
  # Verifica se é um anexo
  expect(disposition).to include("attachment")
  
  # Verifica se o nome do arquivo está correto
  expect(disposition).to include(filename)
end

def verify_no_file_download_occurred
  # Captura os headers apenas uma vez
  headers = page.response_headers
  
  # Verifica se o conteúdo continua sendo uma página web (HTML)
  expect(headers['Content-Type']).to include('text/html')
  
  # Verifica se não há instrução de anexo/download
  expect(headers['Content-Disposition']).to be_nil
end