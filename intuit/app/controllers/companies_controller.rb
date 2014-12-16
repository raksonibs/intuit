class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  def index
    @companies = Company.all
  end

  def show
  end

  def new
    @company = Company.new
  end

  def edit
  end

  def authenticate
    callback = oauth_callback_companies_url
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = Marshal.dump(token)
    @token = token
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
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

    # NTD: Is it always service first as interface?
    # should create all attributes on creation so no need for reconnect
    company.employee_number = @employee_service.query().max_results

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
