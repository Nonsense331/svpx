class SVPX.MusicPage
  constructor: (video)->
    @youtubeConfig = {
      ytPlayer1Loaded: false,
      ytPlayer2Loaded: false,
      yt1State: null,
      yt2State: null,
      ytplayer1: null,
      ytplayer2: null
    }
    google.setOnLoadCallback =>
      @makeVideoPlayer(video, 1)
    $(window).on 'keydown', @onKeyPress

  onKeyPress: (ev) =>
    ev.preventDefault()
    if ev.keyCode == 32 #space
      if @youtubeConfig["yt1State"] == YT.PlayerState.PLAYING
        if @youtubeConfig["ytplayer1"].getPlayerState() == YT.PlayerState.PLAYING
          @youtubeConfig["ytplayer1"].pauseVideo()
        else
          @youtubeConfig["ytplayer1"].playVideo()
      else if @youtubeConfig["yt2State"] == YT.PlayerState.PLAYING
        if @youtubeConfig["ytplayer2"].getPlayerState() == YT.PlayerState.PLAYING
          @youtubeConfig["ytplayer2"].pauseVideo()
        else
          @youtubeConfig["ytplayer2"].playVideo()
      else
        @youtubeConfig["ytplayer1"].playVideo()

  makeVideoPlayer: (video, number) ->
    othernumber = if number == 1 then 2 else 1
    ytplayer = "ytplayer#{number}"
    otherytplayer = "ytplayer#{othernumber}"
    ytPlayerLoaded = "ytPlayer#{number}Loaded"
    $ytelement = $("#player-wrapper#{number}")
    ytState = "yt#{number}State"
    if !@youtubeConfig[ytPlayerLoaded]
      player_wrapper = $ytelement
      player_wrapper.append('<div id="' + ytplayer + '"><p>Loading player...</p></div>')

      @youtubeConfig[ytplayer] = new YT.Player(ytplayer, {
        videoId: video
        playerVars: {
          wmode: 'opaque'
          autoplay: 0
          modestbranding: 1
        }
        events: {
          'onReady': =>
            @youtubeConfig[ytPlayerLoaded] = true
            @youtubeConfig[ytplayer].mute()
            @youtubeConfig[ytplayer].playVideo()
          'onError': (errorCode) =>
            $.ajax
              url: "/random_video"
              success: (data) =>
                @makeVideoPlayer(data.video, number)
          'onStateChange': (data) =>
            state = data.data
            if @youtubeConfig[ytState] == YT.PlayerState.BUFFERING
              @youtubeConfig[ytplayer].pauseVideo()
              @youtubeConfig[ytplayer].unMute()
              @youtubeConfig[ytState] = YT.PlayerState.CUED
            else
              if state == YT.PlayerState.BUFFERING && @youtubeConfig[ytState] != YT.PlayerState.PLAYING
                @youtubeConfig[ytState] = YT.PlayerState.BUFFERING
              if state == YT.PlayerState.PLAYING || state == YT.PlayerState.ENDED
                if @youtubeConfig[ytState] != state
                  @youtubeConfig[ytState] = state
                  if state == YT.PlayerState.PLAYING
                    $.ajax
                      url: "/random_video"
                      success: (data) =>
                        @makeVideoPlayer(data.video, othernumber)
                  else if state == YT.PlayerState.ENDED
                    @youtubeConfig[otherytplayer].playVideo()
        }
      })
    else
      @youtubeConfig[ytplayer].loadVideoById(video)
      @youtubeConfig[ytplayer].playVideo()
