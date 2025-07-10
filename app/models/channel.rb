class Channel < ActiveRecord::Base
  belongs_to :user
  has_many :videos, dependent: :destroy
  has_many :series_channels, dependent: :destroy
  has_many :series, through: :series_channels

  scope :music, -> {where(music: true)}
  scope :normal, -> {where("music IS NOT TRUE")}
end
