class SeriesController < ApplicationController
  def new
    @series = Series.new
    if params[:video_title] && params[:video_title].match(/(^.*?)\d/)
      @title = params[:video_title]
      @series.regex = params[:video_title].match(/(^.*?)\d/)[1]
    end
  end

  def show
    @series = Series.find(params[:id])
  end

  def create
    series = Series.new(series_params)
    series.user = current_user
    series.order = (current_user.series.maximum(:order) || 0) + 1
    series.save!

    series.update_videos

    redirect_to series
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
    @series.channel_ids = params[:channel_ids].split(',')

    respond_to do |format|
      format.js
    end
  end

  def channels_from_regex
    @series = Series.new
    @series.user = current_user
    @series.regex = params[:regex]

    render json: { channel_ids: @series.channels_from_regex.collect(&:id) }
  end

  def next_video
    series = Series.find(params[:id])
    @video = series.next_video

    respond_to do |format|
      format.js
    end
  end

  def load_videos
    series = Series.find(params[:id])

    youtube = Youtube.new(current_user, session['auth_hash'])
    youtube.load_videos_for_series(series)

    series.update_videos

    redirect_to series
  end

  private

  def series_params
    params.require(:series).permit(:title, :regex, :order, {channel_ids: []})
  end
end
