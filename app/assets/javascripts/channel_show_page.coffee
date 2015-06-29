class SVPX.ChannelShowPage
  constructor: ->
    $('.video-container').on 'click', '.video', (e)->
      if !$(e.target).is('a, .watched-link')
        window.open("http://www.youtube.com/watch?v=#{$(this).data('youtube')}", '_blank')