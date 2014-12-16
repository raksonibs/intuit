FactoryGirl.define do 
  factory :company do 
    name 'Fake Company'
    comany_id '1'
    access_token 'Valid Token'
    access_secret 'secret'
    expires_at Date.today + 8
    reconnects_at Date.today + 7
    employee_number 3
  end
end