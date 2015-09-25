class AddPlaysToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :plays, :integer, default: 0, null: false
  end
end
