require "rexml/document"

class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  def index
    @companies = Company.all
  end

  def show
    @balance_sheet = @company.balance_sheet
    @cash_flow = @company.cash_flow
    @profit_and_loss = @company.profit_and_loss
  end

  def new
    @company = Company.new
  end

  def edit
  end

  def report_ranged
    set_qb_services

    # NTD: Make the dates add correctly and map. Need something to grab the date strings and place as what it would be.
    date_range = params[:start_date] + " " + params[:end_date]
    @report_service.query(params[:report], date_range)
    @report_ranged = @report_service.last_response_xml.to_s # shouldn't save each time, should just render the request on these instances and default save is full year.
    # should be doing this in ajax request but can't really render service as object?
    respond_to do |format|
      format.json { render json: @report_ranged }
    end
  end

  def bluedot
    intuit_account = Company.find(params['realmId'])

    unless intuit_account
      render(:text => "You are not connected to Intuit.") and return
    end

    html = Rails.cache.read("cache-key")
    if !html.blank?
      render(:text => html) and return
    end

    # nope, contact Intuit
    access_token = intuit_account.access_token
    access_secret = intuit_account.access_secret
    consumer = OAuth::AccessToken.new($qb_oauth_consumer, access_token, access_secret)
    response = consumer.request(:get, "https://appcenter.intuit.com/api/v1/Account/AppMenu")
    if response && response.body
      html = response.body

      # cache this if we have a valid IntuitAccount
      if intuit_account
        Rails.cache.write("cache-key", html)
      end
      render(:text => html) and return
    else
      Rails.logger.info("Error fetching Intuit Menu proxy code: #{response.inspect}")
    end
    render(:text => "error") and return
  end

  def authenticate
    callback = oauth_callback_companies_url
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = Marshal.dump(token)
    @token = token
    respond_to do |format|
      format.json { render json: @token }
      redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
    end
  end

  def oauth_callback
    at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:token] = at.token
    session[:secret] = at.secret
    session[:realm_id] = params['realmId']

    set_qb_services
    
    @company = @company_service.query().entries.first

    company = Company.where({
      name: @company.company_name,
      company_id: @company.id.to_s
    }).first_or_create

    company.update_attributes({
      access_token: at.token,
      expires_at: Date.today + 6.months,
      reconnect_at: Date.today + 5.months,
      access_secret: at.secret
    })

    company.employee_number = @employee_service.query().max_results

    @report_service.query()
    company.balance_sheet = @report_service.last_response_xml.to_s
    @report_service.query('CashFlow')
    company.cash_flow = @report_service.last_response_xml.to_s
    @report_service.query('ProfitAndLoss')
    company.profit_and_loss = @report_service.last_response_xml.to_s

    company.save!

    session[:company_id] = @company.id.to_s

    redirect_to root_url, notice: "Your QuickBooks account has been successfully linked."
  end

  def create
    @company = Company.new(company_params)

    company = Quickbooks::Model::Company.new 
    company.given_name = company_params[:name]
    @company_service.create(company)

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @company.update(company_params)
        #this line checkts over the company service, checking all entriies. where is @company_service readily available though?
        company = @company_service.query("SELECT * FROM VENDOR WHERE GivenName = '#{company_params[:name]}'").entries.first

        company.email_address = company_params[:email_address]

        @company_service.update(company)

        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def logout
    session[:qb_request_token] = nil
    session[:token] = nil
    session[:secret] = nil
    session[:realm_id] = nil
    redirect_to root_url
  end

  private

    def set_qb_services
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @company_service = Quickbooks::Service::CompanyInfo.new
      @company_service.access_token = oauth_client
      @company_service.company_id = session[:realm_id]

      @employee_service = Quickbooks::Service::Employee.new
      @employee_service.access_token = oauth_client
      @employee_service.company_id = session[:realm_id]

      @report_service = Quickbooks::Service::Reports.new
      @report_service.access_token = oauth_client
      @report_service.company_id = session[:realm_id]
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :email_address)
    end
end
