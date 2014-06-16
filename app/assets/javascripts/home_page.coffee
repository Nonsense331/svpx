class SVPX.HomePage
  constructor: ->
    @initListeners()

  initListeners: ->
    $('.video').click (e)->
      if !$(e.target).is('a')
        window.open("http://www.youtube.com/watch?v=#{$(this).data('youtube')}", '_blank')