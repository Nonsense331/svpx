class Video < ActiveRecord::Base
  belongs_to :user
  belongs_to :series
  belongs_to :channel
end