class User < ActiveRecord::Base
  has_many :videos
  has_many :channels
  has_many :series
end
