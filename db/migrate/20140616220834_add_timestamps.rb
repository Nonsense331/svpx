class AddTimestamps < ActiveRecord::Migration
  def change
    change_table(:videos) { |t| t.timestamps }
    change_table(:channels) { |t| t.timestamps }
    change_table(:series) { |t| t.timestamps }
  end
end
