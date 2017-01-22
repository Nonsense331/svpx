class SVPX.ChannelShowPage
  constructor: (@channel_id)->
    $('.video-container').on 'click', '.video', (e)->
      if !$(e.target).is('a, .watched-link')
        window.open("http://www.youtube.com/watch?v=#{$(this).data('youtube')}", '_blank')

    $('#music').on 'change', (ev)=>
      $.ajax
        url: "/channels/#{@channel_id}",
        method: 'put',
        data:
          channel:
            music: $(ev.target).val()
        success: (data)->

    $('.get-all-link').on 'click', (ev) =>
      ev.preventDefault()
      @startFetch()

  startFetch: =>
    @fetchCount = 0
    $('.fetch-text').html('Fetching...')
    $('.fetching').show()
    @getNextVideos(null)

  updateFetch: =>
    $('.fetch-count').html("Fetched #{@fetchCount}")

  endFetch: =>
    $('.fetch-count').html("Fetched #{@fetchCount}")
    $('.fetch-text').html('Done Fetching!')

  getNextVideos: (nextLink) =>
    $.ajax
      url: "/channels/#{@channel_id}/get_all_videos",
      method: 'get',
      data:
        next_link: nextLink
      success: (data)=>
        @fetchCount += data.count
        if data.next_link
          @getNextVideos(data.next_link)
          @updateFetch()
        else
          @endFetch()
