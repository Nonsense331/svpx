class SVPX.MusicPage
  constructor: (video)->
    @currentNumber = 0
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
      video: null
    }
    @youtubeConfig["ytConfig#{number}"] = ytconfig

    return ytconfig

  getCurrentYoutubeConfig: =>
    othernumber = if @currentNumber == 1 then 2 else 1
    return @getYoutubeConfig(othernumber)

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
    othernumber = if number == 1 then 2 else 1
    ytConfig = @getYoutubeConfig(number)
    ytOtherConfig = @getYoutubeConfig(othernumber)
    if ytConfig.state == YT.PlayerState.BUFFERING
      ytConfig.player.pauseVideo()
      ytConfig.player.unMute()
      ytConfig.state = YT.PlayerState.CUED
    else
      if state == YT.PlayerState.BUFFERING && ytConfig.state != YT.PlayerState.PLAYING
        ytConfig.state = YT.PlayerState.BUFFERING
      if state == YT.PlayerState.PLAYING || state == YT.PlayerState.ENDED
        if ytConfig.state != state
          ytConfig.state = state
          if state == YT.PlayerState.PLAYING
            @currentNumber = number
            $('.love').toggleClass('has-love', ytConfig.video.love)
            $('.plays').html(ytConfig.video.plays)
            $('.channel-title').html(ytConfig.video.channel_title)
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

  makeVideoPlayer: (number) ->
    othernumber = if number == 1 then 2 else 1
    ytConfig = @getYoutubeConfig(number)
    ytOtherConfig = @getYoutubeConfig(othernumber)
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
      ytConfig.player.loadVideoById(ytConfig.video.youtube_id)
      ytConfig.player.mute()
      ytConfig.player.playVideo()

  incrementPlays: () ->
    $.ajax
      url: "/videos/#{@getCurrentYoutubeConfig().video.id}/increment_plays"
