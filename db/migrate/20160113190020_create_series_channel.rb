class CreateSeriesChannel < ActiveRecord::Migration
  def change
    create_table :series_channels do |t|
      t.belongs_to :series
      t.belongs_to :channel
    end
  end
end
