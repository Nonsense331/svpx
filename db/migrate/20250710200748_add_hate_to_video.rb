class AddHateToVideo < ActiveRecord::Migration[7.0]
  def change
    add_column :videos, :hate, :boolean, default: false, null: false
  end
end
