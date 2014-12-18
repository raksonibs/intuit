class BalanceSheetCrudeString < ActiveRecord::Migration
  def change
    add_column :companies, :balance_sheet, :text
  end
end
