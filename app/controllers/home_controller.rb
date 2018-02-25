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

    @series_videos = current_user.videos.includes(:series).select("DISTINCT ON (series_id) *").where.not(series_id: nil).order('series_id, published_at').sort_by{ |s| s.series.order }
    @channels = current_user.channels.includes(:videos).order(:order)
  end

  def channels
  end

  def update_subscriptions
    youtube = Youtube.new(current_user, session['auth_hash'])

    youtube.update_subscriptions

    redirect_to action: :channels
  end

  def update_activities
    youtube = Youtube.new(current_user, session['auth_hash'])

    youtube.update_activities

    redirect_to action: :home
  end
end
