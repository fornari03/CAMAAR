require 'rails_helper'

RSpec.describe "Admins", type: :request do
  describe "GET /gerenciamento" do
    it "returns http success" do
      get "/admin/gerenciamento"
      expect(response).to have_http_status(:success)
    end
  end

end
