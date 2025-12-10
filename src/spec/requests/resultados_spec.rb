require 'rails_helper'

RSpec.describe "Resultados", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/resultados/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/resultados/show"
      expect(response).to have_http_status(:success)
    end
  end

end
