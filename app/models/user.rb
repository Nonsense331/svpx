class User < ActiveRecord::Base
  has_many :videos
  has_many :channels
  has_many :series

  def self.update_activities
    User.all.each do |user|
      begin
        youtube = Youtube.new(user)

        youtube.update_activities
      rescue StandardError => e

      end
    end
  end
end
