require 'rails_helper'

RSpec.describe "Respostas", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/respostas/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/respostas/create"
      expect(response).to have_http_status(:success)
    end
  end

end
