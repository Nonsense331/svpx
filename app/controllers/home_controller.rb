class HomeController < ApplicationController
  skip_before_filter :ensure_authorization, only: :welcome
  def welcome
    redirect_to "/auth/google_oauth2"
  end

  def home
    youtube = Youtube.new(current_user, session['auth_token'])

    youtube.update_activities

    @videos = current_user.videos.where(series_id: nil)
  end

  def channels
  end

  def update_subscriptions
    youtube = Youtube.new(current_user, session['auth_token'])

    youtube.update_subscriptions

    redirect_to action: :channels
  end

  def update_activities
    youtube = Youtube.new(current_user, session['auth_token'])

    youtube.update_activities

    redirect_to action: :home
  end
end