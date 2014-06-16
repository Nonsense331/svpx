class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.belongs_to :user
      t.string :youtube_id
      t.boolean :watched, default: false, null: false
      t.string :title
      t.string :thumbnail
    end

    create_table :channels do |t|
      t.belongs_to :user
      t.string :youtube_id
      t.string :title
    end
  end
end