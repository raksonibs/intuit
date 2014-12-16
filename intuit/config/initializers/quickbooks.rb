$qb_oauth_consumer = OAuth::Consumer.new(Figaro.env.qb_key, Figaro.env.qb_secret, {
    :site                 => "https://oauth.intuit.com",
    :request_token_path   => "/oauth/v1/get_request_token",
    :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
    :access_token_path    => "/oauth/v1/get_access_token"
})

Quickbooks.sandbox_mode = true
Quickbooks.logger = Rails.logger 
Quickbooks.log = true 