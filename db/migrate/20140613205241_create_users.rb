class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :uid
      t.string :name
      t.string :image
      t.string :refresh_token

      t.timestamps
    end
  end
end