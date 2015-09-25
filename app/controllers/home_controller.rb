class HomeController < ApplicationController
  skip_before_filter :ensure_authorization, only: :welcome
  def welcome
    redirect_to "/auth/google_oauth2"
  end

  def home
    if current_user.channels.empty?
      youtube = Youtube.new(current_user, session['auth_hash'])
      youtube.update_subscriptions
    end
    if current_user.videos.empty?
      youtube = Youtube.new(current_user, session['auth_hash'])
      youtube.update_activities
    end

    @series = current_user.series.includes(:videos).order(:order)
    @channels = current_user.channels.includes(:videos).order(:order)
  end

  def channels
  end

  def update_subscriptions
    youtube = Youtube.new(current_user, session['auth_hash'])

    youtube.update_subscriptions
    youtube.update_activities

    redirect_to action: :channels
  end

  def update_activities
    youtube = Youtube.new(current_user, session['auth_hash'])

    youtube.update_activities

    redirect_to action: :home
  end

  def music
    @video = get_random_video
  end

  def random_video
    video = get_random_video

    render json: {success: true, video: video.youtube_id, love: video.love}
  end

  def hate_video
    video = Video.find_by_youtube_id(params[:video_id])
    video.watched = true
    video.save!

    render json: {success: true}
  end

  def love_video
    video = Video.find_by_youtube_id(params[:video_id])
    video.love = !video.love
    video.save!

    render json: {success: true}
  end

  def increment_plays
    video = Video.find_by_youtube_id(params[:video_id])
    video.plays ||= 0
    video.plays += 1
    video.save!

    render json: {success: true}
  end

  private
  def get_random_video
    videos = Video.joins(:channel).unwatched.where(channels:{user_id: current_user.id, music: true})
    videos.where(plays: videos.collect(&:plays).uniq.min).sample
  end
end