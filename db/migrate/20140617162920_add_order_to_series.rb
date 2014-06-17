class AddOrderToSeries < ActiveRecord::Migration
  def change
    add_column :series, :order, :integer
    add_column :channels, :order, :integer
  end
end
