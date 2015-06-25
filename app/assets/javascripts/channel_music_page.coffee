class SVPX.ChannelMusicPage
  constructor: (video, @channel_id)->
    @ytPlayer1Loaded = false
    @ytPlayer2Loaded = false
    @yt1State = null
    @yt2State = null
    google.setOnLoadCallback =>
      @makeVideoPlayer1(video)
    $(window).on 'keydown', (ev) =>
      if ev.keyCode == 32 #space
        if @yt1State == YT.PlayerState.PLAYING
          if @ytplayer1.getPlayerState() == YT.PlayerState.PLAYING
            @ytplayer1.pauseVideo()
          else
            @ytplayer1.playVideo()
        else if @yt2State == YT.PlayerState.PLAYING
          if @ytplayer2.getPlayerState() == YT.PlayerState.PLAYING
            @ytplayer2.pauseVideo()
          else
            @ytplayer2.playVideo()

  makeVideoPlayer1: (video) ->
    if !@ytPlayer1Loaded
      player_wrapper = $('#player-wrapper1')
      player_wrapper.append('<div id="ytPlayer1"><p>Loading player...</p></div>')

      @ytplayer1 = new YT.Player('ytPlayer1', {
        videoId: video
        playerVars: {
          wmode: 'opaque'
          autoplay: 0
          modestbranding: 1
        }
        events: {
          'onReady': =>
            @ytPlayer1Loaded = true
            @ytplayer1.playVideo()
          'onError': (errorCode) -> alert("We are sorry, but the following error occured: " + errorCode)
          'onStateChange': (data) =>
            state = data.data
            if @yt1State == YT.PlayerState.BUFFERING
              @ytplayer1.pauseVideo()
              @yt1State = YT.PlayerState.CUED
            else
              if state == YT.PlayerState.BUFFERING && @yt1State != YT.PlayerState.PLAYING
                @yt1State = YT.PlayerState.BUFFERING
              if state == YT.PlayerState.PLAYING || state == YT.PlayerState.ENDED
                if @yt1State != state
                  @yt1State = state
                  if state == YT.PlayerState.PLAYING
                    $.ajax
                      url: "/channels/#{@channel_id}/random_video"
                      success: (data) =>
                        @makeVideoPlayer2(data.video)
                  else if state == YT.PlayerState.ENDED
                    @ytplayer2.playVideo()
        }
      })
    else
      @ytplayer1.loadVideoById(video)
      @ytplayer1.playVideo()

  makeVideoPlayer2: (video) ->
    if !@ytPlayer2Loaded
      player_wrapper = $('#player-wrapper2')
      player_wrapper.append('<div id="ytPlayer2"><p>Loading player...</p></div>')

      @ytplayer2 = new YT.Player('ytPlayer2', {
        videoId: video
        playerVars: {
          wmode: 'opaque'
          autoplay: 0
          modestbranding: 1
        }
        events: {
          'onReady': =>
            @ytPlayer2Loaded = true
            @ytplayer2.playVideo()
          'onError': (errorCode) -> alert("We are sorry, but the following error occured: " + errorCode)
          'onStateChange': (data) =>
            state = data.data
            if @yt2State == YT.PlayerState.BUFFERING
              @ytplayer2.pauseVideo()
              @yt2State = YT.PlayerState.CUED
            else
              if state == YT.PlayerState.BUFFERING && @yt2State != YT.PlayerState.PLAYING
                @yt2State = YT.PlayerState.BUFFERING
              if state == YT.PlayerState.PLAYING || state == YT.PlayerState.ENDED
                if @yt2State != state
                  @yt2State = state
                  if state == YT.PlayerState.PLAYING
                    $.ajax
                      url: "/channels/#{@channel_id}/random_video"
                      success: (data) =>
                        @makeVideoPlayer1(data.video)
                  else if state == YT.PlayerState.ENDED
                    @ytplayer1.playVideo()
        }
      })
    else
      @ytplayer2.loadVideoById(video)
      @ytplayer2.playVideo()
