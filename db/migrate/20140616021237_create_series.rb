class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.belongs_to :user
      t.string :title
      t.string :regex
    end

    add_column :videos, :series_id, :integer
  end
end
