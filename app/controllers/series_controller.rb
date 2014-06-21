class SeriesController < ApplicationController
  def new
    @series = Series.new
    if params[:video_title] && params[:video_title].match(/(^.*?)\d/)
      @title = params[:video_title]
      @series.regex = params[:video_title].match(/(^.*?)\d/)[1]
    end
  end

  def create
    series = Series.new(series_params)
    series.user = current_user
    series.save!

    series.update_videos

    redirect_to "/home"
  end

  def destroy
    series = Series.find(params[:id])
    series.videos.each do |video|
      video.series_id = nil
      video.save!
    end
    series.destroy

    redirect_to "/home"
  end

  def update
    series = Series.find(params[:id])
    series.attributes = series_params
    series.save!

    respond_to do |format|
      format.js do
        render json: {success: true}
      end
    end
  end

  def videos_from_regex
    @series = Series.new
    @series.user = current_user
    @series.regex = params[:regex]

    respond_to do |format|
      format.js
    end
  end

  def next_video
    @series = Series.find(params[:id])

    respond_to do |format|
      format.js
    end
  end

  private

  def series_params
    params.require(:series).permit(:title, :regex, :order)
  end
end