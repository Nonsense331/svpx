class AddMusicToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :music, :boolean
  end
end
