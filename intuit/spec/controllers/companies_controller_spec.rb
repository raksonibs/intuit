require 'spec_helper'

RSpec.describe CompaniesController, :type => :controller do

  describe "GET create" do
    it "returns http success" do
      get :create
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET authenticate" do
    it "returns http success" do
      get :authenticate
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET logout" do
    it "returns http success" do
      get :logout
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET oauth_callback" do
    it "returns http success" do
      get :oauth_callback
      expect(response).to have_http_status(:success)
    end
  end

end
