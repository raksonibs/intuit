class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :access_token
      t.string :access_secret
      t.string :company_id
      t.datetime :expires_at
      t.datetime :reconnect_at

      t.timestamps
    end
  end
end
