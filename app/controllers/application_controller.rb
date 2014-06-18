class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :ensure_authorization
  helper_method :current_user

  def current_user
    return nil if session['current_user'].nil?
    @current_user ||= User.find(session['current_user'])
  end

  def current_user=(user)
    if user.nil?
      session['current_user'] = nil
    else
      session['current_user'] = user.id
    end
    @current_user = user
  end

  private

  def ensure_authorization
    expires_at = Time.at(session["auth_hash"]["credentials"]["expires_at"]) rescue Time.now
    if !current_user
      redirect_to "/"
    end
    if expires_at && expires_at < Time.now
      youtube = Youtube.new(current_user, session['auth_token'])
      youtube.api_client
    end
  end
end