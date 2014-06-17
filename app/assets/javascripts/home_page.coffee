class SVPX.HomePage
  constructor: ->
    @initListeners()

  initListeners: ->
    $('.video').click (e)->
      if !$(e.target).is('a')
        window.open("http://www.youtube.com/watch?v=#{$(this).data('youtube')}", '_blank')

    $('.series').sortable
      handle: '.handle'
      update: (e, ui)->
        for el in $(this).find('.video-container')
          $el = $(el)
          $.ajax
            url: "/series/#{$el.data('id')}"
            type: "PUT"
            data:
              series:
                order: $el.index()

    $('.channels').sortable
      handle: '.handle'
      update: (e, ui)->
        for el in $(this).find('.channel-container')
          $el = $(el)
          $.ajax
            url: "/channels/#{$el.data('id')}"
            type: "PUT"
            data:
              channel:
                order: $el.index()