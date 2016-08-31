class ChannelsController < ApplicationController
  def update
    channel = Channel.find(params[:id])
    channel.attributes = channel_params
    channel.save!

    if channel.music
      videos = current_user.videos.joins(:channel).where(channels: {music: true})
      max = [videos.maximum(:music_counter), 1].max
      videos.each do |video|
        video.update(music_counter: max - 1)
      end
    end

    respond_to do |format|
      format.js do
        render json: {success: true}
      end
    end
  end

  def show
    @channel = Channel.includes(:videos).find(params[:id])
  end

  def get_all_videos
    channel = Channel.find(params[:id])

    youtube = Youtube.new(current_user, session['auth_hash'])
    youtube.get_all_videos(channel)

    redirect_to action: :show
  end

  private

  def channel_params
    params.require(:channel).permit(:order, :music)
  end
end
