class SVPX.MusicPage
  constructor: (video)->
    @currentNumber = 0
    @youtubeConfig = {
      ytPlayer1Loaded: false,
      ytPlayer2Loaded: false,
      yt1State: null,
      yt2State: null,
      ytplayer1: null,
      ytplayer2: null,
      yt1love: false,
      yt2love: false,
      yt1plays: 0,
      yt2plays: 0,
      yt1video: null,
      yt2video: null
    }
    google.setOnLoadCallback =>
      @makeVideoPlayer(video, 1)
    @initListeners()

  initListeners: =>
    $('#player-wrapper1').show()
    $(window).on 'keydown', @onKeyPress
    $('.skip').on 'click', =>
      return if @currentNumber == 0
      othernumber = if @currentNumber == 1 then 2 else 1
      @youtubeConfig["ytplayer#{@currentNumber}"].pauseVideo()
      @incrementPlays()
      @youtubeConfig["ytplayer#{othernumber}"].playVideo()
      return true

    $('.hate').on 'click', =>
      return if @currentNumber == 0
      $.ajax
        url: "/hate_video"
        data:
          video_id: @youtubeConfig["yt#{@currentNumber}video"]
      othernumber = if @currentNumber == 1 then 2 else 1
      @youtubeConfig["ytplayer#{@currentNumber}"].pauseVideo()
      @youtubeConfig["ytplayer#{othernumber}"].playVideo()
      return true

    $('.love').on 'click', =>
      return if @currentNumber == 0
      $('.love').toggleClass('has-love')
      $.ajax
        url: "/love_video"
        data:
          video_id: @youtubeConfig["yt#{@currentNumber}video"]
        failure: ->
          $('.love').toggleClass('has-love')
      return true
    return true

  onKeyPress: (ev) =>
    if ev.keyCode == 32 #space
      ev.preventDefault()
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
    return true

  onStateChange: (state, number) =>
    othernumber = if number == 1 then 2 else 1
    ytplayer = "ytplayer#{number}"
    otherytplayer = "ytplayer#{othernumber}"
    ytPlayerLoaded = "ytPlayer#{number}Loaded"
    $ytelement = $("#player-wrapper#{number}")
    ytState = "yt#{number}State"
    ytlove = "yt#{number}love"
    ytotherlove = "yt#{othernumber}love"
    ytplays = "yt#{number}plays"
    ytotherplays = "yt#{othernumber}plays"
    ytvideo = "yt#{number}video"
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
            @currentNumber = number
            $('.love').toggleClass('has-love', @youtubeConfig[ytlove])
            $('.plays').html(@youtubeConfig[ytplays])
            $("#player-wrapper#{othernumber}").hide()
            $("#player-wrapper#{number}").show()
            $(window).focus()
            $.ajax
              url: "/random_video"
              data:
                video_id: @youtubeConfig[ytvideo]
              success: (data) =>
                @youtubeConfig[ytotherlove] = data.love
                @youtubeConfig[ytotherplays] = data.plays
                @makeVideoPlayer(data.video, othernumber)
          else if state == YT.PlayerState.ENDED
            @incrementPlays()
            @youtubeConfig[otherytplayer].playVideo()

  makeVideoPlayer: (video, number) ->
    othernumber = if number == 1 then 2 else 1
    ytplayer = "ytplayer#{number}"
    otherytplayer = "ytplayer#{othernumber}"
    ytPlayerLoaded = "ytPlayer#{number}Loaded"
    $ytelement = $("#player-wrapper#{number}")
    ytState = "yt#{number}State"
    ytvideo = "yt#{number}video"
    @youtubeConfig[ytvideo] = video
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
              url: "/hate_video"
              data:
                video_id: @youtubeConfig[ytvideo]
            $.ajax
              url: "/random_video"
              success: (data) =>
                @makeVideoPlayer(data.video, number)
          'onStateChange': (data) =>
            state = data.data
            @onStateChange(state, number)
        }
      })
    else
      @youtubeConfig[ytState] = YT.PlayerState.UNSTARTED
      @youtubeConfig[ytplayer].loadVideoById(video)
      @youtubeConfig[ytplayer].mute()
      @youtubeConfig[ytplayer].playVideo()

  incrementPlays: () ->
    $.ajax
      url: "/increment_plays"
      data:
        video_id: @youtubeConfig["yt#{@currentNumber}video"]