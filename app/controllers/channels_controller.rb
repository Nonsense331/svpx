class ChannelsController < ApplicationController
  def update
    channel = Channel.find(params[:id])
    channel.attributes = channel_params
    channel.save!

    respond_to do |format|
      format.js do
        render json: {success: true}
      end
    end
  end

  def show
    @channel = Channel.find(params[:id])
    @series = []
    @channel.videos.each do |video|
      series = Series.new
      series.user = current_user
      if video.title.match(/(^.*?)\d/)
        series.regex = video.title.match(/(^.*?)\d/)[1]
        if series.videos_from_regex.count > 1 && !@series.collect(&:regex).include?(series.regex)
          @series << series
        end
      end
    end
  end

  def music
    @channel = Channel.find(params[:id])
    @video = @channel.videos.unwatched.sample
  end

  def random_video
    channel = Channel.find(params[:id])
    video = channel.videos.unwatched.sample

    render json: {success: true, video: video.youtube_id}
  end

  private

  def channel_params
    params.require(:channel).permit(:order)
  end
end