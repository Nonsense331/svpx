class SVPX.HomePage
  constructor: ->
    @initListeners()

  initListeners: ->
    $('.video-container').on 'click', '.video', (e)->
      if !$(e.target).is('a, .watched-link')
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

    $('.video-container').on 'click', '.watched-link', (e)->
      id = $(e.target).parent('.video').data('id')
      $.ajax
        url: "/videos/#{id}/watched"
        dataType: 'json'
        success: (data)->
          $videoContainer = $(e.target).parent('.video').parent('.video-container')
          seriesId = $videoContainer.data('id')
          $(e.target).parent('.video').remove()
          if seriesId
            $.ajax
              url: "/series/#{seriesId}/next_video"
              complete: (response)->
                $videoContainer.append(response.responseText)

    setTimeout ->
      location.reload()
    , 1000 * 5 * 60