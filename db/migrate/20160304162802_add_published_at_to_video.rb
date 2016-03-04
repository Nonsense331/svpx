class AddPublishedAtToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :published_at, :datetime

    reversible do |dir|
      dir.up do
        execute("UPDATE videos SET published_at = created_at")
      end
    end
  end
end
