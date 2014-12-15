class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_company

  def current_company
    current_company ||= Company.find_by_company_id(session[:company_id]) if session[:company_id]
  end
end
