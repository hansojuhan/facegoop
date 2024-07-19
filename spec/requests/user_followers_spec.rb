require 'rails_helper'

RSpec.describe "UserFollowers", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/user_followers/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/user_followers/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
