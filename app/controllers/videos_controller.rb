class VideosController < ApplicationController
  def watched
    Video.find(params[:id]).update_attributes!(watched: true)

    redirect_to "/home"
  end
end