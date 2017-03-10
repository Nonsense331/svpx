class SVPX.MusicPage
  constructor: (video)->
    @currentNumber = 1
    @youtubeConfig = {
      ytConfig1: null,
      ytConfig2: null
    }
    google.setOnLoadCallback =>
      @getYoutubeConfig(1).video = video
      @makeVideoPlayer(1)
    @initListeners()

  getYoutubeConfig: (number) =>
    ytconfig = @youtubeConfig["ytConfig#{number}"]
    return ytconfig if ytconfig
    ytconfig = {
      playerLoaded: false,
      state: null,
      player: null,
      video: null,
      initializing: null
    }
    @youtubeConfig["ytConfig#{number}"] = ytconfig

    return ytconfig

  getCurrentYoutubeConfig: =>
    return @getYoutubeConfig(@currentNumber)

  getOtherYoutubeConfig: =>
    othernumber = if @currentNumber == 1 then 2 else 1
    return @getYoutubeConfig(othernumber)

  initListeners: =>
    $('#player-wrapper1').show()
    $(window).on 'keydown', @onKeyPress
    $('.skip').on 'click', =>
      return if @currentNumber == 0
      @getCurrentYoutubeConfig().player.pauseVideo()
      @incrementPlays()
      @getOtherYoutubeConfig().player.playVideo()
      return true

    $('.hate').on 'click', =>
      return if @currentNumber == 0
      $.ajax
        url: "/videos/#{@getCurrentYoutubeConfig().video.id}/hate"
      @getCurrentYoutubeConfig().player.pauseVideo()
      @getOtherYoutubeConfig().player.playVideo()
      return true

    $('.love').on 'click', =>
      return if @currentNumber == 0
      $('.love').toggleClass('has-love')
      $.ajax
        url: "/videos/#{@getCurrentYoutubeConfig().video.id}/love"
        failure: ->
          $('.love').toggleClass('has-love')
      return true
    return true

  onKeyPress: (ev) =>
    if ev.keyCode == 32 #space
      ev.preventDefault()
      ytConfig = @getCurrentYoutubeConfig()
      if ytConfig.state == YT.PlayerState.PLAYING
        if ytConfig.player.getPlayerState() == YT.PlayerState.PLAYING
          ytConfig.player.pauseVideo()
        else
          ytConfig.player.playVideo()
      else
        ytConfig.player.playVideo()
    return true

  onStateChange: (state, number) =>
    console.log("Player #{number}: State #{state}")
    othernumber = if number == 1 then 2 else 1
    ytConfig = @getYoutubeConfig(number)
    # console.log("YTState #{ytConfig.state}")
    ytOtherConfig = @getYoutubeConfig(othernumber)
    if ytConfig.initializing
      if state == YT.PlayerState.PLAYING
        ytConfig.player.pauseVideo()
        ytConfig.player.unMute()
      if state == YT.PlayerState.PAUSED
        ytConfig.state = YT.PlayerState.CUED
        ytConfig.initializing = false
      if state == YT.PlayerState.CUED
        ytConfig.player.playVideo()
    else
      if state == YT.PlayerState.PLAYING || state == YT.PlayerState.ENDED
        if ytConfig.state != state
          ytConfig.state = state
          if state == YT.PlayerState.PLAYING
            @currentNumber = number
            $('.love').toggleClass('has-love', ytConfig.video.love)
            $('.plays').html(ytConfig.video.plays)
            $('.channel-title').html(ytConfig.video.channel_title)
            $('.video-title').html(ytConfig.video.title)
            $('.video-date').html(ytConfig.video.published_at_display)
            $("#player-wrapper#{othernumber}").hide()
            $("#player-wrapper#{number}").show()
            $(window).focus()
            $.ajax
              url: "/videos/random"
              data:
                video_id: ytConfig.video.id
              success: (data) =>
                ytOtherConfig.video = data.video
                @makeVideoPlayer(othernumber)
          else if state == YT.PlayerState.ENDED
            @incrementPlays()
            ytOtherConfig.player.playVideo()

    return true

  makeVideoPlayer: (number) ->
    ytConfig = @getYoutubeConfig(number)
    ytConfig.initializing = true
    $ytelement = $("#player-wrapper#{number}")
    ytplayer = "ytplayer#{number}"
    if !ytConfig.playerLoaded
      player_wrapper = $ytelement
      player_wrapper.append('<div id="' + ytplayer + '"><p>Loading player...</p></div>')

      ytConfig.player = new YT.Player(ytplayer, {
        videoId: ytConfig.video.youtube_id
        playerVars: {
          wmode: 'opaque'
          autoplay: 0
          modestbranding: 1
          fs: 0
          allowfullscreen: false
          iv_load_policy: 3
        }
        events: {
          'onReady': =>
            ytConfig.playerLoaded = true
            ytConfig.player.mute()
            ytConfig.player.playVideo()
          'onError': (errorCode) =>
            $.ajax
              url: "/videos/#{ytConfig.video.id}/hate"
            $.ajax
              url: "/videos/random"
              data:
                video_id: ytConfig.video.id
              success: (data) =>
                ytConfig.video = data.video
                @makeVideoPlayer(number)
          'onStateChange': (data) =>
            state = data.data
            @onStateChange(state, number)
        }
      })
    else
      ytConfig.state = YT.PlayerState.UNSTARTED
      ytConfig.player.cueVideoById(ytConfig.video.youtube_id)
      ytConfig.player.mute()
  incrementPlays: () ->
    $.ajax
      url: "/videos/#{@getCurrentYoutubeConfig().video.id}/increment_plays"
