require 'google/apis/youtube_v3'
require 'google/api_client/client_secrets'

class Youtube
  def initialize(user, auth_hash=nil)
    Google::Apis::ClientOptions.default.application_name = 'SVPX'
    Google::Apis::ClientOptions.default.application_version = '1.0.0'
    @user = user
    @auth_hash = auth_hash
    file = Tempfile.new(["secrets", ".json"])
    file.write <<~EOF
{
  "web": {
    "client_id": "#{ENV["GOOGLE_CLIENT_ID"]}",
    "client_secret": "#{ENV["GOOGLE_CLIENT_SECRET"]}",
    "redirect_uris": ["https://svpx.herokuapp.com/auth/google_oauth2", "http://lvh.me:3000/auth/google_oauth2"],
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://accounts.google.com/o/oauth2/token"
  }
}
EOF
    file.rewind

    client_secrets = Google::APIClient::ClientSecrets.load(file.path)
    @authorization = client_secrets.to_authorization
    @authorization.update_token!(refresh_token: @user.refresh_token) if @user.refresh_token
    @authorization.scope = "http://gdata.youtube.com"

    if @auth_hash
      expires_at = Time.at(@auth_hash["credentials"]["expires_at"]) rescue nil
      if expires_at && expires_at > Time.now
        @authorization.update_token!(access_token: @auth_hash["credentials"]["token"])
      end
    else
      @authorization.grant_type = "refresh_token"
      @authorization.fetch_access_token!
    end
  end

  def api
    @api ||= Google::Apis::YoutubeV3::YouTubeService.new
  end

  def update_activities
    @user.channels.each do |channel|
      params = {channel_id: channel.youtube_id}
      response = api.list_activities('content_details, snippet', **get_parameters(params))
      response.items.each do |item|
        if item.content_details && item.content_details.upload
          load_video(item.content_details.upload.video_id, item, channel)
        end
      end
    end
  end

  def update_subscriptions
    response = get_subscription_page()
    subscriptions = response.items
    next_page_token  = response.next_page_token
    while next_page_token
      response = get_subscription_page(next_page_token )
      subscriptions += response.items
      next_page_token  = response.next_page_token
    end

    channel_ids = subscriptions.collect{|c| c.snippet.resource_id.channel_id}
    # @user.channels.each do |channel|
    #   unless channel_ids.include? channel.youtube_id
    #     channel.destroy
    #   end
    # end

    subscriptions.each do |item|
      channel = Channel.where(user_id: @user.id, youtube_id: item.snippet.resource_id.channel_id).first_or_create
      channel.title = item.snippet.title
      channel.save!
    end
  end

  def get_subscription_page(page_token=nil)
    params = {
      mine: true
    }
    if page_token
      params[:page_token] = page_token
    end
    response = api.list_subscriptions('snippet', **get_parameters(params))
  end

  def get_all_videos(channel, next_page_token =nil)
    response = get_video_page(channel, next_page_token )
    videos = response.items
    next_page_token  = response.next_page_token

    videos.each do |item|
      load_video(item.id.video_id, item, channel)
    end

    return videos, next_page_token
  end

  def get_video_page(channel, page_token=nil)
    params = {
      channel_id: channel.youtube_id,
      max_results: 10,
      type: 'video'
    }
    if page_token
      params[:page_token] = page_token
    end
    response = api.list_searches('snippet', **get_parameters(params))
  end

  def load_videos_for_series(series)
    query = series.videos.first.title.match(Regexp.new(series.regex))[0]

    series.channels.each do |channel|
      response = search(query, channel)
      videos = response.items
      next_page_token  = response.next_page_token

      while next_page_token
        response = get_video_page(channel, next_page_token )
        videos += response.items
        next_page_token  = response.next_page_token
      end

      videos.each do |item|
        load_video(item.id.video_id, item, channel)
      end
    end
  end

  def search(q, channel, page_token=nil)
    params = {
      max_results: 50,
      q: q,
      type: 'video'
    }
    if page_token
      params[:page_token] = page_token
    end
    if channel
      params[:channel_id] = channel.youtube_id
    end
    response = api.list_searches('snippet', **get_parameters(params))
  end

  def load_video(youtube_id, item, channel)
    video = Video.where(youtube_id: youtube_id, user_id: @user.id).first_or_create
    video.title = item.snippet.title
    video.thumbnail = item.snippet.thumbnails.default.url
    video.published_at = item.snippet.published_at
    video.channel = channel
    if channel.music
      video.music_counter = 1
    end
    video.save!

    Series.check_video(video)
  end

  def get_parameters(params={})
    params[:options] = { authorization: @authorization }

    params
  end
end
