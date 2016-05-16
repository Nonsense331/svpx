class AddMusicCounterToVideo < ActiveRecord::Migration
  def up
    add_column :videos, :music_counter, :integer
    execute("UPDATE videos SET music_counter = plays")
    execute("UPDATE videos SET plays = 0")
  end

  def down
    execute("UPDATE videos SET plays = music_counter")
    remove_column :videos, :music_counter
  end
end
