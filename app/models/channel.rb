class Channel < ActiveRecord::Base
  belongs_to :user
  has_many :videos
  has_many :series_channels
  has_many :series, through: :series_channels
end