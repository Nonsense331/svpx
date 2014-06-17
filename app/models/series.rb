class Series < ActiveRecord::Base
  belongs_to :user
  has_many :videos

  def next_video
    lowest_video = nil
    videos.where(watched: false).each do |video|
      if !lowest_video
        lowest_video = video
      else
        if video.title.scan(/\d+/) && (Integer(video.title.scan(/\d+/).first) < Integer(lowest_video.title.scan(/\d+/).first))
          lowest_video = video
        elsif video.created_at < lowest_video.created_at
          #this might be good enough for all videos honestly...
          lowest_video = video
        end
      end
    end

    lowest_video
  end

  def videos_from_regex
    user.videos.where(watched: false, series_id: nil).select do |video|
      video.title =~ /#{Regexp.new(Regexp.quote(regex))}/
    end
  end

  def update_videos
    videos_from_regex.each do |video|
      video.series = self
      video.save!
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