class Video < ActiveRecord::Base
  belongs_to :user
  belongs_to :series, optional: true
  belongs_to :channel, optional: true

  scope :unwatched, -> {where(watched: false)}
  scope :ordered, -> {order(:published_at)}

  def published_at_display
    published_at.strftime("%D")
  end
end
