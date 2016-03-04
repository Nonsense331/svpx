class Video < ActiveRecord::Base
  belongs_to :user
  belongs_to :series
  belongs_to :channel

  scope :unwatched, -> {where(watched: false)}
end
