class CashFlowAndProfitLossTextToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :cash_flow, :string
    add_column :companies, :profit_and_loss, :string
  end
end
