class Series < ActiveRecord::Base
  belongs_to :user
  has_many :videos

  def next_video
    lowest_video = nil
    videos.each do |video|
      if !lowest_video
        lowest_video = video
      elsif Integer(video.title.scan(/\d+/).first) < Integer(lowest_video.title.scan(/\d+/).first)
        lowest_video = video
      end
    end

    lowest_video
  end

  def update_videos
    user.videos.where(watched: false, series_id: nil).each do |video|
      if video.title =~ /#{Regexp.new(Regexp.quote(regex))}/
        video.series = self
        video.save!
      end
    end
  end

  def self.check_video(video)
    return if video.title.blank? || video.series_id
    Series.all.each do |series|
      next if series.regex.blank?
      if video.title =~ /#{series.regex}/
        video.series = series
        video.save!
        break
      end
    end
  end
end