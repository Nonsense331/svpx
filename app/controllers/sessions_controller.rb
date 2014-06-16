class SessionsController < ApplicationController
  skip_before_filter :ensure_authorization
  def create
    @user = User.where(uid: auth_hash.uid).first_or_create
    @user.email = auth_hash.info.email
    @user.name = auth_hash.info.name
    @user.image = auth_hash.info.image
    if auth_hash.credentials.refresh_token
      @user.refresh_token = auth_hash.credentials.refresh_token
    end
    @user.save!

    session['auth_token'] = auth_hash.credentials.token
    session['auth_hash'] = auth_hash

    self.current_user = @user

    redirect_to '/home'
  end

  def destroy
    self.current_user = nil
    redirect_to "/"
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end