class AddEmployeeNumberToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :employee_number, :integer
  end
end
