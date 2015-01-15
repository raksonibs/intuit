class SessionsController < ApplicationController
   before_filter :get_xero_client

    public

        def new
            request_token = @xero_client.request_token(:oauth_callback => 'http://yourapp.com/xero_session/create')
            session[:request_token] = request_token.token
            session[:request_secret] = request_token.secret

            redirect_to request_token.authorize_url
        end

        def create
            @xero_client.authorize_from_request(
                    session[:request_token], 
                    session[:request_secret], 
                    :oauth_verifier => params[:oauth_verifier] )

            session[:xero_auth] = {
                    :access_token => @xero_client.access_token.token,
                    :access_key => @xero_client.access_token.secret }

            session[:request_token] = nil
            session[:request_secret] = nil
        end

        def destroy
            session.data.delete(:xero_auth)
        end

    private

        def get_xero_client
            @xero_client = Xeroizer::PublicApplication.new(Figaro.env.xero_key, Figaro.env.xero_secret)

            # Add AccessToken if authorised previously.
            if session[:xero_auth]
                @xero_client.authorize_from_access(
                    session[:xero_auth][:access_token], 
                    session[:xero_auth][:access_key] )
            end
        end
end
