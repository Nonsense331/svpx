class AddLoveToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :love, :boolean, default: false, null: false
  end
end
