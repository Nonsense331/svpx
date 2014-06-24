class Series < ActiveRecord::Base
  belongs_to :user
  has_many :videos

  def next_video
    videos.where(watched: false).order(:created_at).first
  end

  def videos_from_regex
    user.videos.where(series_id: nil).select do |video|
      video.title =~ Regexp.new(Regexp.quote(regex))
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
    Series.where(user_id: video.user_id).each do |series|
      next if series.regex.blank?
      if video.title =~ Regexp.new(Regexp.quote(series.regex))
        video.series = series
        video.save!
        break
      end
    end
  end
end