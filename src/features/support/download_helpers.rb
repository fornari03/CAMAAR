def verify_csv_download_response(filename)
  # Captura os headers uma única vez para evitar múltiplas chamadas ao driver
  headers = page.response_headers
  
  # Validação do Tipo de Conteúdo
  expect(headers['Content-Type']).to include('text/csv')
  
  # Validação da Disposição do Conteúdo (Anexo + Nome)
  content_disposition = headers['Content-Disposition']
  expect(content_disposition).to include("attachment")
  expect(content_disposition).to include(filename)
end