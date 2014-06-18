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

    @series = current_user.series.order(:order)
    @channels = current_user.channels.order(:order)
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
end