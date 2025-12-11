require 'rails_helper'

RSpec.describe "OmniAuth Google callbacks", type: :request do
  let(:email) { 'test-oauth@example.com' }
  let(:name)  { 'Test User' }
  let(:mock_auth) {
    {
      'omniauth.auth'  => OmniAuth.config.mock_auth[:google_oauth2],
      'devise.mapping' => Devise.mappings[:user]
    }
  }
  
  before do
    # Ensure the AuthHash is present for the tests
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = mock_google_oauth(email: email, name: name)
  end
   
  describe 'with valid omniauth data' do
    context "with non-existent user" do
      it "creates user and authenticated" do
        expect {
          get '/users/auth/google_oauth2/callback', env: mock_auth
        }.to change(User, :count).by(1)
         
         user = User.order(:created_at).last
         expect(user.email).to eq(email)
         expect(response).to redirect_to(root_path)
       end
     end
     
     context "with existing user" do
       let!(:existing_user) { create(:user, email:) }

       it "does not create duplicate and authenticates existing user" do
        expect {
          get '/users/auth/google_oauth2/callback', env: mock_auth
        }.not_to change(User, :count)

        expect(response).to redirect_to(new_user_session_path)
       end
     end
     
     context 'with empty email provider' do
       let(:email) { nil }
       
       it 'raises error and redirects to registration' do
        OmniAuth.config.mock_auth[:google_oauth2] = mock_google_oauth(email: email, name: name)

        expect {
          get '/users/auth/google_oauth2/callback', env: mock_auth
        }.not_to change(User, :count)

        expect(response).to redirect_to(new_user_session_path)
       end
     end
   end
   
   context 'with invalid omniauth data' do
     it 'raises error and redirects to login' do
       OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

      expect {
        get '/users/auth/google_oauth2/callback', env: { 'omniauth.auth' => OmniAuth.config.mock_auth[:google_oauth2], 'devise.mapping' => Devise.mappings[:user] }
      }.not_to change(User, :count)

      expect(response).to have_http_status(302)
     end
   end
 end
