class SeriesController < ApplicationController
  def new
    @series = Series.new
    if params[:video_title]
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

  private

  def series_params
    params[:series].permit(:title, :regex)
  end
end