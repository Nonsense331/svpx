class SVPX.SeriesFormPage
  constructor: ->
    @initListeners()
    if $("#series_regex").val()
      @loadVideos()

  initListeners: ->
    $('#series_regex').on 'keyup', @loadVideos
    $('input[type=checkbox]').on 'change', @loadVideos

  loadVideos: ->
    checkboxValues = $('input[type=checkbox]:checked').map ->
      return this.value
    .get().join(",")
    regex = $('#series_regex').val()
    $('.series').load("/series/videos_from_regex", regex: regex, channel_ids: checkboxValues)