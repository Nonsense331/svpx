class SVPX.SeriesFormPage
  constructor: ->
    @initListeners()
    if $("#series_regex").val()
      @loadVideos()

  initListeners: ->
    $('#series_regex').on 'keyup', @onRegexChange
    $('input[type=checkbox]').on 'change', @loadVideos

  onRegexChange: =>
    clearTimeout(@timeout)
    @timeout = setTimeout =>
      @loadVideos()
    , 300

  loadVideos: ->
    checkboxValues = $('input[type=checkbox]:checked').map ->
      return this.value
    .get().join(",")
    regex = $('#series_regex').val()
    $('.series').load("/series/videos_from_regex", regex: regex, channel_ids: checkboxValues)
    $.ajax
      url: '/series/channels_from_regex',
      dataType: 'json'
      data:
        regex: regex
      success: (data)->
        $('.channels .row').hide()
        for channel_id in data.channel_ids
          $(".channels .row[data-id=#{channel_id}]").show()

