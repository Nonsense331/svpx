require 'google/api_client'
class Youtube
  def initialize(user, auth_hash=nil)
    @user = user
    @auth_hash = auth_hash
  end

  def execute_api_call(method, params)
    response = api_client.execute(api_method: method, parameters: params)
    if response.body["error"]
      if response.body["error"]["code"] == 401
        #unauthorized
        raise "unauthorized"
      end
    end

    response
  end

  def api_client
    @client ||= begin
      client = Google::APIClient.new(application_name: 'SVPX', application_version: '1.0.0')
      client.authorization.client_id = ENV["GOOGLE_CLIENT_ID"]
      client.authorization.client_secret = ENV["GOOGLE_CLIENT_SECRET"]
      client.authorization.scope = "http://gdata.youtube.com"
      client.authorization.update_token!(refresh_token: @user.refresh_token) if @user.refresh_token
      if @auth_hash
        expires_at = Time.at(@auth_hash["credentials"]["expires_at"]) rescue nil
        if expires_at && expires_at > Time.now
          client.authorization.update_token!(access_token: @auth_hash.credentials.token)
        end
      else
        client.authorization.grant_type = "refresh_token"
        client.authorization.fetch_access_token!
      end

      client
    end
  end

  def api
    @api ||= api_client.discovered_api('youtube', 'v3')
  end

  def update_activities
    @user.channels.each do |channel|
      response = execute_api_call(api.activities.list, {'part' => 'contentDetails, snippet', 'channelId' => channel.youtube_id})
      body = JSON.parse response.body
      body["items"].each do |item|
        if item["contentDetails"] && item["contentDetails"]["upload"]
          load_video(item["contentDetails"]["upload"]["videoId"], item, channel)
        end
      end
    end
  end

  def update_subscriptions
    body = get_subscription_page()
    subscriptions = body["items"]
    nextPageToken = body["nextPageToken"]
    while nextPageToken
      body = get_subscription_page(nextPageToken)
      subscriptions += body["items"]
      nextPageToken = body["nextPageToken"]
    end

    channel_ids = subscriptions.collect{|c| c["snippet"]["resourceId"]["channelId"]}
    # @user.channels.each do |channel|
    #   unless channel_ids.include? channel.youtube_id
    #     channel.destroy
    #   end
    # end

    subscriptions.each do |item|
      channel = Channel.where(user_id: @user.id, youtube_id: item["snippet"]["resourceId"]["channelId"]).first_or_create
      channel.title = item["snippet"]["title"]
      channel.save!
    end
  end

  def get_subscription_page(pageToken=nil)
    parameters = {
      'part' => 'snippet',
      'mine' => true
    }
    if pageToken
      parameters['pageToken'] = pageToken
    end
    response = execute_api_call(api.subscriptions.list, parameters)
    JSON.parse response.body
  end

  def get_all_videos(channel, nextPageToken=nil)
    body = get_video_page(channel, nextPageToken)
    videos = body["items"]
    nextPageToken = body["nextPageToken"]

    videos.each do |item|
      load_video(item["id"]["videoId"], item, channel)
    end

    return videos, nextPageToken
  end

  def get_video_page(channel, pageToken=nil)
    parameters = {
      'part' => 'snippet',
      'channelId' => channel.youtube_id,
      'maxResults' => 10,
      'type' => 'video'
    }
    if pageToken
      parameters['pageToken'] = pageToken
    end
    response = execute_api_call(api.search.list, parameters)
    JSON.parse response.body
  end

  def load_videos_for_series(series)
    query = series.videos.first.title.match(Regexp.new(series.regex))[0]

    series.channels.each do |channel|
      body = search(query, channel)
      videos = body["items"]
      nextPageToken = body["nextPageToken"]

      while nextPageToken
        body = get_video_page(channel, nextPageToken)
        videos += body["items"]
        nextPageToken = body["nextPageToken"]
      end

      videos.each do |item|
        load_video(item["id"]["videoId"], item, channel)
      end
    end
  end

  def search(q, channel, pageToken=nil)
    parameters = {
      'part' => 'snippet',
      'maxResults' => 50,
      'q' => q,
      'type' => 'video'
    }
    if pageToken
      parameters['pageToken'] = pageToken
    end
    if channel
      parameters['channelId'] = channel.youtube_id
    end
    response = execute_api_call(api.search.list, parameters)
    JSON.parse response.body
  end

  def load_video(youtube_id, item, channel)
    video = Video.where(youtube_id: youtube_id, user_id: @user.id).first_or_create
    video.title = item["snippet"]["title"]
    video.thumbnail = item["snippet"]["thumbnails"]["default"]["url"]
    video.published_at = item["snippet"]["publishedAt"]
    video.channel = channel
    if channel.music
      max = [channel.videos.maximum(:music_counter), 1].max
      video.music_counter = max - 1
    end
    video.save!

    Series.check_video(video)
  end
end
