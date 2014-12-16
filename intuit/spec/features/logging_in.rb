require 'spec_helper'

feature 'Logging in a company' do 
  scenario 'correct login page', js: true do 
    visit('/')
    page.has_css?('.intuitPlatformConnectButton').should eq(true)
  end

  scenario 'valid oauth', js: true do 
    visit('/')
    click_link "Connect with QuickBooks"
    page.has_text?('Sign in').should eq(true)
    fill_in :email, with: 'oskarniburski@gmail.com'
    fill_in :password, with: 'test'
    click "Sign in"
    page.has_button?('Authorize').should eq(true)
    page.has_css?('.company_name').should eq(true)
    page.has_text?('This is a sandbox').should eq(true)
  end

  scenario 'invalid login because No Thanks' do 
    visit('/')
    click_link "Connect with QuickBooks"
    page.has_text?('Sign in').should eq(true)
    fill_in :email, with: 'oskarniburski@gmail.com'
    fill_in :password, with: 'test'
    click "Sign in"
    page.has_button?('Authorize').should eq(true)
    click_link 'No, Thanks'
    page.has_css?('.intuitPlatformConnectButton').should eq(true)
  end
end