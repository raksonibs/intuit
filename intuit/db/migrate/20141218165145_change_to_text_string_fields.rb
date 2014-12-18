class ChangeToTextStringFields < ActiveRecord::Migration
  def change
    change_column :companies, :cash_flow, :text
    change_column :companies, :profit_and_loss, :text
  end
end
