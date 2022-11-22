class HomeController < ApplicationController
  skip_before_action :ensure_authorization, only: :welcome
  def welcome
  end

  def home
    @series_videos = current_user.videos.includes(:series).select("DISTINCT ON (series_id) *").where.not(series_id: nil).where(watched: false).order('series_id, published_at').sort_by{ |s| s.series.order }
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
