class SeriesChannel < ActiveRecord::Base
  belongs_to :series
  belongs_to :channel
end