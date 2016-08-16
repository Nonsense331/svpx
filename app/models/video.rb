class Video < ActiveRecord::Base
  belongs_to :user
  belongs_to :series
  belongs_to :channel

  scope :unwatched, -> {where(watched: false)}
  scope :ordered, -> {order(:published_at)}
end
