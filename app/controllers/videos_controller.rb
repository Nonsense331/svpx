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

  def music
    @video = get_random_video
  end

  def random
    @video = get_random_video(params[:video_id])

    render :show
  end

  def hate
    @video = Video.find(params[:id])
    @video.watched = true
    @video.save!

    render :show
  end

  def love
    @video = Video.find(params[:id])
    @video.love = !@video.love
    @video.save!

    render :show
  end

  def increment_plays
    @video = Video.find(params[:id])
    @video.plays += 1
    @video.music_counter += 1
    @video.save!

    render :show
  end

  private
  def get_random_video(id=nil)
    videos = Video.joins(:channel).unwatched.where(channels:{user_id: current_user.id, music: true})
    if id
      videos = videos.where("videos.id != ?", id)
    end
    min_music_counter = videos.where(music_counter: videos.minimum(:music_counter))
    if min_music_counter.count > 0
      return min_music_counter.sample
    else
      return videos.where(music_counter: videos.minimum(:music_counter)+1).sample
    end
  end
end
