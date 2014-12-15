class VendorsController < ApplicationController
  before_action :set_vendor, only: [:show, :edit, :update, :destroy]
  before_action :set_qb_service, only: [:create, :edit, :update, :destroy]

  # GET /vendors
  # GET /vendors.json
  def index
    @vendors = Vendor.all
  end

  # GET /vendors/1
  # GET /vendors/1.json
  def show
  end

  # GET /vendors/new
  def new
    @vendor = Vendor.new
  end

  # GET /vendors/1/edit
  def edit
  end

  def authenticate
    callback = oauth_callback_vendors_url
    token = $qb_oauth_consumer.get_request_token(oauth_callback:callback)
    session[:db_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:token] = at.token
    session[:secret] = at.secret
    session[:realm_id] = params['realmId']
    redirect_to root_url, notice: "Your QuickBooks account has been successfully linked."
  end

  # POST /vendors
  # POST /vendors.json
  def create
    @vendor = Vendor.new(vendor_params)

    vendor = Quickbooks::Model::Vendor.new 
    vendor.given_name = vendor_params[:name]
    vendor.email_address = vendor_params[:email_address]
    @vendor_service.create(vendor)

    respond_to do |format|
      if @vendor.save
        format.html { redirect_to @vendor, notice: 'Vendor was successfully created.' }
        format.json { render :show, status: :created, location: @vendor }
      else
        format.html { render :new }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vendors/1
  # PATCH/PUT /vendors/1.json
  def update
    Quickbooks.logger = Rails.logger 
    Quickbooks.log = true 
    
    respond_to do |format|
      if @vendor.update(vendor_params)
        #this line checkts over the vendor service, checking all entriies. where is @vendor_service readily available though?
        vendor = @vendor_service.query("SELECT * FROM VENDOR WHERE GivenName = '#{vendor_params[:name]}'").entries.first

        vendor.email_address = vendor_params[:email_address]

        @vendor_service.update(vendor)

        format.html { redirect_to @vendor, notice: 'Vendor was successfully updated.' }
        format.json { render :show, status: :ok, location: @vendor }
      else
        format.html { render :edit }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vendors/1
  # DELETE /vendors/1.json
  def destroy
    @vendor.destroy
    respond_to do |format|
      format.html { redirect_to vendors_url, notice: 'Vendor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_qb_service
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
      @vendor_service = Quickbooks::Service::Vendor.new
      @vendor_service.access_token = oauth_client
      @vendor_service.company_id = session[:realm_id]
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_vendor
      @vendor = Vendor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vendor_params
      params.require(:vendor).permit(:name, :email_address)
    end
end
