class VideosController < ApplicationController
  def watched
    video = Video.find(params[:id])
    video.update_attributes!(watched: true)

    respond_to do |format|
      format.js do
        render json: {success: true}
      end
    end
  end
end