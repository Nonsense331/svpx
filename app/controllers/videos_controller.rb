class VideosController < ApplicationController
  def watched
    Video.find(params[:id]).update_attributes!(watched: true)
  end
end