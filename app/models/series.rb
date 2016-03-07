class Series < ActiveRecord::Base
  belongs_to :user
  has_many :videos
  has_many :series_channels
  has_many :channels, through: :series_channels

  def next_video
    videos.where(watched: false).order(:published_at).first
  end

  def videos_from_regex
    if channels.any?
      user_videos = user.videos.where(channel_id: channel_ids)
    else
      user_videos = user.videos
    end
    user_videos.where(series_id: nil).select do |video|
      video.title =~ Regexp.new(regex)
    end
  end

  def channels_from_regex
    videos = user.videos.where(series_id: nil).select do |video|
      video.title =~ Regexp.new(regex)
    end

    videos.collect(&:channel).uniq
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
      binding.pry if series.id == 131
      next if series.regex.blank?
      next if series.channels.any? && !series.channels.include?(video.channel)
      if video.title =~ Regexp.new(series.regex)
        video.series = series
        video.save!
        break
      end
    end

    nil
  end
end
