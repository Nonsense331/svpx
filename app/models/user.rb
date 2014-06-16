class User < ActiveRecord::Base
  has_many :videos
  has_many :channels
  has_many :series

  def self.update_activities
    User.all.each do |user|
      youtube = Youtube.new(user)

      youtube.update_activities
    end
  end
end
