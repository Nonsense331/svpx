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

    $('.get-all-link').on 'click', @getNextVideos

  getNextVideos: (nextLink) =>
    $.ajax
      url: "/channels/#{@channel_id}/get_all_videos",
      method: 'put',
      data:
        next_link: nextLink
      success: (data)=>
        if data.next_link
          @getNextVideos(data.next_link)
